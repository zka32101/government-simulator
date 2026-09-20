import 'package:government_simulator/models/event.dart';
import 'package:government_simulator/models/faction.dart';

class EventDatabase {
  static List<GameEvent> getAllEvents() => [
    ..._economicEvents,
    ..._employmentEvents,
    ..._socialEvents,
    ..._politicalEvents,
    ..._environmentalEvents,
    ..._externalShockEvents,
    ..._militaryEvents,
  ];

  // =====================
  // 経済系イベント (14件)
  // =====================
  static final List<GameEvent> _economicEvents = [
    GameEvent(
      id: 'eco_01_tax_reform',
      title: '税制改革の岐路',
      description: '財務大臣が税制改革案を提出しました。\n国庫の立て直しか、国民負担の軽減か。',
      category: EventCategory.economic,
      weight: 4,
      choices: [
        Choice(
          id: 'eco_01_a',
          text: '所得税を増税する',
          shortDescription: '財政安定↑ | 満足度↓ | GDP↓',
          impact: Impact(gdpChange: -1.2, satisfactionChange: -18, stabilityChange: 10, inflationChange: -0.5, publicDebtChange: -4.0),
        ),
        Choice(
          id: 'eco_01_b',
          text: '法人税を減税する',
          shortDescription: '投資↑ | GDP↑ | 格差↑ | 財源なき減税',
          impact: Impact(gdpChange: 2.5, satisfactionChange: -8, nationalPowerChange: 5, stabilityChange: -5, publicDebtChange: 3.0),
        ),
        Choice(
          id: 'eco_01_c',
          text: '消費税を引き上げる',
          shortDescription: '財政収入↑ | 消費↓ | 低所得層打撃',
          impact: Impact(gdpChange: -0.8, satisfactionChange: -22, stabilityChange: 8, inflationChange: 1.5, publicDebtChange: -5.0),
        ),
        Choice(
          id: 'eco_01_d',
          text: '税制を現状維持する',
          shortDescription: '変化なし | 問題先送り',
          impact: Impact(stabilityChange: -3),
        ),
      ],
    ),

    GameEvent(
      id: 'eco_02_trade_deal',
      title: '大型貿易協定の交渉',
      description: '近隣大国から貿易協定の締結を提案されました。\n国内産業を守るか、市場を開放して成長を狙うか。',
      category: EventCategory.economic,
      weight: 3,
      choices: [
        Choice(
          id: 'eco_02_a',
          text: '協定を締結する',
          shortDescription: 'GDP↑↑ | 輸出↑ | 国内産業圧迫',
          impact: Impact(gdpChange: 3.5, nationalPowerChange: 8, unemploymentChange: 1.5, satisfactionChange: 5),
        ),
        Choice(
          id: 'eco_02_b',
          text: '保護主義的条件を交渉する',
          shortDescription: 'GDP↑ | 関係改善 | 時間がかかる',
          impact: Impact(gdpChange: 1.2, nationalPowerChange: 3, stabilityChange: 5),
        ),
        Choice(
          id: 'eco_02_c',
          text: '協定を拒否する',
          shortDescription: '国内産業保護 | 外交関係↓',
          impact: Impact(gdpChange: -1.0, nationalPowerChange: -5, satisfactionChange: 8, stabilityChange: 5),
        ),
      ],
    ),

    GameEvent(
      id: 'eco_03_central_bank',
      title: '中央銀行の金利決定',
      description: 'インフレが加速しつつあります。\n中央銀行が金利変更について政府の意向を伺っています。',
      category: EventCategory.economic,
      weight: 3,
      choices: [
        Choice(
          id: 'eco_03_a',
          text: '金利を大幅引き上げ',
          shortDescription: 'インフレ抑制 | 投資↓ | 景気冷却',
          impact: Impact(gdpChange: -2.0, inflationChange: -2.5, unemploymentChange: 1.0, stabilityChange: 8),
        ),
        Choice(
          id: 'eco_03_b',
          text: '小幅な引き上げにとどめる',
          shortDescription: 'バランス重視 | 緩やかな調整',
          impact: Impact(gdpChange: -0.5, inflationChange: -1.0, stabilityChange: 3),
        ),
        Choice(
          id: 'eco_03_c',
          text: '金利を現状維持する',
          shortDescription: '経済成長維持 | インフレリスク',
          impact: Impact(gdpChange: 1.0, inflationChange: 0.8, satisfactionChange: 5),
        ),
      ],
    ),

    GameEvent(
      id: 'eco_04_infrastructure',
      title: '大規模インフラ投資計画',
      description: '老朽化したインフラの整備計画が浮上しています。\n短期的なコストと長期的な経済効果のバランスは？',
      category: EventCategory.economic,
      weight: 3,
      choices: [
        Choice(
          id: 'eco_04_a',
          text: '大規模投資を承認する',
          shortDescription: '雇用↑ | GDP↑↑(遅延) | 財政赤字↑',
          impact: Impact(gdpChange: 1.5, unemploymentChange: -2.0, satisfactionChange: 12, stabilityChange: 8, nationalPowerChange: 5, publicDebtChange: 7.0),
        ),
        Choice(
          id: 'eco_04_b',
          text: '段階的な投資に縮小する',
          shortDescription: '財政負担軽減 | 効果は中程度',
          impact: Impact(gdpChange: 0.5, unemploymentChange: -0.8, satisfactionChange: 5, stabilityChange: 4, publicDebtChange: 2.5),
        ),
        Choice(
          id: 'eco_04_c',
          text: '民間に委託する',
          shortDescription: 'コスト削減 | 公共性↓',
          impact: Impact(gdpChange: 0.8, satisfactionChange: -5, stabilityChange: 2, publicDebtChange: -1.0),
        ),
      ],
    ),

    GameEvent(
      id: 'eco_05_startup_ecosystem',
      title: 'スタートアップ支援政策',
      description: '若い起業家たちが革新的なビジネスを起こしています。\n政府として支援するか、自由な市場に任せるか。',
      category: EventCategory.economic,
      weight: 2,
      choices: [
        Choice(
          id: 'eco_05_a',
          text: '起業家支援基金を創設する',
          shortDescription: 'イノベーション↑ | 長期GDP↑',
          impact: Impact(gdpChange: 0.8, nationalPowerChange: 6, satisfactionChange: 10, unemploymentChange: -1.0),
        ),
        Choice(
          id: 'eco_05_b',
          text: '規制緩和で民間を促進する',
          shortDescription: '自由市場化 | 一部リスク増大',
          impact: Impact(gdpChange: 1.5, nationalPowerChange: 4, stabilityChange: -5, satisfactionChange: 6),
        ),
        Choice(
          id: 'eco_05_c',
          text: '既存産業を優先する',
          shortDescription: '安定性重視 | イノベーション↓',
          impact: Impact(stabilityChange: 5, gdpChange: -0.3, nationalPowerChange: -3),
        ),
      ],
    ),

    GameEvent(
      id: 'eco_06_housing_crisis',
      title: '住宅価格高騰',
      description: '都市部の住宅価格が急騰し、若い世代が家を持てない状況です。\n住宅問題への対処を迫られています。',
      category: EventCategory.economic,
      weight: 3,
      choices: [
        Choice(
          id: 'eco_06_a',
          text: '公共住宅を大量建設する',
          shortDescription: '満足度↑ | 財政支出増加',
          impact: Impact(satisfactionChange: 20, gdpChange: 0.8, unemploymentChange: -1.5, stabilityChange: 8),
        ),
        Choice(
          id: 'eco_06_b',
          text: '住宅ローン減税を実施する',
          shortDescription: '購入需要↑ | 価格さらに上昇リスク',
          impact: Impact(satisfactionChange: 12, gdpChange: 0.5, inflationChange: 0.8),
        ),
        Choice(
          id: 'eco_06_c',
          text: '外国人不動産購入を制限する',
          shortDescription: '価格安定 | 外資流入↓',
          impact: Impact(satisfactionChange: 15, gdpChange: -0.5, nationalPowerChange: -3),
        ),
      ],
    ),

    GameEvent(
      id: 'eco_07_digital_currency',
      title: '中央銀行デジタル通貨(CBDC)の導入',
      description: '多くの国がデジタル通貨を導入しています。\n我が国も追随すべきか検討が始まりました。',
      category: EventCategory.economic,
      weight: 2,
      choices: [
        Choice(
          id: 'eco_07_a',
          text: 'CBDCを積極的に導入する',
          shortDescription: '金融革新↑ | 国際競争力↑ | リスクあり',
          impact: Impact(gdpChange: 1.2, nationalPowerChange: 8, satisfactionChange: -5, stabilityChange: -8),
        ),
        Choice(
          id: 'eco_07_b',
          text: '試験的に一部導入する',
          shortDescription: '段階的移行 | リスク低減',
          impact: Impact(gdpChange: 0.5, nationalPowerChange: 4, stabilityChange: 2),
        ),
        Choice(
          id: 'eco_07_c',
          text: '現時点では導入しない',
          shortDescription: '安定性重視 | 競争力↓',
          impact: Impact(stabilityChange: 5, nationalPowerChange: -3),
        ),
      ],
    ),

    GameEvent(
      id: 'eco_08_debt_crisis',
      title: '財政赤字の深刻化',
      description: '国の借金が増え続けています。\n国債格付けが下落するリスクが高まっています。',
      category: EventCategory.economic,
      weight: 2,
      choices: [
        Choice(
          id: 'eco_08_a',
          text: '緊縮財政を断行する',
          shortDescription: '財政健全化↑↑ | 景気↓ | 満足度↓↓',
          impact: Impact(gdpChange: -2.5, satisfactionChange: -25, stabilityChange: 12, unemploymentChange: 2.0, publicDebtChange: -18.0),
        ),
        Choice(
          id: 'eco_08_b',
          text: '成長で乗り越える戦略をとる',
          shortDescription: 'GDP↑目標 | リスク継続 | 債務は増加継続',
          impact: Impact(gdpChange: 2.0, nationalPowerChange: 3, stabilityChange: -10, publicDebtChange: 4.0),
        ),
        Choice(
          id: 'eco_08_c',
          text: 'IMFに支援を要請する',
          shortDescription: '緊急支援・債務再編 | 主権制約 | 信頼↓',
          impact: Impact(stabilityChange: 15, satisfactionChange: -30, nationalPowerChange: -15, gdpChange: -1.0, publicDebtChange: -10.0),
        ),
      ],
    ),

    GameEvent(
      id: 'eco_09_wealth_tax',
      title: '富裕層への課税強化',
      description: '格差問題が深刻化する中、富裕層への追加課税が議題に上がっています。',
      category: EventCategory.economic,
      weight: 3,
      choices: [
        Choice(
          id: 'eco_09_a',
          text: '富裕税を新設する',
          shortDescription: '格差改善 | 資本逃避リスク | 財政収入↑',
          impact: Impact(satisfactionChange: 18, gdpChange: -0.8, stabilityChange: 5, nationalPowerChange: -3, publicDebtChange: -6.0),
        ),
        Choice(
          id: 'eco_09_b',
          text: 'キャピタルゲイン税を強化する',
          shortDescription: 'バランス型 | 投資意欲↓',
          impact: Impact(satisfactionChange: 10, gdpChange: -0.4, stabilityChange: 3, publicDebtChange: -3.0),
        ),
        Choice(
          id: 'eco_09_c',
          text: '課税強化を見送る',
          shortDescription: '投資家支持↑ | 格差継続',
          impact: Impact(gdpChange: 0.5, satisfactionChange: -8, nationalPowerChange: 2),
          promiseTarget: Faction.business,
        ),
      ],
    ),

    GameEvent(
      id: 'eco_10_export_boost',
      title: '輸出産業の振興策',
      description: '為替と競争力の問題で輸出が伸び悩んでいます。\n輸出産業への支援策を議論しています。',
      category: EventCategory.economic,
      weight: 2,
      choices: [
        Choice(
          id: 'eco_10_a',
          text: '輸出補助金を拡大する',
          shortDescription: '輸出↑ | WTO問題リスク',
          impact: Impact(gdpChange: 2.0, unemploymentChange: -1.0, nationalPowerChange: 5, stabilityChange: -3),
        ),
        Choice(
          id: 'eco_10_b',
          text: '為替介入を行う',
          shortDescription: '競争力↑ | 国際摩擦リスク',
          impact: Impact(gdpChange: 1.5, nationalPowerChange: -3, inflationChange: 1.0),
        ),
        Choice(
          id: 'eco_10_c',
          text: '技術革新で競争力を高める',
          shortDescription: '長期的効果↑ | 即効性なし',
          impact: Impact(gdpChange: 0.3, nationalPowerChange: 6, stabilityChange: 5),
        ),
      ],
    ),

    GameEvent(
      id: 'eco_11_stock_crash',
      title: '株式市場の暴落',
      description: '国内株式市場が一日で急落し、パニック売りが広がっています。\n年金基金や個人投資家の資産が急速に目減りしています。',
      category: EventCategory.economic,
      weight: 1,
      choices: [
        Choice(
          id: 'eco_11_a',
          text: '公的資金で市場に介入する',
          shortDescription: '市場安定化 | 財政負担 | モラルハザード批判',
          impact: Impact(gdpChange: -0.5, satisfactionChange: 5, stabilityChange: 6, inflationChange: 0.5),
        ),
        Choice(
          id: 'eco_11_b',
          text: '取引を一時停止し様子を見る',
          shortDescription: '時間を稼ぐ | 不透明感が残る',
          impact: Impact(gdpChange: -1.5, satisfactionChange: -8, stabilityChange: -3),
        ),
        Choice(
          id: 'eco_11_c',
          text: '市場原理に任せ介入しない',
          shortDescription: '財政健全性維持 | 資産減少で不満増大',
          impact: Impact(gdpChange: -2.5, satisfactionChange: -15, unemploymentChange: 0.5, stabilityChange: -6),
        ),
      ],
    ),

    GameEvent(
      id: 'eco_12_crypto_bubble',
      title: '仮想通貨バブルの崩壊',
      description: '国内で急拡大していた仮想通貨市場が暴落し、多くの個人投資家が損失を被りました。\n規制の是非が問われています。',
      category: EventCategory.economic,
      weight: 2,
      choices: [
        Choice(
          id: 'eco_12_a',
          text: '仮想通貨取引を厳格に規制する',
          shortDescription: '将来のリスク低減 | 投資家・業界の反発',
          impact: Impact(gdpChange: -0.8, satisfactionChange: -5, nationalPowerChange: -3, stabilityChange: 6),
        ),
        Choice(
          id: 'eco_12_b',
          text: '被害者救済に公的資金を投入する',
          shortDescription: '国民の安心感↑ | 財政負担 | モラルハザード懸念',
          impact: Impact(gdpChange: -0.3, satisfactionChange: 12, publicDebtChange: 3.5, stabilityChange: 2),
        ),
        Choice(
          id: 'eco_12_c',
          text: '自己責任として静観する',
          shortDescription: '財政負担なし | 「無策」との批判',
          impact: Impact(satisfactionChange: -12, stabilityChange: -4),
        ),
      ],
    ),

    GameEvent(
      id: 'eco_13_privatization',
      title: '国営企業の民営化論争',
      description: '非効率が指摘されてきた国営企業について、民営化を求める声が経済界から強まっています。',
      category: EventCategory.economic,
      weight: 2,
      choices: [
        Choice(
          id: 'eco_13_a',
          text: '主要国営企業を全面民営化する',
          shortDescription: '効率化・財政収入↑ | 雇用不安・料金高騰リスク',
          impact: Impact(gdpChange: 2.0, satisfactionChange: -10, unemploymentChange: 1.0, publicDebtChange: -6.0),
          promiseTarget: Faction.business,
        ),
        Choice(
          id: 'eco_13_b',
          text: '部分的な株式売却にとどめる',
          shortDescription: '穏健な改革 | 効果は限定的',
          impact: Impact(gdpChange: 0.8, satisfactionChange: -2, publicDebtChange: -2.0),
        ),
        Choice(
          id: 'eco_13_c',
          text: '国営を維持し経営改革のみ行う',
          shortDescription: '雇用維持 | 財政負担は継続',
          impact: Impact(satisfactionChange: 6, stabilityChange: 3, publicDebtChange: 1.0),
        ),
      ],
    ),

    GameEvent(
      id: 'eco_14_supply_chain',
      title: 'サプライチェーンの寸断',
      description: '世界的な物流混乱と部品不足により、国内製造業の生産ラインが相次いで停止しています。',
      category: EventCategory.economic,
      weight: 2,
      choices: [
        Choice(
          id: 'eco_14_a',
          text: '国内生産回帰（リショアリング）を補助する',
          shortDescription: '長期的な強靭性↑ | 短期コスト増 | 雇用↑',
          impact: Impact(gdpChange: -0.5, unemploymentChange: -1.0, nationalPowerChange: 6, publicDebtChange: 2.5),
        ),
        Choice(
          id: 'eco_14_b',
          text: '複数の調達先を緊急開拓する',
          shortDescription: '迅速だがコスト増 | リスク分散',
          impact: Impact(gdpChange: -1.0, inflationChange: 1.2, stabilityChange: 3),
        ),
        Choice(
          id: 'eco_14_c',
          text: '企業の自助努力に任せる',
          shortDescription: '財政負担なし | 生産停止が長期化',
          impact: Impact(gdpChange: -2.2, unemploymentChange: 1.5, satisfactionChange: -10),
        ),
      ],
    ),
  ];

