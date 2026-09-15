/// ストーリーパック固有イベントデータ
/// 各パックに関連する危機、チャンス、ストーリー分岐

import 'package:government_simulator/models/story_pack_event.dart';

// ==================== ヨーロッパ政治危機パック ====================

final europeanCrisisEvents = <StoryPackEvent>[
  StoryPackEvent(
    id: 'ec_imf_crisis',
    packId: 'european_crisis',
    title: 'IMF救済プログラムの真価',
    description: '国際通貨基金からの救済資金受け入れが迫られるが、その条件は厳しい。',
    eventType: 'crisis',
    theme: 'economic',
    triggerYear: 1,
    triggerScenarioIds: ['ostia'],
    storyText: '''
IMFからの救済プログラムが承認されようとしています。しかし、その条件は厳しく、
公共支出の大幅削減、賃金凍結、年金改革が求められています。

国民は怒り、労働組合はストライキを準備しています。しかし、プログラムなしでは
国家債務のデフォルトは避けられません。

この決定は、あなたの政治的評判と国の長期的安定の間の緊張を象徴しています。
IMFの要求を完全に受け入れるか、交渉するか、あるいは拒否するか—
その選択は今後のすべてを左右します。
''',
    affectedIndicators: ['gdp', 'satisfaction', 'stability', 'debt'],
    impacts: {
      'accept': {'gdp': 50, 'satisfaction': -30, 'stability': 40, 'debt': -200},
      'negotiate': {'gdp': 20, 'satisfaction': -10, 'stability': 10, 'debt': -100},
      'reject': {'gdp': -100, 'satisfaction': 20, 'stability': -50, 'debt': 100},
    },
    choices: [
      StoryPackEventChoice(
        id: 'ec_imf_accept',
        title: 'IMFの条件を受け入れる',
        description: '厳しい緊縮政策を実施。国際的信用を回復するが、国民不満が高まる。',
        outcomes: {'gdp': 50, 'satisfaction': -30, 'stability': 40},
        consequenceText: '国際市場はあなたの決断を歓迎しました。しかし街中で大規模ストライキが始まった。',
        difficulty: 3,
      ),
      StoryPackEventChoice(
        id: 'ec_imf_negotiate',
        title: 'IMFと交渉する',
        description: '条件の緩和を求めて交渉を進める。時間がかかるが危険も減る。',
        outcomes: {'gdp': 20, 'satisfaction': -10, 'stability': 10},
        consequenceText: 'IMFとの交渉は進展しています。ただし、あなたの対応の遅さに批判の声も。',
        difficulty: 4,
      ),
      StoryPackEventChoice(
        id: 'ec_imf_reject',
        title: 'IMFを拒否する',
        description: '独立したやり方を選ぶ。国民の支持は得られるが、経済危機が深刻化する。',
        outcomes: {'gdp': -100, 'satisfaction': 20, 'stability': -50},
        consequenceText: '国民は喝采しましたが、国債価格が急落し、銀行が危機に直面しています。',
        difficulty: 2,
      ),
    ],
    priority: 5,
    isUnique: true,
    followUpEventId: 'ec_political_backlash',
    tags: ['economy', 'international', 'critical'],
  ),
  StoryPackEvent(
    id: 'ec_political_backlash',
    packId: 'european_crisis',
    title: '政治的反発の波',
    description: 'あなたの経済政策に対する野党と労働組合の激しい抵抗が高まる。',
    eventType: 'crisis',
    theme: 'political',
    triggerScenarioIds: ['ostia', 'amanda'],
    storyText: '''
あなたの前の決定に対する反発が日に日に高まっています。
野党指導者は議会で激しく糾弾し、労働組合は全国ストライキを呼びかけています。

新聞の見出しは「政府の裏切り」「民主主義の危機」と叫んでいます。
議会内では、あなたの支持者の中からも懸念の声が上がり始めました。

政治的危機を乗り切るには、国民とのコミュニケーションが重要です。
あなたは国民に直接訴えかけるべきか、それとも沈黙を保つべきか？
''',
    affectedIndicators: ['satisfaction', 'stability', 'nationalPower'],
    impacts: {},
    choices: [
      StoryPackEventChoice(
        id: 'ec_appeal_public',
        title: '国民に直接訴える',
        description: 'テレビ演説で国民に政策の必要性を説明。信頼が取り戻せるかもしれない。',
        outcomes: {'satisfaction': 15, 'stability': 20},
        difficulty: 3,
      ),
      StoryPackEventChoice(
        id: 'ec_negotiate_opposition',
        title: '野党と協議する',
        description: '野党指導者と秘密交渉。妥協案を探る。',
        outcomes: {'stability': 25, 'satisfaction': 5},
        difficulty: 4,
      ),
      StoryPackEventChoice(
        id: 'ec_ignore_backlash',
        title: '対立を無視する',
        description: '政策実施を続ける。短期的には政治的圧力が高まるが、成果が出れば評価される。',
        outcomes: {'stability': -20, 'satisfaction': -15},
        difficulty: 2,
      ),
    ],
    priority: 4,
    isUnique: true,
    tags: ['politics', 'domestic', 'social'],
  ),
];

