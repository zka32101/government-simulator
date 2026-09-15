/// 選挙討論会・システム
/// 選挙前の候補者討論で政策立場と支持率に影響を与える

library;

enum DebateTopic {
  economy('経済', [
    'GDP',
    '雇用',
    '税制',
    '景気',
    '失業',
    '貿易',
  ]),
  healthcare('医療', [
    '健康',
    '医療保険',
    '病院',
    '薬価',
    '公衆衛生',
    '予防',
  ]),
  security('安全保障', [
    '防衛',
    '国防',
    '安全',
    '警察',
    'テロ',
    '外交',
  ]),
  environment('環境', [
    '気候',
    '汚染',
    'エネルギー',
    '自然',
    'リサイクル',
    '温暖化',
  ]),
  infrastructure('インフラ', [
    '道路',
    '鉄道',
    '交通',
    '建設',
    '都市',
    '開発',
  ]),
  education('教育', [
    '学校',
    '教育',
    '研究',
    '大学',
    '知識',
    '技能',
  ]);

  final String label;
  final List<String> keywords; // For policy matching

  const DebateTopic(this.label, this.keywords);
}

enum DebateOutcome {
  dominantVictory,
  clearVictory,
  narrowVictory,
  tie,
  narrowLoss,
  clearLoss,
  dominantLoss;

  // Support change from this debate outcome (-10 to +10)
  double get supportChange {
    switch (this) {
      case DebateOutcome.dominantVictory:
        return 8.0;
      case DebateOutcome.clearVictory:
        return 5.5;
      case DebateOutcome.narrowVictory:
        return 2.5;
      case DebateOutcome.tie:
        return 0.5;
      case DebateOutcome.narrowLoss:
        return -2.5;
      case DebateOutcome.clearLoss:
        return -5.5;
      case DebateOutcome.dominantLoss:
        return -8.0;
    }
  }

  // Reputation change from debate outcome (-15 to +15)
  int get reputationChange {
    switch (this) {
      case DebateOutcome.dominantVictory:
        return 15;
      case DebateOutcome.clearVictory:
        return 10;
      case DebateOutcome.narrowVictory:
        return 5;
      case DebateOutcome.tie:
        return 2;
      case DebateOutcome.narrowLoss:
        return -5;
      case DebateOutcome.clearLoss:
        return -10;
      case DebateOutcome.dominantLoss:
        return -15;
    }
  }

  // Campaign effectiveness multiplier post-debate (4 weeks)
  double get campaignMultiplier {
    switch (this) {
      case DebateOutcome.dominantVictory:
        return 1.5;
      case DebateOutcome.clearVictory:
        return 1.3;
      case DebateOutcome.narrowVictory:
        return 1.15;
      case DebateOutcome.tie:
        return 1.0;
      case DebateOutcome.narrowLoss:
        return 0.85;
      case DebateOutcome.clearLoss:
        return 0.7;
      case DebateOutcome.dominantLoss:
        return 0.5;
    }
  }
}

class DebateRound {
  final int roundNumber;
  final DebateTopic topic;
  final int weekNumber;
  final String playerStatement; // Generated from policies
  final String rivalStatement; // AI generated
  final double playerRoundScore; // 0-100
  final double rivalRoundScore; // 0-100

  DebateRound({
    required this.roundNumber,
    required this.topic,
    required this.weekNumber,
    required this.playerStatement,
    required this.rivalStatement,
    required this.playerRoundScore,
    required this.rivalRoundScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'roundNumber': roundNumber,
      'topic': topic.name,
      'weekNumber': weekNumber,
      'playerStatement': playerStatement,
      'rivalStatement': rivalStatement,
      'playerRoundScore': playerRoundScore,
      'rivalRoundScore': rivalRoundScore,
    };
  }

  static DebateRound fromMap(Map<String, dynamic> map) {
    return DebateRound(
      roundNumber: map['roundNumber'] as int,
      topic: DebateTopic.values.byName(map['topic'] as String),
      weekNumber: map['weekNumber'] as int,
      playerStatement: map['playerStatement'] as String,
      rivalStatement: map['rivalStatement'] as String,
      playerRoundScore: (map['playerRoundScore'] as num).toDouble(),
      rivalRoundScore: (map['rivalRoundScore'] as num).toDouble(),
    );
  }
}

class Debate {
  final String id;
  final int electionYear;
  final List<DebateRound> rounds;
  final String opponentId; // RivalCandidate ID
  final String opponentName;
  final DateTime scheduledAt;
  final DateTime? completedAt;
  final double playerScore; // 0-100, aggregated
  final double rivalScore; // 0-100, aggregated
  final DebateOutcome? outcome; // null if not yet completed
  final int? weekCompletedIn; // Week when debate was resolved
  final int? yearCompletedIn; // Year when debate was resolved

  Debate({
    required this.id,
    required this.electionYear,
    required this.rounds,
    required this.opponentId,
    required this.opponentName,
    required this.scheduledAt,
    this.completedAt,
    required this.playerScore,
    required this.rivalScore,
    this.outcome,
    this.weekCompletedIn,
    this.yearCompletedIn,
  });

  /// 討論会が完了したか
  bool get isCompleted => outcome != null && completedAt != null;

