/// 国民世論調査サービス
/// 国民の意見をリアルタイムで追跡・分析

library;

import 'dart:math';

/// 世論調査のトピック
enum OpinionTopic {
  /// 経済政策
  economy,

  /// 社会福祉
  welfare,

  /// 教育
  education,

  /// 環境
  environment,

  /// 防衛・外交
  defense,

  /// 医療
  healthcare,

  /// インフラ・公共事業
  infrastructure,

  /// 税制
  taxation,
}

extension OpinionTopicExt on OpinionTopic {
  String get label {
    switch (this) {
      case OpinionTopic.economy:
        return '経済政策';
      case OpinionTopic.welfare:
        return '社会福祉';
      case OpinionTopic.education:
        return '教育';
      case OpinionTopic.environment:
        return '環境';
      case OpinionTopic.defense:
        return '防衛・外交';
      case OpinionTopic.healthcare:
        return '医療';
      case OpinionTopic.infrastructure:
        return 'インフラ';
      case OpinionTopic.taxation:
        return '税制';
    }
  }

  String get emoji {
    switch (this) {
      case OpinionTopic.economy:
        return '💰';
      case OpinionTopic.welfare:
        return '🤝';
      case OpinionTopic.education:
        return '📚';
      case OpinionTopic.environment:
        return '🌿';
      case OpinionTopic.defense:
        return '🛡️';
      case OpinionTopic.healthcare:
        return '⚕️';
      case OpinionTopic.infrastructure:
        return '🏗️';
      case OpinionTopic.taxation:
        return '🏦';
    }
  }
}

/// 国民の意見（承認度は別、これは特定トピックの優先度・満足度）
class CitizenOpinion {
  /// トピック
  final OpinionTopic topic;

  /// 優先度（0-100。国民がこのトピックをどれだけ重視しているか）
  double priority;

  /// 満足度（0-100。現在の政策に対する満足度）
  double satisfaction;

  /// 最後に測定された日時
  DateTime lastMeasured;

  /// 支持政策グループ（例：左翼、右翼、中道）
  String? preferredIdeology;

  CitizenOpinion({
    required this.topic,
    required this.priority,
    required this.satisfaction,
    required this.lastMeasured,
    this.preferredIdeology,
  });

  /// 意見スコア（優先度と満足度の組み合わせ）
  /// 高い＝トピックが重要で満足度が低い＝対応が急務
  double get urgencyScore => priority * ((100 - satisfaction) / 100);

  /// 世論の傾向（トレンド）
  String getTrend(CitizenOpinion? previous) {
    if (previous == null) return '新規追跡';

    final satisfactionChange = satisfaction - previous.satisfaction;
    if (satisfactionChange > 5) return '改善中';
    if (satisfactionChange < -5) return '悪化中';
    return '横ばい';
  }

  /// コピー・変更用メソッド
  CitizenOpinion copyWith({
    OpinionTopic? topic,
    double? priority,
    double? satisfaction,
    DateTime? lastMeasured,
    String? preferredIdeology,
  }) {
    return CitizenOpinion(
      topic: topic ?? this.topic,
      priority: priority ?? this.priority,
      satisfaction: satisfaction ?? this.satisfaction,
      lastMeasured: lastMeasured ?? this.lastMeasured,
      preferredIdeology: preferredIdeology ?? this.preferredIdeology,
    );
  }

  /// 辞書に変換
  Map<String, dynamic> toMap() {
    return {
      'topic': topic.name,
      'priority': priority,
      'satisfaction': satisfaction,
      'lastMeasured': lastMeasured.toIso8601String(),
      'preferredIdeology': preferredIdeology,
    };
  }

  /// 辞書から生成
  factory CitizenOpinion.fromMap(Map<String, dynamic> map) {
    return CitizenOpinion(
      topic: OpinionTopic.values.byName(map['topic'] as String? ?? 'economy'),
      priority: (map['priority'] as num?)?.toDouble() ?? 50.0,
      satisfaction: (map['satisfaction'] as num?)?.toDouble() ?? 50.0,
      lastMeasured: DateTime.tryParse(map['lastMeasured'] as String? ?? '') ?? DateTime.now(),
      preferredIdeology: map['preferredIdeology'] as String?,
    );
  }
}

