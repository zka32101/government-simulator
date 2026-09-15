/// 内閣の確執・権力闘争管理サービス
/// 大臣間の対立、権力抗争、背信イベントを管理

library;

import 'dart:math';
import 'package:government_simulator/models/minister.dart';

/// 大臣間の確執を表すイベント
class MinisterConflict {
  /// イベントID
  final String id;

  /// 対立している大臣1
  final MinisterRole minister1;

  /// 対立している大臣2
  final MinisterRole minister2;

  /// 確執の説明
  final String description;

  /// 緊張度（0-100）
  double tensionLevel;

  /// 発生日時
  final DateTime occurredDate;

  /// 最後の対立アクション
  DateTime? lastConflictAction;

  /// 解決済みか
  bool isResolved;

  MinisterConflict({
    required this.id,
    required this.minister1,
    required this.minister2,
    required this.description,
    required this.tensionLevel,
    required this.occurredDate,
    this.lastConflictAction,
    this.isResolved = false,
  });

  /// コピー・変更用メソッド
  MinisterConflict copyWith({
    String? id,
    MinisterRole? minister1,
    MinisterRole? minister2,
    String? description,
    double? tensionLevel,
    DateTime? occurredDate,
    DateTime? lastConflictAction,
    bool? isResolved,
  }) {
    return MinisterConflict(
      id: id ?? this.id,
      minister1: minister1 ?? this.minister1,
      minister2: minister2 ?? this.minister2,
      description: description ?? this.description,
      tensionLevel: tensionLevel ?? this.tensionLevel,
      occurredDate: occurredDate ?? this.occurredDate,
      lastConflictAction: lastConflictAction ?? this.lastConflictAction,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  /// 辞書に変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'minister1': minister1.name,
      'minister2': minister2.name,
      'description': description,
      'tensionLevel': tensionLevel,
      'occurredDate': occurredDate.toIso8601String(),
      'lastConflictAction': lastConflictAction?.toIso8601String(),
      'isResolved': isResolved,
    };
  }

  /// 辞書から生成
  factory MinisterConflict.fromMap(Map<String, dynamic> map) {
    return MinisterConflict(
      id: map['id'] as String? ?? '',
      minister1: MinisterRole.values.byName(map['minister1'] as String? ?? 'finance'),
      minister2: MinisterRole.values.byName(map['minister2'] as String? ?? 'defense'),
      description: map['description'] as String? ?? '',
      tensionLevel: (map['tensionLevel'] as num?)?.toDouble() ?? 0.0,
      occurredDate: DateTime.tryParse(map['occurredDate'] as String? ?? '') ?? DateTime.now(),
      lastConflictAction: map['lastConflictAction'] != null
          ? DateTime.tryParse(map['lastConflictAction'] as String)
          : null,
      isResolved: map['isResolved'] as bool? ?? false,
    );
  }
}

/// 背信（大臣の裏切り）イベント
class BetrayalEvent {
  /// イベントID
  final String id;

  /// 裏切った大臣
  final MinisterRole traitor;

  /// 裏切りの理由
  final String reason;

  /// 発覚日時
  final DateTime discoveredDate;

  /// 支持率ダメージ（%）
  final double approvalDamage;

  /// 信頼度ダメージ（0-100）
  final double trustDamage;

  /// 経済的損失（$）
  final double economicLoss;

  BetrayalEvent({
    required this.id,
    required this.traitor,
    required this.reason,
    required this.discoveredDate,
    required this.approvalDamage,
    required this.trustDamage,
    required this.economicLoss,
  });

