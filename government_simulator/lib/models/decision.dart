import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/event.dart';

class Decision {
  final String id;
  final String sessionId;
  final String eventId;
  final String chosenChoiceId;
  final DateTime decidedAt;

  // 結果記録
  final CountryStatus beforeStatus;
  final CountryStatus afterStatus;
  final String narrative; // 意思決定の結果ナレーション

  // ゲーム性向上
  final Impact appliedImpact;
  final bool wasPositiveOutcome; // 期待値の結果判定
  final double impactScore; // -100 to 100

  const Decision({
    required this.id,
    required this.sessionId,
    required this.eventId,
    required this.chosenChoiceId,
    required this.decidedAt,
    required this.beforeStatus,
    required this.afterStatus,
    required this.narrative,
    required this.appliedImpact,
    required this.wasPositiveOutcome,
    required this.impactScore,
  });

  // 意思決定による変化量
  double get gdpDelta => afterStatus.gdp - beforeStatus.gdp;
  double get unemploymentDelta => afterStatus.unemployment - beforeStatus.unemployment;
  double get satisfactionDelta => afterStatus.satisfaction - beforeStatus.satisfaction;
  double get nationalPowerDelta => afterStatus.nationalPower - beforeStatus.nationalPower;

  // 意思決定が国家に与えた複合効果を評価
  String get evaluationLabel {
    if (impactScore > 50) return '卓越した決定';
    if (impactScore > 20) return '良い決定';
    if (impactScore > -20) return '平凡な決定';
    if (impactScore > -50) return '悪い決定';
    return '失敗した決定';
  }

  // 時系列での影響が可視化されているか
  bool get hasVisualFeedback => true;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'eventId': eventId,
      'chosenChoiceId': chosenChoiceId,
      'decidedAt': decidedAt.toIso8601String(),
      'beforeStatus': beforeStatus.toMap(),
      'afterStatus': afterStatus.toMap(),
      'narrative': narrative,
      'appliedImpact': appliedImpact.toMap(),
      'wasPositiveOutcome': wasPositiveOutcome,
      'impactScore': impactScore,
    };
  }

  factory Decision.fromMap(Map<String, dynamic> map) {
    return Decision(
      id: map['id'] ?? '',
      sessionId: map['sessionId'] ?? '',
      eventId: map['eventId'] ?? '',
      chosenChoiceId: map['chosenChoiceId'] ?? '',
      decidedAt: map['decidedAt'] != null
          ? DateTime.parse(map['decidedAt'])
          : DateTime.now(),
      beforeStatus: map['beforeStatus'] != null
          ? CountryStatus.fromMap(map['beforeStatus'])
          : CountryStatus(
              gdp: 1000,
              unemployment: 5,
              satisfaction: 50,
              nationalPower: 50,
              year: 1,
              day: 1,
              lastUpdated: DateTime.now(),
            ),
      afterStatus: map['afterStatus'] != null
          ? CountryStatus.fromMap(map['afterStatus'])
          : CountryStatus(
              gdp: 1000,
              unemployment: 5,
              satisfaction: 50,
              nationalPower: 50,
              year: 1,
              day: 1,
              lastUpdated: DateTime.now(),
            ),
      narrative: map['narrative'] ?? '',
      appliedImpact:
          map['appliedImpact'] != null ? Impact.fromMap(map['appliedImpact']) : Impact(),
      wasPositiveOutcome: map['wasPositiveOutcome'] ?? false,
      impactScore: (map['impactScore'] ?? 0.0).toDouble(),
    );
  }
}

// 決定の履歴を時系列で管理
class DecisionHistory {
  final List<Decision> decisions;

  const DecisionHistory(this.decisions);

  // 直近N件の決定
  List<Decision> getRecentDecisions({int count = 10}) {
    final sorted = List<Decision>.from(decisions)
      ..sort((a, b) => b.decidedAt.compareTo(a.decidedAt));
    return sorted.take(count).toList();
  }

  // 時系列でのGDP推移
  List<({DateTime date, double gdp})> getGdpTimeline() {
    final sorted = List<Decision>.from(decisions)
      ..sort((a, b) => a.decidedAt.compareTo(b.decidedAt));
    return sorted.map((d) => (date: d.decidedAt, gdp: d.afterStatus.gdp)).toList();
  }

  // 時系列での満足度推移
  List<({DateTime date, double satisfaction})> getSatisfactionTimeline() {
    final sorted = List<Decision>.from(decisions)
      ..sort((a, b) => a.decidedAt.compareTo(b.decidedAt));
    return sorted.map((d) => (date: d.decidedAt, satisfaction: d.afterStatus.satisfaction)).toList();
  }

  // 平均インパクトスコア
  double get averageImpactScore {
    if (decisions.isEmpty) return 0;
    return decisions.fold(0.0, (sum, d) => sum + d.impactScore) / decisions.length;
  }

  // 成功率（ポジティブアウトカムの割合）
  double get successRate {
    if (decisions.isEmpty) return 0;
    final positive = decisions.where((d) => d.wasPositiveOutcome).length;
    return (positive / decisions.length) * 100;
  }
}