// ==================== 島国政治パック ====================

final islandPoliticsEvents = <StoryPackEvent>[
  StoryPackEvent(
    id: 'ip_trade_pressure',
    packId: 'island_politics',
    title: '大国からの貿易圧力',
    description: '周辺大国があなたの国に対して貿易制裁を示唆し始めた。',
    eventType: 'crisis',
    theme: 'diplomatic',
    triggerYear: 1,
    triggerScenarioIds: ['islas'],
    storyText: '''
隣国の大国から、突然、強硬な通達が届きました。
あなたの国の独立的な対外政策が、その利益を害しているというのです。

もし応じなければ、貿易制裁と外交的孤立を示唆する文書が示されました。
あなたの国は、隣国への食料輸入を45%依存しており、これは死活的な脅威です。

島国の地政学的な脆弱性が、今、鋭く迫ってきました。
屈するのか、連携を模索するのか、それとも、他の選択肢を探すのか—
この決断があなたの国の将来を決めます。
''',
    affectedIndicators: ['gdp', 'nationalPower', 'stability'],
    impacts: {},
    choices: [
      StoryPackEventChoice(
        id: 'ip_comply',
        title: '大国の要求に応じる',
        description: '政策を修正し、大国との関係を修復。経済は安定するが独立性を損なう。',
        outcomes: {'gdp': 30, 'nationalPower': -40, 'stability': 25},
        consequenceText: 'あなたの国は経済的安定を手に入れましたが、「大国の属国」という汚名を着せられました。',
        difficulty: 3,
      ),
      StoryPackEventChoice(
        id: 'ip_resist',
        title: '抵抗する',
        description: '独立を守り、大国に対抗する。国民の誇りは高まるが、経済は苦しくなる。',
        outcomes: {'gdp': -50, 'nationalPower': 40, 'stability': -30},
        consequenceText: 'テレビは独立防衛の英雄として描きますが、食糧危機が迫ってきています。',
        difficulty: 2,
      ),
      StoryPackEventChoice(
        id: 'ip_seek_allies',
        title: '他国との同盟を模索する',
        description: '大国に対抗できる国々との連携を探る。複雑だが長期的な選択肢。',
        outcomes: {'gdp': -20, 'nationalPower': 20, 'stability': 15},
        consequenceText: '外交交渉は始まったが、各国は慎重です。あなたには時間がありません。',
        difficulty: 4,
      ),
    ],
    priority: 5,
    isUnique: true,
    followUpEventId: 'ip_alliance_forms',
    tags: ['diplomacy', 'trade', 'international'],
  ),
];

// ==================== 北欧安定パック ====================

