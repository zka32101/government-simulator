/// 国際関係・外交システム
/// 各国との関係、貿易協定、外交的恩義を管理

/// 国家間の関係ステータス
enum RelationshipStatus {
  /// 戦争状態
  enemy,

  /// 敵対的
  hostile,

  /// 緊張状態
  tense,

  /// 中立
  neutral,

  /// 友好的
  cordial,

  /// 同盟国
  allied,

  /// 従属国（稀）
  vassal,
}

/// 外交イベントタイプ
enum DiplomaticEventType {
  /// 貿易交渉
  tradeNegotiation,

  /// 国境紛争
  borderIncident,

  /// 同盟提案
  allianceProposal,

  /// 国際制裁
  sanctions,

  /// 文化交流
  culturalExchange,

  /// 人道支援要請
  humanitarianAid,

  /// 宣戦布告
  warDeclaration,

  /// 平和条約
  peaceTreaty,
}

/// 外交的恩義の種類
enum DiplomaticFavor {
  /// 軍事支援
  militaryAssistance,

  /// 経済支援（ローン）
  economicSupport,

  /// UN投票支持
  voteSupport,

  /// 政治的バックアップ
  politicalBacking,

  /// 貿易交渉優遇
  tradeNegotiation,
}

/// 制裁レベル
enum SanctionLevel {
  /// 軽い制裁
  light,

  /// 中程度の制裁
  moderate,

  /// 厳しい制裁
  severe,

  /// 総経済制裁
  total,
}

/// 各国との関係を表す
class NationRelationship {
  /// 国家ID
  final String nationId;

  /// 国家名
  final String nationName;

  /// 関係スコア（-100 ～ +100）
  double standingScore;

  /// 貿易量（0-100%）
  final double tradeVolume;

  /// 軍事同盟レベル（0-100%）
  final double militaryAllianceLevel;

  /// 文化的影響力（0-100%）
  final double culturalInfluence;

  /// 当国に対して相手が負う恩義（0-100）
  final double favorOwedToMe;

  /// 当国が相手に負う恩義（0-100）
  final double favorIOweThem;

  /// 経済的依存度（0-100%）
  final double economicDependency;

  /// 最後の相互作用の日時
  DateTime? lastInteraction;

  /// 戦争状態か
  final bool isAtWar;

  /// 同盟を結んでいるか
  final bool isAlly;

  /// 最後の同盟変更日
  final DateTime? allianceChangeDate;

  const NationRelationship({
    required this.nationId,
    required this.nationName,
    this.standingScore = 0.0,
    this.tradeVolume = 0.0,
    this.militaryAllianceLevel = 0.0,
    this.culturalInfluence = 0.0,
    this.favorOwedToMe = 0.0,
    this.favorIOweThem = 0.0,
    this.economicDependency = 0.0,
    this.lastInteraction,
    this.isAtWar = false,
    this.isAlly = false,
    this.allianceChangeDate,
  });

  /// 関係ステータスを取得
  RelationshipStatus getStatus() {
    if (isAtWar) {
      return RelationshipStatus.enemy;
    }

    if (standingScore > 80) {
      return RelationshipStatus.allied;
    } else if (standingScore > 50) {
      return RelationshipStatus.cordial;
    } else if (standingScore > 20) {
      return RelationshipStatus.neutral;
    } else if (standingScore > -20) {
      return RelationshipStatus.tense;
    } else if (standingScore > -60) {
      return RelationshipStatus.hostile;
    } else {
      return RelationshipStatus.enemy;
    }
  }

  /// 同盟国か判定
  bool isAllyNation() => isAlly && standingScore > 50;

  /// 敵国か判定
  bool isEnemyNation() => isAtWar || standingScore < -50;

  /// 貿易協定可能か判定
  bool canTradeTreaty() => standingScore > 0 && !isAtWar;

  /// 関係スコアを変更
  void changeStanding(double amount) {
    standingScore = (standingScore + amount).clamp(-100.0, 100.0);
    lastInteraction = DateTime.now();
  }

