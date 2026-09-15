import 'dart:math';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/event.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/faction.dart';
import 'package:government_simulator/models/minister.dart';
import 'package:government_simulator/models/promise.dart';
import 'package:government_simulator/models/achievement.dart';
import 'package:government_simulator/models/historical_scenario.dart';
import 'package:government_simulator/models/country_stage.dart';
import 'package:government_simulator/models/policy_preview.dart';
import 'package:government_simulator/models/campaign.dart';
import 'package:government_simulator/models/rival_candidate.dart';
import 'package:government_simulator/models/polling.dart';
import 'package:government_simulator/models/scandal.dart';
import 'package:government_simulator/models/debate.dart';
import 'package:government_simulator/models/election_result.dart';
import 'package:government_simulator/data/event_database.dart';
import 'package:government_simulator/utils/constants.dart';
import 'package:uuid/uuid.dart';

class GameLogicService {
  final Random _random = Random();
  final _uuid = const Uuid();
  List<GameEvent>? _eventCache;

  List<GameEvent> get _allEvents {
    _eventCache ??= EventDatabase.getAllEvents();
    return _eventCache!;
  }

  GameSession createNewSession({
    required String userId,
    required String countryName,
    required String difficulty,
    String? previousSessionId,
  }) {
    final difficultyMultiplier = difficulty == 'hard'
        ? 0.9
        : difficulty == 'easy'
            ? 1.1
            : 1.0;

    final initialStatus = CountryStatus(
      gdp: AppConstants.initialGdp * difficultyMultiplier,
      unemployment: AppConstants.initialUnemployment /
          (difficulty == 'easy' ? 1.2 : 1.0),
      satisfaction: AppConstants.initialSatisfaction,
      nationalPower: AppConstants.initialNationalPower,
      year: AppConstants.initialYear,
      day: AppConstants.initialDay,
      lastUpdated: DateTime.now(),
      inflationRate: AppConstants.initialInflationRate,
      publicDebt: AppConstants.initialPublicDebt,
      stability: AppConstants.initialStability,
      previousSessionId: previousSessionId,
      isNewGame: true,
    );

    return GameSession(
      id: _uuid.v4(),
      userId: userId,
      countryName: countryName,
      status: initialStatus,
      createdAt: DateTime.now(),
      lastPlayedAt: DateTime.now(),
      difficulty: difficulty,
    );
  }

  /// 「歴史のif」チャレンジ：シナリオが定めた固定の初期ステータスから開始する。
  /// シナリオ自体が難易度を体現しているため、AppConstants の初期値や
  /// difficulty による補正は適用しない。
  GameSession createSessionFromScenario({
    required String userId,
    required String countryName,
    required HistoricalScenario scenario,
    String? previousSessionId,
  }) {
    final initialStatus = CountryStatus(
      gdp: scenario.gdp,
      unemployment: scenario.unemployment,
      satisfaction: scenario.satisfaction,
      nationalPower: scenario.nationalPower,
      year: AppConstants.initialYear,
      day: AppConstants.initialDay,
      lastUpdated: DateTime.now(),
      inflationRate: scenario.inflationRate,
      publicDebt: scenario.publicDebt,
      stability: scenario.stability,
      countryPersonality: scenario.title,
      previousSessionId: previousSessionId,
      isNewGame: true,
    );

    return GameSession(
      id: _uuid.v4(),
      userId: userId,
      countryName: countryName,
      status: initialStatus,
      createdAt: DateTime.now(),
      lastPlayedAt: DateTime.now(),
      difficulty: 'normal',
    );
  }

  /// 「国家ステージ」チャレンジ：資源大国・分断国家など、性格の異なる
  /// 初期環境（ステージ）から新規セッションを開始する。難易度はステージの
  /// 星評価に応じて 'easy'/'normal'/'hard' へマッピングされる。
  GameSession createSessionFromStage({
    required String userId,
    required String countryName,
    required CountryStage stage,
    String? previousSessionId,
  }) {
    final initialStatus = CountryStatus(
      gdp: stage.gdp,
      unemployment: stage.unemployment,
      satisfaction: stage.satisfaction,
      nationalPower: stage.nationalPower,
      year: AppConstants.initialYear,
      day: AppConstants.initialDay,
      lastUpdated: DateTime.now(),
      inflationRate: stage.inflationRate,
      publicDebt: stage.publicDebt,
      stability: stage.stability,
      countryPersonality: stage.title,
      previousSessionId: previousSessionId,
      isNewGame: true,
    );

    return GameSession(
      id: _uuid.v4(),
      userId: userId,
      countryName: countryName,
      status: initialStatus,
      createdAt: DateTime.now(),
      lastPlayedAt: DateTime.now(),
      difficulty: stage.difficultyLabel,
    );
  }

  // 選択による影響を適用し、新しいステータスを計算
  CountryStatus applyImpact(CountryStatus current, Impact impact) {
    // すべての値をクランプして不正な値を防ぐ
    final newGdp = _clamp(
      current.gdp * (1 + impact.gdpChange / 100),
      100,
      10000,
    );

    final newUnemployment = _clamp(
      current.unemployment + impact.unemploymentChange,
      0,
      25,
    );

    final newSatisfaction = _clamp(
      current.satisfaction + impact.satisfactionChange,
      0,
      100,
    );

    final newNationalPower = _clamp(
      current.nationalPower + impact.nationalPowerChange,
      0,
      100,
    );

    final newInflationRate = _clamp(
      current.inflationRate + impact.inflationChange,
      -5,
      15,
    );

    final newStability = _clamp(
      current.stability + impact.stabilityChange,
      0,
      100,
    );

    // 相互作用ロジック：失業率が上がると満足度も下がる傾向
    final unemploymentPenalty =
        (newUnemployment - current.unemployment) * 0.5;
    final adjustedSatisfaction = newSatisfaction - unemploymentPenalty;

    // インフレが高いと国民満足度に負の影響
    final inflationPenalty = (newInflationRate - current.inflationRate) * 1.2;
    final finalSatisfaction = _clamp(adjustedSatisfaction - inflationPenalty, 0, 100);

    // GDP が低いと国力も低下
    final gdpTrend = newGdp / current.gdp;
    // newNationalPower は既に 0-100 にクランプ済みだが、GDP上昇時に
    // 掛け合わせる倍率（最大1.5倍）でその上限を超えうる。ここで
    // 再クランプしないと、範囲外の値が Decision.afterStatus として
    // そのまま永続化されてしまっていた。
    final adjustedNationalPower = _clamp(
      newNationalPower * (0.9 + gdpTrend * 0.1).clamp(0.5, 1.5),
      0,
      100,
    );

    // 派閥支持率を選択の方向性から導出して適用
    final factionDeltas = deriveFactionImpact(impact);
    final newFactions = current.factions.applyDeltas(factionDeltas);

    // 汚職度の自然な推移：安定度を犠牲にする決定や、満足度を無視して
    // GDPだけを追う「裏取引」的な決定で悪化し、それ以外はゆっくり改善する。
    final backroomDeal = impact.gdpChange > 0 && impact.satisfactionChange < 0;
    final corruptionDrift = (-impact.stabilityChange * 0.15) +
        (backroomDeal ? 1.5 : 0) -
        0.3;
    final newCorruption =
        _clamp(current.corruption + corruptionDrift, 0, 100);

    // 財政：対GDP公的債務比率の推移。以前は初期値のまま一切変化せず、
    // 「現実世界でいうと」の財政スコアや財政破綻警告が実際のプレイ内容と
    // 無関係な飾りになっていたため、実際に動くようにした。
    //   ・impact.publicDebtChange … 選択肢による明示的な増減
    //     （減税・給付拡充で財源を伴わないものは増加、増税・緊縮財政は減少）
    //   ・利払い負担 … 既存の債務残高が大きいほど、その分だけ自然に増える
    //   ・成長による相対的改善 … GDPが伸びれば対GDP比の分母が拡大し、
    //     比率としては下がる（実際のマクロ経済と同じ効果）
    final interestBurden = current.publicDebt * 0.0015;
    final growthRelief = (gdpTrend - 1) * 15;
    final newPublicDebt = _clamp(
      current.publicDebt +
          impact.publicDebtChange +
          interestBurden -
          growthRelief,
      0,
      300,
    );

    return current.copyWith(
      gdp: newGdp,
      unemployment: newUnemployment,
      satisfaction: finalSatisfaction,
      nationalPower: adjustedNationalPower,
      inflationRate: newInflationRate,
      stability: newStability,
      factions: newFactions,
      corruption: newCorruption,
      publicDebt: newPublicDebt,
    );
  }

