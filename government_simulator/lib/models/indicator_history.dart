/// 国家指標の履歴スナップショット。
/// ゲーム進行に伴い、毎年末（またはターン終了時）に記録される。
class IndicatorSnapshot {
  /// ゲーム内の年（1から始まる）
  final int year;

  /// ゲーム内の日（1-7で循環）
  final int day;

  /// GDP（10億ドル単位）
  final double gdp;

  /// 失業率（パーセンテージ）
  final double unemployment;

  /// 国民満足度（0-100）
  final double satisfaction;

  /// 国力（0-100）
  final double nationalPower;

  /// インフレ率（パーセンテージ）
  final double inflationRate;

  /// 公的債務対GDP比（パーセンテージ）
  final double publicDebt;

  /// 経済安定度（0-100）
  final double stability;

  const IndicatorSnapshot({
    required this.year,
    required this.day,
    required this.gdp,
    required this.unemployment,
    required this.satisfaction,
    required this.nationalPower,
    required this.inflationRate,
    required this.publicDebt,
    required this.stability,
  });

  /// CountryStatus からスナップショットを作成。
  factory IndicatorSnapshot.fromCountryStatus(
    int year,
    int day,
    dynamic countryStatus,
  ) {
    return IndicatorSnapshot(
      year: year,
      day: day,
      gdp: countryStatus.gdp,
      unemployment: countryStatus.unemployment,
      satisfaction: countryStatus.satisfaction,
      nationalPower: countryStatus.nationalPower,
      inflationRate: countryStatus.inflationRate,
      publicDebt: countryStatus.publicDebt,
      stability: countryStatus.stability,
    );
  }

  /// JSON への変換（永続化用）
  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'day': day,
      'gdp': gdp,
      'unemployment': unemployment,
      'satisfaction': satisfaction,
      'nationalPower': nationalPower,
      'inflationRate': inflationRate,
      'publicDebt': publicDebt,
      'stability': stability,
    };
  }

  /// JSON から復元
  factory IndicatorSnapshot.fromMap(Map<String, dynamic> map) {
    return IndicatorSnapshot(
      year: map['year'] ?? 0,
      day: map['day'] ?? 1,
      gdp: (map['gdp'] ?? 0.0).toDouble(),
      unemployment: (map['unemployment'] ?? 0.0).toDouble(),
      satisfaction: (map['satisfaction'] ?? 50.0).toDouble(),
      nationalPower: (map['nationalPower'] ?? 50.0).toDouble(),
      inflationRate: (map['inflationRate'] ?? 2.0).toDouble(),
      publicDebt: (map['publicDebt'] ?? 60.0).toDouble(),
      stability: (map['stability'] ?? 70.0).toDouble(),
    );
  }
}