  /// コピー・変更用メソッド
  NationRelationship copyWith({
    String? nationId,
    String? nationName,
    double? standingScore,
    double? tradeVolume,
    double? militaryAllianceLevel,
    double? culturalInfluence,
    double? favorOwedToMe,
    double? favorIOweThem,
    double? economicDependency,
    DateTime? lastInteraction,
    bool? isAtWar,
    bool? isAlly,
    DateTime? allianceChangeDate,
  }) {
    return NationRelationship(
      nationId: nationId ?? this.nationId,
      nationName: nationName ?? this.nationName,
      standingScore: standingScore ?? this.standingScore,
      tradeVolume: tradeVolume ?? this.tradeVolume,
      militaryAllianceLevel: militaryAllianceLevel ?? this.militaryAllianceLevel,
      culturalInfluence: culturalInfluence ?? this.culturalInfluence,
      favorOwedToMe: favorOwedToMe ?? this.favorOwedToMe,
      favorIOweThem: favorIOweThem ?? this.favorIOweThem,
      economicDependency: economicDependency ?? this.economicDependency,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      isAtWar: isAtWar ?? this.isAtWar,
      isAlly: isAlly ?? this.isAlly,
      allianceChangeDate: allianceChangeDate ?? this.allianceChangeDate,
    );
  }

  /// 辞書に変換
  Map<String, dynamic> toMap() {
    return {
      'nationId': nationId,
      'nationName': nationName,
      'standingScore': standingScore,
      'tradeVolume': tradeVolume,
      'militaryAllianceLevel': militaryAllianceLevel,
      'culturalInfluence': culturalInfluence,
      'favorOwedToMe': favorOwedToMe,
      'favorIOweThem': favorIOweThem,
      'economicDependency': economicDependency,
      'lastInteraction': lastInteraction?.toIso8601String(),
      'isAtWar': isAtWar,
      'isAlly': isAlly,
      'allianceChangeDate': allianceChangeDate?.toIso8601String(),
    };
  }

