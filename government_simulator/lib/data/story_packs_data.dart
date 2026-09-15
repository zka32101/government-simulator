/// ストーリーパック定義データ
/// テーマ別にシナリオをグループ化してナラティブな体験を提供

library;

import 'package:government_simulator/models/story_pack.dart';

/// ヨーロッパ政治危機パック
final europeanPoliticalCrisisPack = StoryPack(
  id: 'european_crisis',
  title: 'ヨーロッパ政治危機',
  description: '経済危機と政治分裂に直面したヨーロッパ諸国での統治体験。'
      'EU加盟国として国際的責任と国内要求のバランスを取ることが求められます。',
  theme: 'political',
  emoji: '🇪🇺',
  region: 'ヨーロッパ',
  order: 1,
  scenarioIds: ['ostia', 'amanda'],
  backgroundStory: '''
ヨーロッパの統合過程において、経済格差と政治的対立が深刻化しています。
オスティア共和国とアマンダ帝国は、ともにEU・NATO加盟国として
西側陣営に属しながらも、国内で深刻な経済危機と政治分裂に直面しています。

このパックでは、異なる政治体制を持つ2つの国家で、
国際的圧力と国内の民主的要求のバランスを取る困難さを体験します。
''',
  tags: ['経済危機', '政治対立', '国際関係', 'EU'],
  isLocked: false,
);

/// 島国政治パック
final islandNationPoliticsPack = StoryPack(
  id: 'island_politics',
  title: '島国政治の危機',
  description: '海に囲まれた島国で、限定的なリソースと独立性を守りながら'
      '国家を統治するシミュレーション。地政学的な脆弱性との向き合い方を学びます。',
  theme: 'diplomatic',
  emoji: '🏝️',
  region: 'カリブ海・太平洋',
  order: 2,
  scenarioIds: ['islas'],
  backgroundStory: '''
イスラス共和国は、カリブ海の島国として独自の道を歩んできました。
しかし、グローバル化の波と地域大国の圧力により、
その独立性と経済的自立が脅かされています。

島国という地政学的制約の中で、どのように外交を展開し、
国家主権を守り続けるのかが問われます。
''',
  tags: ['外交', '独立性', '地政学', 'リソース管理'],
  isLocked: false,
);

/// 北欧安定パック
final nordicStabilityPack = StoryPack(
  id: 'nordic_stability',
  title: '北欧民主主義の理想と現実',
  description: '北欧の福祉国家モデルを実践するノースランド。'
      '高い生活水準を維持しながら、変化する世界に適応する方法を探ります。',
  theme: 'economic',
  emoji: '❄️',
  region: '北欧',
  order: 3,
  scenarioIds: ['norsland'],
  backgroundStory: '''
ノースランドは北欧民主主義の象徴として、
世界で最も安定した経済と高い国民満足度を享受してきました。

しかし、グローバル競争の激化、移民問題、気候変動など
新たな課題が福祉国家モデルの持続可能性に疑問を投げかけています。

伝統的な成功モデルを守りながら、
新しい時代への対応を迫られるバランスの取り方を経験します。
''',
  tags: ['福祉国家', '民主主義', '経済安定', '社会統合'],
  isLocked: false,
);

/// 植民地遺産パック
final colonialLegacyPack = StoryPack(
  id: 'colonial_legacy',
  title: '植民地遺産と新興国の選択',
  description: '植民地時代の遺産を引き継いだ新興国テラノヴァ。'
      'その後進性を乗り越え、独立した国家として自らの道を切り開く挑戦。',
  theme: 'economic',
  emoji: '🌎',
  region: '中央アメリカ',
  order: 4,
  scenarioIds: ['terranova'],
  backgroundStory: '''
テラノヴァは長年、外国列強に支配されてきた歴史を持ちます。
独立後も経済的な従属性、不安定な政治体制、社会的分裂が課題となっています。

国際的な経済システムの中で自らの地位を確立し、
真の経済的独立と社会的発展を実現することが重要な使命です。

限定的なリソースと強大な隣国の圧力の中で、
自国の発展パスを選択する難しさを体験します。
''',
  tags: ['発展途上国', '経済的自立', '社会格差', '国際関係'],
  isLocked: false,
);

/// 全ストーリーパック
final allStoryPacks = [
  europeanPoliticalCrisisPack,
  islandNationPoliticsPack,
  nordicStabilityPack,
  colonialLegacyPack,
];