  /// Impact と現在の汚職度から、各大臣の忠誠度変化を推定する。
  /// 汚職が蔓延しているほど、内閣全体の忠誠が一様に蝕まれていく。
  Map<MinisterRole, double> deriveMinisterImpact(Impact impact,
      {required double corruption}) {
    final corruptionDrag = corruption / 100 * -3.0;

    final d = <MinisterRole, double>{
      // 財務大臣: GDP↑を歓迎、インフレを嫌う。汚職の影響を最も強く受ける。
      MinisterRole.finance:
          impact.gdpChange * 1.5 - impact.inflationChange * 1.0 + corruptionDrag,
      // 国防大臣: 国力↑・安定↑を歓迎
      MinisterRole.defense: impact.nationalPowerChange * 0.6 +
          impact.stabilityChange * 0.3 +
          corruptionDrag * 0.5,
      // 内務大臣: 国民満足度・安定度に敏感
      MinisterRole.interior: impact.satisfactionChange * 0.5 +
          impact.stabilityChange * 0.4 +
          corruptionDrag,
      // 外務大臣: インフレ（≒通商の混乱）を嫌い、国力を歓迎
      MinisterRole.foreign: -impact.inflationChange * 0.8 +
          impact.nationalPowerChange * 0.2 +
          corruptionDrag * 0.5,
      // 環境大臣: 安定を歓迎、軍拡偏重（環境軽視）を嫌う
      MinisterRole.environment: impact.stabilityChange * 0.3 -
          (impact.nationalPowerChange > 0 ? impact.nationalPowerChange * 0.4 : 0) +
          corruptionDrag * 0.7,
    };

    return d.map((k, v) => MapEntry(k, v.clamp(-10.0, 10.0)));
  }

  /// 内閣の裏切り判定。最も忠誠度が低い大臣（まだ裏切っていない中で）を対象に、
  /// 忠誠度が低いほど高い確率で裏切りが発覚する。
  MinisterRole? checkMinisterBetrayal(Cabinet cabinet) {
    final candidate = cabinet.mostDisloyal;
    if (candidate == null || candidate.value > 15) return null;

    // 忠誠度0で最大35%、15で0%に近づく発覚確率
    final betrayalChance = (15 - candidate.value) / 15 * 0.35;
    if (_random.nextDouble() < betrayalChance) return candidate.key;
    return null;
  }

  /// 派閥への公約を作成する（二枚舌外交システム）。
  Promise makePromise(Faction faction, CountryStatus status) {
    return Promise(
      id: _uuid.v4(),
      faction: faction,
      madeAtDecisionCount: status.decisionsCount,
      dueAtDecisionCount: status.decisionsCount + 5,
      supportAtPromiseTime: status.factions.of(faction),
    );
  }

  /// 期限が来た公約を判定する。支持率が公約時より上がっていれば果たされた
  /// とみなし、横ばい・下降なら破約となり通常より重い支持率低下と
  /// 永続的な「嘘つき」評価を受ける。
  PromiseResolutionResult resolvePromises(
      List<Promise> promises, CountryStatus status) {
    final remaining = <Promise>[];
    final resolutions = <PromiseResolution>[];
    var factions = status.factions;

    for (final p in promises) {
      if (status.decisionsCount < p.dueAtDecisionCount) {
        remaining.add(p);
        continue;
      }

      final currentSupport = factions.of(p.faction);
      final fulfilled = currentSupport > p.supportAtPromiseTime;

      if (fulfilled) {
        resolutions.add(PromiseResolution(
          promise: p,
          fulfilled: true,
          narrative: '${p.faction.label}との公約を果たした。信頼が深まっている。',
        ));
      } else {
        // 通常の失望よりも重いペナルティ（一回の決定の最大変動幅の目安 ±12 の
        // 3倍相当）＋永続的な「嘘つき」評価。
        factions = factions
            .applyDeltas({p.faction: -15.0}).markLiar(p.faction);
        resolutions.add(PromiseResolution(
          promise: p,
          fulfilled: false,
          narrative: '${p.faction.label}との公約が反故にされたと報じられた。'
              '「嘘つき」との評価が広まっている。',
        ));
      }
    }

    return PromiseResolutionResult(
      factions: factions,
      remaining: remaining,
      resolutions: resolutions,
    );
  }

  /// Impact の方向性から各派閥の好感度変化を推定する。
  /// 既存イベントを変更せずに派閥システムを成立させるための要。
  Map<Faction, double> deriveFactionImpact(Impact i) {
    final d = <Faction, double>{
      Faction.military: 0,
      Faction.business: 0,
      Faction.labor: 0,
      Faction.citizen: 0,
    };

    // 軍部: 国力↑を歓迎、国力↓を嫌う
    d[Faction.military] = d[Faction.military]! + i.nationalPowerChange * 0.8;

    // 財界: GDP↑歓迎、インフレ↑と不安定化を嫌う
    d[Faction.business] = d[Faction.business]! +
        i.gdpChange * 2.5 -
        i.inflationChange * 1.5 -
        (i.stabilityChange < 0 ? i.stabilityChange.abs() * 0.5 : 0);

    // 労働者: 失業↓歓迎（失業↑を激しく嫌う）、満足度↑も歓迎
    d[Faction.labor] = d[Faction.labor]! -
        i.unemploymentChange * 4.0 +
        i.satisfactionChange * 0.3;

    // 市民: 満足度↑・安定↑を歓迎、国力偏重（軍拡）を警戒
    d[Faction.citizen] = d[Faction.citizen]! +
        i.satisfactionChange * 0.4 +
        i.stabilityChange * 0.3 -
        (i.nationalPowerChange > 0 ? i.nationalPowerChange * 0.3 : 0);

    // クランプ（1決定で±12まで）
    return d.map((k, v) => MapEntry(k, v.clamp(-12.0, 12.0)));
  }

  /// ゲームオーバー判定。最優先の崩壊要因を返す。
  GameOverType checkGameOver(CountryStatus s) {
    if (s.satisfaction <= 0) return GameOverType.revolution;
    if (s.stability <= 0) return GameOverType.collapse;
    // 財政破綻は GDP の崩壊だけでなく、累積した債務そのものでも起こりうる。
    // publicDebt が実際にプレイ内容に応じて動くようになったため
    // （applyImpact 参照）、対GDP比300%満点中250%を国家財政が
    // 立ち行かなくなる目安として追加した。
    if (s.gdp <= 120 || s.publicDebt >= 250) return GameOverType.bankruptcy;
    if (s.factions.mostHostile.value <= 0 &&
        s.factions.mostHostile.key == Faction.military) {
      return GameOverType.coup;
    }
    return GameOverType.none;
  }

