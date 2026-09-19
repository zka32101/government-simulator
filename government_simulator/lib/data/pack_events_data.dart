/// ストーリーパック固有イベントデータ
/// 各パックに関連する危機、チャンス、ストーリー分岐
library;

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
  StoryPackEvent(
    id: 'ec_referendum_call',
    packId: 'european_crisis',
    title: '信任を問う国民投票',
    description: '野党があなたの経済政策への信任を問う国民投票の実施を要求している。',
    eventType: 'decision_point',
    theme: 'political',
    triggerYear: 3,
    triggerScenarioIds: ['ostia', 'amanda'],
    storyText: '''
経済政策をめぐる対立は膠着状態に陥りました。野党は「国民に直接信を問うべきだ」として
国民投票の実施を要求し、街頭では連日デモが続いています。

応じれば、勝てば強い政治的正統性を得られますが、負ければ即座に退陣を迫られるでしょう。
拒否すれば「独裁的」との批判を浴びますが、政治的な安定は保てるかもしれません。

あなたの決断は、残りの任期の性格を決定づけることになります。
''',
    affectedIndicators: ['satisfaction', 'stability', 'nationalPower'],
    impacts: {},
    choices: [
      StoryPackEventChoice(
        id: 'ec_referendum_accept',
        title: '国民投票を実施する',
        description: '正面から信を問う。勝てば大きな追い風になるが、賭けでもある。',
        outcomes: {'satisfaction': 20, 'stability': -10, 'nationalPower': 15},
        consequenceText: '投票は接戦の末、僅差であなたの政策が支持されました。しかし国は真っ二つに割れたままです。',
        difficulty: 4,
      ),
      StoryPackEventChoice(
        id: 'ec_referendum_refuse',
        title: '国民投票を拒否する',
        description: '議会制民主主義の手続きを盾に拒否する。安定は保てるが批判は避けられない。',
        outcomes: {'satisfaction': -15, 'stability': 15, 'nationalPower': -5},
        consequenceText: '「民意を恐れる政権」という見出しが新聞に躍りましたが、政局は落ち着きを取り戻しつつあります。',
        difficulty: 2,
      ),
      StoryPackEventChoice(
        id: 'ec_referendum_compromise',
        title: '限定的な諮問投票に落とし込む',
        description: '法的拘束力のない諮問的な投票として実施し、双方の顔を立てる。',
        outcomes: {'satisfaction': 5, 'stability': 10, 'nationalPower': 0},
        consequenceText: '玉虫色の決着に両陣営とも不満げですが、街頭の熱気は少しずつ冷めていきました。',
        difficulty: 3,
      ),
    ],
    priority: 3,
    isUnique: true,
    tags: ['politics', 'democracy', 'referendum'],
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
  StoryPackEvent(
    id: 'ip_alliance_forms',
    packId: 'island_politics',
    title: '小国連合の呼びかけ',
    description: '同じように大国の圧力に苦しむ島嶼国から、共同戦線を張る提案が届く。',
    eventType: 'opportunity',
    theme: 'diplomatic',
    triggerScenarioIds: ['islas'],
    storyText: '''
あなたの対応が国際的に注目を集める中、同じ海域の島嶼国数カ国から連絡が入りました。
彼らもまた、同じ大国からの圧力に苦しんでいるといいます。

「一国では抗えなくとも、共に立てば交渉力を持てる」——そう呼びかける小国連合の構想が
持ち上がっています。参加すれば発言力は増しますが、外交的な足並みを揃える難しさもあります。

この機会を活かすか、独自路線を貫くか。あなたの選択が、島国外交の今後の形を決めます。
''',
    affectedIndicators: ['nationalPower', 'stability', 'gdp'],
    impacts: {},
    choices: [
      StoryPackEventChoice(
        id: 'ip_join_coalition',
        title: '小国連合に参加する',
        description: '共同戦線に加わり、集団交渉力を得る。国内の意思決定の自由度は下がる。',
        outcomes: {'nationalPower': 30, 'stability': 15, 'gdp': 10},
        consequenceText: '連合の一員として、あなたの国は初めて大国と対等な交渉テーブルに着きました。',
        difficulty: 3,
      ),
      StoryPackEventChoice(
        id: 'ip_lead_coalition',
        title: '連合の主導権を取りに行く',
        description: '積極的に連合をまとめ上げる立場に立つ。成功すれば影響力は大きいが、失敗のリスクも高い。',
        outcomes: {'nationalPower': 45, 'stability': -10, 'gdp': -10},
        consequenceText: 'あなたはこの海域の小国外交の顔になりつつあります。しかし国内では「他国の面倒まで見る余裕はない」との声も。',
        difficulty: 5,
      ),
      StoryPackEventChoice(
        id: 'ip_decline_coalition',
        title: '独自路線を貫く',
        description: '連合には加わらず、二国間交渉に徹する。身軽だが孤立のリスクがある。',
        outcomes: {'nationalPower': -10, 'stability': 10, 'gdp': 5},
        consequenceText: '短期的な安定は保てましたが、次に危機が来たとき、あなたの国はまた一人で立ち向かうことになります。',
        difficulty: 2,
      ),
    ],
    priority: 4,
    isUnique: true,
    tags: ['diplomacy', 'alliance', 'international'],
  ),
  StoryPackEvent(
    id: 'ip_offshore_discovery',
    packId: 'island_politics',
    title: '海底資源の発見',
    description: '領海内で大規模な海底資源が発見され、開発をめぐる思惑が渦巻く。',
    eventType: 'opportunity',
    theme: 'economic',
    triggerYear: 3,
    triggerScenarioIds: ['islas'],
    storyText: '''
調査船からの報告に、閣議室がどよめきました。あなたの国の排他的経済水域内で、
大規模なレアメタル鉱床が発見されたというのです。

国営で開発すれば富は国民に還元されますが、技術も資金も不足しています。
外資を導入すれば早期に開発できますが、利益の多くは国外に流出するでしょう。

隣接する海域を主張する国もあり、この発見は新たな緊張の火種にもなりかねません。
''',
    affectedIndicators: ['gdp', 'nationalPower', 'stability'],
    impacts: {},
    choices: [
      StoryPackEventChoice(
        id: 'ip_state_development',
        title: '国営で開発する',
        description: '時間はかかるが、利益をすべて国内に還元できる。',
        outcomes: {'gdp': 15, 'nationalPower': 20, 'stability': 5},
        consequenceText: '開発は遅々として進みませんが、国民は「自分たちの資源」という誇りを感じています。',
        difficulty: 3,
      ),
      StoryPackEventChoice(
        id: 'ip_foreign_investment',
        title: '外資を導入する',
        description: '急速に開発が進むが、利益の大半は国外へ。国内から批判の声も。',
        outcomes: {'gdp': 45, 'nationalPower': -15, 'stability': -5},
        consequenceText: '経済指標は急上昇しましたが、「資源を売り渡した」という批判がSNSで拡散しています。',
        difficulty: 2,
      ),
      StoryPackEventChoice(
        id: 'ip_shared_development',
        title: '周辺国との共同開発を提案する',
        description: '領海紛争のリスクを外交で先回りして解消する。開発の速度は遅い。',
        outcomes: {'gdp': 20, 'nationalPower': 10, 'stability': 20},
        consequenceText: '共同開発の枠組みは、思いがけず地域の緊張緩和にもつながりました。',
        difficulty: 4,
      ),
    ],
    priority: 3,
    isUnique: true,
    tags: ['economy', 'resources', 'territory'],
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
    followUpEventId: 'ns_reform_debate',
    tags: ['environment', 'economy', 'social'],
  ),
  StoryPackEvent(
    id: 'ns_reform_debate',
    packId: 'nordic_stability',
    title: '福祉モデル改革論争',
    description: '気候対応の余波で、福祉国家モデルそのものの持続可能性が国会で議論される。',
    eventType: 'decision_point',
    theme: 'social',
    triggerScenarioIds: ['norsland'],
    storyText: '''
気候危機への対応を経て、国民の間で率直な議論が始まりました。
「このままの福祉モデルを維持できるのか」——長年タブー視されてきた問いが、
ついに国会の場で公然と議論されています。

若い世代は柔軟な制度改革を求め、高齢者層は既存の保障の維持を訴えます。
世代間の対立が、これまで誇ってきた社会的合意の基盤を揺るがし始めています。

あなたには、この論争に決着をつける機会と責任があります。
''',
    affectedIndicators: ['satisfaction', 'stability'],
    impacts: {},
    choices: [
      StoryPackEventChoice(
        id: 'ns_gradual_reform',
        title: '段階的な制度改革を進める',
        description: '時間をかけて合意形成しながら制度を調整する。急進的な反発は避けられる。',
        outcomes: {'satisfaction': 10, 'stability': 20},
        consequenceText: '改革は遅々としていますが、世代を超えた対話の場が生まれ始めています。',
        difficulty: 3,
      ),
      StoryPackEventChoice(
        id: 'ns_preserve_model',
        title: '既存モデルを堅持する',
        description: '福祉国家の伝統を守り抜くと宣言する。安心感はあるが、財政の持続可能性に不安が残る。',
        outcomes: {'satisfaction': 20, 'stability': -10},
        consequenceText: '国民は歓迎しましたが、財務省からは将来の財政悪化への強い懸念が示されています。',
        difficulty: 2,
      ),
      StoryPackEventChoice(
        id: 'ns_bold_overhaul',
        title: '抜本的な制度刷新に踏み切る',
        description: '北欧モデルを次世代型に大胆に作り替える。大きな反発を覚悟する必要がある。',
        outcomes: {'satisfaction': -20, 'stability': 25},
        consequenceText: '街では抗議デモが起きましたが、制度は驚くほど早く新しい均衡に落ち着き始めました。',
        difficulty: 5,
      ),
    ],
    priority: 3,
    isUnique: true,
    tags: ['social', 'welfare', 'generational'],
  ),
  StoryPackEvent(
    id: 'ns_immigration_wave',
    packId: 'nordic_stability',
    title: '移民の波と社会統合',
    description: '近隣地域の不安定化を受け、これまでにない規模の移民・難民が押し寄せる。',
    eventType: 'crisis',
    theme: 'social',
    triggerYear: 1,
    triggerScenarioIds: ['norsland'],
    storyText: '''
近隣地域の政情不安を受け、あなたの国に移民・難民申請が急増しています。
その数は過去最大規模で、既存の受け入れ体制の限界をはるかに超えています。

人道的な受け入れを求める声がある一方、住宅・雇用・治安への不安から
受け入れ制限を求める声も日増しに強まっています。

北欧の寛容さの象徴として知られてきたあなたの国の対応が、世界から注視されています。
''',
    affectedIndicators: ['satisfaction', 'stability', 'gdp'],
    impacts: {},
    choices: [
      StoryPackEventChoice(
        id: 'ns_open_doors',
        title: '積極的に受け入れる',
        description: '人道的な立場を貫き、大規模な受け入れ体制を整える。財政負担と社会摩擦は増える。',
        outcomes: {'satisfaction': -10, 'stability': -15, 'gdp': -15},
        consequenceText: '国際社会はあなたの決断を称賛しましたが、地方都市では住宅不足が深刻化しています。',
        difficulty: 4,
      ),
      StoryPackEventChoice(
        id: 'ns_restrict_intake',
        title: '受け入れを大幅に制限する',
        description: '国境管理を強化し、受け入れ数を抑制する。国内は落ち着くが、国際的批判を浴びる。',
        outcomes: {'satisfaction': 10, 'stability': 10, 'gdp': 5},
        consequenceText: '国内の不安は和らぎましたが、「北欧モデルの終わり」と国際メディアに書き立てられました。',
        difficulty: 2,
      ),
      StoryPackEventChoice(
        id: 'ns_managed_integration',
        title: '受け入れつつ統合政策に投資する',
        description: '受け入れ数は維持しつつ、語学教育・就労支援に大規模投資する。効果は数年後。',
        outcomes: {'satisfaction': -5, 'stability': 5, 'gdp': -10},
        consequenceText: '短期的な負担は大きいですが、地域社会では新しい住民との協働が少しずつ始まっています。',
        difficulty: 4,
      ),
    ],
    priority: 4,
    isUnique: true,
    tags: ['social', 'immigration', 'integration'],
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
  StoryPackEvent(
    id: 'cl_social_unrest',
    packId: 'colonial_legacy',
    title: '格差への怒り',
    description: '経済路線の選択がもたらした恩恵の偏りに、都市部と地方の間で不満が爆発する。',
    eventType: 'crisis',
    theme: 'social',
    triggerScenarioIds: ['terranova'],
    storyText: '''
あなたの経済政策は数字の上では成果を上げつつありますが、その恩恵は
一部の都市部エリートに集中しているという調査結果が公表されました。

地方では依然として貧困が深刻で、「独立とは誰のためのものだったのか」という
怒りの声がSNSと路上の両方で広がっています。大規模なデモの噂も流れています。

この格差にどう向き合うかが、あなたの政権の正統性を左右します。
''',
    affectedIndicators: ['satisfaction', 'stability', 'gdp'],
    impacts: {},
    choices: [
      StoryPackEventChoice(
        id: 'cl_redistribute',
        title: '再分配政策を強化する',
        description: '都市部から地方への財政移転を大幅に増やす。成長率は下がるが不満は和らぐ。',
        outcomes: {'satisfaction': 20, 'stability': 15, 'gdp': -15},
        consequenceText: '地方からは歓迎の声が上がりましたが、投資家からは「バラマキだ」との批判も出ています。',
        difficulty: 3,
      ),
      StoryPackEventChoice(
        id: 'cl_stay_course',
        title: '現行路線を維持する',
        description: '成長優先の路線を崩さない。いずれ恩恵は波及すると説明する。',
        outcomes: {'satisfaction': -20, 'stability': -20, 'gdp': 15},
        consequenceText: '経済指標は好調を保っていますが、地方都市では抗議の炎が上がり始めました。',
        difficulty: 2,
      ),
      StoryPackEventChoice(
        id: 'cl_targeted_programs',
        title: '地域を絞った重点投資を行う',
        description: '最も困窮した地域に絞って集中的に投資する。効果は限定的だが持続可能。',
        outcomes: {'satisfaction': 8, 'stability': 10, 'gdp': -5},
        consequenceText: '劇的な変化ではありませんが、対象地域では確かな手応えが生まれ始めています。',
        difficulty: 4,
      ),
    ],
    priority: 4,
    isUnique: true,
    tags: ['social', 'inequality', 'domestic'],
  ),
  StoryPackEvent(
    id: 'cl_heritage_dispute',
    packId: 'colonial_legacy',
    title: '文化遺産をめぐる対立',
    description: '旧宗主国が、植民地時代に持ち去られた文化財の返還交渉を持ちかけてくる。',
    eventType: 'plot_twist',
    theme: 'diplomatic',
    triggerYear: 3,
    triggerScenarioIds: ['terranova'],
    storyText: '''
思いがけない申し出が旧宗主国から届きました。植民地時代に持ち去られた
数百点の文化財について、返還交渉に応じる用意があるというのです。

ただし条件があります——見返りとして、資源開発における優遇的な権益を求めています。
国民感情としては文化財の返還を強く望む声が大きい一方、
その代償として国の資源主権に踏み込ませることへの懸念も根強くあります。

この交渉の行方が、あなたの国のアイデンティティと経済の両面に影響します。
''',
    affectedIndicators: ['satisfaction', 'nationalPower', 'gdp'],
    impacts: {},
    choices: [
      StoryPackEventChoice(
        id: 'cl_accept_exchange',
        title: '条件をのんで返還を受け入れる',
        description: '資源権益を譲る代わりに文化財を取り戻す。国民感情は満たされるが経済的代償は大きい。',
        outcomes: {'satisfaction': 25, 'nationalPower': -15, 'gdp': -10},
        consequenceText: '博物館に文化財が戻った日、多くの国民が涙を流しました。しかし資源相は渋い顔をしています。',
        difficulty: 3,
      ),
      StoryPackEventChoice(
        id: 'cl_reject_exchange',
        title: '条件を拒否し無条件返還を求める',
        description: '資源主権は譲らず、無条件での返還を粘り強く要求する。交渉は長引く。',
        outcomes: {'satisfaction': -5, 'nationalPower': 15, 'gdp': 0},
        consequenceText: '交渉は決裂に近い状態ですが、あなたの毅然とした姿勢は国内で評価されています。',
        difficulty: 4,
      ),
      StoryPackEventChoice(
        id: 'cl_partial_deal',
        title: '一部の権益に限定して合意する',
        description: '譲る権益を最小限に絞り込み、部分的な返還で折り合いをつける。',
        outcomes: {'satisfaction': 10, 'nationalPower': -5, 'gdp': -3},
        consequenceText: '完全な決着ではありませんが、双方が受け入れ可能な現実的な合意にたどり着きました。',
        difficulty: 3,
      ),
    ],
    priority: 3,
    isUnique: true,
    tags: ['diplomacy', 'culture', 'identity'],
  ),
];

/// すべてのパックイベント
final allPackEvents = <StoryPackEvent>[
  ...europeanCrisisEvents,
  ...islandPoliticsEvents,
  ...nordicStabilityEvents,
  ...colonialLegacyEvents,
];