  /// 辞書から生成
  factory NationRelationship.fromMap(Map<String, dynamic> map) {
    return NationRelationship(
      nationId: map['nationId'] as String? ?? '',
      nationName: map['nationName'] as String? ?? '',
      standingScore: (map['standingScore'] as num?)?.toDouble() ?? 0.0,
      tradeVolume: (map['tradeVolume'] as num?)?.toDouble() ?? 0.0,
      militaryAllianceLevel:
          (map['militaryAllianceLevel'] as num?)?.toDouble() ?? 0.0,
      culturalInfluence: (map['culturalInfluence'] as num?)?.toDouble() ?? 0.0,
      favorOwedToMe: (map['favorOwedToMe'] as num?)?.toDouble() ?? 0.0,
      favorIOweThem: (map['favorIOweThem'] as num?)?.toDouble() ?? 0.0,
      economicDependency: (map['economicDependency'] as num?)?.toDouble() ?? 0.0,
      lastInteraction: map['lastInteraction'] != null
          ? DateTime.tryParse(map['lastInteraction'] as String)
          : null,
      isAtWar: map['isAtWar'] as bool? ?? false,
      isAlly: map['isAlly'] as bool? ?? false,
      allianceChangeDate: map['allianceChangeDate'] != null
          ? DateTime.tryParse(map['allianceChangeDate'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NationRelationship &&
          runtimeType == other.runtimeType &&
          nationId == other.nationId &&
          standingScore == other.standingScore;

  @override
  int get hashCode => nationId.hashCode ^ standingScore.hashCode;

  @override
  String toString() {
    return 'NationRelationship('
        'nationId: $nationId, '
        'nationName: $nationName, '
        'standing: ${standingScore.toStringAsFixed(1)}, '
        'status: ${getStatus().toString()}'
        ')';
  }
}

/// 貿易協定
class TradeAgreement {
  /// パートナー国ID
  final String partnerId;

  /// パートナー国名
  final String partnerName;

  /// 年間収入（$）
  final double yearlyIncome;

  /// 年間支出（$）
  final double yearlyExpense;

  /// 開始年
  final int startYear;

  /// 終了年
  final int endYear;

  /// 影響を受ける国内産業
  final List<String> affectedIndustries;

  /// アクティブか
  final bool isActive;

  const TradeAgreement({
    required this.partnerId,
    required this.partnerName,
    required this.yearlyIncome,
    required this.yearlyExpense,
    required this.startYear,
    required this.endYear,
    required this.affectedIndustries,
    this.isActive = true,
  });

  /// 純利益を計算
  double getNetIncome() => yearlyIncome - yearlyExpense;

  /// コピー・変更用メソッド
  TradeAgreement copyWith({
    String? partnerId,
    String? partnerName,
    double? yearlyIncome,
    double? yearlyExpense,
    int? startYear,
    int? endYear,
    List<String>? affectedIndustries,
    bool? isActive,
  }) {
    return TradeAgreement(
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      yearlyIncome: yearlyIncome ?? this.yearlyIncome,
      yearlyExpense: yearlyExpense ?? this.yearlyExpense,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      affectedIndustries: affectedIndustries ?? this.affectedIndustries,
      isActive: isActive ?? this.isActive,
    );
  }

  /// 辞書に変換
  Map<String, dynamic> toMap() {
    return {
      'partnerId': partnerId,
      'partnerName': partnerName,
      'yearlyIncome': yearlyIncome,
      'yearlyExpense': yearlyExpense,
      'startYear': startYear,
      'endYear': endYear,
      'affectedIndustries': affectedIndustries,
      'isActive': isActive,
    };
  }

  /// 辞書から生成
  factory TradeAgreement.fromMap(Map<String, dynamic> map) {
    return TradeAgreement(
      partnerId: map['partnerId'] as String? ?? '',
      partnerName: map['partnerName'] as String? ?? '',
      yearlyIncome: (map['yearlyIncome'] as num?)?.toDouble() ?? 0.0,
      yearlyExpense: (map['yearlyExpense'] as num?)?.toDouble() ?? 0.0,
      startYear: map['startYear'] as int? ?? 0,
      endYear: map['endYear'] as int? ?? 0,
      affectedIndustries:
          (map['affectedIndustries'] as List<dynamic>?)?.cast<String>() ?? [],
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}

/// 外交イベント
class DiplomaticEvent {
  /// イベントID
  final String id;

  /// イベントタイプ
  final DiplomaticEventType type;

  /// タイトル
  final String title;

  /// 説明
  final String description;

  /// 関係する国家（カンマ区切り）
  final String involvedNations;

  /// 発生日時
  final DateTime occurredDate;

  /// 利用可能な選択肢
  final List<DiplomaticOption> availableOptions;

  /// プレイヤーの選択
  DiplomaticOption? playerChoice;

  /// 解決日時
  DateTime? resolvedDate;

  DiplomaticEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.involvedNations,
    required this.occurredDate,
    required this.availableOptions,
    this.playerChoice,
    this.resolvedDate,
  });

  /// コピー・変更用メソッド
  DiplomaticEvent copyWith({
    String? id,
    DiplomaticEventType? type,
    String? title,
    String? description,
    String? involvedNations,
    DateTime? occurredDate,
    List<DiplomaticOption>? availableOptions,
    DiplomaticOption? playerChoice,
    DateTime? resolvedDate,
  }) {
    return DiplomaticEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      involvedNations: involvedNations ?? this.involvedNations,
      occurredDate: occurredDate ?? this.occurredDate,
      availableOptions: availableOptions ?? this.availableOptions,
      playerChoice: playerChoice ?? this.playerChoice,
      resolvedDate: resolvedDate ?? this.resolvedDate,
    );
  }

  /// 辞書に変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'description': description,
      'involvedNations': involvedNations,
      'occurredDate': occurredDate.toIso8601String(),
      'availableOptions':
          availableOptions.map((opt) => opt.toMap()).toList(),
      'playerChoice': playerChoice?.toMap(),
      'resolvedDate': resolvedDate?.toIso8601String(),
    };
  }

  /// 辞書から生成
  factory DiplomaticEvent.fromMap(Map<String, dynamic> map) {
    return DiplomaticEvent(
      id: map['id'] as String? ?? '',
      type: DiplomaticEventType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => DiplomaticEventType.tradeNegotiation,
      ),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      involvedNations: map['involvedNations'] as String? ?? '',
      occurredDate: DateTime.tryParse(map['occurredDate'] as String? ?? '') ??
          DateTime.now(),
      availableOptions: (map['availableOptions'] as List<dynamic>?)
              ?.map((opt) => DiplomaticOption.fromMap(opt as Map<String, dynamic>))
              .toList() ??
          [],
      playerChoice: map['playerChoice'] != null
          ? DiplomaticOption.fromMap(map['playerChoice'] as Map<String, dynamic>)
          : null,
      resolvedDate: map['resolvedDate'] != null
          ? DateTime.tryParse(map['resolvedDate'] as String)
          : null,
    );
  }
}