  // =====================
  // 雇用系イベント (9件)
  // =====================
  static final List<GameEvent> _employmentEvents = [
    GameEvent(
      id: 'emp_01_automation',
      title: 'AI・自動化の波',
      description: 'AIと自動化技術が急速に普及し、多くの職業が脅威にさらされています。\n政府としての対応が迫られています。',
      category: EventCategory.employment,
      weight: 4,
      choices: [
        Choice(
          id: 'emp_01_a',
          text: '職業訓練プログラムを大規模展開',
          shortDescription: '再教育 | 中長期で雇用改善',
          impact: Impact(unemploymentChange: -1.5, satisfactionChange: 15, gdpChange: -0.5, nationalPowerChange: 5),
        ),
        Choice(
          id: 'emp_01_b',
          text: '自動化税を課し財源を確保',
          shortDescription: 'BI財源確保 | テック企業反発',
          impact: Impact(unemploymentChange: -0.5, satisfactionChange: 8, gdpChange: -1.0, nationalPowerChange: -2),
        ),
        Choice(
          id: 'emp_01_c',
          text: '規制緩和で自動化を促進する',
          shortDescription: 'GDP↑ | 雇用喪失↑ | 長期競争力↑',
          impact: Impact(gdpChange: 2.5, unemploymentChange: 3.0, nationalPowerChange: 8, satisfactionChange: -20),
        ),
        Choice(
          id: 'emp_01_d',
          text: 'ベーシックインカムを試験導入',
          shortDescription: '格差縮小 | 財政負担大',
          impact: Impact(satisfactionChange: 22, unemploymentChange: -1.0, gdpChange: -1.5, stabilityChange: 8),
        ),
      ],
    ),

    GameEvent(
      id: 'emp_02_minimum_wage',
      title: '最低賃金の大幅引き上げ',
      description: '労働組合が最低賃金30%引き上げを要求しています。\n経営者団体は雇用削減を警告しています。',
      category: EventCategory.employment,
      weight: 3,
      choices: [
        Choice(
          id: 'emp_02_a',
          text: '要求通り大幅引き上げを承認',
          shortDescription: '低賃金層満足度↑↑ | 中小企業圧迫',
          impact: Impact(satisfactionChange: 25, unemploymentChange: 1.5, gdpChange: 0.5, stabilityChange: -5),
          promiseTarget: Faction.labor,
        ),
        Choice(
          id: 'emp_02_b',
          text: '段階的に引き上げる（3年計画）',
          shortDescription: 'バランス型 | 労使双方が妥協',
          impact: Impact(satisfactionChange: 12, unemploymentChange: 0.5, gdpChange: 0.3, stabilityChange: 5),
        ),
        Choice(
          id: 'emp_02_c',
          text: '引き上げを拒否する',
          shortDescription: '企業側支持 | 労働者不満↑',
          impact: Impact(satisfactionChange: -18, gdpChange: 1.0, unemploymentChange: -0.5, stabilityChange: -8),
        ),
      ],
    ),

    GameEvent(
      id: 'emp_03_immigration',
      title: '移民労働者政策の見直し',
      description: '労働力不足が深刻化しています。\n移民受け入れ拡大か、国内労働力育成かの選択を迫られています。',
      category: EventCategory.employment,
      weight: 3,
      choices: [
        Choice(
          id: 'emp_03_a',
          text: '移民受け入れを大幅拡大する',
          shortDescription: '労働力↑ | GDP↑ | 社会統合コスト↑',
          impact: Impact(unemploymentChange: -2.5, gdpChange: 2.0, satisfactionChange: -10, nationalPowerChange: 5),
        ),
        Choice(
          id: 'emp_03_b',
          text: '高度技術者のみ受け入れる',
          shortDescription: '技術力↑ | 低スキル不足継続',
          impact: Impact(unemploymentChange: -1.0, gdpChange: 1.2, nationalPowerChange: 8, satisfactionChange: 5),
        ),
        Choice(
          id: 'emp_03_c',
          text: '移民規制を強化する',
          shortDescription: '社会統一性↑ | 労働力↓ | GDP↓',
          impact: Impact(satisfactionChange: 15, gdpChange: -1.5, unemploymentChange: 1.0, nationalPowerChange: -3),
        ),
      ],
    ),

    GameEvent(
      id: 'emp_04_gig_economy',
      title: 'ギグエコノミーの規制',
      description: 'フリーランスや非正規雇用が急増し、社会保障の網の目から外れる人が増えています。',
      category: EventCategory.employment,
      weight: 2,
      choices: [
        Choice(
          id: 'emp_04_a',
          text: 'ギグワーカーに正規雇用並みの保護',
          shortDescription: '労働者保護↑ | 企業コスト↑ | 雇用↓',
          impact: Impact(satisfactionChange: 18, gdpChange: -0.8, unemploymentChange: 1.0, stabilityChange: 8),
        ),
        Choice(
          id: 'emp_04_b',
          text: '柔軟な中間的保護制度を創設',
          shortDescription: '折衷案 | 双方が妥協',
          impact: Impact(satisfactionChange: 10, gdpChange: 0.2, stabilityChange: 5),
        ),
        Choice(
          id: 'emp_04_c',
          text: '規制せず市場に委ねる',
          shortDescription: '企業自由度↑ | 格差↑',
          impact: Impact(gdpChange: 1.5, satisfactionChange: -12, unemploymentChange: -0.5),
        ),
      ],
    ),

    GameEvent(
      id: 'emp_05_public_sector',
      title: '公務員採用の拡大・縮小',
      description: '失業率改善のため公務員を大幅増員する案と、効率化のため削減する案が対立しています。',
      category: EventCategory.employment,
      weight: 2,
      choices: [
        Choice(
          id: 'emp_05_a',
          text: '公務員を大幅増員する',
          shortDescription: '失業↓ | 財政負担↑ | 効率↓',
          impact: Impact(unemploymentChange: -2.0, satisfactionChange: 15, gdpChange: -1.0, stabilityChange: 5),
        ),
        Choice(
          id: 'emp_05_b',
          text: 'AI活用で公務を効率化する',
          shortDescription: '効率↑ | 公務員雇用↓',
          impact: Impact(gdpChange: 0.5, unemploymentChange: 1.0, nationalPowerChange: 5, satisfactionChange: -5),
        ),
        Choice(
          id: 'emp_05_c',
          text: '現状の人員体制を維持する',
          shortDescription: 'バランス維持',
          impact: Impact(stabilityChange: 3),
        ),
      ],
    ),

    GameEvent(
      id: 'emp_06_work_life',
      title: '週4日労働制の導入',
      description: '生産性向上と労働者の幸福のため、週4日労働制を試験導入する国が増えています。\n我が国でも議論が始まりました。',
      category: EventCategory.employment,
      weight: 2,
      choices: [
        Choice(
          id: 'emp_06_a',
          text: '全国規模で週4日制を導入',
          shortDescription: '満足度↑↑ | 生産性影響未知',
          impact: Impact(satisfactionChange: 28, gdpChange: -0.5, stabilityChange: 8, nationalPowerChange: -2),
        ),
        Choice(
          id: 'emp_06_b',
          text: '希望企業のみ試験導入を認可',
          shortDescription: '柔軟対応 | データ収集',
          impact: Impact(satisfactionChange: 12, gdpChange: 0.2, stabilityChange: 5),
        ),
        Choice(
          id: 'emp_06_c',
          text: '現行の週5日制を維持する',
          shortDescription: '生産性維持 | 時代遅れのリスク',
          impact: Impact(gdpChange: 0.3, satisfactionChange: -8),
        ),
      ],
    ),

    GameEvent(
      id: 'emp_07_remote_work',
      title: 'リモートワークの大転換',
      description: '在宅勤務を恒久化する企業が急増し、オフィス街の空洞化と働き方の分断が進んでいます。',
      category: EventCategory.employment,
      weight: 2,
      choices: [
        Choice(
          id: 'emp_07_a',
          text: 'リモートワークを法的権利として保障する',
          shortDescription: '労働者満足度↑ | 都市部経済への打撃',
          impact: Impact(satisfactionChange: 14, gdpChange: -0.5, stabilityChange: -2),
          promiseTarget: Faction.labor,
        ),
        Choice(
          id: 'emp_07_b',
          text: 'オフィス回帰を企業に促す優遇策を導入する',
          shortDescription: '都市経済維持 | 労働者の反発',
          impact: Impact(gdpChange: 1.0, satisfactionChange: -10, nationalPowerChange: 2),
        ),
        Choice(
          id: 'emp_07_c',
          text: '企業の判断に委ねる',
          shortDescription: '介入なし | 分断が固定化',
          impact: Impact(stabilityChange: -3),
        ),
      ],
    ),

    GameEvent(
      id: 'emp_08_general_strike',
      title: '労働組合のゼネスト警告',
      description: '賃上げと待遇改善を求める労働組合連合が、応じなければ全国規模のストライキも辞さないと通告してきました。',
      category: EventCategory.employment,
      weight: 2,
      choices: [
        Choice(
          id: 'emp_08_a',
          text: '要求をほぼ全面的に受け入れる',
          shortDescription: '労働者満足度↑↑ | 企業負担増・GDP↓',
          impact: Impact(satisfactionChange: 18, gdpChange: -1.5, unemploymentChange: 0.5, stabilityChange: 5),
          promiseTarget: Faction.labor,
        ),
        Choice(
          id: 'emp_08_b',
          text: '部分的な譲歩で妥協点を探る',
          shortDescription: 'バランス型 | 双方に不満残る',
          impact: Impact(satisfactionChange: 5, gdpChange: -0.3, stabilityChange: 2),
        ),
        Choice(
          id: 'emp_08_c',
          text: '要求を拒否し法的措置も辞さない構えを見せる',
          shortDescription: '財界の支持↑ | ストライキ決行のリスク',
          impact: Impact(satisfactionChange: -20, nationalPowerChange: -3, stabilityChange: -8),
        ),
      ],
    ),

    GameEvent(
      id: 'emp_09_elderly_employment',
      title: '高齢者雇用延長の義務化論争',
      description: '年金財政の悪化を受け、企業に70歳までの雇用延長を義務付ける法案が検討されています。',
      category: EventCategory.employment,
      weight: 2,
      choices: [
        Choice(
          id: 'emp_09_a',
          text: '雇用延長を義務化する',
          shortDescription: '年金負担↓ | 若年層の雇用機会減少への懸念',
          impact: Impact(satisfactionChange: 6, unemploymentChange: 0.8, publicDebtChange: -2.0, stabilityChange: 2),
        ),
        Choice(
          id: 'emp_09_b',
          text: '企業への補助金で緩やかに促す',
          shortDescription: '穏健な移行 | 財政負担あり',
          impact: Impact(satisfactionChange: 4, publicDebtChange: 1.5),
        ),
        Choice(
          id: 'emp_09_c',
          text: '現行の年金制度・定年を維持する',
          shortDescription: '変化なし | 年金財政の悪化は継続',
          impact: Impact(stabilityChange: -4, publicDebtChange: -1.0),
        ),
      ],
    ),
  ];

