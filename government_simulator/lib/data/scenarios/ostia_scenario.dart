/// オスティア共和国シナリオ
/// ヨーロッパ・カルパチア地方の中堅先進国
/// テーマ：経済危機からの回復と国際紛争の選択肢

library;

import 'package:government_simulator/models/scenario.dart';
import 'package:government_simulator/models/crisis.dart';

final ostiaScenario = GameScenario(
  id: 'ostia',
  countryName: 'オスティア共和国',
  region: 'ヨーロッパ・カルパチア地方',
  description: '経済危機から回復途上の中堅先進国。隣国との緊張と国内の政治分裂が課題。',
  difficulty: 'normal',
  population: 35.0, // 3500万人
  gdp: 2.8, // $2.8兆
  politicalSystem: '議会制民主主義共和国',
  currency: 'オスティア・マルク (OM)',
  initialApproval: 45.0,
  economicSatisfaction: 42.0,
  socialSatisfaction: 48.0,
  securitySatisfaction: 55.0,
  healthcareSatisfaction: 50.0,
  budget: 280000.0, // $2800億
  nationalDebt: 850.0, // $8500億
  historicalBackground: '''
30年前の民族紛争から統一された共和国。ソビエト時代の重工業遺産と現代化の衝突。
前政権の経済悪化により国債が急増。最近のIMF支援プログラム受け入れが市民から反発を招く。
EU・NATO加盟国として西側陣営に属するが、ロスカ帝国との国境問題が常に緊張を生む。
  ''',
  currentChallenges: [
    '失業率12%、インフレ率8% - 経済危機の継続',
    'ロスカ帝国との国境紛争 - 領土紛争と軍事的緊張',
    '政治的分裂 - 改革派vs保守派の対立激化',
    '少数民族問題 - スラヴ系30%、イスラム系15%の統合',
    '労働組合の力強い抵抗 - 賃上げ要求と経済との葛藤',
  ],
  opportunities: [
    'プロスペリア連邦との貿易拡大 - 経済成長の機会',
    '国家主権強化 - IMFからの独立で国民支持回復',
    '地域的影響力の拡大 - 小国の同盟構築',
    '技術産業の育成 - 重工業から脱却',
    '国内統和による社会安定化 - 長期的な繁栄基盤構築',
  ],
  characters: [
    ScenarioCharacter(
      name: 'ボリス・ノヴァク',
      title: '財務大臣',
      position: '内閣',
      stance: '緊縮財政派',
      influence: 0.8,
      description: '経済学者出身。IMFプログラムの忠実な実行者。改革には厳格だが国際的評価が高い。',
      faction: '改革派',
    ),
    ScenarioCharacter(
      name: 'マルタ・コーバル',
      title: '野党党首',
      position: '野党（労働党）',
      stance: '福祉充実派',
      influence: 0.75,
      description: '国民の苦しみを前面に出す政治家。IMF政策への強い反発。大衆的人気が高い。',
      faction: '保守派',
    ),
    ScenarioCharacter(
      name: 'イワン・ペトロフ',
      title: '労働組合連盟会長',
      position: '労働運動',
      stance: '労働者擁護',
      influence: 0.65,
      description: 'ストライキを頻繁に呼びかける。緊縮政策への激しい抵抗勢力。',
      faction: null,
    ),
    ScenarioCharacter(
      name: 'ジョアンナ・クレス',
      title: '国防大臣',
      position: '内閣',
      stance: '強硬派',
      influence: 0.6,
      description: 'ロスカ帝国への対抗に強気。軍事費増加を主張。タカ派の象徴。',
      faction: '改革派',
    ),
    ScenarioCharacter(
      name: 'ミロス・ラディック',
      title: '大富豪実業家',
      position: '民間経済界',
      stance: '規制緩和派',
      influence: 0.55,
      description: 'オスティア最大の鉱業企業グループ会長。政治に多大な影響力を行使。',
      faction: null,
    ),
    ScenarioCharacter(
      name: 'ネナド・コスティック',
      title: 'スラヴ系民族指導者',
      position: '少数民族代表',
      stance: '民族自治要求派',
      influence: 0.45,
      description: '東部地域の自治権拡大を要求。分離主義的傾向。',
      faction: null,
    ),
  ],
  initialNations: [
    InitialNationRelation(
      nationName: 'ロスカ帝国',
      relationship: '敵対国',
      standingScore: -60,
      description: '北隣の権威主義国家。領土的野心と経済的支配を目指す。',
      conflicts: '国境紛争、少数民族政策、地政学的対立',
      sharedInterests: null,
    ),
    InitialNationRelation(
      nationName: 'プロスペリア連邦',
      relationship: '友好国',
      standingScore: 45,
      description: '東隣の経済大国。EUの中核メンバー。',
      sharedInterests: '貿易拡大、EUでの協力',
      conflicts: '農業補助金、競争力の差',
    ),
    InitialNationRelation(
      nationName: 'ヴァリア王国',
      relationship: 'NATO同盟国',
      standingScore: 35,
      description: '西隣の北欧国家。NATO・EU加盟国。',
      sharedInterests: 'ロスカ対抗、地域安全保障',
      conflicts: '難民政策、環境規制',
    ),
    InitialNationRelation(
      nationName: 'アルタイ共和国',
      relationship: '中立国（不安定）',
      standingScore: 5,
      description: '南東の資源豊富な小国。列強の綱引きの舞台。',
      sharedInterests: '経済協力の可能性',
      conflicts: 'ロスカの影響拡大',
    ),
  ],
  storyArcs: [
    StoryArc(
      title: '経済危機からの回復',
      description: 'IMF支援プログラムの実行。国民の反発と国際的圧力のバランス。緊縮か拡大か。',
      theme: 'economic',
      keyEvents: [
        '失業対策：雇用創出か緊縮維持か',
        '労働ストの危機：交渉か強硬対応か',
        '銀行危機：政府救済か市場任せか',
        '技術産業育成：投資か消極的か',
      ],
      priority: 5,
    ),
    StoryArc(
      title: 'ロスカ帝国との国境紛争',
      description: 'ロスカの領土的野心とオスティアの主権防衛。戦争か外交か。',
      theme: 'military',
      keyEvents: [
        '国境での小競り合い激化',
        '国防費の急増要求',
        '国際的な調停と制裁',
        'NATO同盟国からの援助',
      ],
      priority: 5,
    ),
    StoryArc(
      title: '国内政治の分裂と統和',
      description: 'IMF政策への反発と改革推進のバランス。民主主義か独裁か。',
      theme: 'domestic',
      keyEvents: [
        '労働組合によるストライキ',
        '野党との激しい対立',
        '国民投票による政策決定',
        'クーデター未遂事件',
      ],
      priority: 4,
    ),
    StoryArc(
      title: '少数民族問題の解決',
      description: 'スラヴ系・イスラム系市民との共生。分離主義か統合か。',
      theme: 'domestic',
      keyEvents: [
        '自治権要求運動',
        '民族間の紛争勃発',
        '文化政策と教育改革',
        '国家的アイデンティティ構築',
      ],
      priority: 3,
    ),
    StoryArc(
      title: '国際的地位の確立',
      description: 'EU・NATO内での役割と地域的影響力。西側か中立か。',
      theme: 'diplomatic',
      keyEvents: [
        'EU内での発言力強化',
        'NATO参加のコスト',
        'ロシア周辺国との協力',
        'アルタイ共和国への影響力拡大',
      ],
      priority: 3,
    ),
  ],
  uniqueCrises: [
    CrisisType.demonstration,
    CrisisType.riot,
    CrisisType.laborStrike,
    CrisisType.economicCrisis,
    CrisisType.militaryCoup,
  ],
);
