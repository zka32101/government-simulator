/// テラノバ共和国シナリオ
/// ラテンアメリカ・カリブ地域
/// テーマ：民主主義の危機、麻薬組織、米国の影響

library;

import 'package:government_simulator/models/scenario.dart';
import 'package:government_simulator/models/crisis.dart';

final terranovaScenario = GameScenario(
  id: 'terranova',
  countryName: 'テラノバ共和国',
  region: 'ラテンアメリカ・カリブ地域',
  description: '民主化からわずか20年。麻薬組織の暴力と政治的腐敗が民主主義を脅かす。',
  difficulty: 'very_hard',
  population: 48.0, // 4800万人
  gdp: 0.95, // $950億
  politicalSystem: '大統領制民主共和国（脆弱）',
  currency: 'テラノバ・ペソ (TNP)',
  initialApproval: 32.0,
  economicSatisfaction: 28.0,
  socialSatisfaction: 25.0,
  securitySatisfaction: 15.0,
  healthcareSatisfaction: 30.0,
  budget: 95000.0, // $950億
  nationalDebt: 280.0, // $2800億
  historicalBackground: '''
20年前の独裁体制の崩壊と民主化。最初は希望に満ちていたが、麻薬組織の権力拡大により状況が悪化。
2005年に民主化を実現したものの、麻薬戦争による暴力により毎年5000人以上が殺害されている。
警察・軍隊・司法制度が麻薬組織に浸透し、国家機能の麻痺が起きている。
米国からの麻薬取締り支援と軍事援助があるが、十分な成果を上げていない。
農民の貧困と麻薬栽培の収益性により、農村地帯では麻薬組織が実質的な支配者となっている。
  ''',
  currentChallenges: [
    '麻薬組織による暴力と支配 - 毎年5000人以上の殺害',
    '警察・司法制度の腐敗 - 麻薬組織の賄賂と脅迫',
    '政治的不安定性 - クーデターと権力奪取の危機',
    '社会的極度の不平等 - Gini係数60超え',
    '移民・難民の急増 - 米国への違法入国',
  ],
  opportunities: [
    '民主主義の再生 - 反腐敗・民主化改革',
    '米国との協力強化 - 麻薬取締り支援',
    '農村経済の転換 - コーヒーなど違法でない換金作物',
    '社会的和解と真実究明 - 暴力の根絶',
    '法の支配の確立 - 司法制度の再構築',
  ],
  characters: [
    ScenarioCharacter(
      name: 'カルロス・ロドリゲス',
      title: '大統領',
      position: '大統領府',
      stance: '麻薬戦争強硬派',
      influence: 0.75,
      description: '前の大統領から就任。麻薬組織との戦いに強い決意。しかし腐敗しやすい。',
      faction: '改革派',
    ),
    ScenarioCharacter(
      name: 'ホセ・アルバレス',
      title: '検察総長',
      position: '司法',
      stance: '反腐敗・法治主義派',
      influence: 0.65,
      description: '独立した検察官。汚職した警察官や政治家を起訴。麻薬組織から脅迫を受ける。',
      faction: '改革派',
    ),
    ScenarioCharacter(
      name: 'ルイス・メンデス',
      title: '野党党首',
      position: '野党',
      stance: '左派・社会正義派',
      influence: 0.6,
      description: 'かつての学生活動家。不平等と抑圧に対する激しい批判者。',
      faction: '保守派',
    ),
    ScenarioCharacter(
      name: 'エドゥアルド・サンチェス',
      title: '軍部総司令官',
      position: '軍部',
      stance: '秩序維持・強権派',
      influence: 0.7,
      description: 'クーデターのリスクを持つ人物。民主主義より秩序を重視。',
      faction: null,
    ),
    ScenarioCharacter(
      name: 'パトリシア・ロペス',
      title: 'NGO指導者・人権活動家',
      position: 'NGO',
      stance: '人権・民主主義擁護派',
      influence: 0.55,
      description: '麻薬戦争の被害者家族の代弁者。国際的にも知られた活動家。',
      faction: null,
    ),
    ScenarioCharacter(
      name: 'トマス・ウィルソン',
      title: '米国大使',
      position: '外交',
      stance: '対テラノバ支援・監視派',
      influence: 0.65,
      description: 'メリーダ・イニシアティブ（麻薬戦争支援）を推進。政治的影響力大。',
      faction: null,
    ),
  ],
  initialNations: [
    InitialNationRelation(
      nationName: 'アメリカ合衆国',
      relationship: '支配的な大国',
      standingScore: 40,
      description: '麻薬戦争支援と軍事援助の主要提供国。政治的影響力も大きい。',
      sharedInterests: 'テロ対策・麻薬取締り',
      conflicts: '米国の政策押し付け、主権の侵害感',
    ),
    InitialNationRelation(
      nationName: 'メキシコ',
      relationship: '北隣の麻薬戦争同盟国',
      standingScore: 35,
      description: '同じく麻薬戦争の最前線。越境犯罪と人身売買が課題。',
      sharedInterests: '麻薬組織対策、治安維持',
      conflicts: 'なし',
    ),
    InitialNationRelation(
      nationName: 'コロンビア',
      relationship: 'コカイン麻薬供給源',
      standingScore: -15,
      description: 'コカイン生産の源地。麻薬組織ネットワークの中心。',
      sharedInterests: 'なし',
      conflicts: '麻薬密売、越境テロ',
    ),
    InitialNationRelation(
      nationName: 'ラテンアメリカ諸国',
      relationship: '地域パートナー',
      standingScore: 25,
      description: 'ブラジル・アルゼンチン・チリなど。地域統合の試み。',
      sharedInterests: '地域統合、共同治安対策',
      conflicts: 'なし',
    ),
  ],
  storyArcs: [
    StoryArc(
      title: '麻薬戦争と暴力の根絶',
      description: '麻薬組織の絶滅か共存か。米国支援の効果。',
      theme: 'military',
      keyEvents: [
        '麻薬組織指導者の逮捕・殺害',
        '大規模銃撃戦と市民被害',
        '脱獄と逆転の危機',
        '国際的な麻薬取締り協力',
      ],
      priority: 5,
    ),
    StoryArc(
      title: '汚職と司法制度の改革',
      description: '警察と司法の浄化。腐敗した公務員との戦い。',
      theme: 'domestic',
      keyEvents: [
        '汚職警察官の逮捕',
        '検察総長暗殺未遂事件',
        '司法制度改革とコスト',
        '国際的な監視と支援',
      ],
      priority: 5,
    ),
    StoryArc(
      title: '民主主義の生存',
      description: 'クーデター危機。軍部と文民統制。',
      theme: 'military',
      keyEvents: [
        '軍部によるクーデター未遂',
        '緊急体制と民主的手続きの緊張',
        '国際的な民主主義支援',
        'クーデター派勢力の鎮圧',
      ],
      priority: 5,
    ),
    StoryArc(
      title: '社会的不平等と貧困',
      description: '極度の格差。上流階級と下層民の分断。',
      theme: 'social',
      keyEvents: [
        'スラムでの貧困と暴力',
        '農民のコカイン栽培への依存',
        '教育・医療インフラの崩壊',
        '社会的和解と発展プログラム',
      ],
      priority: 4,
    ),
    StoryArc(
      title: 'US支援と主権のバランス',
      description: 'アメリカ軍顧問の駐留。属国化の危機か必要な支援か。',
      theme: 'diplomatic',
      keyEvents: [
        'メリーダ・イニシアティブの強化',
        'US軍事顧問団の派遣',
        '主権侵害への国民的反発',
        '自主的な対麻薬組織戦略',
      ],
      priority: 3,
    ),
  ],
  uniqueCrises: [
    CrisisType.riot,
    CrisisType.militaryCoup,
    CrisisType.demonstration,
  ],
);
