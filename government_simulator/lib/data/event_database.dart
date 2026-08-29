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
  // 経済系イベント (11件)
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
  ];

  // =====================
  // 雇用系イベント (6件)
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
  ];

  // =====================
  // 社会系イベント (6件)
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
  ];

  // =====================
  // 政治系イベント (5件)
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
  ];

  // =====================
  // 環境系イベント (5件)
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
  ];

  // ========================
  // 外部ショック系イベント (5件)
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
  ];

  // =====================
  // 軍事系イベント (5件)
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
  ];
}