  // =====================
  // 社会系イベント (9件)
  // =====================
  static final List<GameEvent> _socialEvents = [
    GameEvent(
      id: 'soc_01_education_reform',
      title: '教育制度の抜本改革',
      description: '国際競争力低下に危機感を持つ教育省が抜本的な改革案を提案しました。',
      category: EventCategory.social,
      weight: 3,
      choices: [
        Choice(
          id: 'soc_01_a',
          text: 'STEM教育に全面転換する',
          shortDescription: '技術力↑ | 人文科学↓',
          impact: Impact(nationalPowerChange: 10, gdpChange: 0.5, satisfactionChange: -5, stabilityChange: -3),
        ),
        Choice(
          id: 'soc_01_b',
          text: '教師の待遇を大幅改善する',
          shortDescription: '教育質↑ | 長期的効果 | 財政支出↑',
          impact: Impact(satisfactionChange: 15, stabilityChange: 8, gdpChange: -0.3, nationalPowerChange: 5),
        ),
        Choice(
          id: 'soc_01_c',
          text: '大学無償化を実現する',
          shortDescription: '機会平等↑ | 財政負担大',
          impact: Impact(satisfactionChange: 25, gdpChange: -1.0, nationalPowerChange: 8, unemploymentChange: -1.0),
        ),
        Choice(
          id: 'soc_01_d',
          text: '民間教育機関に委ねる',
          shortDescription: 'コスト削減 | 格差拡大',
          impact: Impact(gdpChange: 0.5, satisfactionChange: -10, stabilityChange: -5),
        ),
      ],
    ),

    GameEvent(
      id: 'soc_02_healthcare',
      title: '医療制度の危機',
      description: '高齢化で医療費が急増し、制度の持続可能性が問われています。',
      category: EventCategory.social,
      weight: 3,
      choices: [
        Choice(
          id: 'soc_02_a',
          text: '医療費を大幅増額する',
          shortDescription: '医療質↑ | 財政悪化',
          impact: Impact(satisfactionChange: 22, gdpChange: -1.5, stabilityChange: 5, nationalPowerChange: 3, publicDebtChange: 6.0),
        ),
        Choice(
          id: 'soc_02_b',
          text: '予防医療に転換して効率化',
          shortDescription: '長期的コスト↓ | 即効性なし',
          impact: Impact(satisfactionChange: 8, gdpChange: 0.2, stabilityChange: 6, nationalPowerChange: 5, publicDebtChange: 1.0),
        ),
        Choice(
          id: 'soc_02_c',
          text: '自己負担割合を引き上げる',
          shortDescription: '財政改善 | 満足度↓↓',
          impact: Impact(satisfactionChange: -25, stabilityChange: 10, gdpChange: -0.5, publicDebtChange: -4.0),
        ),
      ],
    ),

    GameEvent(
      id: 'soc_03_aging',
      title: '急速な少子高齢化',
      description: '出生率が過去最低を記録し、高齢化が加速しています。\n中長期的な対策が不可欠です。',
      category: EventCategory.social,
      weight: 3,
      choices: [
        Choice(
          id: 'soc_03_a',
          text: '子育て支援を大幅強化する',
          shortDescription: '出生率↑(長期) | 財政負担↑',
          impact: Impact(satisfactionChange: 18, gdpChange: -0.8, nationalPowerChange: 4, stabilityChange: 5),
        ),
        Choice(
          id: 'soc_03_b',
          text: '年金受給年齢を引き上げる',
          shortDescription: '財政改善 | 高齢層反発',
          impact: Impact(stabilityChange: 10, satisfactionChange: -20, gdpChange: 0.5, nationalPowerChange: 2),
        ),
        Choice(
          id: 'soc_03_c',
          text: 'ロボット・AI活用で労働力補填',
          shortDescription: '生産性↑ | 高額投資必要',
          impact: Impact(gdpChange: 1.5, nationalPowerChange: 8, unemploymentChange: 1.0, satisfactionChange: 5),
        ),
      ],
    ),

    GameEvent(
      id: 'soc_04_inequality',
      title: '格差問題と社会不満の高まり',
      description: '所得格差が拡大し、街では抗議デモが起きています。\n格差解消に向けた政策が求められています。',
      category: EventCategory.social,
      weight: 3,
      choices: [
        Choice(
          id: 'soc_04_a',
          text: '富の再分配政策を強化する',
          shortDescription: '格差↓ | 低所得層満足↑ | 富裕層反発',
          impact: Impact(satisfactionChange: 20, gdpChange: -0.5, stabilityChange: 8, nationalPowerChange: -2),
          promiseTarget: Faction.citizen,
        ),
        Choice(
          id: 'soc_04_b',
          text: '経済成長で底上げを図る',
          shortDescription: 'トリクルダウン | 格差継続リスク',
          impact: Impact(gdpChange: 2.0, satisfactionChange: 5, unemploymentChange: -1.0, stabilityChange: -3),
        ),
        Choice(
          id: 'soc_04_c',
          text: '社会対話の場を設ける',
          shortDescription: '即効性低 | 長期信頼醸成',
          impact: Impact(satisfactionChange: 8, stabilityChange: 10, nationalPowerChange: 3),
        ),
      ],
    ),

    GameEvent(
      id: 'soc_05_media',
      title: 'フェイクニュース問題',
      description: 'SNS上でのフェイクニュース拡散が社会的混乱を引き起こしています。\n規制か表現の自由か。',
      category: EventCategory.social,
      weight: 2,
      choices: [
        Choice(
          id: 'soc_05_a',
          text: 'SNS規制法を制定する',
          shortDescription: '社会安定↑ | 表現の自由↓',
          impact: Impact(stabilityChange: 12, satisfactionChange: -10, nationalPowerChange: -5),
        ),
        Choice(
          id: 'soc_05_b',
          text: 'メディアリテラシー教育を強化',
          shortDescription: '根本解決志向 | 時間がかかる',
          impact: Impact(nationalPowerChange: 5, satisfactionChange: 5, stabilityChange: 5),
        ),
        Choice(
          id: 'soc_05_c',
          text: 'プラットフォームの自主規制に任せる',
          shortDescription: '規制最小化 | 混乱継続',
          impact: Impact(satisfactionChange: -5, stabilityChange: -5, gdpChange: 0.3),
        ),
      ],
    ),

    GameEvent(
      id: 'soc_06_epidemic',
      title: '地方都市での疫病集団感染',
      description: '地方の都市で原因不明の伝染病が集団発生し、急速に広がっています。\n医療体制が逼迫しています。',
      category: EventCategory.social,
      weight: 1,
      choices: [
        Choice(
          id: 'soc_06_a',
          text: '都市封鎖と医療資源の集中投入',
          shortDescription: '感染拡大防止 | 経済的損失 | 医療費増',
          impact: Impact(gdpChange: -2.0, satisfactionChange: -8, unemploymentChange: 1.0, stabilityChange: 3),
        ),
        Choice(
          id: 'soc_06_b',
          text: '情報公開を最小限に抑え混乱を回避',
          shortDescription: '短期混乱回避 | 感染拡大リスク | 隠蔽との批判',
          impact: Impact(satisfactionChange: -20, stabilityChange: -12, gdpChange: 0.5),
        ),
        Choice(
          id: 'soc_06_c',
          text: '国際医療機関と連携して対応',
          shortDescription: '専門知見を活用 | 主体性やや低下 | 信頼回復',
          impact: Impact(satisfactionChange: 8, nationalPowerChange: -3, stabilityChange: 5, gdpChange: -0.8),
        ),
      ],
    ),

    GameEvent(
      id: 'soc_07_religious_tension',
      title: '宗教・信仰をめぐる社会対立',
      description: '公共施設での宗教的シンボルの扱いをめぐり、異なる信仰を持つ市民の間で対立が激化しています。',
      category: EventCategory.social,
      weight: 1,
      choices: [
        Choice(
          id: 'soc_07_a',
          text: '公共空間での宗教的表現を制限する（世俗主義の徹底）',
          shortDescription: '一部から強い支持 | 信仰者コミュニティの反発',
          impact: Impact(satisfactionChange: -6, stabilityChange: -4, nationalPowerChange: 2),
        ),
        Choice(
          id: 'soc_07_b',
          text: '多様な信仰の共存を積極的に推進する',
          shortDescription: '寛容な社会像 | 保守層からの反発',
          impact: Impact(satisfactionChange: 5, stabilityChange: -3),
        ),
        Choice(
          id: 'soc_07_c',
          text: '対話の場を設け当面は現状を維持する',
          shortDescription: '穏健だが根本解決にはならない',
          impact: Impact(stabilityChange: 2),
        ),
      ],
    ),

    GameEvent(
      id: 'soc_08_minority_rights',
      title: '少数民族・言語政策の見直し',
      description: '国内の少数民族コミュニティから、言語教育と文化的権利の公的保障を求める声が強まっています。',
      category: EventCategory.social,
      weight: 1,
      choices: [
        Choice(
          id: 'soc_08_a',
          text: '少数言語教育を公的に保障する',
          shortDescription: '多様性尊重↑ | 統合を懸念する層の反発',
          impact: Impact(satisfactionChange: 8, stabilityChange: -3, publicDebtChange: 1.0),
          promiseTarget: Faction.citizen,
        ),
        Choice(
          id: 'soc_08_b',
          text: '国語教育を優先し統合を重視する',
          shortDescription: '一体感を重視 | 少数派の疎外感増大',
          impact: Impact(satisfactionChange: -8, stabilityChange: 3, nationalPowerChange: 2),
        ),
        Choice(
          id: 'soc_08_c',
          text: '地域ごとの裁量に委ねる',
          shortDescription: '中央の摩擦を回避 | 地域差が拡大',
          impact: Impact(stabilityChange: 1),
        ),
      ],
    ),

    GameEvent(
      id: 'soc_09_social_media_mental_health',
      title: 'SNS依存と若者のメンタルヘルス',
      description: 'SNSの長時間利用と若年層のメンタルヘルス悪化の関連が専門家から指摘され、規制論が高まっています。',
      category: EventCategory.social,
      weight: 2,
      choices: [
        Choice(
          id: 'soc_09_a',
          text: '未成年のSNS利用を法規制する',
          shortDescription: '保護者からの支持 | 若者・IT業界の反発',
          impact: Impact(satisfactionChange: 6, gdpChange: -0.4, nationalPowerChange: -2, stabilityChange: 3),
        ),
        Choice(
          id: 'soc_09_b',
          text: '学校教育でのメディアリテラシーを強化する',
          shortDescription: '穏健な対応 | 効果は緩やか',
          impact: Impact(satisfactionChange: 4, publicDebtChange: 1.0),
        ),
        Choice(
          id: 'soc_09_c',
          text: '企業の自主規制に任せる',
          shortDescription: '介入なし | 問題の放置との批判',
          impact: Impact(satisfactionChange: -6, stabilityChange: -2),
        ),
      ],
    ),
  ];

