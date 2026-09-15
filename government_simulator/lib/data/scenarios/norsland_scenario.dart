/// ノルスランド王国シナリオ
/// 北ヨーロッパ・北欧地方
/// テーマ：高福祉国家の危機、気候変動、移民問題

library;

import 'package:government_simulator/models/scenario.dart';
import 'package:government_simulator/models/crisis.dart';

final norslandScenario = GameScenario(
  id: 'norsland',
  countryName: 'ノルスランド王国',
  region: '北ヨーロッパ・北極圏',
  description: '高度な福祉国家で知られる北欧の先進国。気候変動による急速な環境変化と移民増加が課題。',
  difficulty: 'normal',
  population: 5.5, // 550万人
  gdp: 2.2, // $2.2兆
  politicalSystem: '立憲君主制議会制民主主義',
  currency: 'ノルスランド・クローネ (NK)',
  initialApproval: 58.0,
  economicSatisfaction: 72.0,
  socialSatisfaction: 68.0,
  securitySatisfaction: 65.0,
  healthcareSatisfaction: 78.0,
  budget: 220000.0, // $2200億
  nationalDebt: 180.0, // $1800億
  historicalBackground: '''
ノーベル賞の発祥地であり、福祉国家の典型例として知られる王国。
高い税率（50-60%）と充実した医療・教育・社会保障により、市民生活の質が世界トップクラス。
しかし過去20年で急速に気候が変動し、北極圏の氷が減少。
また移民流入の加速により、文化的アイデンティティと多文化共生の緊張が高まっている。
  ''',
  currentChallenges: [
    '気候変動による環境危機 - 北極氷の急速融解',
    '移民・難民の急増 - 社会統合の困難',
    '福祉制度の持続可能性 - 高齢化による社会保障費増加',
    '産業転換の必要性 - 石油産業から脱却',
    'ポピュリズムの台頭 - 右翼政党による移民排斥',
  ],
  opportunities: [
    '再生可能エネルギーの世界的リーダー - 風力・水力発電',
    '気候変動対策のモデル国 - グリーン経済への転換',
    '北極圏資源の開発機会 - 氷の融解による新航路',
    '多文化社会の成功例 - 移民統合の実現',
    'スタートアップ生態系 - 技術イノベーション',
  ],
  characters: [
    ScenarioCharacter(
      name: 'エリック・オーストロム',
      title: '首相',
      position: '内閣',
      stance: '気候変動対策最優先派',
      influence: 0.9,
      description: '環境科学者出身。パリ協定を超える目標を掲げる。進歩的で理想主義的。',
      faction: '緑の党',
    ),
    ScenarioCharacter(
      name: 'ソフィア・リンドストローム',
      title: '保守党党首',
      position: '野党',
      stance: '移民制限派・福祉削減派',
      influence: 0.75,
      description: '右翼ポピュリズムの象徴。スウェーデン・デンマークの政治潮流に同調。',
      faction: '保守派',
    ),
    ScenarioCharacter(
      name: 'ムハマド・アムスン',
      title: '労働・統合担当大臣',
      position: '内閣',
      stance: '移民統合・多文化共生派',
      influence: 0.65,
      description: 'ソマリア系移民2世。移民の社会統合を強く推進。',
      faction: '緑の党',
    ),
    ScenarioCharacter(
      name: 'ペール・ユンソン',
      title: '産業・エネルギー大臣',
      position: '内閣',
      stance: 'グリーン産業転換派',
      influence: 0.7,
      description: '石油産業出身だがグリーン転換を推進。実務的で現実的。',
      faction: '中道左派',
    ),
    ScenarioCharacter(
      name: 'インゲリ・オルセン',
      title: '労働組合連盟会長',
      position: '労働運動',
      stance: '雇用と福祉重視派',
      influence: 0.6,
      description: '産業転換による失業を懸念。早期リトレーニングを要求。',
      faction: null,
    ),
    ScenarioCharacter(
      name: 'クリスティアン・ハンセン',
      title: 'ノルスランド銀行総裁',
      position: '中央銀行',
      stance: '財政規律派',
      influence: 0.65,
      description: 'インフレ・デフレ管理の専門家。福祉支出の抑制を主張。',
      faction: null,
    ),
  ],
  initialNations: [
    InitialNationRelation(
      nationName: 'スウェーデン',
      relationship: '北欧パートナー',
      standingScore: 65,
      description: '北欧隣国。文化的に非常に似ている。密接な協力関係。',
      sharedInterests: 'EUでの連携、北極圏政策',
      conflicts: 'なし',
    ),
    InitialNationRelation(
      nationName: 'デンマーク',
      relationship: '北欧パートナー',
      standingScore: 60,
      description: '北欧隣国。EU内での調整役。',
      sharedInterests: '北欧統合、気候政策',
      conflicts: 'なし',
    ),
    InitialNationRelation(
      nationName: 'ロシア',
      relationship: '地政学的対立国',
      standingScore: -25,
      description: '北極圏での領土主張。北欧として NATO加盟圧力も。',
      sharedInterests: 'なし',
      conflicts: '北極圏資源、NATOメンバーシップ',
    ),
    InitialNationRelation(
      nationName: 'ドイツ',
      relationship: 'EU主要国',
      standingScore: 55,
      description: 'EU内での最大経済国。政治的影響力も大きい。',
      sharedInterests: 'グリーン転換、EUでの協力',
      conflicts: 'なし',
    ),
  ],
  storyArcs: [
    StoryArc(
      title: '気候変動の急速化と対応',
      description: '北極圏の氷融解は現実。経済と環境のトレードオフ。',
      theme: 'economic',
      keyEvents: [
        '記録的な高温と異常気象',
        '北極航路の開通と資源開発',
        'グリーン産業への投資',
        '化石燃料企業の転換支援',
      ],
      priority: 5,
    ),
    StoryArc(
      title: '移民危機と社会統合',
      description: '難民流入増加。文化的多様性と社会統和。',
      theme: 'domestic',
      keyEvents: [
        '移民・難民の急増',
        '社会統合プログラムの成功と失敗',
        '右翼ポピュリズムの台頭',
        '言語教育と雇用機会',
      ],
      priority: 5,
    ),
    StoryArc(
      title: '福祉国家の持続可能性',
      description: '高い税率と充実した福祉。人口減少時代に耐えられるか。',
      theme: 'social',
      keyEvents: [
        '高齢化による社会保障費増加',
        '若年層の働き手不足',
        '福祉予算の削減か拡大か',
        '年金制度の改革と反発',
      ],
      priority: 4,
    ),
    StoryArc(
      title: '北極圏の地政学',
      description: 'ロシアの北極進出とNATO加盟圧力。国防と中立の選択。',
      theme: 'military',
      keyEvents: [
        'ロシアの北極軍事化',
        'NATO加盟論議の激化',
        '防衛予算の急増',
        '核戦争危機の懸念',
      ],
      priority: 3,
    ),
    StoryArc(
      title: 'グリーン経済への産業転換',
      description: 'ノーベル賞の国から次世代イノベーションの地へ。',
      theme: 'economic',
      keyEvents: [
        '石油産業からの撤出',
        '風力・水力発電の世界展開',
        'EV・クリーン技術の開発競争',
        '労働者のリトレーニングと雇用創出',
      ],
      priority: 4,
    ),
  ],
  uniqueCrises: [
    CrisisType.demonstration,
    CrisisType.economicCrisis,
    CrisisType.riot,
  ],
);
