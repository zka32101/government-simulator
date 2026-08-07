import 'dart:math';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/event.dart';
import 'package:government_simulator/models/decision.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/faction.dart';
import 'package:government_simulator/models/achievement.dart';
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
    final adjustedNationalPower =
        newNationalPower * (0.9 + gdpTrend * 0.1).clamp(0.5, 1.5);

    // 派閥支持率を選択の方向性から導出して適用
    final factionDeltas = deriveFactionImpact(impact);
    final newFactions = current.factions.applyDeltas(factionDeltas);

    return current.copyWith(
      gdp: newGdp,
      unemployment: newUnemployment,
      satisfaction: finalSatisfaction,
      nationalPower: adjustedNationalPower,
      inflationRate: newInflationRate,
      stability: newStability,
      factions: newFactions,
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
    if (s.gdp <= 120) return GameOverType.bankruptcy;
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

    return status.copyWith(
      gdp: adjustedGdp,
      unemployment: newUnemployment,
      nationalPower: newNationalPower,
      inflationRate: newInflationRate,
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