  // =====================
  // 政治系イベント (8件)
  // =====================
  static final List<GameEvent> _politicalEvents = [
    GameEvent(
      id: 'pol_01_corruption',
      title: '政府高官の汚職疑惑',
      description: '政府高官が汚職に関与しているとの疑惑が浮上しました。\nどう対処しますか？',
      category: EventCategory.political,
      weight: 2,
      choices: [
        Choice(
          id: 'pol_01_a',
          text: '即座に調査委員会を設置する',
          shortDescription: '透明性↑ | 政権ダメージあり',
          impact: Impact(satisfactionChange: 15, stabilityChange: -5, nationalPowerChange: 3),
        ),
        Choice(
          id: 'pol_01_b',
          text: '内部調査にとどめる',
          shortDescription: 'ダメージ最小化 | 信頼性低下',
          impact: Impact(satisfactionChange: -15, stabilityChange: 5, nationalPowerChange: -5),
        ),
        Choice(
          id: 'pol_01_c',
          text: '疑惑を否定して続投させる',
          shortDescription: '短期安定 | 発覚時に壊滅的ダメージ',
          impact: Impact(satisfactionChange: -25, stabilityChange: -15, nationalPowerChange: -10),
        ),
      ],
    ),

    GameEvent(
      id: 'pol_02_election_reform',
      title: '選挙制度改革',
      description: '現行の小選挙区制への不満が高まり、比例代表制への移行を求める声があります。',
      category: EventCategory.political,
      weight: 2,
      choices: [
        Choice(
          id: 'pol_02_a',
          text: '比例代表制に移行する',
          shortDescription: '民意反映↑ | 政治安定↓',
          impact: Impact(satisfactionChange: 15, stabilityChange: -8, nationalPowerChange: 3),
        ),
        Choice(
          id: 'pol_02_b',
          text: '混合制を採用する',
          shortDescription: '折衷案 | 複雑な制度',
          impact: Impact(satisfactionChange: 8, stabilityChange: 3),
        ),
        Choice(
          id: 'pol_02_c',
          text: '現行制度を維持する',
          shortDescription: '安定性維持 | 民意反映↓',
          impact: Impact(stabilityChange: 8, satisfactionChange: -10),
        ),
      ],
    ),

    GameEvent(
      id: 'pol_03_press_freedom',
      title: 'メディアの独立性問題',
      description: '国営メディアへの介入疑惑が国際社会から批判を受けています。',
      category: EventCategory.political,
      weight: 2,
      choices: [
        Choice(
          id: 'pol_03_a',
          text: 'メディア独立性を完全に保障する',
          shortDescription: '国際評価↑ | 政権批判増加',
          impact: Impact(nationalPowerChange: 10, satisfactionChange: 12, stabilityChange: -5),
        ),
        Choice(
          id: 'pol_03_b',
          text: '影響を維持しつつ形式的に改善',
          shortDescription: '批判継続 | リスク先送り',
          impact: Impact(nationalPowerChange: -3, satisfactionChange: -5, stabilityChange: 5),
        ),
        Choice(
          id: 'pol_03_c',
          text: 'メディア規制を強化する',
          shortDescription: '政権安定 | 民主主義指数↓',
          impact: Impact(stabilityChange: 12, nationalPowerChange: -15, satisfactionChange: -15),
        ),
      ],
    ),

    GameEvent(
      id: 'pol_04_decentralization',
      title: '地方分権の推進',
      description: '地方自治体が独自政策の権限拡大を求めています。\n中央集権か地方分権かの選択です。',
      category: EventCategory.political,
      weight: 2,
      choices: [
        Choice(
          id: 'pol_04_a',
          text: '大幅な権限委譲を実施',
          shortDescription: '地方活性化 | 政策格差拡大',
          impact: Impact(satisfactionChange: 15, gdpChange: 0.8, stabilityChange: -5, nationalPowerChange: -3),
        ),
        Choice(
          id: 'pol_04_b',
          text: '段階的に権限を移譲する',
          shortDescription: '慎重なアプローチ',
          impact: Impact(satisfactionChange: 8, stabilityChange: 3, gdpChange: 0.3),
        ),
        Choice(
          id: 'pol_04_c',
          text: '中央集権体制を維持する',
          shortDescription: '統一性維持 | 地方の不満↑',
          impact: Impact(stabilityChange: 8, satisfactionChange: -10, nationalPowerChange: 3),
        ),
      ],
    ),

    GameEvent(
      id: 'pol_05_coalition_collapse',
      title: '連立政権の崩壊危機',
      description: '連立を組む政党が政策方針の対立から離脱を示唆しています。\n政権の存続が危ぶまれています。',
      category: EventCategory.political,
      weight: 2,
      choices: [
        Choice(
          id: 'pol_05_a',
          text: '連立相手に大幅譲歩し政権を維持',
          shortDescription: '政権安定 | 独自政策の後退',
          impact: Impact(stabilityChange: 10, satisfactionChange: -5, nationalPowerChange: -5),
        ),
        Choice(
          id: 'pol_05_b',
          text: '少数与党として単独運営に踏み切る',
          shortDescription: '政策の自由度↑ | 政局不安定化',
          impact: Impact(stabilityChange: -12, satisfactionChange: 3, nationalPowerChange: -3),
        ),
        Choice(
          id: 'pol_05_c',
          text: '解散総選挙に打って出る',
          shortDescription: '民意に信を問う | 短期的混乱 | 結果次第で大きく変動',
          impact: Impact(stabilityChange: -8, satisfactionChange: 8, gdpChange: -0.5),
        ),
      ],
    ),

    GameEvent(
      id: 'pol_06_constitution',
      title: '憲法改正論争',
      description: '与党内から憲法改正を求める声が強まり、国を二分する議論に発展しています。',
      category: EventCategory.political,
      weight: 1,
      choices: [
        Choice(
          id: 'pol_06_a',
          text: '改正案を国会に提出し議論を進める',
          shortDescription: '支持層の結集 | 国論分裂のリスク',
          impact: Impact(nationalPowerChange: 6, satisfactionChange: -8, stabilityChange: -6),
        ),
        Choice(
          id: 'pol_06_b',
          text: '国民的合意ができるまで議論を続ける',
          shortDescription: '慎重だが「決められない政治」との批判も',
          impact: Impact(stabilityChange: 2, satisfactionChange: -2),
        ),
        Choice(
          id: 'pol_06_c',
          text: '改正論議を凍結する',
          shortDescription: '対立回避 | 改正派からの強い不満',
          impact: Impact(stabilityChange: 4, satisfactionChange: -4, nationalPowerChange: -3),
        ),
      ],
    ),

    GameEvent(
      id: 'pol_07_opposition_scandal',
      title: '野党指導者のスキャンダル発覚',
      description: '最大野党の指導者に金銭スキャンダルが発覚し、政界全体に激震が走っています。対応が問われます。',
      category: EventCategory.political,
      weight: 2,
      choices: [
        Choice(
          id: 'pol_07_a',
          text: '徹底追及し政治的優位を最大限利用する',
          shortDescription: '短期的な支持率↑ | 「政治利用」との批判リスク',
          impact: Impact(satisfactionChange: 10, nationalPowerChange: 4, stabilityChange: -3),
        ),
        Choice(
          id: 'pol_07_b',
          text: '司法の判断に委ね静観する',
          shortDescription: '公正な印象 | 政治的な機会損失',
          impact: Impact(stabilityChange: 3),
        ),
        Choice(
          id: 'pol_07_c',
          text: '「政治全体の信頼回復」を訴え自らも身を引く姿勢を示す',
          shortDescription: '高潔なイメージ | 支持層の一部が困惑',
          impact: Impact(satisfactionChange: 5, nationalPowerChange: -4, stabilityChange: 5),
        ),
      ],
    ),

    GameEvent(
      id: 'pol_08_special_prosecutor',
      title: '特別検察官の任命要求',
      description: '政権に近い企業への便宜供与疑惑を受け、独立した特別検察官の任命を求める声が強まっています。',
      category: EventCategory.political,
      weight: 2,
      choices: [
        Choice(
          id: 'pol_08_a',
          text: '要求を受け入れ独立捜査を認める',
          shortDescription: '透明性への評価↑ | 政権基盤へのリスク',
          impact: Impact(satisfactionChange: 12, stabilityChange: -6, nationalPowerChange: -3),
        ),
        Choice(
          id: 'pol_08_b',
          text: '内部調査で対応し外部介入を拒む',
          shortDescription: '政権基盤は守れる | 「隠蔽」との疑念',
          impact: Impact(satisfactionChange: -14, stabilityChange: -2),
        ),
        Choice(
          id: 'pol_08_c',
          text: '限定的な権限の調査委員会を設置する',
          shortDescription: '妥協案 | 双方から不十分との批判',
          impact: Impact(satisfactionChange: -2, stabilityChange: 1),
        ),
      ],
    ),
  ];

