import 'package:government_simulator/models/faction.dart';
import 'package:government_simulator/models/minister.dart';

class CountryStatus {
  final double gdp; // 10-10000 (billions)
  final double unemployment; // 0-25 (percentage)
  final double satisfaction; // 0-100
  final double nationalPower; // 0-100
  final int year;
  final int day;
  final DateTime lastUpdated;

  // Additional richness factors for gameplay
  final double inflationRate; // -5 to 15 (percentage)
  final double publicDebt; // GDP比 (percentage)
  final String? countryPersonality; // 企業家型/労働者型/環境型など
  final int decisionsCount; // 総意思決定数
  final double stability; // 0-100 (経済安定度)
  final FactionSupport factions; // 派閥支持率
  final Cabinet cabinet; // 内閣（大臣忠誠度）
  final double corruption; // 0-100 汚職度。高いほど内閣の忠誠が蝕まれる

  // 引退→新しい国家で再起する際、直前のセッションを辿れるようにする。
  final String? previousSessionId;
  final bool isNewGame;

  const CountryStatus({
    required this.gdp,
    required this.unemployment,
    required this.satisfaction,
    required this.nationalPower,
    required this.year,
    required this.day,
    required this.lastUpdated,
    this.inflationRate = 2.0,
    this.publicDebt = 60.0,
    this.countryPersonality,
    this.decisionsCount = 0,
    this.stability = 70.0,
    FactionSupport? factions,
    Cabinet? cabinet,
    this.corruption = 0.0,
    this.previousSessionId,
    this.isNewGame = true,
  })  : factions = factions ?? const FactionSupport({
          Faction.military: 50,
          Faction.business: 50,
          Faction.labor: 50,
          Faction.citizen: 50,
        }),
        // Cabinet.initial() と同じ初期値（大臣忠誠度60）。const コンストラクタの
        // 初期化子はコンパイル時定数のみ許されるため、Cabinet.initial() を
        // 呼ぶ代わりにここでもリテラルを複製している。
        cabinet = cabinet ?? const Cabinet(loyalty: {
          MinisterRole.finance: 60,
          MinisterRole.defense: 60,
          MinisterRole.interior: 60,
          MinisterRole.foreign: 60,
          MinisterRole.environment: 60,
        });

  // 国家危機レベルを計算（ゲーム性向上用）
  CrisisLevel get crisisLevel {
    if (unemployment > 15 || satisfaction < 20 || gdp < 200) {
      return CrisisLevel.critical;
    }
    if (unemployment > 10 || satisfaction < 40 || gdp < 400) {
      return CrisisLevel.high;
    }
    if (unemployment > 7 || satisfaction < 60 || gdp < 700) {
      return CrisisLevel.medium;
    }
    return CrisisLevel.stable;
  }

  // 国家の"健全性スコア" (0-100)
  double get healthScore {
    // gdp は 100〜10000 の範囲（applyImpact でクランプ）。/1000 だと
    // 最大値でも 10 点にしかならず、achievement.dart の perfect_score
    // (healthScore >= 85) が数学的に到達不可能になっていたバグがあった。
    // num.clamp(int, int) は num を返すため .toDouble() を付けないと、
    // gdp が範囲外（0未満や10000超）になった際に整数の 0/100 が
    // そのまま返り、この getter の double 型の戻り値へ暗黙変換しようと
    // して実行時に型エラーとなるバグがあった。
    final gdpScore = (gdp / 100).clamp(0, 100).toDouble();
    final employmentScore = ((100 - unemployment) / 100 * 100).clamp(0, 100).toDouble();
    final satisfactionScore = satisfaction.clamp(0, 100).toDouble();
    final stabilityScore = stability.clamp(0, 100).toDouble();

    return (gdpScore * 0.25 +
        employmentScore * 0.25 +
        satisfactionScore * 0.25 +
        stabilityScore * 0.25);
  }

  // 1年分の現実時間（日数）
  bool get isYearEnd => day >= 7;

  // 進行状況（0.0-1.0）
  double get yearProgress => (day - 1) / 6.0;

