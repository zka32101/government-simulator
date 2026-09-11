/// 危機管理システム
/// デモ、暴動、クーデターなどの政治的危機を管理

/// 危機タイプ
enum CrisisType {
  demonstration,    // 低レベルの市民不安
  riot,            // 暴力的な市民不安
  laborStrike,     // 労働者ストライキ
  economicCrisis,  // 経済危機
  militaryCoup,    // 軍事クーデター
}

/// 危機への対応方法
enum CrisisResponse {
  negotiate,       // 交渉で解決
  military,        // 軍事力の行使
  emergency,       // 緊急措置
  appeasement,     // 懐柔（譲歩）
  ignore,          // 無視（エスカレーションリスク）
}

/// 危機リスクレベル
enum CrisisRiskLevel {
  stable,          // 60-100%: 安定
  tensionRising,   // 45-60%: 緊張上昇
  highDanger,      // 30-45%: 高危険
  critical,        // 0-30%: 緊急
}

/// 危機イベント
class Crisis {
  final String id;
  final CrisisType type;
  final DateTime startDate;
  final int durationDays;
  final double approvalImpact;           // 承認度への影響
  final double? economicImpact;           // 経済ダメージ（オプション）
  final String description;
  final List<String> triggers;            // この危機を引き起こした要因
  final CrisisResponse? playerResponse;
  final DateTime? resolvedDate;
  final double escalationRisk;            // エスカレーションリスク（0-1）

  const Crisis({
    required this.id,
    required this.type,
    required this.startDate,
    required this.durationDays,
    required this.approvalImpact,
    this.economicImpact,
    required this.description,
    required this.triggers,
    this.playerResponse,
    this.resolvedDate,
    this.escalationRisk = 0.0,
  });

  /// 危機が解決したか
  bool get isResolved => resolvedDate != null;

  /// 危機がアクティブか
  bool get isActive =>
      !isResolved &&
      DateTime.now().difference(startDate).inDays < durationDays;

  /// 承認度への最終的な影響を計算
  double getApprovalImpact() {
    // 対応方法によって影響が変わる
    if (playerResponse == null) {
      return approvalImpact; // デフォルト影響
    }

    switch (playerResponse) {
      case CrisisResponse.negotiate:
        return approvalImpact * 0.5; // 交渉は影響を半減
      case CrisisResponse.military:
        return approvalImpact * 1.5; // 軍事対応は負の影響を増加
      case CrisisResponse.emergency:
        return approvalImpact * 0.8; // 緊急措置は軽減
      case CrisisResponse.appeasement:
        return approvalImpact * 0.3; // 懐柔は大幅軽減
      case CrisisResponse.ignore:
        return approvalImpact * 2.0; // 無視は影響を倍増
      default:
        return approvalImpact;
    }
  }

  Crisis copyWith({
    String? id,
    CrisisType? type,
    DateTime? startDate,
    int? durationDays,
    double? approvalImpact,
    double? economicImpact,
    String? description,
    List<String>? triggers,
    CrisisResponse? playerResponse,
    DateTime? resolvedDate,
    double? escalationRisk,
  }) {
    return Crisis(
      id: id ?? this.id,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
      approvalImpact: approvalImpact ?? this.approvalImpact,
      economicImpact: economicImpact ?? this.economicImpact,
      description: description ?? this.description,
      triggers: triggers ?? this.triggers,
      playerResponse: playerResponse ?? this.playerResponse,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      escalationRisk: escalationRisk ?? this.escalationRisk,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'durationDays': durationDays,
      'approvalImpact': approvalImpact,
      'economicImpact': economicImpact,
      'description': description,
      'triggers': triggers,
      'playerResponse': playerResponse?.toString().split('.').last,
      'resolvedDate': resolvedDate?.toIso8601String(),
      'escalationRisk': escalationRisk,
    };
  }

  factory Crisis.fromMap(Map<String, dynamic> map) {
    return Crisis(
      id: map['id'] ?? '',
      type: CrisisType.values
          .firstWhere((e) => e.toString().split('.').last == map['type']),
      startDate: DateTime.parse(map['startDate'] as String),
      durationDays: map['durationDays'] ?? 7,
      approvalImpact: (map['approvalImpact'] as num?)?.toDouble() ?? -5.0,
      economicImpact: (map['economicImpact'] as num?)?.toDouble(),
      description: map['description'] ?? '',
      triggers: List<String>.from(map['triggers'] ?? []),
      playerResponse: map['playerResponse'] != null
          ? CrisisResponse.values.firstWhere(
              (e) => e.toString().split('.').last == map['playerResponse'])
          : null,
      resolvedDate: map['resolvedDate'] != null
          ? DateTime.parse(map['resolvedDate'] as String)
          : null,
      escalationRisk: (map['escalationRisk'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// 承認度の変化を追跡
class ApprovalChange {
  final DateTime date;
  final double change;
  final String reason;

  const ApprovalChange({
    required this.date,
    required this.change,
    required this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'change': change,
      'reason': reason,
    };
  }

  factory ApprovalChange.fromMap(Map<String, dynamic> map) {
    return ApprovalChange(
      date: DateTime.parse(map['date'] as String),
      change: (map['change'] as num?)?.toDouble() ?? 0.0,
      reason: map['reason'] ?? '',
    );
  }
}