  // =====================
  // 環境系イベント (8件)
  // =====================
  static final List<GameEvent> _environmentalEvents = [
    GameEvent(
      id: 'env_01_climate',
      title: '気候変動対策の国際合意',
      description: '国際社会から温室効果ガス削減の大幅な目標引き上げを求められています。',
      category: EventCategory.environmental,
      weight: 3,
      choices: [
        Choice(
          id: 'env_01_a',
          text: '野心的な削減目標を受け入れる',
          shortDescription: '国際評価↑↑ | 産業コスト↑ | 長期GDP↑',
          impact: Impact(nationalPowerChange: 12, gdpChange: -1.5, satisfactionChange: 8, stabilityChange: -5),
        ),
        Choice(
          id: 'env_01_b',
          text: '現実的な目標を設定する',
          shortDescription: '経済への影響軽減 | 批判あり',
          impact: Impact(nationalPowerChange: 5, gdpChange: -0.5, satisfactionChange: 5, stabilityChange: 3),
        ),
        Choice(
          id: 'env_01_c',
          text: '目標を骨抜きにする',
          shortDescription: '経済優先 | 国際孤立リスク',
          impact: Impact(gdpChange: 1.0, nationalPowerChange: -12, satisfactionChange: -5, stabilityChange: 5),
        ),
      ],
    ),

    GameEvent(
      id: 'env_02_renewable',
      title: '再生可能エネルギーへの大転換',
      description: 'エネルギー自給率向上と脱炭素化のため、再生可能エネルギー投資の加速が議論されています。',
      category: EventCategory.environmental,
      weight: 3,
      choices: [
        Choice(
          id: 'env_02_a',
          text: '2040年100%再エネ目標を宣言',
          shortDescription: '国際評価↑↑ | 移行コスト大',
          impact: Impact(nationalPowerChange: 10, gdpChange: -0.8, satisfactionChange: 10, unemploymentChange: -1.5),
        ),
        Choice(
          id: 'env_02_b',
          text: '化石燃料補助金を削減・再エネ移行',
          shortDescription: 'バランス型転換',
          impact: Impact(nationalPowerChange: 6, gdpChange: 0.2, satisfactionChange: 5, stabilityChange: -3),
        ),
        Choice(
          id: 'env_02_c',
          text: '原子力発電を推進する',
          shortDescription: '安定供給↑ | 世論二分',
          impact: Impact(gdpChange: 0.5, nationalPowerChange: 4, satisfactionChange: -8, stabilityChange: 5),
        ),
      ],
    ),

    GameEvent(
      id: 'env_03_disaster',
      title: '大規模自然災害の発生',
      description: '大型台風と洪水が国土を直撃し、多くの被害が出ています。\n復興計画が急がれます。',
      category: EventCategory.environmental,
      weight: 2,
      choices: [
        Choice(
          id: 'env_03_a',
          text: '総額5兆円の緊急復興予算を組む',
          shortDescription: '復興促進 | 財政悪化',
          impact: Impact(satisfactionChange: 20, gdpChange: 1.5, unemploymentChange: -2.0, stabilityChange: -10),
        ),
        Choice(
          id: 'env_03_b',
          text: '国際支援を要請しながら復興',
          shortDescription: '国際協調 | 主体性↓',
          impact: Impact(satisfactionChange: 10, gdpChange: 0.5, nationalPowerChange: -5, stabilityChange: -5),
        ),
        Choice(
          id: 'env_03_c',
          text: '市民の自助努力を促す',
          shortDescription: 'コスト削減 | 信頼失墜',
          impact: Impact(satisfactionChange: -30, gdpChange: -2.0, stabilityChange: -15, nationalPowerChange: -8),
        ),
      ],
    ),

    GameEvent(
      id: 'env_04_plastic',
      title: 'プラスチック汚染対策',
      description: '海洋プラスチック汚染が深刻化し、国際社会から対策を求められています。',
      category: EventCategory.environmental,
      weight: 2,
      choices: [
        Choice(
          id: 'env_04_a',
          text: 'プラスチック製品を全面禁止',
          shortDescription: '環境改善↑ | 産業影響大',
          impact: Impact(nationalPowerChange: 8, gdpChange: -0.5, satisfactionChange: 12, unemploymentChange: 0.5),
        ),
        Choice(
          id: 'env_04_b',
          text: 'プラスチック税を導入する',
          shortDescription: '徐々に削減 | 財政収入↑',
          impact: Impact(nationalPowerChange: 5, gdpChange: 0.2, satisfactionChange: 5, stabilityChange: 3),
        ),
        Choice(
          id: 'env_04_c',
          text: 'リサイクル技術への投資を優先',
          shortDescription: 'イノベーション重視 | 即効性なし',
          impact: Impact(nationalPowerChange: 6, gdpChange: 0.3, satisfactionChange: 5, stabilityChange: 5),
        ),
      ],
    ),

    GameEvent(
      id: 'env_05_earthquake',
      title: '大規模地震の発生',
      description: '国内で大規模な地震が発生し、インフラや住宅に甚大な被害が出ています。',
      category: EventCategory.environmental,
      weight: 1,
      choices: [
        Choice(
          id: 'env_05_a',
          text: '国家総動員による緊急復興',
          shortDescription: '復興加速 | 財政大幅悪化 | 国民の安心感',
          impact: Impact(satisfactionChange: 22, gdpChange: -3.0, unemploymentChange: -1.5, stabilityChange: -8),
        ),
        Choice(
          id: 'env_05_b',
          text: '民間主導の復興を支援',
          shortDescription: 'バランス型 | 復興はやや遅め',
          impact: Impact(satisfactionChange: 10, gdpChange: -1.0, stabilityChange: -3),
        ),
        Choice(
          id: 'env_05_c',
          text: '最低限の支援に留め財政を優先',
          shortDescription: '財政健全性を維持 | 国民の不満増大',
          impact: Impact(satisfactionChange: -25, gdpChange: 0.5, stabilityChange: -15, nationalPowerChange: -5),
        ),
      ],
    ),

    GameEvent(
      id: 'env_06_drought',
      title: '深刻な干ばつと水資源危機',
      description: '記録的な少雨により主要河川の水位が低下し、農業と飲料水の供給に深刻な影響が出ています。',
      category: EventCategory.environmental,
      weight: 2,
      choices: [
        Choice(
          id: 'env_06_a',
          text: '大規模な水利インフラに緊急投資する',
          shortDescription: '長期的な解決 | 財政負担大',
          impact: Impact(satisfactionChange: 6, gdpChange: -1.5, publicDebtChange: 4.0, stabilityChange: 4),
        ),
        Choice(
          id: 'env_06_b',
          text: '節水を義務化し配給制を導入する',
          shortDescription: '即効性あり | 国民生活への強い制約',
          impact: Impact(satisfactionChange: -12, gdpChange: -0.5, stabilityChange: 2),
        ),
        Choice(
          id: 'env_06_c',
          text: '農業用水を優先し他は自然解決を待つ',
          shortDescription: '農業は守れる | 都市部の不満増大',
          impact: Impact(satisfactionChange: -8, gdpChange: -0.3),
        ),
      ],
    ),

    GameEvent(
      id: 'env_07_deforestation',
      title: '森林伐採と生物多様性の損失',
      description: '木材産業と農地拡大により森林伐採が加速し、国際社会から生物多様性保護の対応を求められています。',
      category: EventCategory.environmental,
      weight: 1,
      choices: [
        Choice(
          id: 'env_07_a',
          text: '伐採を厳格に規制し保護区を拡大する',
          shortDescription: '国際評価↑ | 林業・農業関係者の反発',
          impact: Impact(nationalPowerChange: 8, gdpChange: -1.2, satisfactionChange: -6, stabilityChange: -2),
        ),
        Choice(
          id: 'env_07_b',
          text: '持続可能な林業への転換を段階的に進める',
          shortDescription: '穏健な移行 | 効果は緩やか',
          impact: Impact(nationalPowerChange: 3, gdpChange: -0.3, satisfactionChange: 2),
        ),
        Choice(
          id: 'env_07_c',
          text: '経済優先で現状の産業を維持する',
          shortDescription: '短期的な産業維持 | 国際的な批判',
          impact: Impact(gdpChange: 1.0, nationalPowerChange: -6, satisfactionChange: -3),
        ),
      ],
    ),

    GameEvent(
      id: 'env_08_nuclear_power',
      title: '原子力発電所の新設論争',
      description: 'エネルギー安全保障と脱炭素を両立させる手段として、原子力発電所の新設が国会で議論されています。',
      category: EventCategory.environmental,
      weight: 2,
      choices: [
        Choice(
          id: 'env_08_a',
          text: '新設を承認し原子力を推進する',
          shortDescription: '長期的な電力安定 | 安全性への不安・反対運動',
          impact: Impact(gdpChange: 1.5, nationalPowerChange: 8, satisfactionChange: -10, stabilityChange: -4),
        ),
        Choice(
          id: 'env_08_b',
          text: '既存施設の稼働継続のみ認め新設は見送る',
          shortDescription: '妥協案 | 電力不足のリスクは残る',
          impact: Impact(gdpChange: 0.3, satisfactionChange: 2),
        ),
        Choice(
          id: 'env_08_c',
          text: '原子力から完全に撤退し再エネへ全面転換する',
          shortDescription: '国民の支持厚い層あり | 電力コスト上昇',
          impact: Impact(gdpChange: -1.8, satisfactionChange: 8, inflationChange: 1.0, stabilityChange: -3),
          promiseTarget: Faction.citizen,
        ),
      ],
    ),
  ];