  // インパクトスコアを計算（-100 to 100）
  // 正 = 良い決定、負 = 悪い決定
  double calculateImpactScore(CountryStatus before, CountryStatus after) {
    final gdpImprovement = ((after.gdp - before.gdp) / before.gdp) * 100;
    final employmentImprovement = (before.unemployment - after.unemployment);
    final satisfactionImprovement = after.satisfaction - before.satisfaction;
    final stabilityImprovement = after.stability - before.stability;

    // 重み付き合計
    final score = (gdpImprovement * 0.3 +
        employmentImprovement * 0.3 +
        satisfactionImprovement * 0.2 +
        stabilityImprovement * 0.2);

    return score.clamp(-100, 100);
  }

  // 意思決定の結果ナレーションを生成
  String generateNarrative(
    Choice choice,
    CountryStatus beforeStatus,
    CountryStatus afterStatus,
  ) {
    final gdpChanged = afterStatus.gdp - beforeStatus.gdp;
    final gdpDir = gdpChanged > 0 ? '増加' : '減少';
    final unemploymentChanged =
        afterStatus.unemployment - beforeStatus.unemployment;
    final empDir = unemploymentChanged > 0 ? '悪化' : '改善';
    final satisfactionChanged =
        afterStatus.satisfaction - beforeStatus.satisfaction;
    final satDir = satisfactionChanged > 0 ? '上昇' : '低下';

    return '''
「${choice.text}」が実行されました。

📊 その結果：
• GDP: ${gdpChanged.abs().toStringAsFixed(0)}B${gdpDir}
• 失業率: ${unemploymentChanged.abs().toStringAsFixed(1)}%${empDir}
• 国民満足度: ${satisfactionChanged.toStringAsFixed(0)}${satDir}

これからの国家運営が試されます...
    '''.trim();
  }

  // ランダムイベントを生成（ゲーム性向上用）
  GameEvent generateRandomEvent(CountryStatus status,
      {Set<String> recentIds = const {}}) {
    final crisis = status.crisisLevel;
    List<GameEvent> pool = _allEvents;

    // 危機時は経済・雇用イベントの重みを2倍
    if (crisis == CrisisLevel.critical || crisis == CrisisLevel.high) {
      pool = pool.map((e) {
        if ([EventCategory.employment, EventCategory.economic]
            .contains(e.category)) {
          return GameEvent(
            id: e.id,
            title: e.title,
            description: e.description,
            category: e.category,
            weight: e.weight * 2,
            choices: e.choices,
          );
        }
        return e;
      }).toList();
    }

    // 直近と同じイベントは除外（同じイベントが続かないように）
    if (recentIds.isNotEmpty) {
      final filtered = pool.where((e) => !recentIds.contains(e.id)).toList();
      if (filtered.isNotEmpty) pool = filtered;
    }

    // 加重ランダム選択
    final totalWeight = pool.fold(0, (sum, e) => sum + e.weight);
    var randomValue = _random.nextInt(totalWeight);
    for (final event in pool) {
      randomValue -= event.weight;
      if (randomValue < 0) return event;
    }
    return pool.first;
  }

  // 複数の政策の相互作用を計算（複雑なゲーム性）
  Impact calculateCompoundImpact(List<Impact> impacts) {
    if (impacts.isEmpty) return Impact();

    double gdpChange = 0;
    double unemploymentChange = 0;
    double satisfactionChange = 0;
    double nationalPowerChange = 0;
    double inflationChange = 0;
    double stabilityChange = 0;

    for (final impact in impacts) {
      gdpChange += impact.gdpChange;
      unemploymentChange += impact.unemploymentChange;
      satisfactionChange += impact.satisfactionChange;
      nationalPowerChange += impact.nationalPowerChange;
      inflationChange += impact.inflationChange;
      stabilityChange += impact.stabilityChange;
    }

    // シナジー効果：複数の政策を組み合わせるとボーナス
    if (impacts.length > 1) {
      // 例：経済政策と雇用政策の組み合わせは効果が倍増
      gdpChange *= 1.1;
      unemploymentChange *= 1.1;
    }

    return Impact(
      gdpChange: gdpChange,
      unemploymentChange: unemploymentChange,
      satisfactionChange: satisfactionChange,
      nationalPowerChange: nationalPowerChange,
      inflationChange: inflationChange,
      stabilityChange: stabilityChange,
    );
  }

  // 年が経過した時の自動ステータス調整（経済的な自然な変動）
  CountryStatus simulateYearPassed(CountryStatus status) {
    // 基本的な経済成長
    final naturalGdpGrowth = 2.0; // 年2%
    final newGdp = status.gdp * (1 + naturalGdpGrowth / 100);

    // インフレレートが高いと経済成長が減速
    final inflationPenalty = (status.inflationRate - 2.0).clamp(0, 15);
    final adjustedGdp = newGdp * (1 - inflationPenalty / 100);

    // 失業率は自然に若干改善
    final newUnemployment = (status.unemployment * 0.98).clamp(0.0, 25.0);

    // 安定度が高いと国力が向上
    final stabilityBonus = status.stability / 100;
    final newNationalPower =
        _clamp(status.nationalPower + stabilityBonus * 5, 0, 100);

    // インフレレートは基本的に目標値（2%）に向かって収束
    final inflationTarget = 2.0;
    final newInflationRate = status.inflationRate * 0.8 + inflationTarget * 0.2;

    // 年間の自然成長も、applyImpact と同じ理屈で対GDP債務比率を
    // わずかに押し下げる（GDPという分母が拡大するため）。これが無いと、
    // 年末に発生する自然成長分だけ debt/GDP 比の改善が正しく反映されない。
    final gdpTrend = adjustedGdp / status.gdp;
    final growthRelief = (gdpTrend - 1) * 15;
    final newPublicDebt = _clamp(status.publicDebt - growthRelief, 0, 300);

    return status.copyWith(
      gdp: adjustedGdp,
      unemployment: newUnemployment,
      nationalPower: newNationalPower,
      inflationRate: newInflationRate,
      publicDebt: newPublicDebt,
      year: status.year + 1,
      day: 1,
      lastUpdated: DateTime.now(),
    );
  }

  // 判定：良い決定だったか（期待値）
  bool wasPositiveOutcome(Impact impact, CountryStatus status) {
    // 国家の危機レベルに応じた判定
    final crisis = status.crisisLevel;

    // 危機時は失業率の改善が重要
    if (crisis == CrisisLevel.critical) {
      return impact.unemploymentChange < -1;
    }

    // 通常時は総合的な改善を判定
    // 失業率は下がる(負の変化)ほど良いので符号を反転する。
    // .abs() で符号を潰していたため、失業率を改善する選択が常に
    // 減点されるバグがあった（calculateImpactScore と同じ向きに統一）。
    final score = impact.gdpChange * 0.3 +
        -impact.unemploymentChange * 0.3 +
        impact.satisfactionChange * 0.2 +
        impact.stabilityChange * 0.2;

    return score > 0;
  }

  // ヘルパー：値をクランプ
  double _clamp(double value, double min, double max) {
    return value.clamp(min, max).toDouble();
  }