/// 世論調査の結果
class SurveyResult {
  /// 調査ID
  final String id;

  /// 調査日時
  final DateTime surveyDate;

  /// サンプルサイズ（信頼度に影響）
  final int sampleSize;

  /// 調査対象の意見マップ
  final Map<OpinionTopic, CitizenOpinion> opinions;

  /// 全体的な国民心理（0-100の平均満足度）
  double get averageSatisfaction {
    if (opinions.isEmpty) return 50.0;
    return opinions.values.fold(0.0, (sum, op) => sum + op.satisfaction) / opinions.length;
  }

  /// 信頼度（サンプルサイズに基づく）
  double get confidenceLevel => (sampleSize / 2000).clamp(0.0, 1.0) * 100;

  /// 最も優先度が高いトピック
  OpinionTopic? get topPriority {
    if (opinions.isEmpty) return null;
    var maxTopic = opinions.entries.first;
    for (final entry in opinions.entries) {
      if (entry.value.priority > maxTopic.value.priority) {
        maxTopic = entry;
      }
    }
    return maxTopic.key;
  }

  /// 最も満足度が低いトピック
  OpinionTopic? get mostDissatisfied {
    if (opinions.isEmpty) return null;
    var minTopic = opinions.entries.first;
    for (final entry in opinions.entries) {
      if (entry.value.satisfaction < minTopic.value.satisfaction) {
        minTopic = entry;
      }
    }
    return minTopic.key;
  }

  SurveyResult({
    required this.id,
    required this.surveyDate,
    required this.sampleSize,
    required this.opinions,
  });

  /// 辞書に変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surveyDate': surveyDate.toIso8601String(),
      'sampleSize': sampleSize,
      'opinions': opinions.map((key, value) => MapEntry(key.name, value.toMap())),
    };
  }

  /// 辞書から生成
  factory SurveyResult.fromMap(Map<String, dynamic> map) {
    final opinionsMap = <OpinionTopic, CitizenOpinion>{};
    final rawOpinions = map['opinions'] as Map<String, dynamic>?;
    if (rawOpinions != null) {
      for (final entry in rawOpinions.entries) {
        final topic = OpinionTopic.values.byName(entry.key);
        opinionsMap[topic] = CitizenOpinion.fromMap(entry.value as Map<String, dynamic>);
      }
    }

    return SurveyResult(
      id: map['id'] as String? ?? '',
      surveyDate: DateTime.tryParse(map['surveyDate'] as String? ?? '') ?? DateTime.now(),
      sampleSize: map['sampleSize'] as int? ?? 1000,
      opinions: opinionsMap,
    );
  }
}

/// 国民世論調査管理サービス
class CitizenSurveyService {
  /// 過去の調査結果
  final List<SurveyResult> surveyHistory;

  /// 現在の世論
  final Map<OpinionTopic, CitizenOpinion> currentOpinions;

  CitizenSurveyService({
    this.surveyHistory = const [],
    this.currentOpinions = const {},
  });

