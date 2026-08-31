/// 政策選択肢の経済学的根拠を説明するモデル。
/// 教育的価値向上のため、各政策がなぜそのような影響を持つのかを
/// 経済学の観点から詳細に説明する。
class PolicyExplanation {
  final String policyId;
  final String policyName;
  final String economicTheory;        // 適用される経済学理論
  final String mechanism;              // 作用メカニズム
  final String expectedOutcomes;       // 期待される効果
  final String risks;                  // リスク・副作用
  final String historicalPrecedents;   // 歴史的事例
  final List<String> relatedConcepts;  // 関連する経済概念
  final String keyTakeaway;            // 学習ポイント

  const PolicyExplanation({
    required this.policyId,
    required this.policyName,
    required this.economicTheory,
    required this.mechanism,
    required this.expectedOutcomes,
    required this.risks,
    required this.historicalPrecedents,
    required this.relatedConcepts,
    required this.keyTakeaway,
  });
}

/// 経済学的概念の説明（ツールチップ用）
class EconomicConcept {
  final String name;
  final String shortDefinition;
  final String detailedExplanation;
  final String realWorldExample;
  final List<String> relatedPolicies;

  const EconomicConcept({
    required this.name,
    required this.shortDefinition,
    required this.detailedExplanation,
    required this.realWorldExample,
    required this.relatedPolicies,
  });
}

