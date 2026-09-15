/// イスラス連邦シナリオ
/// アジア太平洋地域の新興経済大国
/// テーマ：急速経済成長、地域覇権争い、民族多様性

library;

import 'package:government_simulator/models/scenario.dart';
import 'package:government_simulator/models/crisis.dart';

final islasScenario = GameScenario(
  id: 'islas',
  countryName: 'イスラス連邦',
  region: 'アジア太平洋地域',
  description: '多島嶼国家で急速な経済成長を遂行中。地域大国との競争と内部不安が同時進行。',
  difficulty: 'hard',
  population: 275.0, // 2.75億人
  gdp: 2.1, // $2.1兆
  politicalSystem: '大統領制連邦共和国',
  currency: 'イスラス・ルピア (IDR)',
  initialApproval: 52.0,
  economicSatisfaction: 58.0,
  socialSatisfaction: 45.0,
  securitySatisfaction: 48.0,
  healthcareSatisfaction: 42.0,
  budget: 210000.0, // $2100億
  nationalDebt: 250.0, // $2500億
  historicalBackground: '''
20世紀初頭の独立から民主化を経て、最近30年で急速な経済成長を達成した島嶼国家。
17000以上の島々で構成され、300以上の民族語が話される極めて多様な社会。
20年前のテロとの戦いを経て、現在は民主主義と市場経済による成長を遂行中。
しかし富の不平等と宗教対立が社会の亀裂を深めている。
中国の一帯一路戦略とアメリカのインド太平洋戦略の狭間で地政学的圧力を受ける。
  ''',
  currentChallenges: [
    '急速な都市化と格差拡大 - 都市と農村の所得差が倍増',
    '宗教・民族対立の頻発 - キリスト教とイスラム教の衝突',
    '環境破壊と気候変動 - 森林破壊、洪水・干ばつの頻度増',
    '中国との領土紛争 - 南シナ海での島嶼領有権問題',
    'テロリズムの脅威 - テロ組織の再活性化',
  ],
  opportunities: [
    'アジアの成長エンジン - インドネシアの GDP成長率5-6%を維持',
    '地域統合の指導者 - ASEAN内での影響力強化',
    'インフラへの投資 - 技術移転と雇用創出',
    '観光業の拡大 - 島々の美しさを資源に',
    '再生可能エネルギー - 島嶼国家の特性を活かした成長',
  ],
  characters: [
    ScenarioCharacter(
      name: 'ジャヤ・スタメガ',
      title: '大蔵大臣',
      position: '内閣',
      stance: '経済成長最優先派',
      influence: 0.8,
      description: 'ハーバード卒のテクノクラート。GDP成長至上主義。環境・福祉政策に後ろ向き。',
      faction: '改革派',
    ),
    ScenarioCharacter(
      name: 'アイシャ・ラーマン',
      title: '野党党首',
      position: '野党（社会民主党）',
      stance: '福祉・環境重視派',
      influence: 0.72,
      description: '女性指導者。貧困層と環境問題の代弁者。若い世代から支持。',
      faction: '保守派',
    ),
    ScenarioCharacter(
      name: 'ハジ・アマル',
      title: 'イスラム指導者評議会議長',
      position: '宗教勢力',
      stance: 'イスラム法厳格化推進派',
      influence: 0.68,
      description: 'イスラム教の厳格派。シャリア法導入を主張。キリスト教との対立。',
      faction: null,
    ),
    ScenarioCharacter(
      name: 'サリム・ウドヤナ',
      title: '国防大臣',
      position: '内閣',
      stance: '対中国強硬派',
      influence: 0.65,
      description: '軍部出身。南シナ海での領土防衛を強く主張。',
      faction: '改革派',
    ),
    ScenarioCharacter(
      name: 'アンゲリン・クリスタイナ',
      title: 'キリスト教団体指導者',
      position: '宗教勢力',
      stance: '宗教の自由と平等派',
      influence: 0.55,
      description: 'キリスト教少数派の利益代弁。イスラム指導者との対立が常。',
      faction: null,
    ),
    ScenarioCharacter(
      name: 'リ・ウェイ',
      title: '中国大使',
      position: '外交',
      stance: '対中国協力推進',
      influence: 0.6,
      description: '一帯一路によるインフラ投資を仲介。政治的影響力も大きい。',
      faction: null,
    ),
  ],
  initialNations: [
    InitialNationRelation(
      nationName: '中国',
      relationship: '経済的主導国・領土紛争国',
      standingScore: 15,
      description: '最大の貿易相手であり投資家。だが南シナ海での領土主張で対立。',
      sharedInterests: '貿易・投資、インフラ協力',
      conflicts: '領土主張、環境問題',
    ),
    InitialNationRelation(
      nationName: 'アメリカ',
      relationship: 'セキュリティ同盟国',
      standingScore: 40,
      description: 'インド太平洋戦略の重要拠点。防衛同盟を求める。',
      sharedInterests: '自由な航行、安全保障',
      conflicts: '中国への対抗の圧力',
    ),
    InitialNationRelation(
      nationName: 'シンガポール',
      relationship: '地域経済的リーダー',
      standingScore: 50,
      description: '金融センター。多くの投資と技術がシンガポール経由。',
      sharedInterests: 'ASEAN統合、貿易自由化',
      conflicts: 'なし',
    ),
    InitialNationRelation(
      nationName: 'オーストラリア',
      relationship: '地域パートナー',
      standingScore: 35,
      description: '南太平洋での協力国。気候変動対策での連携。',
      sharedInterests: 'インド太平洋安全保障、環境',
      conflicts: 'イスラム過激派への対立',
    ),
  ],
  storyArcs: [
    StoryArc(
      title: '経済成長と格差の拡大',
      description: 'GDP成長を続けるか、福祉と平等を優先するか。成長と配分のジレンマ。',
      theme: 'economic',
      keyEvents: [
        '都市部への人口流入と農村の衰退',
        '低賃金労働問題と労働ストライキ',
        '最低賃金引き上げと企業競争力',
        '福祉拡充と財政赤字のバランス',
      ],
      priority: 5,
    ),
    StoryArc(
      title: '宗教・民族対立の緊張',
      description: 'イスラム教とキリスト教の衝突。多元主義か宗教優先か。',
      theme: 'domestic',
      keyEvents: [
        '宗教紛争の激化と暴力事件',
        'シャリア法導入をめぐる議論',
        '少数派の権利と多数派の民意',
        '国家のアイデンティティ定義',
      ],
      priority: 5,
    ),
    StoryArc(
      title: '南シナ海での領土争い',
      description: '中国との領土紛争。外交か軍事力か。アメリカとの同盟。',
      theme: 'military',
      keyEvents: [
        '中国の島嶼化と軍事化',
        'アメリカ軍艦の航行の自由作戦',
        '漁業資源をめぐる紛争',
        '国際仲裁と平和的解決の努力',
      ],
      priority: 5,
    ),
    StoryArc(
      title: '環境破壊と気候変動対策',
      description: '森林破壊と洪水対策。開発か保全か。',
      theme: 'social',
      keyEvents: [
        'パーム油企業による違法開伐',
        'El Niño による干ばつと水不足',
        'モンスーン豪雨による洪水災害',
        '再生可能エネルギーへの転換',
      ],
      priority: 4,
    ),
    StoryArc(
      title: '地域統合のリーダーシップ',
      description: 'ASEAN内での指導的役割。地政学的バランスの維持。',
      theme: 'diplomatic',
      keyEvents: [
        'ASEAN議長国としての責務',
        '米中二大国の影響力回避',
        '地域統合の深化と各国の利益',
        '自由で開かれたインド太平洋の実現',
      ],
      priority: 3,
    ),
  ],
  uniqueCrises: [
    CrisisType.demonstration,
    CrisisType.riot,
    CrisisType.economicCrisis,
  ],
);
