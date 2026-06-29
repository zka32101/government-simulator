import 'package:flutter/foundation.dart';
import 'package:government_simulator/models/faction.dart';

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
  }) : factions = factions ?? const FactionSupport({
          Faction.military: 50,
          Faction.business: 50,
          Faction.labor: 50,
          Faction.citizen: 50,
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
    final gdpScore = (gdp / 1000).clamp(0, 100);
    final employmentScore = ((100 - unemployment) / 100) * 100;
    final satisfactionScore = satisfaction;
    final stabilityScore = stability;

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