  /// 辞書に変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'traitor': traitor.name,
      'reason': reason,
      'discoveredDate': discoveredDate.toIso8601String(),
      'approvalDamage': approvalDamage,
      'trustDamage': trustDamage,
      'economicLoss': economicLoss,
    };
  }

  /// 辞書から生成
  factory BetrayalEvent.fromMap(Map<String, dynamic> map) {
    return BetrayalEvent(
      id: map['id'] as String? ?? '',
      traitor: MinisterRole.values.byName(map['traitor'] as String? ?? 'finance'),
      reason: map['reason'] as String? ?? '',
      discoveredDate: DateTime.tryParse(map['discoveredDate'] as String? ?? '') ?? DateTime.now(),
      approvalDamage: (map['approvalDamage'] as num?)?.toDouble() ?? 0.0,
      trustDamage: (map['trustDamage'] as num?)?.toDouble() ?? 0.0,
      economicLoss: (map['economicLoss'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// 内閣確執管理サービス
class CabinetInfightingService {
  /// 現在のキャビネット状態
  final Cabinet cabinet;

  /// 現在の大臣間確執
  final List<MinisterConflict> activeConflicts;

  /// 過去の背信イベント
  final List<BetrayalEvent> betrayalHistory;

  CabinetInfightingService({
    required this.cabinet,
    this.activeConflicts = const [],
    this.betrayalHistory = const [],
  });

  /// 大臣間の対立確率を計算（0-1）
  double calculateConflictProbability(MinisterRole role1, MinisterRole role2) {
    final loyalty1 = cabinet.of(role1);
    final loyalty2 = cabinet.of(role2);

    // 忠誠度の差が大きいほど対立が起きやすい
    final loyaltyDifference = (loyalty1 - loyalty2).abs();
    double probability = (loyaltyDifference / 100) * 0.3;

    // 両方とも低忠誠度なら対立しやすい
    if (loyalty1 < 40 && loyalty2 < 40) {
      probability += 0.2;
    }

    // 両方とも高忠誠度なら対立しにくい
    if (loyalty1 > 80 && loyalty2 > 80) {
      probability -= 0.1;
    }

    return probability.clamp(0.0, 1.0);
  }

  /// 背信の確率を計算（0-1）
  double calculateBetrayalProbability(MinisterRole role) {
    final loyalty = cabinet.of(role);

    // 忠誠度が低いほど背信しやすい
    // 40以下で検討開始、20以下で高リスク
    double probability = 0.0;

    if (loyalty < 40) {
      probability = (40 - loyalty) / 100 * 0.3;
    }

    if (loyalty < 20) {
      probability = 0.5;
    }

    // すでに背信している大臣は再度背信しない
    if (cabinet.betrayed.contains(role)) {
      probability = 0.0;
    }

    return probability.clamp(0.0, 1.0);
  }

  /// 内閣の不安定性を計算（0-100）
  /// 高いほど対立や背信が起こりやすい
  double calculateCabinetInstability() {
    double instability = 0.0;

    // 低忠誠度の大臣が多いほど不安定
    int disloyal = 0;
    for (final loyalty in cabinet.loyalty.values) {
      if (loyalty < 50) disloyal++;
    }
    instability += disloyal * 15;

    // アクティブな確執が多いほど不安定
    instability += activeConflicts.length * 10;

    // 対立の緊張度が高いほど不安定
    for (final conflict in activeConflicts) {
      instability += conflict.tensionLevel * 0.2;
    }

    // 忠誠度の分散が大きいほど不安定
    if (cabinet.loyalty.isNotEmpty) {
      final values = cabinet.loyalty.values.toList();
      final mean = values.fold(0.0, (sum, v) => sum + v) / values.length;
      final variance = values.fold(0.0, (sum, v) => sum + (v - mean) * (v - mean)) / values.length;
      instability += (variance / 1000); // 分散スケール
    }

    return instability.clamp(0.0, 100.0);
  }

  /// 大臣の忠誠度に基づく権力構造を計算
  /// 最も忠誠度が高い大臣を中心とした権力構造
  MinisterRole? getStrongestMinister() {
    MapEntry<MinisterRole, double>? strongest;
    for (final entry in cabinet.loyalty.entries) {
      if (strongest == null || entry.value > strongest.value) {
        strongest = entry;
      }
    }
    return strongest?.key;
  }

  /// 権力構造の動的計算
  /// 同盟と対立を表す
  Map<MinisterRole, List<MinisterRole>> calculatePowerAlliances() {
    final alliances = <MinisterRole, List<MinisterRole>>{};

    for (final role in MinisterRole.values) {
      alliances[role] = [];

      // 忠誠度が60以上なら同じグループ
      final roleLoyalty = cabinet.of(role);
      if (roleLoyalty < 40) continue; // 低忠誠度は同盟を組まない

      for (final other in MinisterRole.values) {
        if (role == other) continue;
        final otherLoyalty = cabinet.of(other);

        // 忠誠度の差が小さいほど同盟しやすい
        if ((roleLoyalty - otherLoyalty).abs() < 20 && otherLoyalty >= 40) {
          alliances[role]!.add(other);
        }
      }
    }

    return alliances;
  }

  /// 対立の緊張度を増加
  MinisterConflict escalateConflict(MinisterConflict conflict, double escalation) {
    return conflict.copyWith(
      tensionLevel: (conflict.tensionLevel + escalation).clamp(0.0, 100.0),
      lastConflictAction: DateTime.now(),
    );
  }

  /// 対立を緩和
  MinisterConflict deescalateConflict(MinisterConflict conflict, double reduction) {
    return conflict.copyWith(
      tensionLevel: (conflict.tensionLevel - reduction).clamp(0.0, 100.0),
      lastConflictAction: DateTime.now(),
    );
  }

  /// 対立が解決する可能性を計算
  bool shouldConflictResolve(MinisterConflict conflict) {
    // 緊張度が低い対立は自然に解決しやすい
    if (conflict.tensionLevel < 20) return Random().nextDouble() < 0.3;

    // 中程度の対立
    if (conflict.tensionLevel < 60) return Random().nextDouble() < 0.1;

    // 高い対立は自然には解決しない
    return false;
  }

  /// コピー・変更用メソッド
  CabinetInfightingService copyWith({
    Cabinet? cabinet,
    List<MinisterConflict>? activeConflicts,
    List<BetrayalEvent>? betrayalHistory,
  }) {
    return CabinetInfightingService(
      cabinet: cabinet ?? this.cabinet,
      activeConflicts: activeConflicts ?? this.activeConflicts,
      betrayalHistory: betrayalHistory ?? this.betrayalHistory,
    );
  }

  /// シリアライゼーション
  Map<String, dynamic> toMap() {
    return {
      'cabinet': cabinet.toMap(),
      'activeConflicts': activeConflicts.map((c) => c.toMap()).toList(),
      'betrayalHistory': betrayalHistory.map((b) => b.toMap()).toList(),
    };
  }

  factory CabinetInfightingService.fromMap(Map<String, dynamic> map) {
    return CabinetInfightingService(
      cabinet: Cabinet.fromMap(map['cabinet'] as Map<String, dynamic>?),
      activeConflicts: (map['activeConflicts'] as List?)
              ?.map((c) => MinisterConflict.fromMap(c as Map<String, dynamic>))
              .toList() ??
          [],
      betrayalHistory: (map['betrayalHistory'] as List?)
              ?.map((b) => BetrayalEvent.fromMap(b as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
