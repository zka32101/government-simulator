/// 「歴史のif」チャレンジ：実在の歴史的局面を想起させる架空シナリオ。
/// 固定された初期国家ステータスから統治をスタートする。
class HistoricalScenario {
  final String id;
  final String emoji;
  final String title;
  final String era;
  final String description;
  final double gdp;
  final double unemployment;
  final double satisfaction;
  final double nationalPower;
  final double inflationRate;
  final double publicDebt;
  final double stability;

  const HistoricalScenario({
    required this.id,
    required this.emoji,
    required this.title,
    required this.era,
    required this.description,
    required this.gdp,
    required this.unemployment,
    required this.satisfaction,
    required this.nationalPower,
    required this.inflationRate,
    required this.publicDebt,
    required this.stability,
  });

  /// AI生成挿絵画像のアセットパス
  String get imagePath => 'assets/images/scenarios/$id.png';

  static const List<HistoricalScenario> all = [
    HistoricalScenario(
      id: 'scenario_great_depression',
      emoji: '📉',
      title: '大恐慌下の新興国',
      era: '世界恐慌期',
      description: '株価大暴落の余波で失業者が街に溢れている。'
          '国庫は乏しく、国民の不満は限界に達しつつある。',
      gdp: 420,
      unemployment: 18.0,
      satisfaction: 30.0,
      nationalPower: 35.0,
      inflationRate: -2.0,
      publicDebt: 90.0,
      stability: 40.0,
    ),
    HistoricalScenario(
      id: 'scenario_oil_shock',
      emoji: '🛢️',
      title: 'オイルショックの資源輸入国',
      era: '石油危機期',
      description: '原油価格の急騰でインフレが猛威を振るう。'
          '産業界は悲鳴を上げ、国民生活は圧迫されている。',
      gdp: 850,
      unemployment: 8.0,
      satisfaction: 40.0,
      nationalPower: 55.0,
      inflationRate: 12.0,
      publicDebt: 65.0,
      stability: 50.0,
    ),
    HistoricalScenario(
      id: 'scenario_cold_war_divide',
      emoji: '🧱',
      title: '分断国家の最前線',
      era: '冷戦期',
      description: 'イデオロギー対立の最前線に立つ国家。'
          '軍事的緊張が高く、国内でも路線対立が絶えない。',
      gdp: 700,
      unemployment: 6.0,
      satisfaction: 45.0,
      nationalPower: 70.0,
      inflationRate: 3.0,
      publicDebt: 55.0,
      stability: 45.0,
    ),
    HistoricalScenario(
      id: 'scenario_new_independence',
      emoji: '🕊️',
      title: '独立直後の新興国家',
      era: '独立直後',
      description: '長い支配からようやく独立を勝ち取った。'
          '希望に満ちているが、国家としての基盤はまだ脆い。',
      gdp: 180,
      unemployment: 12.0,
      satisfaction: 65.0,
      nationalPower: 20.0,
      inflationRate: 5.0,
      publicDebt: 30.0,
      stability: 35.0,
    ),
    HistoricalScenario(
      id: 'scenario_export_boom',
      emoji: '🏭',
      title: '高度成長期の輸出大国',
      era: '高度経済成長期',
      description: '輸出産業が急成長し、GDPは右肩上がり。'
          'しかし過重労働への不満がくすぶっている。',
      gdp: 1600,
      unemployment: 3.0,
      satisfaction: 48.0,
      nationalPower: 65.0,
      inflationRate: 4.0,
      publicDebt: 40.0,
      stability: 60.0,
    ),
    HistoricalScenario(
      id: 'scenario_welfare_debt',
      emoji: '🏥',
      title: '財政危機の福祉国家',
      era: '福祉国家爛熟期',
      description: '手厚い社会保障で国民満足度は高いが、'
          '財政赤字が膨らみ続け限界が近づいている。',
      gdp: 1100,
      unemployment: 5.0,
      satisfaction: 75.0,
      nationalPower: 50.0,
      inflationRate: 2.0,
      publicDebt: 180.0,
      stability: 55.0,
    ),
    HistoricalScenario(
      id: 'scenario_post_coup',
      emoji: '⚔️',
      title: 'クーデター後の暫定政権',
      era: 'クーデター後',
      description: '前政権はクーデターで倒れた。あなたは暫定政権の長として、'
          '揺らぐ軍と不信を抱く国民の両方を相手にする。',
      gdp: 500,
      unemployment: 10.0,
      satisfaction: 35.0,
      nationalPower: 45.0,
      inflationRate: 6.0,
      publicDebt: 70.0,
      stability: 20.0,
    ),
    HistoricalScenario(
      id: 'scenario_currency_crisis',
      emoji: '💱',
      title: '通貨危機の新興市場',
      era: '通貨危機期',
      description: '通貨価値が暴落し、輸入物価が急騰している。'
          '投資家は資本を引き揚げ、経済は混乱の渦中にある。',
      gdp: 600,
      unemployment: 9.0,
      satisfaction: 32.0,
      nationalPower: 40.0,
      inflationRate: 15.0,
      publicDebt: 95.0,
      stability: 38.0,
    ),
    HistoricalScenario(
      id: 'scenario_reunification',
      emoji: '🤝',
      title: '統一直後の東西融合国家',
      era: '再統一期',
      description: '長らく分断されていた国がついに一つになった。'
          '制度も経済格差も統合の途上で、国内には温度差が残る。',
      gdp: 900,
      unemployment: 11.0,
      satisfaction: 55.0,
      nationalPower: 60.0,
      inflationRate: 3.5,
      publicDebt: 75.0,
      stability: 42.0,
    ),
    HistoricalScenario(
      id: 'scenario_post_pandemic',
      emoji: '🦠',
      title: '感染症危機後の再建期',
      era: 'パンデミック後',
      description: '長期の行動制限がようやく明けた。経済は傷つき、'
          '雇用は不安定だが、国民は再建への期待を抱いている。',
      gdp: 750,
      unemployment: 13.0,
      satisfaction: 52.0,
      nationalPower: 48.0,
      inflationRate: 4.5,
      publicDebt: 110.0,
      stability: 48.0,
    ),
  ];
}