/// 政策説明データベース
class PolicyExplanationDatabase {
  static final Map<String, PolicyExplanation> _explanations = {
    // 税制改革系
    'eco_01_a': PolicyExplanation(
      policyId: 'eco_01_a',
      policyName: '所得税を増税する',
      economicTheory: '供給側経済学 (Supply-Side Economics) vs ケインズ経済学',
      mechanism: '所得税増加により、政府の税収が増加する。'
          '一方で、可処分所得が減少することで消費が低下し、'
          'GDP成長率が低下する傾向がある。短期的には不況を招きやすい。',
      expectedOutcomes: '• 財政収支の改善\n'
          '• インフレ圧力の軽減\n'
          '• 所得再分配の促進',
      risks: '• 労働意欲の低下（Labor Disincentive）\n'
          '• 消費需要の縮小（Aggregate Demand減少）\n'
          '• 企業投資の抑制\n'
          '• 人材の海外流出リスク',
      historicalPrecedents: 'スウェーデンの高福祉・高税率モデル（成功例）\n'
          'イギリス1970年代のスタグフレーション（失敗例）\n'
          '日本1997年の消費税引き上げ後の景気悪化',
      relatedConcepts: ['所得税', '税収効果', '累進課税', '労働供給', 'スタグフレーション'],
      keyTakeaway: '増税は財政改善の最短経路だが、経済全体への悪影響が大きく、'
          '短期的な景気悪化を招く可能性が高い。中長期の経済成長を損なわないよう、'
          '支出削減とセットで検討される必要がある。',
    ),
    'eco_01_b': PolicyExplanation(
      policyId: 'eco_01_b',
      policyName: '法人税を減税する',
      economicTheory: 'サプライサイド経済学 (Supply-Side Economics)',
      mechanism: '法人税率を低下させることで、企業の手取り利益が増加する。'
          '企業は増加した利益を設備投資やR&D、雇用拡大に充てるインセンティブが生じる。'
          'これにより生産性が向上し、GDP成長が促進される。',
      expectedOutcomes: '• 企業投資の増加\n'
          '• 経済成長率の上昇\n'
          '• 雇用創出\n'
          '• 国際競争力の強化',
      risks: '• 政府の税収が低下し、財政赤字が増加\n'
          '• 所得不平等の拡大（企業利益が労働者給与に転嫁されない場合）\n'
          '• 租税回避の助長\n'
          '• 社会福祉・教育への投資が抑制される懸念',
      historicalPrecedents: 'アメリカのレーガン政策（1980年代、投資促進に成功）\n'
          'アイルランドのコーク地域振興（法人税12.5%で外資誘致）\n'
          '日本の法人税率段階的引き下げ（2012年以降）',
      relatedConcepts: ['法人税', '設備投資', 'トリクルダウン効果', '国際競争力', '租税回避'],
      keyTakeaway: '法人税減税は短期的なGDP成長を促進するが、財政負担が増加し、'
          '所得格差が拡大する可能性がある。効果は企業の投資姿勢に依存するため、'
          '必ずしも雇用創出に繋がらない点に注意が必要。',
    ),
    'eco_01_c': PolicyExplanation(
      policyId: 'eco_01_c',
      policyName: '消費税を引き上げる',
      economicTheory: 'ケインズ経済学・逆進性問題',
      mechanism: '消費税は販売時点で課税される間接税であり、全消費者が負担する。'
          '低所得層ほど消費に占める割合が大きいため、実質的に低所得層への負担が重くなる。'
          '消費税引き上げにより物価が上昇し、消費需要が低下する傾向がある。',
      expectedOutcomes: '• 政府税収の増加\n'
          '• インフレ率の上昇（消費税分）\n'
          '• 財政赤字削減',
      risks: '• 消費需要の急激な縮小（Consumption Shock）\n'
          '• デフレスパイラルの誘発リスク\n'
          '• 低所得層への負担増（逆進性）\n'
          '• 景気悪化による失業増加\n'
          '• インフレと不況の同時発生（スタグフレーション）',
      historicalPrecedents: '日本の消費税引き上げ：\n'
          '• 1989年3%導入 → 一時的な景気悪化\n'
          '• 1997年5%引き上げ → 失われた10年へ\n'
          '• 2014年8%引き上げ → 消費の落ち込み\n'
          'EUの消費税（付加価値税）は17-27%で財政安定に貢献',
      relatedConcepts: ['消費税', '逆進性', '景気循環', 'インフレ', '消費需要'],
      keyTakeaway: '消費税は広い課税ベースで税収が安定するメリットがある一方で、'
          '引き上げのタイミングが極めて重要。景気が弱い時期の引き上げは'
          '景気悪化を加速させるため、経済状況の見極めが不可欠。',
    ),
    // 金利政策系
    'eco_03_a': PolicyExplanation(
      policyId: 'eco_03_a',
      policyName: '金利を大幅引き上げ',
      economicTheory: 'マネタリズム・物価安定化政策',
      mechanism: '中央銀行が政策金利を引き上げると、銀行の借入コストが上昇し、'
          '企業や消費者の借入意欲が減退する。通貨供給量が減少し、インフレ圧力が低下。'
          'ただし借入コスト上昇は投資・消費を抑制し、景気後退につながる。',
      expectedOutcomes: '• インフレ率の低下\n'
          '• 通貨価値の安定・上昇\n'
          '• 海外からの資本流入',
      risks: '• 企業投資の大幅な縮小\n'
          '• 消費の冷え込み\n'
          '• 失業率の上昇\n'
          '• 政府債務利息の増加（借換時の金利上昇）\n'
          '• 資産バブル崩壊リスク',
      historicalPrecedents: 'アメリカ・ボルカー議長（1980-82）：\n'
          'インフレ退治のため金利を20%まで引き上げ、\n'
          'インフレを収束させたが深刻な不況を招く。\n'
          '日本の1990年代「失われた10年」時の\n'
          'ゼロ金利導入前の高金利政策',
      relatedConcepts: ['政策金利', 'インフレ', 'インフレターゲット', '景気循環', 'テイラー・ルール'],
      keyTakeaway: '金利引き上げはインフレ抑制の強力な手段だが、'
          '景気への悪影響が大きい。政策当局者は（インフレ率と失業率の）'
          'フィリップス曲線を念頭に、バランスの取れた金利設定が求められる。',
    ),
    // 雇用系
    'emp_01_a': PolicyExplanation(
      policyId: 'emp_01_a',
      policyName: '公共事業を実施',
      economicTheory: 'ケインズ経済学・乗数効果',
      mechanism: '政府が直接的に公共投資を増やすと、建設業等での雇用が生まれる。'
          '賃金を得た労働者が消費を増やすことで、他の産業にも需要が波及する（乗数効果）。'
          'ただし短期的には有効だが、長期的には政府債務の増加につながる。',
      expectedOutcomes: '• 失業率の低下\n'
          '• GDPの短期的な増加\n'
          '• 地域経済の活性化\n'
          '• インフラ整備',
      risks: '• 政府債務の増加\n'
          '• バラマキ感による財政規律の喪失\n'
          '• 生産性の低い事業の温存\n'
          '• インフレの加速（供給が追いつかない場合）\n'
          '• クラウディング・アウト効果（民間投資の圧迫）',
      historicalPrecedents: 'ニューディール政策（米国1930年代：大恐慌対策）\n'
          '日本の公共事業依存（1990年代-2000年代）\n'
          'ポストCOVID-19経済対策（各国で大規模実施中）',
      relatedConcepts: ['乗数効果', '財政政策', 'クラウディング・アウト', '有効需要', 'インフラ投資'],
      keyTakeaway: '公共事業は景気循環の底で投入すれば高い効果が期待できるが、'
          '景気が良い時期に実施するとインフレと債務を招く。タイミングと規模の判断が重要。',
    ),
    'emp_01_b': PolicyExplanation(
      policyId: 'emp_01_b',
      policyName: '職業訓練を強化',
      economicTheory: '人的資本投資理論',
      mechanism: '労働者のスキル向上を通じた長期的な雇用促進。'
          '直近の失業率低下効果は限定的だが、労働者の生産性が向上し、'
          '中長期的には企業の競争力強化と賃金上昇をもたらす。',
      expectedOutcomes: '• 長期的な失業率低下\n'
          '• 労働生産性の向上\n'
          '• 賃金上昇\n'
          '• 産業構造の転換支援',
      risks: '• 短期的な失業率改善効果が限定的\n'
          '• 訓練内容と実際の求人のミスマッチ\n'
          '• 継続的な予算投入が必要\n'
          '• 高スキル人材の海外流出',
      historicalPrecedents: 'デンマークの「フレクシキュリティ」モデル\n'
          '（柔軟な雇用と充実した職業訓練）\n'
          'シンガポールのSkillsFuture計画\n'
          'ドイツの職人制度（Handwerk）',
      relatedConcepts: ['人的資本', 'スキルミスマッチ', '構造的失業', '生産性', '教育投資'],
      keyTakeaway: '職業訓練は短期的には失業者の救済効果が限定的だが、'
          '長期的には産業競争力の向上と個人の生涯所得を大きく向上させる投資。',
    ),
  };