  /// 政策選択の影響をプレビュー（選択前に表示）
  ///
  /// ユーザーが選択肢を選んだが、まだコミットする前に、
  /// その選択によって国家がどう変わるかを予測して表示する。
  PolicyPreview createPolicyPreview({
    required String choiceId,
    required String choiceText,
    required CountryStatus currentStatus,
    required Impact impact,
  }) {
    // 影響を適用した後の状態を計算
    final projectedStatus = applyImpact(currentStatus, impact);

    // 各指標のデルタを計算
    final indicatorDeltas = <String, IndicatorDelta>{
      'gdp': _createIndicatorDelta(
        key: 'gdp',
        label: '国内総生産',
        before: currentStatus.gdp,
        after: projectedStatus.gdp,
      ),
      'unemployment': _createIndicatorDelta(
        key: 'unemployment',
        label: '失業率',
        before: currentStatus.unemployment,
        after: projectedStatus.unemployment,
      ),
      'satisfaction': _createIndicatorDelta(
        key: 'satisfaction',
        label: '国民満足度',
        before: currentStatus.satisfaction,
        after: projectedStatus.satisfaction,
      ),
      'nationalPower': _createIndicatorDelta(
        key: 'nationalPower',
        label: '国力',
        before: currentStatus.nationalPower,
        after: projectedStatus.nationalPower,
      ),
      'inflationRate': _createIndicatorDelta(
        key: 'inflationRate',
        label: 'インフレ率',
        before: currentStatus.inflationRate,
        after: projectedStatus.inflationRate,
      ),
      'publicDebt': _createIndicatorDelta(
        key: 'publicDebt',
        label: '公的債務',
        before: currentStatus.publicDebt,
        after: projectedStatus.publicDebt,
      ),
      'stability': _createIndicatorDelta(
        key: 'stability',
        label: '治安・安定性',
        before: currentStatus.stability,
        after: projectedStatus.stability,
      ),
    };

    // 大臣忠誠度の変化を計算
    final ministerDeltas = _calculateMinisterLoyaltyDeltas(
      impact: impact,
      newStatus: projectedStatus,
    );

    // 派閥支持率の変化を計算
    final factionDeltas = _calculateFactionDeltas(
      impact: impact,
      beforeStatus: currentStatus,
      afterStatus: projectedStatus,
    );

    // リスク要因を特定
    final riskFactors = _identifyRiskFactors(
      impact: impact,
      projectedStatus: projectedStatus,
      ministerLoyaltyDeltas: ministerDeltas,
      factionDeltas: factionDeltas,
    );

    return PolicyPreview(
      choiceId: choiceId,
      choiceText: choiceText,
      beforeStatus: currentStatus,
      projectedStatus: projectedStatus,
      appliedImpact: impact,
      indicatorDeltas: indicatorDeltas,
      ministerLoyaltyDeltas: ministerDeltas,
      factionDeltas: factionDeltas,
      riskFactors: riskFactors,
    );
  }

  /// 指標のデルタを計算
  IndicatorDelta _createIndicatorDelta({
    required String key,
    required String label,
    required double before,
    required double after,
  }) {
    final delta = after - before;
    final deltaPercent = before != 0 ? (delta / before * 100) : 0.0;

    // トレンドを決定
    final trend = delta > 0.1
        ? IndicatorTrend.up
        : delta < -0.1
            ? IndicatorTrend.down
            : IndicatorTrend.neutral;

    return IndicatorDelta(
      indicatorKey: key,
      indicatorLabel: label,
      currentValue: before,
      projectedValue: after,
      delta: delta,
      deltaPercent: deltaPercent,
      trend: trend,
    );
  }

  /// 大臣忠誠度の変化を計算
  Map<String, MinisterLoyaltyDelta> _calculateMinisterLoyaltyDeltas({
    required Impact impact,
    required CountryStatus newStatus,
  }) {
    final deltas = <String, MinisterLoyaltyDelta>{};

    // 大臣忠誠度への影響を計算（簡略版）
    // 注：実際の計算は Cabinet.applyDeltas で行われるため、ここでは推定値を使用
    final ministerImpacts = deriveMinisterImpact(
      impact,
      corruption: newStatus.corruption,
    );

    // 現在の内閣の状態から大臣を取得
    final cabinet = newStatus.cabinet;

    for (final role in ministerImpacts.keys) {
      final delta = ministerImpacts[role] ?? 0.0;
      final currentLoyalty = cabinet.of(role);
      final projectedLoyalty = _clamp(currentLoyalty + delta, 0, 100);

      deltas[role.name] = MinisterLoyaltyDelta(
        ministerRole: role.name,
        roleJapanese: _getMinisterRoleJapanese(role),
        roleEmoji: _getMinisterRoleEmoji(role),
        currentLoyalty: currentLoyalty,
        projectedLoyalty: projectedLoyalty,
        delta: delta,
      );
    }

    return deltas;
  }

  /// 派閥支持率の変化を計算
  Map<String, FactionDelta> _calculateFactionDeltas({
    required Impact impact,
    required CountryStatus beforeStatus,
    required CountryStatus afterStatus,
  }) {
    final deltas = <String, FactionDelta>{};

    // 派閥支持率への影響を推定
    // 簡略版：指標の変化から派閥の好みを推測
    final factions = afterStatus.factions;

    for (final faction in Faction.values) {
      final beforeSupport = beforeStatus.factions.of(faction);
      final afterSupport = factions.of(faction);

      deltas[faction.name] = FactionDelta(
        factionName: faction.name,
        factionJapanese: _getFactionJapanese(faction),
        currentSupport: beforeSupport,
        projectedSupport: afterSupport,
        delta: afterSupport - beforeSupport,
      );
    }

    return deltas;
  }

  /// リスク要因を特定
  List<RiskFactor> _identifyRiskFactors({
    required Impact impact,
    required CountryStatus projectedStatus,
    required Map<String, MinisterLoyaltyDelta> ministerLoyaltyDeltas,
    required Map<String, FactionDelta> factionDeltas,
  }) {
    final risks = <RiskFactor>[];

    // 失業率が高すぎる
    if (projectedStatus.unemployment > 25) {
      risks.add(RiskFactor(
        severity: projectedStatus.unemployment > 40
            ? RiskSeverity.critical
            : RiskSeverity.warning,
        message:
            '失業率が${projectedStatus.unemployment.toStringAsFixed(1)}%に達します',
        affectedAspect: 'Unemployment',
        advice: '失業保険の拡充や職業訓練プログラムの充実を検討してください',
      ));
    }

    // 満足度が低い
    if (projectedStatus.satisfaction < 20) {
      risks.add(RiskFactor(
        severity: RiskSeverity.critical,
        message: '国民満足度が${projectedStatus.satisfaction.toStringAsFixed(1)}%まで低下します',
        affectedAspect: 'Satisfaction',
        advice: 'この選択は国民の不満を極度に高め、社会不安につながります',
      ));
    }

    // 安定性が著しく低下
    if (projectedStatus.stability < 20) {
      risks.add(RiskFactor(
        severity: RiskSeverity.critical,
        message: '治安・安定性が${projectedStatus.stability.toStringAsFixed(1)}%に低下します',
        affectedAspect: 'Stability',
        advice: 'クーデターや暴動のリスクが高まります。慎重に判断してください',
      ));
    }

    // 大臣の忠誠度が危険水準
    for (final delta in ministerLoyaltyDeltas.values) {
      if (delta.projectedLoyalty <= 0) {
        risks.add(RiskFactor(
          severity: RiskSeverity.critical,
          message: '${delta.roleJapanese}が内閣を裏切る可能性があります',
          affectedAspect: 'Minister Loyalty',
          advice: 'この大臣の支持を失うと内閣の安定性が著しく低下します',
        ));
      } else if (delta.projectedLoyalty < 30) {
        risks.add(RiskFactor(
          severity: RiskSeverity.warning,
          message: '${delta.roleJapanese}の忠誠度が${delta.projectedLoyalty.toStringAsFixed(0)}%に低下します',
          affectedAspect: 'Minister Loyalty',
          advice: '今後の政策で${delta.roleJapanese}の支持を回復する施策が必要です',
        ));
      }
    }

    // 派閥支持の崩壊
    for (final delta in factionDeltas.values) {
      if (delta.projectedSupport <= 0) {
        risks.add(RiskFactor(
          severity: RiskSeverity.critical,
          message: '${delta.factionJapanese}の支持が完全に失われます',
          affectedAspect: 'Faction Support',
          advice: '${delta.factionJapanese}の反発により、政策実行が困難になるおそれがあります',
        ));
      }
    }

    // GDP急減
    if (impact.gdpChange < -20) {
      risks.add(RiskFactor(
        severity: RiskSeverity.critical,
        message: 'GDP が${(-impact.gdpChange).toStringAsFixed(1)}% 低下します',
        affectedAspect: 'Economic',
        advice: 'この選択は経済に深刻なダメージを与えます',
      ));
    }

    return risks;
  }

