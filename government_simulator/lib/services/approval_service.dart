/// 承認度管理サービス
/// 市民満足度を承認度に変換し、危機トリガーを判定

import 'package:government_simulator/models/crisis.dart';
import 'package:government_simulator/models/game_session.dart';

/// 承認度計算・管理サービス
class ApprovalService {
  /// 現在の国民承認度（0-100）
  double currentApproval;

  /// 承認度変化の履歴
  final List<ApprovalChange> history;

  ApprovalService({
    this.currentApproval = 50.0,
    List<ApprovalChange>? history,
  }) : history = history ?? [];

  /// 市民満足度スコアから承認度を計算
  /// 4つの満足度スコアの平均が承認度になる
  double calculateApprovalFromSatisfaction({
    required double economicSatisfaction,
    required double socialSatisfaction,
    required double securitySatisfaction,
    required double healthcareSatisfaction,
  }) {
    final average = (economicSatisfaction +
            socialSatisfaction +
            securitySatisfaction +
            healthcareSatisfaction) /
        4;
    return average.clamp(0.0, 100.0);
  }

  /// 週間の承認度変化を適用
  void applyWeeklyChange(double change, String reason) {
    currentApproval = (currentApproval + change).clamp(0.0, 100.0);
    history.add(ApprovalChange(
      date: DateTime.now(),
      change: change,
      reason: reason,
    ));
  }

  /// 危機による承認度影響を適用
  void applyCrisisImpact(Crisis crisis) {
    final impact = crisis.getApprovalImpact();
    applyWeeklyChange(impact, '危機: ${crisis.type.toString().split('.').last}');
  }

  /// 政策による承認度変化
  void applyPolicyImpact(
    String policyName, {
    required double economicChange,
    required double socialChange,
    required double securityChange,
    required double healthcareChange,
  }) {
    // 各セクターへの影響を平均化
    final avgChange =
        (economicChange + socialChange + securityChange + healthcareChange) / 4;
    applyWeeklyChange(avgChange, 'ポリシー: $policyName');
  }

  /// 現在の危機リスクレベルを取得
  CrisisRiskLevel getRiskLevel() {
    if (currentApproval >= 60) {
      return CrisisRiskLevel.stable;
    } else if (currentApproval >= 45) {
      return CrisisRiskLevel.tensionRising;
    } else if (currentApproval >= 30) {
      return CrisisRiskLevel.highDanger;
    } else {
      return CrisisRiskLevel.critical;
    }
  }

  /// 次に起こりやすい危機のリストを取得
  List<CrisisType> getProbableCrises() {
    final riskLevel = getRiskLevel();
    final crises = <CrisisType>[];

    // 承認度に応じた危機確率
    switch (riskLevel) {
      case CrisisRiskLevel.stable:
        // リスクなし
        break;
      case CrisisRiskLevel.tensionRising:
        crises.add(CrisisType.demonstration);
        break;
      case CrisisRiskLevel.highDanger:
        crises.add(CrisisType.demonstration);
        crises.add(CrisisType.riot);
        crises.add(CrisisType.laborStrike);
        break;
      case CrisisRiskLevel.critical:
        crises.add(CrisisType.demonstration);
        crises.add(CrisisType.riot);
        crises.add(CrisisType.laborStrike);
        crises.add(CrisisType.militaryCoup);
        break;
    }

    return crises;
  }

  /// 危機トリガー確率を計算
  /// 承認度と危機タイプから発生確率を算出
  double calculateCrisisProbability(CrisisType type) {
    final riskLevel = getRiskLevel();

    // ベース確率
    double baseProbability = switch (type) {
      CrisisType.demonstration =>
        0.20 + (60 - currentApproval.clamp(0, 60)) / 60 * 0.1,
      CrisisType.riot =>
        0.15 + (45 - currentApproval.clamp(0, 45)) / 45 * 0.15,
      CrisisType.laborStrike => 0.10,
      CrisisType.economicCrisis => 0.05,
      CrisisType.militaryCoup =>
        currentApproval < 30 ? 0.20 + (30 - currentApproval) / 30 * 0.2 : 0.0,
    };

    return baseProbability.clamp(0.0, 1.0);
  }

  /// 承認度の復旧効果
  void applyApprovalRecovery(double amount, String reason) {
    applyWeeklyChange(amount, '復旧: $reason');
  }

  /// スキャンダルが承認度に与える影響
  void applyScandal(String scandalName, double intensity) {
    // 強度に応じた承認度低下（0-1の強度を-20から-50%に変換）
    final impact = -(intensity * 30 + 20);
    applyWeeklyChange(impact, 'スキャンダル: $scandalName');
  }

  /// 選挙成功による承認度上昇
  void applyElectionVictory(double margin) {
    // 勝利の余裕に応じた承認度上昇
    final boost = (margin / 100) * 15 + 5;
    applyWeeklyChange(boost, '選挙勝利: ${margin.toStringAsFixed(1)}%');
  }

  /// 外交的成功による承認度上昇
  void applyDiplomaticSuccess(String eventName, double impact) {
    applyWeeklyChange(impact, '外交的成功: $eventName');
  }

  /// コピーメソッド
  ApprovalService copyWith({
    double? currentApproval,
    List<ApprovalChange>? history,
  }) {
    return ApprovalService(
      currentApproval: currentApproval ?? this.currentApproval,
      history: history ?? List.from(this.history),
    );
  }

  /// シリアライゼーション
  Map<String, dynamic> toMap() {
    return {
      'currentApproval': currentApproval,
      'history': history.map((h) => h.toMap()).toList(),
    };
  }

  factory ApprovalService.fromMap(Map<String, dynamic> map) {
    return ApprovalService(
      currentApproval: (map['currentApproval'] as num?)?.toDouble() ?? 50.0,
      history: (map['history'] as List?)
              ?.map((h) => ApprovalChange.fromMap(h as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