  /// 討論会がこの週に予定されているか
  bool isScheduledForWeek(int year, int week) {
    if (year != electionYear) return false;
    // 選挙の4-6週間前に開催
    return week >= electionYear * 100 - 6 && week <= electionYear * 100 - 4;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'electionYear': electionYear,
      'rounds': rounds.map((r) => r.toMap()).toList(),
      'opponentId': opponentId,
      'opponentName': opponentName,
      'scheduledAt': scheduledAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'playerScore': playerScore,
      'rivalScore': rivalScore,
      'outcome': outcome?.name,
      'weekCompletedIn': weekCompletedIn,
      'yearCompletedIn': yearCompletedIn,
    };
  }

  static Debate fromMap(Map<String, dynamic> map) {
    return Debate(
      id: map['id'] as String,
      electionYear: map['electionYear'] as int,
      rounds: (map['rounds'] as List?)
              ?.map((r) => DebateRound.fromMap(r as Map<String, dynamic>))
              .toList() ??
          const [],
      opponentId: map['opponentId'] as String,
      opponentName: map['opponentName'] as String,
      scheduledAt: DateTime.parse(map['scheduledAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      playerScore: (map['playerScore'] as num).toDouble(),
      rivalScore: (map['rivalScore'] as num).toDouble(),
      outcome: map['outcome'] != null
          ? DebateOutcome.values.byName(map['outcome'] as String)
          : null,
      weekCompletedIn: map['weekCompletedIn'] as int?,
      yearCompletedIn: map['yearCompletedIn'] as int?,
    );
  }
}

/// 討論会管理用ユーティリティクラス
class DebateManager {
  static const List<String> economyStatements = [
    'GDP成長を重視し、税制改革を推進します',
    '雇用創出と労働者保護のバランスを取ります',
    '地域経済の活性化に注力します',
    '財政規律を守りながら投資を行います',
  ];

  static const List<String> healthcareStatements = [
    '医療アクセスの拡大と質の向上を目指します',
    '予防医療と公衆衛生に力を入れます',
    '医療保険制度の効率化を進めます',
    '医療従事者の待遇改善を推進します',
  ];

  static const List<String> securityStatements = [
    '国防力の強化と外交による平和を両立させます',
    '国民の安全保障と自由のバランスを取ります',
    '国際協調による平和維持活動を支援します',
    '内部セキュリティと人権保護を重視します',
  ];

  static const List<String> environmentStatements = [
    '気候変動対策と経済成長の両立を目指します',
    'グリーンエネルギーへの投資を加速します',
    '環境保護と産業発展のバランスを取ります',
    '自然資源の持続可能な利用を推進します',
  ];

  static const List<String> infrastructureStatements = [
    '都市インフラの整備と地域開発を推進します',
    '公共交通網の拡充と環境負荷低減を目指します',
    '老朽化インフラの更新と新規開発を並行します',
    'スマートシティへの転換を支援します',
  ];

  static const List<String> educationStatements = [
    '教育の質の向上と機会均等を実現します',
    '研究開発への投資を拡大し、人材育成を強化します',
    'デジタル化による教育アクセスの改善を進めます',
    'キャリア教育と生涯学習を推進します',
  ];

  /// トピックに基づいて声明文を生成
  static String generatePlayerStatement(DebateTopic topic) {
    final statements = switch (topic) {
      DebateTopic.economy => economyStatements,
      DebateTopic.healthcare => healthcareStatements,
      DebateTopic.security => securityStatements,
      DebateTopic.environment => environmentStatements,
      DebateTopic.infrastructure => infrastructureStatements,
      DebateTopic.education => educationStatements,
    };
    final random = DateTime.now().microsecond % statements.length;
    return statements[random];
  }

  /// ライバルの声明文を生成（AIベース）
  static String generateRivalStatement(DebateTopic topic) {
    // ライバルはプレイヤーと異なるアプローチを取る
    final statements = switch (topic) {
      DebateTopic.economy => [
        '経済効率を最優先に、規制緩和を推し進めます',
        '大企業支援による経済成長を重視します',
        '雇用よりも市場の自由を優先します',
      ],
      DebateTopic.healthcare => [
        '民間医療の活力を生かし、競争を促進します',
        '医療費削減により財政効率化を図ります',
        '選別的医療制度の導入を検討します',
      ],
      DebateTopic.security => [
        '強固な防衛力による抑止力を重視します',
        'セキュリティの厳格化を推し進めます',
        '独立した防衛体制の強化を目指します',
      ],
      DebateTopic.environment => [
        '経済成長を優先し、環境対策は後発で対応',
        'エネルギー安定供給を最優先にします',
        '産業振興と環境対策の選別的推進',
      ],
      DebateTopic.infrastructure => [
        '大規模プロジェクトによる経済効果を狙います',
        '民間投資の活用により効率化を図ります',
        '開発優先で持続可能性は後付けで対応',
      ],
      DebateTopic.education => [
        'エリート教育と実践的職業訓練の重視',
        '市場ニーズに合わせた教育改革を推進',
        '教育への公的投資を抑制します',
      ],
    };
    final random = DateTime.now().microsecond % statements.length;
    return statements[random];
  }
}