  /// 大臣職の日本語名を取得
  String _getMinisterRoleJapanese(MinisterRole role) {
    return role.label;
  }

  /// 大臣職の絵文字を取得
  String _getMinisterRoleEmoji(MinisterRole role) {
    return role.emoji;
  }

  /// 派閥の日本語名を取得
  String _getFactionJapanese(Faction faction) {
    return faction.label;
  }

  /// キャンペーンを開始する
  Campaign launchCampaign({
    required String sessionId,
    required CampaignType type,
    required int durationWeeks,
    required int currentYear,
    required int currentWeek,
  }) {
    final effectiveness = CampaignManager.calculateInitialEffectiveness(
      type: type,
      budgetSpent: CampaignManager.costByDifficulty['normal']![type]! * 1.5, // デフォルト予算
      difficulty: 'normal',
    );

    final maxSupportBoost = CampaignManager.calculateMaxSupportBoost(type);

    return Campaign(
      id: _uuid.v4(),
      name: '${type.label}キャンペーン',
      type: type,
      startWeek: currentWeek,
      durationWeeks: durationWeeks,
      startYear: currentYear,
      effectiveness: effectiveness,
      maxSupportBoost: maxSupportBoost,
      launchedAt: DateTime.now(),
    );
  }

  /// キャンペーンの純粋な支持率への影響を計算
  /// プレイヤーキャンペーンとカウンターキャンペーンの効果を合計
  double calculateCampaignNetImpact({
    required int year,
    required int week,
    required List<Campaign> activeCampaigns,
    required List<CounterCampaign> counterCampaigns,
  }) {
    // プレイヤーキャンペーンの総効果
    double playerImpact = 0.0;
    for (final campaign in activeCampaigns) {
      playerImpact += campaign.getWeeklyImpact(year, week);
    }

    // カウンターキャンペーンの総効果（負）
    double counterImpact = 0.0;
    for (final campaign in counterCampaigns) {
      counterImpact += campaign.getWeeklyImpact(year, week);
    }

    // カウンターキャンペーンはプレイヤー効果を30-50%削減
    final counterReduction = playerImpact * (0.3 + _random.nextDouble() * 0.2);

    return (playerImpact - counterReduction - counterImpact).clamp(-15.0, 15.0);
  }

  /// ライバル候補者がプレイヤーキャンペーンに対抗キャンペーンで応答するかを判定
  /// プレイヤーキャンペーンが5%以上の効果を持つ場合に応答確率がある
  CounterCampaign? generateRivalCounterCampaign({
    required Campaign playerCampaign,
    required RivalCandidate rival,
    required int currentYear,
    required int currentWeek,
    required String difficulty,
  }) {
    // プレイヤーキャンペーンの最大効果が5%未満なら応答しない
    if (playerCampaign.maxSupportBoost < 5.0) {
      return null;
    }

    // ライバルがこのキャンペーンに応答する確率（60-80%）
    final responseStrength = 0.6 + _random.nextDouble() * 0.2;

    // 応答の遅延：2-3週間後に開始
    final delayWeeks = 2 + _random.nextInt(2);
    final responseStartWeek = (currentWeek + delayWeeks - 1) % 52 + 1;

    // ライバルキャンペーンの効果度（プレイヤー効果の60-80%）
    final rivalEffectiveness = playerCampaign.effectiveness * responseStrength;

    // ライバルキャンペーンの最大支持率上昇（プレイヤー効果の60-80%）
    final rivalMaxBoost = playerCampaign.maxSupportBoost * responseStrength;

    return CounterCampaign(
      id: _uuid.v4(),
      name: '${playerCampaign.type.label}対抗キャンペーン',
      type: playerCampaign.type,
      startWeek: responseStartWeek,
      durationWeeks: playerCampaign.durationWeeks,
      startYear: currentYear,
      effectiveness: rivalEffectiveness.clamp(0, 100),
      maxSupportBoost: rivalMaxBoost,
      launchedAt: DateTime.now(),
      rivalId: rival.id,
      isRetaliatory: true,
    );
  }

  /// 日次でキャンペーン効果をセッションに適用
  /// 支持率の変化とライバル応答をトリガー
  GameSession applyDailyCampaignEffects({
    required GameSession session,
  }) {
    var updatedSession = session;
    final year = session.status.year;
    final week = (session.status.day / 7).ceil();

    // キャンペーンの純粋な支持率への影響を計算
    final campaignNetImpact = calculateCampaignNetImpact(
      year: year,
      week: week,
      activeCampaigns: session.activeCampaigns,
      counterCampaigns: session.rivalCampaigns,
    );

    // 支持率に影響を適用（満足度として）
    var newStatus = session.status;
    if (campaignNetImpact.abs() > 0.1) {
      newStatus = newStatus.copyWith(
        satisfaction: (newStatus.satisfaction + campaignNetImpact).clamp(0, 100).toDouble(),
      );
      updatedSession = updatedSession.copyWith(status: newStatus);
    }

    // ライバル応答をトリガー：有効なキャンペーンに対して
    final newRivalCampaigns = List<CounterCampaign>.from(session.rivalCampaigns);

    for (final campaign in session.activeCampaigns) {
      // このキャンペーンに対する応答がまだ存在するか確認
      final hasExistingResponse = newRivalCampaigns.any(
        (rc) => rc.type == campaign.type && rc.isRetaliatory
      );

      if (!hasExistingResponse && campaign.maxSupportBoost >= 5.0) {
        // ライバル候補者から応答を生成
        for (final rival in session.rivalCandidates) {
          final counterCampaign = generateRivalCounterCampaign(
            playerCampaign: campaign,
            rival: rival,
            currentYear: year,
            currentWeek: week,
            difficulty: session.difficulty,
          );

          if (counterCampaign != null) {
            newRivalCampaigns.add(counterCampaign);
            // 最初のライバルのみ応答
            break;
          }
        }
      }
    }

    if (newRivalCampaigns.length != session.rivalCampaigns.length) {
      updatedSession = updatedSession.copyWith(
        rivalCampaigns: newRivalCampaigns,
      );
    }

    return updatedSession;
  }