  /// 新しい世論調査を実施
  SurveyResult conductSurvey({
    required double approval,
    required double gdp,
    required double unemployment,
    required double stability,
    int sampleSize = 1000,
  }) {
    final random = Random();
    final opinions = <OpinionTopic, CitizenOpinion>{};

    // 各トピックの意見を生成
    for (final topic in OpinionTopic.values) {
      // トピックの優先度：ゲーム状態に基づいて変動
      double priority = 50.0 + random.nextDouble() * 30 - 15; // 35-65

      // 失業率が高いと経済トピックの優先度が上がる
      if (topic == OpinionTopic.economy && unemployment > 3) {
        priority += (unemployment - 3) * 10;
      }

      // 安定度が低いと防衛トピックの優先度が上がる
      if (topic == OpinionTopic.defense && stability < 50) {
        priority += (50 - stability) * 0.5;
      }

      // 承認度に基づいて満足度を決定
      double satisfaction = approval + random.nextDouble() * 20 - 10;
      satisfaction = satisfaction.clamp(0.0, 100.0);

      opinions[topic] = CitizenOpinion(
        topic: topic,
        priority: priority.clamp(0.0, 100.0),
        satisfaction: satisfaction,
        lastMeasured: DateTime.now(),
      );
    }

    return SurveyResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      surveyDate: DateTime.now(),
      sampleSize: sampleSize,
      opinions: opinions,
    );
  }

  /// 特定トピックの満足度を更新
  void updateTopicSatisfaction(OpinionTopic topic, double changeAmount) {
    final opinion = currentOpinions[topic];
    if (opinion != null) {
      currentOpinions[topic] = opinion.copyWith(
        satisfaction: (opinion.satisfaction + changeAmount).clamp(0.0, 100.0),
      );
    }
  }

  /// トピック優先度の時間経過による減衰
  void decayPriorities() {
    for (final entry in currentOpinions.entries) {
      final opinion = entry.value;
      // 優先度は週ごとに50%まで減衰（低下する）
      currentOpinions[entry.key] = opinion.copyWith(
        priority: opinion.priority * 0.95,
      );
    }
  }

  /// 世論の分裂度を計算（0-100）
  /// 各トピックの優先度がどれだけばらつているか
  double calculatePolarization() {
    if (currentOpinions.isEmpty) return 0.0;

    final priorities = currentOpinions.values.map((op) => op.priority).toList();
    final mean = priorities.fold(0.0, (sum, p) => sum + p) / priorities.length;
    final variance = priorities.fold(0.0, (sum, p) => sum + (p - mean) * (p - mean)) / priorities.length;
    final stdDev = sqrt(variance);

    return (stdDev / 50).clamp(0.0, 100.0);
  }

  /// 複数トピック間の意見の一致度（0-100）
  /// 高い＝世論が一致している、低い＝分裂している
  double calculateConsensus() {
    return 100 - calculatePolarization();
  }

  /// 過去の調査との比較
  Map<OpinionTopic, double> compareWithPrevious(SurveyResult previous) {
    final changes = <OpinionTopic, double>{};

    for (final topic in OpinionTopic.values) {
      final currentSatisfaction = currentOpinions[topic]?.satisfaction ?? 50.0;
      final previousSatisfaction = previous.opinions[topic]?.satisfaction ?? 50.0;
      changes[topic] = currentSatisfaction - previousSatisfaction;
    }

    return changes;
  }

  /// 世論調査をコピー・変更
  CitizenSurveyService copyWith({
    List<SurveyResult>? surveyHistory,
    Map<OpinionTopic, CitizenOpinion>? currentOpinions,
  }) {
    return CitizenSurveyService(
      surveyHistory: surveyHistory ?? this.surveyHistory,
      currentOpinions: currentOpinions ?? this.currentOpinions,
    );
  }

  /// シリアライゼーション
  Map<String, dynamic> toMap() {
    return {
      'surveyHistory': surveyHistory.map((s) => s.toMap()).toList(),
      'currentOpinions': currentOpinions.map(
        (key, value) => MapEntry(key.name, value.toMap()),
      ),
    };
  }

  factory CitizenSurveyService.fromMap(Map<String, dynamic> map) {
    final history = (map['surveyHistory'] as List?)
            ?.map((s) => SurveyResult.fromMap(s as Map<String, dynamic>))
            .toList() ??
        [];

    final opinionsMap = <OpinionTopic, CitizenOpinion>{};
    final rawOpinions = map['currentOpinions'] as Map<String, dynamic>?;
    if (rawOpinions != null) {
      for (final entry in rawOpinions.entries) {
        final topic = OpinionTopic.values.byName(entry.key);
        opinionsMap[topic] = CitizenOpinion.fromMap(entry.value as Map<String, dynamic>);
      }
    }

    return CitizenSurveyService(
      surveyHistory: history,
      currentOpinions: opinionsMap,
    );
  }
}