  CountryStatus copyWith({
    double? gdp,
    double? unemployment,
    double? satisfaction,
    double? nationalPower,
    int? year,
    int? day,
    DateTime? lastUpdated,
    double? inflationRate,
    double? publicDebt,
    String? countryPersonality,
    int? decisionsCount,
    double? stability,
    FactionSupport? factions,
    Cabinet? cabinet,
    double? corruption,
    String? previousSessionId,
    bool? isNewGame,
  }) {
    return CountryStatus(
      gdp: gdp ?? this.gdp,
      unemployment: unemployment ?? this.unemployment,
      satisfaction: satisfaction ?? this.satisfaction,
      nationalPower: nationalPower ?? this.nationalPower,
      year: year ?? this.year,
      day: day ?? this.day,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      inflationRate: inflationRate ?? this.inflationRate,
      publicDebt: publicDebt ?? this.publicDebt,
      countryPersonality: countryPersonality ?? this.countryPersonality,
      decisionsCount: decisionsCount ?? this.decisionsCount,
      stability: stability ?? this.stability,
      factions: factions ?? this.factions,
      cabinet: cabinet ?? this.cabinet,
      corruption: corruption ?? this.corruption,
      previousSessionId: previousSessionId ?? this.previousSessionId,
      isNewGame: isNewGame ?? this.isNewGame,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gdp': gdp,
      'unemployment': unemployment,
      'satisfaction': satisfaction,
      'nationalPower': nationalPower,
      'year': year,
      'day': day,
      'lastUpdated': lastUpdated.toIso8601String(),
      'inflationRate': inflationRate,
      'publicDebt': publicDebt,
      'countryPersonality': countryPersonality,
      'decisionsCount': decisionsCount,
      'stability': stability,
      'factions': factions.toMap(),
      'cabinet': cabinet.toMap(),
      'corruption': corruption,
      'previousSessionId': previousSessionId,
      'isNewGame': isNewGame,
    };
  }

  factory CountryStatus.fromMap(Map<String, dynamic> map) {
    return CountryStatus(
      gdp: (map['gdp'] ?? 1000).toDouble(),
      unemployment: (map['unemployment'] ?? 5).toDouble(),
      satisfaction: (map['satisfaction'] ?? 50).toDouble(),
      nationalPower: (map['nationalPower'] ?? 50).toDouble(),
      year: map['year'] ?? 1,
      day: map['day'] ?? 1,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : DateTime.now(),
      inflationRate: (map['inflationRate'] ?? 2.0).toDouble(),
      publicDebt: (map['publicDebt'] ?? 60).toDouble(),
      countryPersonality: map['countryPersonality'],
      decisionsCount: map['decisionsCount'] ?? 0,
      stability: (map['stability'] ?? 70).toDouble(),
      factions: FactionSupport.fromMap(
          map['factions'] as Map<String, dynamic>?),
      cabinet: Cabinet.fromMap(map['cabinet'] as Map<String, dynamic>?),
      corruption: (map['corruption'] ?? 0.0).toDouble(),
      previousSessionId: map['previousSessionId'],
      isNewGame: map['isNewGame'] ?? true,
    );
  }

  @override
  String toString() => 'CountryStatus(gdp: $gdp, unemployment: $unemployment, satisfaction: $satisfaction)';
}

enum CrisisLevel {
  stable,
  medium,
  high,
  critical,
}

extension CrisisLevelExt on CrisisLevel {
  String get label {
    switch (this) {
      case CrisisLevel.stable:
        return '安定';
      case CrisisLevel.medium:
        return '注意';
      case CrisisLevel.high:
        return '警告';
      case CrisisLevel.critical:
        return '緊急';
    }
  }

  String get emoji {
    switch (this) {
      case CrisisLevel.stable:
        return '✅';
      case CrisisLevel.medium:
        return '⚠️';
      case CrisisLevel.high:
        return '🚨';
      case CrisisLevel.critical:
        return '🔥';
    }
  }
}