  /// キャンペーン効果を反映したポール調査を実施
  Poll conductPollWithCampaigns({
    required Poll basePoll,
    required int year,
    required int week,
    required List<Campaign> activeCampaigns,
    required List<CounterCampaign> counterCampaigns,
  }) {
    // キャンペーンの純粋な支持率への影響を計算
    final campaignImpact = calculateCampaignNetImpact(
      year: year,
      week: week,
      activeCampaigns: activeCampaigns,
      counterCampaigns: counterCampaigns,
    );

    // キャンペーン調整済みの支持率
    final adjustedSupport = (basePoll.playerSupport + campaignImpact).clamp(0.0, 100.0).toDouble();

    // キャンペーンが活発な場合は誤差範囲を縮小（意見がより固まっている）
    final campaignInfluence = (activeCampaigns.length + counterCampaigns.length) * 0.5;
    final adjustedMargin = (basePoll.marginOfError * (1 - campaignInfluence / 100)).clamp(1.0, 10.0).toDouble();

    return Poll(
      id: _uuid.v4(),
      year: year,
      week: week,
      playerSupport: adjustedSupport,
      marginOfError: adjustedMargin,
      sampleSize: basePoll.sampleSize,
      conductedAt: DateTime.now(),
      rivalSupport: basePoll.rivalSupport,
    );
  }

  /// スキャンダルを生成・トリガー
  /// 確率に基づいてスキャンダルを発生させる
  Scandal? generateRandomScandal({
    required int currentYear,
    required int currentWeek,
    required double playerSupport,
    required String difficulty,
    required int playerReputation,
    required int activecampaignCount,
  }) {
    // スキャンダル発生確率を計算
    final probability = ScandalManager.calculateScandalProbability(
      playerSupport: playerSupport,
      activecampaignCount: activecampaignCount,
      difficulty: difficulty,
      playerReputation: playerReputation,
    );

    // 確率判定
    if (_random.nextDouble() > probability) {
      return null;
    }

    // スキャンダルタイプをランダムに選択
    final types = ScandalType.values;
    final type = types[_random.nextInt(types.length)];

    // スキャンダルタイトルを取得
    final title = ScandalManager.getScandalTitle(type);

    // 基本影響度 (5-15%)
    final baseImpact = type.baseImpact + (_random.nextDouble() * 5 - 2.5);

    return Scandal(
      id: _uuid.v4(),
      title: title,
      type: type,
      discoveredAt: DateTime.now(),
      startWeek: currentWeek,
      startYear: currentYear,
      baseImpact: baseImpact.clamp(5.0, 15.0),
      initialIntensity: 100.0,
      involvedPersonId: null, // プレイヤーのスキャンダル
    );
  }

  /// ライバルスキャンダルの生成
  Scandal? generateRivalScandal({
    required RivalCandidate rival,
    required int currentYear,
    required int currentWeek,
  }) {
    // ライバルスキャンダルの発生確率: 5-10%
    if (_random.nextDouble() > 0.075) {
      return null;
    }

    final types = ScandalType.values;
    final type = types[_random.nextInt(types.length)];
    final title = ScandalManager.getScandalTitle(type);
    final baseImpact = type.baseImpact + (_random.nextDouble() * 3 - 1.5);

    return Scandal(
      id: _uuid.v4(),
      title: title,
      type: type,
      discoveredAt: DateTime.now(),
      startWeek: currentWeek,
      startYear: currentYear,
      baseImpact: baseImpact.clamp(5.0, 15.0),
      initialIntensity: 100.0,
      involvedPersonId: rival.id,
    );
  }

  /// スキャンダルの支持率への影響を計算
  double calculateScandalNetImpact({
    required List<Scandal> activeScandalsList,
    required int year,
    required int week,
    required int playerReputation,
    required int mediaFavoring,
  }) {
    if (activeScandalsList.isEmpty) return 0.0;

    double totalImpact = 0.0;

    for (final scandal in activeScandalsList) {
      // プレイヤーのスキャンダルのみ（involvedPersonId == null）影響を計算
      if (scandal.involvedPersonId == null) {
        var impact = scandal.getWeeklyImpact(year, week);

        // メディア報道乗数を適用
        final mediaCoverageMultiplier =
            ScandalManager.calculateMediaCoverageMultiplier(
          playerReputation: playerReputation,
          mediaFavoring: mediaFavoring,
        );
        impact *= mediaCoverageMultiplier;

        totalImpact -= impact; // 支持率低下はマイナス
      }
    }

    return totalImpact.clamp(-30.0, 0.0);
  }

  /// スキャンダルへのプレイヤー応答を処理
  GameSession respondToScandal({
    required GameSession session,
    required Scandal scandal,
    required ScandalResponse response,
  }) {
    // スキャンダルを応答済みに更新
    final respondedScandal = Scandal(
      id: scandal.id,
      title: scandal.title,
      type: scandal.type,
      discoveredAt: scandal.discoveredAt,
      startWeek: scandal.startWeek,
      startYear: scandal.startYear,
      baseImpact: scandal.baseImpact,
      initialIntensity: scandal.initialIntensity,
      involvedPersonId: scandal.involvedPersonId,
      playerResponse: response,
      respondedAt: DateTime.now(),
    );

    // スキャンダルリストを更新
    final updatedScandalsList = session.activeScandalsList
        .map((s) => s.id == scandal.id ? respondedScandal : s)
        .toList();

    // 応答に応じて評判を調整
    int reputationChange = 0;
    switch (response) {
      case ScandalResponse.deny:
        reputationChange = -5; // 否定は信頼低下
        break;
      case ScandalResponse.apologize:
        reputationChange = -10; // 謝罪は長期的信頼低下
        break;
      case ScandalResponse.counterattack:
        reputationChange = -3; // 反論は少し低下
        break;
      case ScandalResponse.ignore:
        reputationChange = 0; // 無視は影響なし
        break;
    }

    final newReputation =
        (session.playerReputation + reputationChange).clamp(0, 100);

    return session.copyWith(
      activeScandalsList: updatedScandalsList,
      playerReputation: newReputation,
    );
  }

  /// 次の選挙のための討論会をスケジュール設定
  Debate? scheduleDebate({
    required GameSession session,
    required RivalCandidate opponent,
    required int electionYear,
  }) {
    // 既に討論会がスケジュールされていないか確認
    if (session.upcomingDebate != null &&
        session.upcomingDebate!.electionYear == electionYear) {
      return null;
    }

    return Debate(
      id: _uuid.v4(),
      electionYear: electionYear,
      rounds: [],
      opponentId: opponent.id,
      opponentName: opponent.name,
      scheduledAt: DateTime.now(),
      playerScore: 0.0,
      rivalScore: 0.0,
    );
  }

  /// 討論ラウンドのプレイヤーパフォーマンスを計算
  double calculatePlayerRoundPerformance({
    required GameSession session,
    required DebateTopic topic,
    required String difficulty,
  }) {
    // ベーススコア: 50
    double score = 50.0;

    // 政策マッチボーナス
    final status = session.status;
    final policyMatchBonus = _calculatePolicyMatchBonus(topic, status);
    score += policyMatchBonus;

    // 満足度：高いほど自信がある
    final satisfactionBonus = (status.satisfaction / 100) * 15;
    score += satisfactionBonus;

    // 安定度：低いと緊張して悪くなる
    final stabilityPenalty = (100 - status.stability) / 100 * 10;
    score -= stabilityPenalty;

    // 評判：高いほど説得力がある
    final reputationBonus = (session.playerReputation / 100) * 10;
    score += reputationBonus;

    // スキャンダル：進行中のスキャンダルは信頼度を落とす
    if (session.activeScandalsList.isNotEmpty) {
      final activeScandalCount = session.activeScandalsList
          .where((s) => s.involvedPersonId == null)
          .length;
      score -= activeScandalCount * 5;
    }

    // ランダム要素: パフォーマンスの変動 (±30)
    final performanceVariation =
        (_random.nextDouble() * 60) - 30;
    score += performanceVariation;

    return score.clamp(0.0, 100.0);
  }

