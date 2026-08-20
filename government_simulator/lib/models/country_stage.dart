/// 国家ステージ：開始時に選べる「国の設定（環境）」。
///
/// 難易度固定の easy/normal/hard 選択とは異なり、資源国・観光国・
/// 財政危機国など性格の異なる初期環境を「ステージ」として選ばせ、
/// 星の数（difficultyStars, 1〜5）で難易度を視覚的に表現する。
class CountryStage {
  final String id;
  final String emoji;
  final String title;
  final String description;

  /// 難易度の星評価 (1: 易しい 〜 5: 最難関)。
  final int difficultyStars;

  final double gdp;
  final double unemployment;
  final double satisfaction;
  final double nationalPower;
  final double inflationRate;
  final double publicDebt;
  final double stability;

  const CountryStage({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.difficultyStars,
    required this.gdp,
    required this.unemployment,
    required this.satisfaction,
    required this.nationalPower,
    required this.inflationRate,
    required this.publicDebt,
    required this.stability,
  });

  /// GameSession.difficulty（既存の 'easy'/'normal'/'hard' 文字列）へ
  /// 近似マッピングする。再スタート時などの難易度倍率計算で使われる。
  String get difficultyLabel {
    if (difficultyStars <= 2) return 'easy';
    if (difficultyStars >= 4) return 'hard';
    return 'normal';
  }

  static const List<CountryStage> all = [
    CountryStage(
      id: 'stage_resource_rich',
      emoji: '⛏️',
      title: '資源大国',
      description: '豊富な天然資源に恵まれた国。輸出収入は潤沢だが、'
          '資源価格の変動に一喜一憂する経済構造が課題。',
      difficultyStars: 1,
      gdp: 1800,
      unemployment: 4.0,
      satisfaction: 60.0,
      nationalPower: 55.0,
      inflationRate: 3.0,
      publicDebt: 35.0,
      stability: 65.0,
    ),
    CountryStage(
      id: 'stage_island_nation',
      emoji: '🏝️',
      title: '島嶼観光国家',
      description: '美しい島々からなる観光立国。晴れやかな観光収入が経済を'
          '支えるが、外的ショックへの耐性は低い。',
      difficultyStars: 2,
      gdp: 900,
      unemployment: 6.0,
      satisfaction: 62.0,
      nationalPower: 30.0,
      inflationRate: 2.0,
      publicDebt: 55.0,
      stability: 60.0,
    ),
    CountryStage(
      id: 'stage_balanced_republic',
      emoji: '🏛️',
      title: '標準的な共和国',
      description: '特筆すべき強みも弱みもない、ごく平均的な国家。'
          'バランスの取れた統治手腕が試される。',
      difficultyStars: 3,
      gdp: 1000,
      unemployment: 5.0,
      satisfaction: 50.0,
      nationalPower: 50.0,
      inflationRate: 2.0,
      publicDebt: 60.0,
      stability: 70.0,
    ),
    CountryStage(
      id: 'stage_declining_power',
      emoji: '👑',
      title: '没落した大国',
      description: 'かつて世界に覇を唱えた大国も、今や見る影もない。'
          '高い国力の遺産と、崩れゆく経済のギャップに苦しむ。',
      difficultyStars: 4,
      gdp: 1200,
      unemployment: 9.0,
      satisfaction: 35.0,
      nationalPower: 75.0,
      inflationRate: 4.0,
      publicDebt: 120.0,
      stability: 40.0,
    ),
    CountryStage(
      id: 'stage_fiscal_crisis',
      emoji: '🏦',
      title: '財政危機国家',
      description: '積み重なった財政赤字が限界に近づいている。'
          '国民サービスを維持しながら財政を立て直せるか。',
      difficultyStars: 4,
      gdp: 700,
      unemployment: 8.0,
      satisfaction: 45.0,
      nationalPower: 40.0,
      inflationRate: 6.0,
      publicDebt: 160.0,
      stability: 45.0,
    ),
    CountryStage(
      id: 'stage_divided_state',
      emoji: '💣',
      title: '分断国家',
      description: '国内対立が深く根付いた国。派閥間の不信が渦巻く中、'
          '統一と安定をもたらせるか。',
      difficultyStars: 5,
      gdp: 500,
      unemployment: 12.0,
      satisfaction: 30.0,
      nationalPower: 35.0,
      inflationRate: 8.0,
      publicDebt: 100.0,
      stability: 25.0,
    ),
  ];
}