final nordicStabilityEvents = <StoryPackEvent>[
  StoryPackEvent(
    id: 'ns_climate_crisis',
    packId: 'nordic_stability',
    title: '気候変動への挑戦',
    description: '北欧で予想外の環境変化が急速に進行。福祉国家モデルが試される。',
    eventType: 'crisis',
    theme: 'economic',
    triggerYear: 2,
    triggerScenarioIds: ['norsland'],
    storyText: '''
あなたの国の気象学者から、予想外の警告が上がってきました。
これまでのシミュレーションより20年早く、大規模な気候変動が進行しているというのです。

農業生産量は急落し、エネルギーコストは2倍に跳ね上がろうとしています。
これは、あなたの国の福祉制度—高い税金と充実した社会保障—の持続可能性に
直結した脅威です。

国民は安定を期待していますが、この危機を乗り切るには
困難な選択をしなければなりません。
''',
    affectedIndicators: ['gdp', 'satisfaction', 'stability'],
    impacts: {},
    choices: [
      StoryPackEventChoice(
        id: 'ns_green_investment',
        title: 'グリーン投資に全力投資',
        description: '再生可能エネルギーに膨大な投資。長期的には成功するが、短期的には負担。',
        outcomes: {'gdp': -30, 'stability': 35, 'satisfaction': 10},
        consequenceText: '国民は将来への希望を感じ始めましたが、今年の経済は厳しくなります。',
        difficulty: 4,
      ),
      StoryPackEventChoice(
        id: 'ns_reduce_welfare',
        title: '福祉予算を削減',
        description: '伝統的な福祉制度を削減し、予算をシフト。タブーを犯すが経済的には効率的。',
        outcomes: {'gdp': 40, 'satisfaction': -40, 'stability': -20},
        consequenceText: 'これはあなたが治めるノースランドの根本的なアイデンティティへの挑戦でした。',
        difficulty: 2,
      ),
      StoryPackEventChoice(
        id: 'ns_balanced_approach',
        title: 'バランス型アプローチ',
        description: '投資と効率化の両方を進める。時間がかかるが、持続可能。',
        outcomes: {'gdp': 5, 'satisfaction': 5, 'stability': 15},
        consequenceText: 'ゆっくりとした改革が始まりました。結果が出るまで、あなたは国民の信頼を保つ必要があります。',
        difficulty: 3,
      ),
    ],
    priority: 4,
    isUnique: true,
    tags: ['environment', 'economy', 'social'],
  ),
];

// ==================== 植民地遺産パック ====================

final colonialLegacyEvents = <StoryPackEvent>[
  StoryPackEvent(
    id: 'cl_economic_dependency',
    packId: 'colonial_legacy',
    title: '経済的依存からの脱却',
    description: 'テラノヴァの経済は依然として先進国に依存。真の独立に必要な決断を迫られる。',
    eventType: 'crisis',
    theme: 'economic',
    triggerYear: 1,
    triggerScenarioIds: ['terranova'],
    storyText: '''
経済分析が明確な現実を示しています：あなたの国の輸出の70%は、かつての宗主国と
その同盟国に依存しています。

産業基盤は弱く、技術は遅れており、独立的な経済を構築するには
数十年の投資が必要です。しかし、その投資のための資本がないのです。

目の前には三つの道があります：
1. 現状を受け入れ、関係を深化させる
2. 高いリスクを承知で、急速な産業化に投資する
3. 近隣国との地域的統合を模索する
''',
    affectedIndicators: ['gdp', 'nationalPower', 'stability'],
    impacts: {},
    choices: [
      StoryPackEventChoice(
        id: 'cl_accept_dependency',
        title: '経済的関係を深化',
        description: '先進国との関係をさらに深化。経済は成長するが、従属性が強まる。',
        outcomes: {'gdp': 50, 'nationalPower': -30, 'stability': 25},
        consequenceText: '外資が大量に流入し、経済は成長します。しかし、あなたの国は外国資本に支配されていきます。',
        difficulty: 3,
      ),
      StoryPackEventChoice(
        id: 'cl_rapid_industrialization',
        title: '急速な産業化に投資',
        description: '教育と技術開発に全力投資。成功すれば独立できるが、失敗は破滅的。',
        outcomes: {'gdp': -40, 'nationalPower': 50, 'stability': -40},
        consequenceText: 'あなたは賭けに出ました。国内は建設ラッシュ。しかし失敗のリスクは大きいです。',
        difficulty: 2,
      ),
      StoryPackEventChoice(
        id: 'cl_regional_integration',
        title: '地域統合を進める',
        description: '近隣国との経済・文化的統合。大国への依存を減らすが、自主性に課題。',
        outcomes: {'gdp': 20, 'nationalPower': 25, 'stability': 20},
        consequenceText: 'あなたの国は地域的な重要性を増していきます。しかし、各国との関係管理は複雑です。',
        difficulty: 4,
      ),
    ],
    priority: 5,
    isUnique: true,
    followUpEventId: 'cl_social_unrest',
    tags: ['economy', 'independence', 'development'],
  ),
];

/// すべてのパックイベント
final allPackEvents = <StoryPackEvent>[
  ...europeanCrisisEvents,
  ...islandPoliticsEvents,
  ...nordicStabilityEvents,
  ...colonialLegacyEvents,
];