  /// ライバルのラウンドパフォーマンスを計算
  double calculateRivalRoundPerformance({
    required RivalCandidate rival,
    required DebateTopic topic,
    required String difficulty,
  }) {
    // ベーススコア: 50
    double score = 50.0;

    // 難易度による調整
    final difficultyMult = difficulty == 'hard'
        ? 1.3
        : difficulty == 'easy'
            ? 0.7
            : 1.0;

    // ライバルの支持率が高いほど自信がある
    final supportBonus = (rival.popularity / 100) * 15;
    score += supportBonus * difficultyMult;

    // ライバルの政策一貫性
    score += _random.nextDouble() * 20;

    // ランダム要素
    final performanceVariation =
        (_random.nextDouble() * 60) - 30;
    score += performanceVariation;

    return score.clamp(0.0, 100.0);
  }

  /// 討論の勝者を決定
  DebateOutcome determineDebateWinner({
    required double playerScore,
    required double rivalScore,
  }) {
    final difference = playerScore - rivalScore;

    if (difference > 30) {
      return DebateOutcome.dominantVictory;
    } else if (difference > 15) {
      return DebateOutcome.clearVictory;
    } else if (difference > 5) {
      return DebateOutcome.narrowVictory;
    } else if (difference.abs() <= 5) {
      return DebateOutcome.tie;
    } else if (difference < -5) {
      return DebateOutcome.narrowLoss;
    } else if (difference < -15) {
      return DebateOutcome.clearLoss;
    } else {
      return DebateOutcome.dominantLoss;
    }
  }

  /// 討論結果から支持率変化を計算
  double calculateDebateImpact({
    required DebateOutcome outcome,
  }) {
    return outcome.supportChange;
  }

  /// トピックに基づいて政策マッチボーナスを計算
  double _calculatePolicyMatchBonus(DebateTopic topic, CountryStatus status) {
    switch (topic) {
      case DebateTopic.economy:
        // GDP成長政策を選択していれば+10
        return (status.gdp > 1500) ? 10.0 : ((status.gdp > 1000) ? 5.0 : -5.0);

      case DebateTopic.healthcare:
        // 満足度が高ければ医療に投資している
        return (status.satisfaction > 70) ? 10.0 : -5.0;

      case DebateTopic.security:
        // 国力が高ければセキュリティに注力している
        return (status.nationalPower > 70) ? 10.0 : -5.0;

      case DebateTopic.environment:
        // 安定度が高ければ環境政策も充実
        return (status.stability > 70) ? 10.0 : -5.0;

      case DebateTopic.infrastructure:
        // GDP成長と安定度で判定
        return ((status.gdp > 1000 && status.stability > 60)
            ? 10.0
            : (status.stability > 50)
                ? 5.0
                : -5.0);

      case DebateTopic.education:
        // 国力と国家人材を示唆する統計で判定
        return (status.nationalPower > 60) ? 10.0 : -5.0;
    }
  }

  /// プレイヤーの得票率を計算
  double calculatePlayerVoteShare({
    required GameSession session,
    required CountryStatus status,
    required List<Campaign> activeCampaigns,
    required List<Scandal> activeScandalsList,
    required Debate? debate,
  }) {
    // ベース支持率（満足度と安定度の平均）
    double baseSupport =
        ((status.satisfaction * 0.4) + (status.stability * 0.3) + (session.playerReputation * 0.3)) /
            100 *
            60;

    // キャンペーン効果
    double campaignBonus = 0.0;
    for (final campaign in activeCampaigns) {
      // 有効な状態のキャンペーンは +1 から +3% の効果
      final effectiveness = campaign.effectiveness;
      if (effectiveness > 0) {
        campaignBonus += 2.0 * (effectiveness / 100);
      }
    }
    // キャンペーン効果にデバウンス乗数を適用
    campaignBonus = campaignBonus * (1 + (session.debateEffectsMultiplier - 1) * 0.5);

    // 討論会効果
    double debateBonus = 0.0;
    if (debate != null && debate.isCompleted) {
      debateBonus = switch (debate.outcome!) {
        DebateOutcome.dominantVictory => 10.0,
        DebateOutcome.clearVictory => 6.0,
        DebateOutcome.narrowVictory => 3.0,
        DebateOutcome.tie => 0.5,
        DebateOutcome.narrowLoss => -3.0,
        DebateOutcome.clearLoss => -6.0,
        DebateOutcome.dominantLoss => -10.0,
      };
    }

    // スキャンダル影響
    double scandalPenalty = 0.0;
    final currentYear = session.status.year;
    final currentWeek = (session.status.day / 7).ceil();
    for (final scandal in activeScandalsList) {
      if (scandal.isActive(currentYear, currentWeek)) {
        scandalPenalty -= scandal.getWeeklyImpact(currentYear, currentWeek);
      }
    }

    // 最終的な得票率を計算し、0-100 にクランプ
    double totalVoteShare = baseSupport + campaignBonus + debateBonus + scandalPenalty;
    return totalVoteShare.clamp(0.0, 100.0);
  }

  /// ライバルの得票率を計算（AI難易度に応じた調整）
  double calculateRivalVoteShare({
    required RivalCandidate rival,
    required double playerVoteShare,
    required String difficulty,
  }) {
    // ライバルのベース支持率
    double baseRivalSupport = rival.popularity;

    // 難易度による乗数（ハードなら敵が強い）
    final difficultyMultiplier = switch (difficulty) {
      'easy' => 0.8,
      'normal' => 1.0,
      'hard' => 1.2,
      _ => 1.0,
    };

    // ライバルの支持率調整（プレイヤーの得票率に応じた市場シェア）
    double adjustedRivalSupport = baseRivalSupport * difficultyMultiplier;

    // 100未満の範囲に納める
    return adjustedRivalSupport.clamp(0.0, 100.0);
  }