  static final Map<String, EconomicConcept> _concepts = {
    '所得税': EconomicConcept(
      name: '所得税（Income Tax）',
      shortDefinition: '個人の所得に対して課せられる直接税。',
      detailedExplanation: '所得から必要経費を控除した利益に対して課せられる税。'
          'の率が高いほど、労働や投資のインセンティブが低下する。'
          '累進税率制により、高所得者ほど高い税率が適用される制度が多い。',
      realWorldExample: '日本：45%（最高税率）、米国：37%、スウェーデン：57%（最高）',
      relatedPolicies: ['eco_01_a', '所得再分配', '労働供給'],
    ),
    '消費税': EconomicConcept(
      name: '消費税（Consumption Tax / VAT）',
      shortDefinition: '商品・サービスの購入時に課せられる間接税。',
      detailedExplanation: '販売額に一定率を乗じて課せられる税。全消費者が負担するため、'
          '低所得層の負担割合が高い（逆進性）。ただし課税ベースが広いため、'
          '税収は安定している。',
      realWorldExample: '日本：10%（標準税率）、EU：17-27%、シンガポール：9%',
      relatedPolicies: ['eco_01_c', '逆進性', '消費需要'],
    ),
    'インフレ': EconomicConcept(
      name: 'インフレーション（Inflation）',
      shortDefinition: '時間経過に伴う一般的な物価水準の上昇。',
      detailedExplanation: '物価が上昇すると、同じ金額で購入できる商品の量が減少。'
          'マイルドなインフレ（年2-3%程度）は経済成長を促進するが、'
          '過度なインフレは貯蓄を減少させ、経済を不安定にする。',
      realWorldExample: '日本：数十年のデフレから脱却希望中（目標2%）\n'
          'ベネズエラ：2016年から100万倍超えのハイパーインフレ',
      relatedPolicies: ['eco_03_a', '中央銀行金利', 'スタグフレーション'],
    ),
    '乗数効果': EconomicConcept(
      name: '乗数効果（Multiplier Effect）',
      shortDefinition: '初期投資が経済全体に波及する効果。',
      detailedExplanation: '政府が100円投資すると、その100円が労働者の賃金となり、'
          '労働者がその賃金を消費に充てることで、別の企業の売上になる。'
          'このプロセスが繰り返され、初期投資額の数倍の経済効果が生じる。',
      realWorldExample: 'ケインズの理論では乗数は1.5-2.0程度。'
          'つまり100円の公共投資は150-200円のGDP増加をもたらす。',
      relatedPolicies: ['emp_01_a', '公共事業', '有効需要'],
    ),
  };

  static PolicyExplanation? getExplanation(String policyId) {
    return _explanations[policyId];
  }

  static EconomicConcept? getConcept(String conceptName) {
    return _concepts[conceptName];
  }

  static List<PolicyExplanation> getAllExplanations() {
    return _explanations.values.toList();
  }

  static List<EconomicConcept> getAllConcepts() {
    return _concepts.values.toList();
  }
}