/// 外交オプション
class DiplomaticOption {
  /// オプション説明
  final String label;

  /// 詳細説明
  final String description;

  /// 経済コスト（$）
  final double economicCost;

  /// 関係スコア変化
  final double relationshipChange;

  /// 承認評価への影響（%）
  final double approvalImpact;

  /// 副作用テキスト
  final String? sideEffect;

  const DiplomaticOption({
    required this.label,
    required this.description,
    required this.economicCost,
    required this.relationshipChange,
    required this.approvalImpact,
    this.sideEffect,
  });

  /// 辞書に変換
  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'description': description,
      'economicCost': economicCost,
      'relationshipChange': relationshipChange,
      'approvalImpact': approvalImpact,
      'sideEffect': sideEffect,
    };
  }

  /// 辞書から生成
  factory DiplomaticOption.fromMap(Map<String, dynamic> map) {
    return DiplomaticOption(
      label: map['label'] as String? ?? '',
      description: map['description'] as String? ?? '',
      economicCost: (map['economicCost'] as num?)?.toDouble() ?? 0.0,
      relationshipChange: (map['relationshipChange'] as num?)?.toDouble() ?? 0.0,
      approvalImpact: (map['approvalImpact'] as num?)?.toDouble() ?? 0.0,
      sideEffect: map['sideEffect'] as String?,
    );
  }
}

/// 外交制裁
class DiplomaticSanction {
  /// 対象国ID
  final String targetNationId;

  /// 制裁レベル
  final SanctionLevel level;

  /// 開始日
  final DateTime startDate;

  /// 予定終了日
  DateTime? plannedEndDate;

  /// 理由
  final String reason;

  /// 経済影響（月額損失）
  final double monthlyEconomicImpact;

  DiplomaticSanction({
    required this.targetNationId,
    required this.level,
    required this.startDate,
    required this.reason,
    required this.monthlyEconomicImpact,
    this.plannedEndDate,
  });

  /// コピー・変更用メソッド
  DiplomaticSanction copyWith({
    String? targetNationId,
    SanctionLevel? level,
    DateTime? startDate,
    DateTime? plannedEndDate,
    String? reason,
    double? monthlyEconomicImpact,
  }) {
    return DiplomaticSanction(
      targetNationId: targetNationId ?? this.targetNationId,
      level: level ?? this.level,
      startDate: startDate ?? this.startDate,
      reason: reason ?? this.reason,
      monthlyEconomicImpact:
          monthlyEconomicImpact ?? this.monthlyEconomicImpact,
      plannedEndDate: plannedEndDate ?? this.plannedEndDate,
    );
  }

  /// 辞書に変換
  Map<String, dynamic> toMap() {
    return {
      'targetNationId': targetNationId,
      'level': level.toString(),
      'startDate': startDate.toIso8601String(),
      'plannedEndDate': plannedEndDate?.toIso8601String(),
      'reason': reason,
      'monthlyEconomicImpact': monthlyEconomicImpact,
    };
  }

  /// 辞書から生成
  factory DiplomaticSanction.fromMap(Map<String, dynamic> map) {
    return DiplomaticSanction(
      targetNationId: map['targetNationId'] as String? ?? '',
      level: SanctionLevel.values.firstWhere(
        (e) => e.toString() == map['level'],
        orElse: () => SanctionLevel.light,
      ),
      startDate: DateTime.tryParse(map['startDate'] as String? ?? '') ??
          DateTime.now(),
      reason: map['reason'] as String? ?? '',
      monthlyEconomicImpact:
          (map['monthlyEconomicImpact'] as num?)?.toDouble() ?? 0.0,
      plannedEndDate: map['plannedEndDate'] != null
          ? DateTime.tryParse(map['plannedEndDate'] as String)
          : null,
    );
  }
}