  // ========================
  // 外部ショック系イベント (8件)
  // ========================
  static final List<GameEvent> _externalShockEvents = [
    GameEvent(
      id: 'ext_01_pandemic',
      title: '新型感染症の流行',
      description: '近隣国で新型ウイルスが発生し、国内でも感染者が確認されました。\n初動対応が問われます。',
      category: EventCategory.external,
      weight: 1,
      choices: [
        Choice(
          id: 'ext_01_a',
          text: '国境封鎖と厳格なロックダウン',
          shortDescription: '感染抑制 | 経済壊滅的打撃',
          impact: Impact(gdpChange: -5.0, satisfactionChange: -15, unemploymentChange: 5.0, stabilityChange: -10),
        ),
        Choice(
          id: 'ext_01_b',
          text: '段階的な規制と経済維持を両立',
          shortDescription: 'バランス型 | 感染と経済の妥協',
          impact: Impact(gdpChange: -2.5, satisfactionChange: -10, unemploymentChange: 2.5, stabilityChange: -5),
        ),
        Choice(
          id: 'ext_01_c',
          text: 'ワクチン開発・調達に全力投資',
          shortDescription: '根本解決 | 時間が必要',
          impact: Impact(gdpChange: -1.5, satisfactionChange: 5, nationalPowerChange: 8, stabilityChange: 5),
        ),
      ],
    ),

    GameEvent(
      id: 'ext_02_global_recession',
      title: '世界同時不況の波及',
      description: '主要国経済の失速が世界に波及し、我が国にも影響が出始めています。',
      category: EventCategory.external,
      weight: 2,
      choices: [
        Choice(
          id: 'ext_02_a',
          text: '大型財政出動で内需拡大',
          shortDescription: '景気下支え | 財政赤字↑',
          impact: Impact(gdpChange: -1.0, satisfactionChange: 10, unemploymentChange: 1.0, stabilityChange: 5),
        ),
        Choice(
          id: 'ext_02_b',
          text: '国際協調で共同対策を立てる',
          shortDescription: '多国間協力 | 単独では難しい',
          impact: Impact(gdpChange: -1.5, nationalPowerChange: 6, satisfactionChange: 5, stabilityChange: 3),
        ),
        Choice(
          id: 'ext_02_c',
          text: '経済のリストラクチャリングを断行',
          shortDescription: '痛みを伴う改革 | 長期強靭化',
          impact: Impact(gdpChange: -3.0, satisfactionChange: -20, unemploymentChange: 3.0, stabilityChange: 10),
        ),
      ],
    ),

    GameEvent(
      id: 'ext_03_tech_war',
      title: '技術覇権争いの激化',
      description: '大国間の技術覇権争いが激化し、我が国はどちらにつくか迫られています。',
      category: EventCategory.external,
      weight: 2,
      choices: [
        Choice(
          id: 'ext_03_a',
          text: '西側技術ブロックに参加する',
          shortDescription: '同盟強化 | 対抗勢力との関係↓',
          impact: Impact(nationalPowerChange: 8, gdpChange: -1.0, satisfactionChange: 5, stabilityChange: 5),
        ),
        Choice(
          id: 'ext_03_b',
          text: '独自の技術路線を追求する',
          shortDescription: '自主独立 | コスト大',
          impact: Impact(nationalPowerChange: 12, gdpChange: -2.0, satisfactionChange: 8, stabilityChange: -5),
        ),
        Choice(
          id: 'ext_03_c',
          text: '戦略的曖昧性を維持する',
          shortDescription: '両睨み | どちらからも不信感',
          impact: Impact(gdpChange: 0.5, nationalPowerChange: -5, satisfactionChange: -3, stabilityChange: -3),
        ),
      ],
    ),

    GameEvent(
      id: 'ext_04_energy_crisis',
      title: '国際エネルギー危機',
      description: '中東情勢の悪化でエネルギー価格が急騰しています。\n緊急対応が必要です。',
      category: EventCategory.external,
      weight: 2,
      choices: [
        Choice(
          id: 'ext_04_a',
          text: 'エネルギー補助金を大幅拡充',
          shortDescription: '国民負担軽減 | 財政圧迫',
          impact: Impact(satisfactionChange: 20, gdpChange: -1.5, inflationChange: -1.0, stabilityChange: -3, publicDebtChange: 5.0),
        ),
        Choice(
          id: 'ext_04_b',
          text: '省エネ政策と需要削減を推進',
          shortDescription: '構造改革 | 短期的不便',
          impact: Impact(satisfactionChange: -10, gdpChange: -0.5, nationalPowerChange: 5, stabilityChange: 5),
        ),
        Choice(
          id: 'ext_04_c',
          text: '新たなエネルギー輸入先を確保',
          shortDescription: '外交的解決 | 時間が必要',
          impact: Impact(gdpChange: -1.0, nationalPowerChange: 8, satisfactionChange: 5, stabilityChange: 3),
        ),
      ],
    ),

    GameEvent(
      id: 'ext_05_refugee_crisis',
      title: '難民危機の発生',
      description: '近隣国の紛争により大量の難民が国境に押し寄せています。\n人道的対応と社会的受容力の両立が問われています。',
      category: EventCategory.external,
      weight: 2,
      choices: [
        Choice(
          id: 'ext_05_a',
          text: '難民を積極的に受け入れる',
          shortDescription: '国際評価↑ | 社会統合コスト | 国内反発リスク',
          impact: Impact(nationalPowerChange: 10, gdpChange: -0.8, satisfactionChange: -5, stabilityChange: -5),
        ),
        Choice(
          id: 'ext_05_b',
          text: '国境で人数を制限しつつ支援キャンプを設置',
          shortDescription: 'バランス型 | 人道支援と管理を両立',
          impact: Impact(nationalPowerChange: 3, gdpChange: -0.3, satisfactionChange: 2, stabilityChange: 2),
        ),
        Choice(
          id: 'ext_05_c',
          text: '国境を封鎖し受け入れを拒否',
          shortDescription: '社会的負担回避 | 国際的批判 | 人道問題化',
          impact: Impact(nationalPowerChange: -15, satisfactionChange: -8, stabilityChange: 5, gdpChange: 0.2),
        ),
      ],
    ),

    GameEvent(
      id: 'ext_06_sanctions_target',
      title: '国際制裁の対象国に指定される',
      description: '人権問題を理由に、国際社会から経済制裁の対象として指定される可能性が急速に高まっています。',
      category: EventCategory.external,
      weight: 1,
      choices: [
        Choice(
          id: 'ext_06_a',
          text: '国際社会の要求に応じ改善策を示す',
          shortDescription: '制裁回避の可能性 | 「屈服」との国内批判',
          impact: Impact(nationalPowerChange: -5, satisfactionChange: -6, stabilityChange: 3, gdpChange: 0.5),
        ),
        Choice(
          id: 'ext_06_b',
          text: '主権を主張し要求を拒否する',
          shortDescription: '国内の一部から強い支持 | 制裁による経済打撃',
          impact: Impact(nationalPowerChange: 5, satisfactionChange: 8, gdpChange: -2.5, stabilityChange: -3),
        ),
        Choice(
          id: 'ext_06_c',
          text: '第三国を通じた外交交渉で時間を稼ぐ',
          shortDescription: '穏健な対応 | 決定的な解決にはならない',
          impact: Impact(gdpChange: -0.3, stabilityChange: 1),
        ),
      ],
    ),

    GameEvent(
      id: 'ext_07_currency_crisis',
      title: '通貨暴落と資本流出',
      description: '投資家の信頼低下から自国通貨が急落し、資本が海外へ流出しています。緊急対応が求められています。',
      category: EventCategory.external,
      weight: 2,
      choices: [
        Choice(
          id: 'ext_07_a',
          text: '政策金利を大幅に引き上げる',
          shortDescription: '通貨安定化 | 国内経済の冷え込み',
          impact: Impact(gdpChange: -2.0, unemploymentChange: 1.5, satisfactionChange: -10, stabilityChange: 5),
        ),
        Choice(
          id: 'ext_07_b',
          text: '外貨準備を投入し為替介入する',
          shortDescription: '即効性あり | 外貨準備の急速な減少',
          impact: Impact(gdpChange: -0.8, stabilityChange: 4, publicDebtChange: 3.0),
        ),
        Choice(
          id: 'ext_07_c',
          text: '資本規制を導入し流出を止める',
          shortDescription: '流出は止まる | 国際的信用の失墜',
          impact: Impact(nationalPowerChange: -8, gdpChange: -1.5, stabilityChange: 2),
        ),
      ],
    ),

    GameEvent(
      id: 'ext_08_space_race',
      title: '国際的な宇宙開発競争',
      description: '大国間の宇宙開発競争が激化し、自国も参加すべきだとの機運が高まっています。',
      category: EventCategory.external,
      weight: 1,
      choices: [
        Choice(
          id: 'ext_08_a',
          text: '国家宇宙計画に大規模投資する',
          shortDescription: '国際的威信↑↑ | 巨額の財政負担',
          impact: Impact(nationalPowerChange: 15, satisfactionChange: 5, publicDebtChange: 6.0, gdpChange: 0.5),
        ),
        Choice(
          id: 'ext_08_b',
          text: '民間企業との連携で低コストに参加する',
          shortDescription: 'バランス型 | 効果は限定的',
          impact: Impact(nationalPowerChange: 6, gdpChange: 0.8),
        ),
        Choice(
          id: 'ext_08_c',
          text: '参加を見送り国内課題に予算を集中する',
          shortDescription: '財政健全性維持 | 国際的地位の低下',
          impact: Impact(nationalPowerChange: -6, satisfactionChange: 3, publicDebtChange: -1.5),
        ),
      ],
    ),
  ];

