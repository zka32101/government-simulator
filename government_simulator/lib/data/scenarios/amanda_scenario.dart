/// アマンダ共和国シナリオ
/// アフリカ中部・サハラ以南地域
/// テーマ：資源紛争、内戦危機、国家建設

library;

import 'package:government_simulator/models/scenario.dart';
import 'package:government_simulator/models/crisis.dart';

final amandaScenario = GameScenario(
  id: 'amanda',
  countryName: 'アマンダ共和国',
  region: 'アフリカ・サハラ以南',
  description: 'ダイヤモンドなど豊富な天然資源を持つ発展途上国。内戦勃発の危機と汚職の蔓延が課題。',
  difficulty: 'hard',
  population: 28.0, // 2800万人
  gdp: 0.65, // $650億
  politicalSystem: '大統領制共和国（不安定）',
  currency: 'アマンダ・フラン (AF)',
  initialApproval: 38.0,
  economicSatisfaction: 35.0,
  socialSatisfaction: 30.0,
  securitySatisfaction: 25.0,
  healthcareSatisfaction: 20.0,
  budget: 65000.0, // $650億
  nationalDebt: 12.0, // $120億（多くは国際機関への返済）
  historicalBackground: '''
15年前の独立戦争で独立した若い国家。ダイヤモンド鉱山など豊富な天然資源を保有。
しかし資源の富は支配層と外国企業に独占され、一般市民の生活水準は上がらない。
前政権の強圧的統治と汚職により社会不安が高まっている。
民族紛争の歴史があり、族間対立が常に潜在的な危険要因。
  ''',
  currentChallenges: [
    '貧困と不平等 - 国民の60%が貧困線以下',
    '汚職の蔓延 - 資源収益の横領と利権構造',
    '族間対立の危機 - 複数の民族グループの対立',
    '医療・教育の崩壊 - 識字率40%、乳幼児死亡率高い',
    'テロリスト集団の活動 - 北部でのゲリラ活動',
  ],
  opportunities: [
    'ダイヤモンド産業の透明化 - 資源収益の有効活用',
    '国際支援プログラム - 先進国からの援助と技術移転',
    'インフラ投資 - 資源を活用した国家建設',
    '民族和解と平和構築 - 長期的な社会安定化',
    '地域統合 - アフリカ連合との協力強化',
  ],
  characters: [
    ScenarioCharacter(
      name: 'ジャスティン・カバラ',
      title: 'エネルギー資源大臣',
      position: '内閣',
      stance: '資源開発推進派',
      influence: 0.85,
      description: '外国企業との契約交渉を仕切る。汚職疑惑が絶えない。個人的な利益優先。',
      faction: '支配層',
    ),
    ScenarioCharacter(
      name: 'ドミニク・アベベ',
      title: '野党党首',
      position: '野党（民主運動）',
      stance: '反汚職・平等推進派',
      influence: 0.7,
      description: '若き指導者。資源の公正配分と民主化を掲げる。若者から熱い支持。',
      faction: '改革派',
    ),
    ScenarioCharacter(
      name: 'イサイア・ムベンベ',
      title: 'マジョリティ民族指導者',
      position: '民族組織',
      stance: '民族優先主義',
      influence: 0.65,
      description: '大多数派民族の利益代弁者。族間対立を扇動することもある危険人物。',
      faction: null,
    ),
    ScenarioCharacter(
      name: 'シスター・マリア',
      title: '医療・人道支援指導者',
      position: 'NGO',
      stance: '民間人福祉派',
      influence: 0.55,
      description: '国際NGO連盟の代表。医療と教育改革を強く主張。政府への批判的。',
      faction: null,
    ),
    ScenarioCharacter(
      name: 'ジェラール・シェンバ',
      title: '軍部最高司令官',
      position: '軍部',
      stance: '秩序維持・強権派',
      influence: 0.7,
      description: 'テロ対策の名目で独裁的統治を求める。クーデター候補者。',
      faction: '支配層',
    ),
    ScenarioCharacter(
      name: 'ジェームス・ブラウン',
      title: '国際鉱業企業CEO',
      position: '外国企業',
      stance: '利益最優先',
      influence: 0.6,
      description: 'アメリカの大手鉱業企業代表。政治家への影響力大。',
      faction: null,
    ),
  ],
  initialNations: [
    InitialNationRelation(
      nationName: '南アフリカ連邦',
      relationship: '友好国・経済的主導国',
      standingScore: 50,
      description: '経済規模の大きい隣国。投資と貿易の主要パートナー。',
      sharedInterests: '地域経済統合、アフリカンユニオン内での協力',
      conflicts: '労働力流出、環境問題',
    ),
    InitialNationRelation(
      nationName: 'フランス共和国',
      relationship: '旧宗主国・経済的影響国',
      standingScore: 25,
      description: 'かつての植民地支配国。引き続き政治・経済的影響力を保持。',
      sharedInterests: 'フランス語圏での協力、資源採掘権',
      conflicts: '新植民地主義への批判、資源所有権',
    ),
    InitialNationRelation(
      nationName: '中国',
      relationship: '新興経済的パートナー',
      standingScore: 35,
      description: 'インフラ投資と資源購入者。しかし労働搾取疑惑も。',
      sharedInterests: 'ダイヤモンド採掘、インフラ建設',
      conflicts: '労働条件、技術移転',
    ),
    InitialNationRelation(
      nationName: 'ルワンダ',
      relationship: '隣国（不安定）',
      standingScore: 10,
      description: 'すぐ北隣。難民流出と武装勢力の越境が課題。',
      sharedInterests: '地域平和構築',
      conflicts: '難民問題、越境犯罪',
    ),
  ],
  storyArcs: [
    StoryArc(
      title: '資源の呪い：富と汚職',
      description: 'ダイヤモンド産業の利益を誰が独占するか。透明性か私腹か。',
      theme: 'economic',
      keyEvents: [
        '鉱業企業との契約交渉：利益配分',
        '汚職スキャンダルの爆発',
        'IMF・世銀の監視と調査',
        '資源の国有化vs民営化の選択',
      ],
      priority: 5,
    ),
    StoryArc(
      title: '内戦危機の回避',
      description: ' 族間対立の激化を抑制し、国家統和を実現できるか。',
      theme: 'military',
      keyEvents: [
        '少数民族グループの反乱',
        '軍部によるクーデター未遂',
        'テロリスト集団による攻撃',
        '和平協議と国家統和',
      ],
      priority: 5,
    ),
    StoryArc(
      title: '民主化と人権',
      description: '抑圧的な統治から民主的な体制へ。野党と改革派の力',
      theme: 'domestic',
      keyEvents: [
        '野党による民主化デモ',
        '選挙の透明性と自由',
        '人権団体による圧力',
        '憲法改正と権力の制限',
      ],
      priority: 4,
    ),
    StoryArc(
      title: '医療・教育の危機的状況',
      description: '国民の基本的ニーズ。投資か汚職か。',
      theme: 'social',
      keyEvents: [
        '医療施設建設と医者不足',
        'コレラなどの伝染病流行',
        '初等教育の無料化',
        '識字率向上プログラム',
      ],
      priority: 4,
    ),
    StoryArc(
      title: '国際的信用と開発援助',
      description: 'IMF・世銀との関係。外国資本と独立性の葛藤。',
      theme: 'diplomatic',
      keyEvents: [
        'IMF支援プログラムの受け入れ',
        '先進国からの援助の条件',
        '地域統合と貿易ブロック',
        '南アフリカとの経済的従属',
      ],
      priority: 3,
    ),
  ],
  uniqueCrises: [
    CrisisType.demonstration,
    CrisisType.riot,
    CrisisType.militaryCoup,
  ],
);
