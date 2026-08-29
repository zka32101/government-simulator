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
}