  // =====================
  // 軍事系イベント (8件)
  // =====================
  static final List<GameEvent> _militaryEvents = [
    GameEvent(
      id: 'mil_01_defense_budget',
      title: '防衛費の大幅増額要求',
      description: '軍部が周辺国の脅威を理由に防衛費の大幅増額を要求しています。',
      category: EventCategory.military,
      weight: 2,
      choices: [
        Choice(
          id: 'mil_01_a',
          text: 'GDP比2%まで防衛費を増額する',
          shortDescription: '抑止力↑ | 財政圧迫 | 外交緊張',
          impact: Impact(nationalPowerChange: 12, gdpChange: -1.0, satisfactionChange: -5, stabilityChange: 5, publicDebtChange: 5.0),
          promiseTarget: Faction.military,
        ),
        Choice(
          id: 'mil_01_b',
          text: '小幅な増額にとどめる',
          shortDescription: 'バランス型',
          impact: Impact(nationalPowerChange: 5, gdpChange: -0.3, satisfactionChange: 3, stabilityChange: 3, publicDebtChange: 1.5),
        ),
        Choice(
          id: 'mil_01_c',
          text: '防衛費を削減して社会に回す',
          shortDescription: '社会保障↑ | 安全保障リスク',
          impact: Impact(satisfactionChange: 15, gdpChange: 0.5, nationalPowerChange: -8, stabilityChange: -3, publicDebtChange: -3.0),
        ),
      ],
    ),

    GameEvent(
      id: 'mil_02_alliance',
      title: '軍事同盟の強化交渉',
      description: '大国から軍事同盟の強化を提案されています。\n安全保障と自主性のトレードオフです。',
      category: EventCategory.military,
      weight: 2,
      choices: [
        Choice(
          id: 'mil_02_a',
          text: '同盟を強化する',
          shortDescription: '安全保障↑ | 自主性↓ | 外交摩擦',
          impact: Impact(nationalPowerChange: 10, satisfactionChange: 5, stabilityChange: 8, gdpChange: 0.5),
        ),
        Choice(
          id: 'mil_02_b',
          text: '現行の同盟水準を維持する',
          shortDescription: '現状維持',
          impact: Impact(stabilityChange: 3, nationalPowerChange: 2),
        ),
        Choice(
          id: 'mil_02_c',
          text: '中立路線を宣言する',
          shortDescription: '外交の自由度↑ | 安全保障リスク↑',
          impact: Impact(nationalPowerChange: -5, satisfactionChange: 10, stabilityChange: -8, gdpChange: 0.3),
        ),
      ],
    ),

    GameEvent(
      id: 'mil_03_cyber',
      title: 'サイバー攻撃への対応',
      description: '国家インフラが大規模サイバー攻撃を受けました。\n犯人は外国の国家機関とみられています。',
      category: EventCategory.military,
      weight: 2,
      choices: [
        Choice(
          id: 'mil_03_a',
          text: '外交的に強く抗議・制裁を発動',
          shortDescription: '毅然対応 | 緊張高まる',
          impact: Impact(nationalPowerChange: 8, satisfactionChange: 10, stabilityChange: -5, gdpChange: -0.5),
        ),
        Choice(
          id: 'mil_03_b',
          text: 'サイバー防衛能力に大規模投資',
          shortDescription: '長期的安全保障↑ | コスト大',
          impact: Impact(nationalPowerChange: 10, gdpChange: -0.8, stabilityChange: 5, satisfactionChange: 5),
        ),
        Choice(
          id: 'mil_03_c',
          text: '証拠が不十分として穏便に対応',
          shortDescription: '緊張回避 | 弱腰批判',
          impact: Impact(nationalPowerChange: -5, satisfactionChange: -8, stabilityChange: 5),
        ),
      ],
    ),

    GameEvent(
      id: 'mil_04_invasion',
      title: '隣国からの軍事侵攻',
      description: '北方の隣国が国境を越えて軍を進めてきました。\n即座の対応が求められています。',
      category: EventCategory.military,
      weight: 1,
      choices: [
        Choice(
          id: 'mil_04_a',
          text: '全面的に迎撃する',
          shortDescription: '国力↑↑ | 経済打撃大 | 犠牲者増',
          impact: Impact(nationalPowerChange: 15, gdpChange: -4.0, satisfactionChange: -15, stabilityChange: -15),
        ),
        Choice(
          id: 'mil_04_b',
          text: '国際社会に支援を要請しつつ交渉',
          shortDescription: '国際協調 | 時間を稼ぐ | 主体性低下',
          impact: Impact(nationalPowerChange: 3, gdpChange: -1.5, satisfactionChange: -5, stabilityChange: -5),
        ),
        Choice(
          id: 'mil_04_c',
          text: '領土の一部割譲で和平交渉',
          shortDescription: '短期的平和 | 国民の屈辱感 | 国力大幅低下',
          impact: Impact(nationalPowerChange: -20, gdpChange: 1.0, satisfactionChange: -25, stabilityChange: -10),
        ),
      ],
    ),

    GameEvent(
      id: 'mil_05_domestic_terror',
      title: '国内テロ・大規模暴動',
      description: '首都で爆破テロが発生し、混乱に乗じた大規模暴動が拡大しています。\n治安維持と自由のバランスが問われています。',
      category: EventCategory.military,
      weight: 1,
      choices: [
        Choice(
          id: 'mil_05_a',
          text: '非常事態宣言と厳戒態勢を敷く',
          shortDescription: '治安回復 | 自由の制限に反発',
          impact: Impact(stabilityChange: 12, satisfactionChange: -12, nationalPowerChange: 3, gdpChange: -1.0),
        ),
        Choice(
          id: 'mil_05_b',
          text: '対話と社会対策で沈静化を図る',
          shortDescription: '長期的安定 | 即効性に欠ける',
          impact: Impact(stabilityChange: -5, satisfactionChange: 6, gdpChange: -0.5),
        ),
        Choice(
          id: 'mil_05_c',
          text: '最小限の対応にとどめ様子を見る',
          shortDescription: '介入コスト回避 | 事態悪化のリスク',
          impact: Impact(stabilityChange: -15, satisfactionChange: -10, nationalPowerChange: -5, gdpChange: -1.5),
        ),
      ],
    ),

    GameEvent(
      id: 'mil_06_civilian_control',
      title: '軍の政治介入と文民統制の危機',
      description: '軍高官が政府批判の声明を公然と発表し、文民統制の原則が揺らいでいます。対応を迫られています。',
      category: EventCategory.military,
      weight: 1,
      choices: [
        Choice(
          id: 'mil_06_a',
          text: '当該高官を即座に更迭する',
          shortDescription: '文民統制の再確立 | 軍内部の反発リスク',
          impact: Impact(nationalPowerChange: -6, stabilityChange: -8, satisfactionChange: 8),
        ),
        Choice(
          id: 'mil_06_b',
          text: '内々に注意し公にはしない',
          shortDescription: '軍との衝突回避 | 「弱腰」との批判',
          impact: Impact(satisfactionChange: -8, stabilityChange: -2),
        ),
        Choice(
          id: 'mil_06_c',
          text: '軍の待遇改善と対話で関係修復を図る',
          shortDescription: '穏健な対応 | 財政負担・前例化のリスク',
          impact: Impact(publicDebtChange: 2.0, stabilityChange: 4, satisfactionChange: -3),
          promiseTarget: Faction.military,
        ),
      ],
    ),

    GameEvent(
      id: 'mil_07_conscription',
      title: '徴兵制の復活論争',
      description: '安全保障環境の悪化を受け、志願制から徴兵制への転換を求める声が国会で強まっています。',
      category: EventCategory.military,
      weight: 1,
      choices: [
        Choice(
          id: 'mil_07_a',
          text: '徴兵制を復活させる',
          shortDescription: '軍事力↑↑ | 若年層・国民の強い反発',
          impact: Impact(nationalPowerChange: 15, satisfactionChange: -20, stabilityChange: -6, gdpChange: -1.0),
        ),
        Choice(
          id: 'mil_07_b',
          text: '志願制を維持し待遇改善で人員を確保する',
          shortDescription: '穏健な対応 | 効果は限定的',
          impact: Impact(nationalPowerChange: 3, publicDebtChange: 1.5, satisfactionChange: 2),
        ),
        Choice(
          id: 'mil_07_c',
          text: '徴兵制を明確に否定する',
          shortDescription: '国民の支持↑ | 軍部からの不満',
          impact: Impact(satisfactionChange: 10, nationalPowerChange: -8),
        ),
      ],
    ),

    GameEvent(
      id: 'mil_08_border_smuggling',
      title: '国境地帯の密輸・治安悪化',
      description: '国境地帯で武器・薬物の密輸ネットワークが拡大し、地元自治体から治安対策の強化を求められています。',
      category: EventCategory.military,
      weight: 2,
      choices: [
        Choice(
          id: 'mil_08_a',
          text: '国境警備に軍を動員する',
          shortDescription: '即効性あり | 「軍の国内治安介入」への懸念',
          impact: Impact(stabilityChange: 8, satisfactionChange: -4, nationalPowerChange: 3, publicDebtChange: 1.5),
        ),
        Choice(
          id: 'mil_08_b',
          text: '警察組織の増員と機材強化で対応する',
          shortDescription: '穏健な対応 | 効果はやや緩やか',
          impact: Impact(stabilityChange: 5, publicDebtChange: 2.0),
        ),
        Choice(
          id: 'mil_08_c',
          text: '近隣国と共同で取締りを強化する',
          shortDescription: '外交関係強化 | 主権・調整コストの問題',
          impact: Impact(stabilityChange: 4, nationalPowerChange: 2, gdpChange: -0.3),
        ),
      ],
    ),
  ];
}
