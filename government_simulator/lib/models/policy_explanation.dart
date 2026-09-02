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

/// 経済学的カテゴリー
enum EconomicCategory {
  monetaryPolicy('金融政策'),
  fiscalPolicy('財政政策'),
  tradeAndExchange('貿易と為替'),
  laborMarket('労働市場'),
  environmental('環境経済'),
  structuralEconomics('構造経済'),
  behavioralEconomics('行動経済学');

  final String label;
  const EconomicCategory(this.label);
}

/// 経済学的概念の説明（ツールチップ用）
class EconomicConcept {
  final String name;
  final String shortDefinition;
  final String detailedExplanation;
  final String realWorldExample;
  final List<String> relatedPolicies;
  final EconomicCategory category;
  final String visualMnemonic;
  final List<String> keyEquations;
  final String historicalContext;

  const EconomicConcept({
    required this.name,
    required this.shortDefinition,
    required this.detailedExplanation,
    required this.realWorldExample,
    required this.relatedPolicies,
    required this.category,
    required this.visualMnemonic,
    required this.keyEquations,
    required this.historicalContext,
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
    // ============ 金融政策（Monetary Policy）============
    'インフレ': EconomicConcept(
      name: 'インフレーション（Inflation）',
      shortDefinition: '時間経過に伴う一般的な物価水準の上昇。',
      detailedExplanation: '物価が上昇すると、同じ金額で購入できる商品の量が減少。'
          'マイルドなインフレ（年2-3%程度）は経済成長を促進するが、'
          '過度なインフレは貯蓄を減少させ、経済を不安定にする。',
      realWorldExample: '日本：数十年のデフレから脱却希望中（目標2%）\n'
          'ベネズエラ：2016年から100万倍超えのハイパーインフレ',
      relatedPolicies: ['eco_03_a', '中央銀行金利', 'スタグフレーション'],
      category: EconomicCategory.monetaryPolicy,
      visualMnemonic: '📈💰',
      keyEquations: ['物価上昇率 = (現在の価格 - 過去の価格) / 過去の価格'],
      historicalContext: '日本は1990年代から2010年代中盤まで持続的なデフレに直面。'
          '黒田日銀総裁による大規模金融緩和（2013年-）で脱デフレを目指している。',
    ),
    '政策金利': EconomicConcept(
      name: '政策金利（Policy Interest Rate）',
      shortDefinition: '中央銀行が設定する基準となる金利。',
      detailedExplanation: '政策金利は民間銀行の借入コストに直結し、全体的な金利水準を決定。'
          '金利が高いと借入コストが上昇するため企業投資や消費が冷え込む。'
          '金利が低いと借入が容易になり、投資・消費が促進される。',
      realWorldExample: '日本銀行：-0.1%（マイナス金利政策）\n'
          '米国FRB：3.75%-4.0%（2023年時点）',
      relatedPolicies: ['eco_03_a', 'インフレターゲット', '景気循環'],
      category: EconomicCategory.monetaryPolicy,
      visualMnemonic: '🎛️',
      keyEquations: ['実質金利 = 名目金利 - インフレ率'],
      historicalContext: 'ボルカーFRB議長は1980年代初頭に金利を20%まで引き上げて'
          'インフレを撃退したが、深刻な景気後退を招いた。',
    ),
    'インフレターゲット': EconomicConcept(
      name: 'インフレターゲット（Inflation Targeting）',
      shortDefinition: '中央銀行が物価上昇の目標値を設定する政策枠組み。',
      detailedExplanation: '通常は2%程度のインフレ目標を設定。この枠組みにより、'
          '中央銀行は金融政策の方向性を明確に発表でき、市場の予期インフレを安定させる。'
          '市場参加者が「インフレは2%に抑制される」と予想すれば、実際に2%に近づく。',
      realWorldExample: 'ニュージーランド（1989年導入、最初）→現在100カ国以上が採用\n'
          '日本銀行：2%のインフレターゲット（2013年設定）',
      relatedPolicies: ['eco_03_a', '量的緩和', 'テイラー・ルール'],
      category: EconomicCategory.monetaryPolicy,
      visualMnemonic: '🎯',
      keyEquations: ['期待インフレ率 ∝ 中央銀行の信認'],
      historicalContext: '1990年代の日本はインフレターゲットを導入せず、'
          'デフレが固定化してしまった反省から、2013年に2%目標を設定。',
    ),
    '量的緩和': EconomicConcept(
      name: '量的緩和（Quantitative Easing, QE）',
      shortDefinition: '中央銀行が大量に資産を購入して市中にマネーを供給する政策。',
      detailedExplanation: '政策金利がゼロ近辺に達したとき、さらなる金融緩和の手段として用いられる。'
          '中央銀行が国債や株式ETFを大量購入し、市場に流動性を注入。'
          'これにより借入コストを低下させ、投資・消費を促進する。',
      realWorldExample: '日本銀行（2001-2006, 2013年-）\n'
          '米国FRB（2008年金融危機後, COVID-19期）\n'
          'ECB（ユーロ圏危機対応）',
      relatedPolicies: ['eco_03_a', 'インフレターゲット', 'マネー供給'],
      category: EconomicCategory.monetaryPolicy,
      visualMnemonic: '💵📊',
      keyEquations: ['マネーサプライ↑ → 実質金利↓ → 投資・消費↑'],
      historicalContext: '2008年のリーマンショック後、各国中央銀行は伝統的な金利政策の効果限界を認識。'
          'QEが金融政策の主要な手段となった。',
    ),

    // ============ 財政政策（Fiscal Policy）============
    '所得税': EconomicConcept(
      name: '所得税（Income Tax）',
      shortDefinition: '個人の所得に対して課せられる直接税。',
      detailedExplanation: '所得から必要経費を控除した利益に対して課せられる税。'
          '税率が高いほど、労働や投資のインセンティブが低下する。'
          '累進税率制により、高所得者ほど高い税率が適用される制度が多い。',
      realWorldExample: '日本：45%（最高税率）、米国：37%、スウェーデン：57%（最高）',
      relatedPolicies: ['eco_01_a', '再分配', '労働供給'],
      category: EconomicCategory.fiscalPolicy,
      visualMnemonic: '💼',
      keyEquations: ['税収 = 所得 × 税率'],
      historicalContext: '所得税は20世紀初頭に導入。第一次世界大戦の戦費調達手段から始まった。',
    ),
    '消費税': EconomicConcept(
      name: '消費税（Consumption Tax / VAT）',
      shortDefinition: '商品・サービスの購入時に課せられる間接税。',
      detailedExplanation: '販売額に一定率を乗じて課せられる税。全消費者が負担するため、'
          '低所得層の負担割合が高い（逆進性）。ただし課税ベースが広いため、'
          '税収は安定している。',
      realWorldExample: '日本：10%（標準税率）、EU：17-27%、シンガポール：9%',
      relatedPolicies: ['eco_01_c', '逆進性', '消費需要'],
      category: EconomicCategory.fiscalPolicy,
      visualMnemonic: '🛍️',
      keyEquations: ['消費税収 = 消費額 × 税率'],
      historicalContext: '日本は1989年に消費税を3%で導入。1997年に5%、2014年に8%、'
          '2019年に10%に段階的に引き上げられた。',
    ),
    'プライマリーバランス': EconomicConcept(
      name: 'プライマリーバランス（Primary Balance）',
      shortDefinition: '金利払い前の政府収支（税収 - 金利以外の支出）。',
      detailedExplanation: 'PBが黒字なら、利息を除いた部分で収入が支出を上回っている。'
          'PBの赤字が続くと、政府債務が雪だるま式に増加。'
          '財政の持続可能性を判断する重要指標。',
      realWorldExample: '日本：PB赤字が続く状況（2020年代）\n'
          'ドイツ：2009年以降、PB黒字を維持する政策指針',
      relatedPolicies: ['eco_01_a', '財政赤字', '政府債務'],
      category: EconomicCategory.fiscalPolicy,
      visualMnemonic: '⚖️',
      keyEquations: ['PB = 税収 - (支出 - 金利払い)'],
      historicalContext: '1990年代の日本が構造的な財政赤字に直面した反省から、'
          'PBは財政規律を示す重要な指標として認識されるようになった。',
    ),
    'ラッファー曲線': EconomicConcept(
      name: 'ラッファー曲線（Laffer Curve）',
      shortDefinition: '税率と税収の関係を示す曲線。税率が高いほど税収が増えるわけではない。',
      detailedExplanation: '税率を上げると、労働・投資のインセンティブが低下し、実際の経済活動が減少。'
          'ある税率まで税収は増加するが、その先は減税するほうが税収が増える可能性がある。'
          'この理論は「供給側経済学」の基礎となっている。',
      realWorldExample: 'ロナルド・レーガン大統領（1980年代）はこの理論に基づき減税を実施。\n'
          'ただし実際の経済効果については経済学者間でも議論がある。',
      relatedPolicies: ['eco_01_b', '供給側経済学', '経済成長'],
      category: EconomicCategory.fiscalPolicy,
      visualMnemonic: '📉',
      keyEquations: ['税収 = 税率 × 課税ベース（税率↑でも課税ベース↓の可能性）'],
      historicalContext: 'アメリカのエコノミスト、アーサー・ラッファーが1974年に提唱。'
          'ペーパーナプキンに描いたとされる有名な逸話がある。',
    ),
    '自動安定化装置': EconomicConcept(
      name: '自動安定化装置（Automatic Stabilizers）',
      shortDefinition: '明示的な政策決定なしに景気を安定させる税・支出制度。',
      detailedExplanation: '景気が悪化すると失業給付や生活保護が自動的に増加し、消費を下支え。'
          'また、景気悪化で所得が減ると累進税率の所得税も自動的に減少。'
          '政治的な遅れなく機能する自動的な景気調整メカニズム。',
      realWorldExample: '失業保険、生活保護給付、累進所得税\n'
          'COVID-19時も失業保険の増加が消費を支えた。',
      relatedPolicies: ['eco_01_a', 'ケインズ経済学', '有効需要'],
      category: EconomicCategory.fiscalPolicy,
      visualMnemonic: '🛡️',
      keyEquations: ['支出 ∝ 所得（自動調整）'],
      historicalContext: '1930年代の大恐慌で失業給付制度が導入され、'
          '以降の景気後退での経済落ち込みが軽減されるようになった。',
    ),

    // ============ 貿易と為替（Trade & Exchange）============
    '比較優位': EconomicConcept(
      name: '比較優位（Comparative Advantage）',
      shortDefinition: '相対的な生産効率が高い産業に特化する貿易理論。',
      detailedExplanation: '各国が相対的な競争優位を持つ産業に特化して貿易すれば、'
          '全体の生産量が増加する。デヴィッド・リカードが提唱し、'
          '自由貿易の経済的利益を説明する最も重要な理論。',
      realWorldExample: '日本：自動車・電子機器の比較優位 ↔ 米国：農産物・エネルギーの比較優位\n'
          'バングラデシュ：低コスト労働による衣類製造',
      relatedPolicies: ['保護主義', '産業空洞化', '国際競争力'],
      category: EconomicCategory.tradeAndExchange,
      visualMnemonic: '🌍',
      keyEquations: ['各国は相対的に効率が高い産業に特化'],
      historicalContext: 'デヴィッド・リカード（1817年）が『経済学および課税の原理』で発表。'
          '自由貿易の経済的根拠として今も引用されている。',
    ),
    '為替相場': EconomicConcept(
      name: '為替相場（Exchange Rate）',
      shortDefinition: '異なる通貨の交換比率（例：1米ドル = 150円）。',
      detailedExplanation: '為替相場は国の相対的な経済力、金利差、インフレ率などで決定。'
          '自国通貨が強くなると輸出競争力が低下し、輸入が増加する。'
          '逆に通貨が弱くなると輸出が有利になるが、輸入物価が上昇。',
      realWorldExample: '円高（1ドル = 100円）→ 日本製品は割高、輸出減少\n'
          '円安（1ドル = 150円）→ 日本製品は割安、輸出増加',
      relatedPolicies: ['eco_01_b', 'インフレ', '輸出競争力'],
      category: EconomicCategory.tradeAndExchange,
      visualMnemonic: '💱',
      keyEquations: ['購買力平価説：為替相場 ∝ (国内物価水準 / 外国物価水準)'],
      historicalContext: '1944年のブレトンウッズ体制では固定相場制、1973年から変動相場制に移行。',
    ),
    '保護主義': EconomicConcept(
      name: '保護主義（Protectionism）',
      shortDefinition: '関税や輸入規制で国内産業を外国との競争から守る政策。',
      detailedExplanation: '幼稚産業保護論や雇用・産業維持の観点から正当化されるが、'
          '報復関税を招き、全体的には消費者負担が増加し、資源配分が非効率になる。'
          'ただし急激な産業転換による失業対策として機能することもある。',
      realWorldExample: 'トランプ政権の中国への追加関税\n日本の農業保護（米への高い関税）',
      relatedPolicies: ['比較優位', '国際競争力', '雇用'],
      category: EconomicCategory.tradeAndExchange,
      visualMnemonic: '🚧',
      keyEquations: ['保護主義 → 報復関税 → 全体的な経済効率低下'],
      historicalContext: '1930年のスムート=ホーリー関税法はアメリカの大恐慌を悪化させたと指摘される。'
          '現代でも保護主義圧力は常に存在。',
    ),

    // ============ 労働市場（Labor Market）============
    'スキルミスマッチ': EconomicConcept(
      name: 'スキルミスマッチ（Skill Mismatch）',
      shortDefinition: '労働者のスキルと求人要件の不一致により、失業と求人が同時に存在する状態。',
      detailedExplanation: '労働者がある産業で失業していても、別の産業では求人がある場合、'
          '単純な職業訓練では解決できない「構造的失業」となる。'
          '産業構造の急速な変化が進むと、スキルミスマッチは拡大する傾向。',
      realWorldExample: '2020年代：AI技術者は高需要だが、製造業の単純作業者は過剰供給\n'
          '石炭産業の衰退地域での失業',
      relatedPolicies: ['emp_01_b', '構造的失業', '職業訓練'],
      category: EconomicCategory.laborMarket,
      visualMnemonic: '🔧',
      keyEquations: ['失業率と求人有効倍率が同時に高い状態'],
      historicalContext: '産業革命以来、定期的に技術進歩がスキルミスマッチを引き起こしてきた。',
    ),
    'フィリップス曲線': EconomicConcept(
      name: 'フィリップス曲線（Phillips Curve）',
      shortDefinition: '失業率とインフレ率の間の負の相関関係。',
      detailedExplanation: '失業率が低いほど賃金インフレが上昇する傾向。'
          '政策当局者は「失業率を1%下げるのに、インフレが1%上昇する代価を払う」という'
          'トレードオフに直面する。1970年代のスタグフレーションで有効性が問われた。',
      realWorldExample: '1960年代：失業率3% ↔ インフレ5%の安定的なトレードオフ\n'
          '1970年代：スタグフレーション（失業率も高い、インフレも高い）',
      relatedPolicies: ['eco_03_a', 'インフレ', '景気循環'],
      category: EconomicCategory.laborMarket,
      visualMnemonic: '📈📉',
      keyEquations: ['インフレ率 ≈ α - β × 失業率'],
      historicalContext: 'A・フィリップス（1958年）がデータで確認。'
          '1970年代のスタグフレーションで修正フィリップス曲線が提唱された。',
    ),
    'NAIRU': EconomicConcept(
      name: 'NAIRU（Non-Accelerating Inflation Rate of Unemployment）',
      shortDefinition: 'インフレを加速させない失業率。この失業率以下だとインフレが加速する。',
      detailedExplanation: 'NAIRUは「自然失業率」とも呼ばれ、経済学者の推定では3-5%程度。'
          'NAIRUを下回ると労働逼迫によりインフレが加速するとされるが、'
          '実際のNAIRUを測定することは難しい。',
      realWorldExample: '米国（2022年）：失業率3.5%（NAIRUと推定）でもインフレが8%に達した',
      relatedPolicies: ['フィリップス曲線', 'インフレターゲット', '完全雇用'],
      category: EconomicCategory.laborMarket,
      visualMnemonic: '⚠️',
      keyEquations: ['失業率 < NAIRU → インフレ加速'],
      historicalContext: 'ミルトン・フリードマンとエドマンド・フェルプスが1960年代に提唱。',
    ),

    // ============ 環境経済（Environmental）============
    '外部性': EconomicConcept(
      name: '外部性（Externality）',
      shortDefinition: '市場取引に反映されない経済活動の副次的効果。',
      detailedExplanation: '正の外部性：教育投資による社会全体の生産性向上\n'
          '負の外部性：工場からの汚染による健康被害、CO2排出による気候変動\n'
          '外部性があると市場メカニズムだけでは最適な資源配分が達成されず、政府介入が必要。',
      realWorldExample: '喫煙による受動喫煙被害（負）、蜜蜂の受粉による農業への利益（正）',
      relatedPolicies: 'カーボン・プライシング、環境税',
      category: EconomicCategory.environmental,
      visualMnemonic: '☁️',
      keyEquations: ['社会的限界費用 > 私的限界費用（負の外部性の場合）'],
      historhistorical Context: 'ロナルド・コースが「コースの定理」で外部性問題への対処法を分析。',
    ),
    'カーボン・プライシング': EconomicConcept(
      name: 'カーボン・プライシング（Carbon Pricing）',
      shortDefinition: 'CO2排出に対して価格（税金またはクレジット）を付与する政策。',
      detailedExplanation: 'CO2排出という負の外部性に価格を付けることで、企業・個人に削減インセンティブを与える。'
          '方式は①炭素税（固定価格）、②排出権取引（変動価格）がある。'
          'EU-ETS（欧州排出権取引制度）が先例で、現在30カ国以上が実施。',
      realWorldExample: 'EU-ETS：EU加盟国の産業セクターからのCO2排出の約40%を対象\n日本：J-クレジット制度（任意参加）',
      relatedPolicies: ['外部性', '環境規制', 'SDGs'],
      category: EconomicCategory.environmental,
      visualMnemonic: '🌱',
      keyEquations: ['炭素税 = €CO2排出量'],
      historicalContext: '京都議定書（1997年）の排出権取引スキームが発端。'
          'パリ協定（2015年）でカーボン・プライシングの採用が拡大。',
    ),

    // ============ 構造経済（Structural Economics）============
    '供給側経済学': EconomicConcept(
      name: '供給側経済学（Supply-Side Economics）',
      shortDefinition: '経済成長は供給能力（生産側）の強化で達成するという経済学派。',
      detailedExplanation: 'ケインズ経済学の「需要不足 → 不況」と対比して、'
          '「供給能力の向上 → 経済成長」を重視。減税、規制緩和、技術投資を通じて'
          '労働・資本・起業家精神を促進することを主張する。',
      realWorldExample: 'レーガン政権（米国1980年代）、サッチャー政権（英国1980年代）',
      relatedPolicies: ['ラッファー曲線', '法人税減税', 'イノベーション'],
      category: EconomicCategory.structuralEconomics,
      visualMnemonic: '🚀',
      keyEquations: ['GDP成長 ∝ 供給能力（資本・労働・技術）'],
      historicalContext: 'ジョージ・ギルダーとアーサー・ラッファーが1980年代に提唱。'
          '保守系政権に支持されたが、所得格差拡大への批判もある。',
    ),
    'クラウディング・アウト': EconomicConcept(
      name: 'クラウディング・アウト（Crowding Out）',
      shortDefinition: '政府支出増加が民間投資を圧迫する効果。',
      detailedExplanation: '政府が国債を増発して支出を増やすと、金利が上昇。'
          'これにより民間企業の借入コストが上がり、投資が減少する。'
          'つまり、政府支出の増加が民間投資を「押し出す」（crowd out）。',
      realWorldExample: 'COVID-19期の大規模財政出動で金利上昇、民間投資が抑制される懸念',
      relatedPolicies: ['公共事業', '金利', 'インフレ'],
      category: EconomicCategory.structuralEconomics,
      visualMnemonic: '📉',
      keyEquations: ['政府支出↑ → 金利↑ → 民間投資↓'],
      historicalContext: '1980年代の高金利時代に、レーガン政権の減税と支出増加による'
          'クラウディング・アウト効果が議論された。',
    ),
    'スタグフレーション': EconomicConcept(
      name: 'スタグフレーション（Stagflation）',
      shortDefinition: '景気停滞（Stagnation）とインフレ（Inflation）が同時に起こる現象。',
      detailedExplanation: '通常、不況ではデフレ、好況ではインフレが起こるが、'
          'オイルショックなどで供給が急減すると、インフレと失業が同時に上昇。'
          '1970年代に先進国を悩ませた。伝統的なフィリップス曲線では説明不能。',
      realWorldExample: '1973年・1979年のオイルショックによる1970年代のスタグフレーション\n'
          'COVID-19後の2022年のインフレと経済鈍化',
      relatedPolicies: ['インフレ', '失業', 'フィリップス曲線'],
      category: EconomicCategory.structuralEconomics,
      visualMnemonic: '⚡❄️',
      keyEquations: ['インフレ率↑ かつ 失業率↑'],
      historicalContext: '1970年代のスタグフレーションによる経済学の危機は、'
          'マネタリスト革命と新古典派の台頭をもたらした。',
    ),

    // ============ 行動経済学（Behavioral Economics）============
    '再分配': EconomicConcept(
      name: '再分配（Redistribution）',
      shortDefinition: '税金や給付を通じて、所得・資産を再分配する政策。',
      detailedExplanation: '市場メカニズムだけでは所得格差が拡大するため、'
          '累進税や福祉給付を通じて再分配。社会的安定と公正を実現する一方で、'
          '労働インセンティブの低下や政府支出の増加をもたらす。',
      realWorldExample: 'スウェーデンの高税率・高福祉モデル：所得格差が小さい（ジニ係数0.27）\n'
          '米国：所得格差が大きい（ジニ係数0.40）',
      relatedPolicies: ['所得税', '社会保障', '不平等'],
      category: EconomicCategory.behavioralEconomics,
      visualMnemonic: '⚖️',
      keyEquations: ['ジニ係数 = 0（完全平等） ～ 1（完全不平等）'],
      historicalContext: 'ピケティの『21世紀の資本』（2013年）が所得格差問題をグローバルアジェンダに上昇させた。',
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