  /// 選挙結果を計算
  ElectionResult calculateElectionResult({
    required String sessionId,
    required int year,
    required GameSession session,
    required List<RivalCandidate> rivals,
    required String difficulty,
  }) {
    // プレイヤーの得票率を計算
    final playerVote = calculatePlayerVoteShare(
      session: session,
      status: session.status,
      activeCampaigns: session.activeCampaigns,
      activeScandalsList: session.activeScandalsList,
      debate: session.debateHistory.lastOrNull,
    );

    // ライバル候補者の得票率を計算
    final rivalVotes = <String, double>{};
    for (final rival in rivals) {
      final rivalVote = calculateRivalVoteShare(
        rival: rival,
        playerVoteShare: playerVote,
        difficulty: difficulty,
      );
      rivalVotes[rival.id] = rivalVote;
    }

    // 少数派候補の投票率を生成（3-5人、各2-8%）
    final minorCandidateVotes = <String, double>{};
    final minorCandidateCount = 3 + _random.nextInt(3);
    double totalMinorVotes = 0.0;

    for (int i = 0; i < minorCandidateCount; i++) {
      final minorVote = 2.0 + (_random.nextInt(7) * 1.0);
      minorCandidateVotes['minor_$i'] = minorVote;
      totalMinorVotes += minorVote;
    }

    // 投票率を正規化（100%になるように調整）
    final totalVotes = playerVote + rivalVotes.values.fold(0.0, (a, b) => a + b) + totalMinorVotes;
    final scaleFactor = totalVotes > 0 ? 100.0 / totalVotes : 1.0;

    final scaledPlayerVote = (playerVote * scaleFactor).clamp(0.0, 100.0);
    final scaledRivalVotes = <String, double>{};
    for (final entry in rivalVotes.entries) {
      scaledRivalVotes[entry.key] = (entry.value * scaleFactor).clamp(0.0, 100.0);
    }
    final scaledMinorVotes = <String, double>{};
    for (final entry in minorCandidateVotes.entries) {
      scaledMinorVotes[entry.key] = (entry.value * scaleFactor).clamp(0.0, 100.0);
    }

    // 勝敗を決定
    final maxRivalVote = scaledRivalVotes.values.isNotEmpty ? scaledRivalVotes.values.reduce((a, b) => a > b ? a : b) : 0.0;
    final playerWon = scaledPlayerVote >= maxRivalVote && scaledPlayerVote >= 40;
    final marginOfVictory = scaledPlayerVote - maxRivalVote;

    // 勝利タイプを決定
    final victoryType = _determineVictoryType(scaledPlayerVote, playerWon, marginOfVictory);

    // 選挙パフォーマンススコアを計算
    final electoralScore = calculateElectoralScore(
      voteShare: scaledPlayerVote,
      playerReputation: session.playerReputation,
      debateOutcome: session.debateHistory.lastOrNull?.outcome,
      campaignEfficiency: _calculateCampaignEfficiency(session),
    );

    // ナレーティブを生成
    final narrativeText = _generateElectionNarrative(
      voteShare: scaledPlayerVote,
      victoryType: victoryType,
      playerWon: playerWon,
      marginOfVictory: marginOfVictory,
      rivals: rivals,
    );

    return ElectionResult(
      year: year,
      playerVoteShare: scaledPlayerVote,
      playerMarginOfVictory: marginOfVictory,
      rivalVotes: scaledRivalVotes,
      minorCandidateVotes: scaledMinorVotes,
      playerWon: playerWon,
      victoryType: victoryType,
      electoralScore: electoralScore,
      narrativeText: narrativeText,
    );
  }

  /// 選挙パフォーマンススコアを計算（0-100）
  double calculateElectoralScore({
    required double voteShare,
    required int playerReputation,
    required DebateOutcome? debateOutcome,
    required double campaignEfficiency,
  }) {
    // 得票率ベース（0-100の範囲から0-50を取得）
    double baseScore = (voteShare / 100) * 50;

    // 名声ボーナス（0-15）
    double reputationBonus = (playerReputation / 100) * 15;

    // 討論会ボーナス（0-20）
    double debateBonus = 0.0;
    if (debateOutcome != null) {
      debateBonus = switch (debateOutcome) {
        DebateOutcome.dominantVictory => 20.0,
        DebateOutcome.clearVictory => 15.0,
        DebateOutcome.narrowVictory => 10.0,
        DebateOutcome.tie => 5.0,
        DebateOutcome.narrowLoss => 0.0,
        DebateOutcome.clearLoss => -5.0,
        DebateOutcome.dominantLoss => -10.0,
      };
    }

    // キャンペーン効率ボーナス（0-15）
    double efficiencyBonus = (campaignEfficiency * 100).clamp(0.0, 100.0) / 100 * 15;

    double totalScore = (baseScore + reputationBonus + debateBonus + efficiencyBonus).clamp(0.0, 100.0);
    return totalScore;
  }

  /// キャンペーン効率を計算（支出と効果の比率）
  double _calculateCampaignEfficiency(GameSession session) {
    if (session.activeCampaigns.isEmpty) return 0.5;

    double totalEffectiveness = 0.0;
    for (final campaign in session.activeCampaigns) {
      totalEffectiveness += campaign.effectiveness;
    }

    final avgEffectiveness = totalEffectiveness / session.activeCampaigns.length;
    return (avgEffectiveness / 100).clamp(0.0, 1.0);
  }

  /// 勝利タイプを決定
  ElectionVictoryType _determineVictoryType(double playerVote, bool playerWon, double marginOfVictory) {
    if (!playerWon) {
      if (playerVote >= 45) {
        return ElectionVictoryType.narrowLoss;
      } else if (playerVote >= 35) {
        return ElectionVictoryType.clearLoss;
      } else {
        return ElectionVictoryType.landslideDefeat;
      }
    }

    // プレイヤーが勝った場合
    if (playerVote >= 65) {
      return ElectionVictoryType.dominantVictory;
    } else if (playerVote >= 55) {
      return ElectionVictoryType.clearVictory;
    } else if (playerVote >= 50) {
      return ElectionVictoryType.narrowVictory;
    } else if (playerVote >= 40) {
      return ElectionVictoryType.pluralityVictory;
    }

    return ElectionVictoryType.pluralityVictory;
  }

  /// 選挙ナレーティブを生成
  String _generateElectionNarrative({
    required double voteShare,
    required ElectionVictoryType victoryType,
    required bool playerWon,
    required double marginOfVictory,
    required List<RivalCandidate> rivals,
  }) {
    final mainRival = rivals.isNotEmpty ? rivals.first : null;

    if (playerWon) {
      if (victoryType == ElectionVictoryType.dominantVictory) {
        return '圧倒的な勝利！${voteShare.toStringAsFixed(1)}%の得票率で、${mainRival?.name ?? "ライバル"}候補に大差をつけた。'
            '国民は君の方針に強い支持を示した。';
      } else if (victoryType == ElectionVictoryType.clearVictory) {
        return '明確な勝利を収めた。${voteShare.toStringAsFixed(1)}%の支持で、${mainRival?.name ?? "ライバル"}候補を上回った。'
            '次の任期での政策実行に向けて、国民の信任を得た。';
      } else if (victoryType == ElectionVictoryType.narrowVictory) {
        return '接戦を制した。${voteShare.toStringAsFixed(1)}%で50%を超え、辛くも勝利を手にした。'
            '国民の声に耳を傾け、更なる成果を上げる必要がある。';
      } else {
        return '相対多数での勝利。${voteShare.toStringAsFixed(1)}%で最多得票を獲得したが、完全な過半数ではない。'
            '政治的課題は多く、連携が求められる時代となった。';
      }
    } else {
      if (victoryType == ElectionVictoryType.narrowLoss) {
        return '僅差での敗北。${voteShare.toStringAsFixed(1)}%の支持を得たが、${mainRival?.name ?? "ライバル"}候補に及ばなかった。'
            '再起を目指す次の機会に向けて、戦略を再考する必要がある。';
      } else if (victoryType == ElectionVictoryType.clearLoss) {
        return '明確な敗北。${voteShare.toStringAsFixed(1)}%の得票率は、${mainRival?.name ?? "ライバル"}候補の信任には届かなかった。'
            '君の時代は終わり、新しい指導者の下で国は進む。';
      } else {
        return '圧倒的な敗北。わずか${voteShare.toStringAsFixed(1)}%の支持率で、国民は明確に君の方針を拒否した。'
            '政治キャリアは終焉を迎えた。';
      }
    }
  }

  /// Update political party states based on current game conditions
  static void updatePoliticalPartyStates(GameSession session) {
    // TODO: Implement political party state updates
  }

  /// Determine if election should be held based on game progress
  static bool shouldHoldElection(GameSession session) {
    // Elections typically held annually or at specific game milestones
    return false; // Placeholder
  }

  /// Initialize rival candidates for election
  static List<RivalCandidate> initializeRivalCandidatesForElection(
      GameSession session) {
    // Use existing rivals or create new ones
    return session.rivalCandidates ?? [];
  }
}
