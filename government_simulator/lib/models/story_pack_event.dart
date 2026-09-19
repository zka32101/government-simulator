/// ストーリーパックイベントモデル
/// パック内で発生する物語的イベント、危機、チャンス
library;

/// パックイベント：シナリオプレイ中に発生する重要なイベント
class StoryPackEvent {
  final String id;
  final String packId; // このイベントが属するパック
  final String title;
  final String description;
  final String eventType; // 'crisis', 'opportunity', 'plot_twist', 'decision_point'
  final String theme; // 'economic', 'military', 'diplomatic', 'social'

  /// イベント発生条件
  final int? triggerYear; // 発生可能になる年（triggerYearMaxがnullなら、この年ちょうどに発生）
  final int? triggerYearMax; // 発生可能な年の範囲の終端（triggerYearと合わせて「n年目〜m年目のどこか」を表す）
  final List<String> triggerScenarioIds; // どのシナリオで発生するか
  final String? triggerCondition; // 条件文（例：gdp < 500）

  /// イベント内容
  final String storyText; // イベント説明テキスト（300-500語）
  final List<String> affectedIndicators; // 影響を受ける指標 (gdp, satisfaction, etc)
  final Map<String, dynamic> impacts; // 各指標への影響

  /// 選択肢（分岐）
  final List<StoryPackEventChoice> choices;

  /// メタデータ
  final int priority; // 優先度 (1-5)
  final bool isUnique; // 一度だけ発生するか
  final String? followUpEventId; // 後続イベント
  final List<String> tags;

  const StoryPackEvent({
    required this.id,
    required this.packId,
    required this.title,
    required this.description,
    required this.eventType,
    required this.theme,
    this.triggerYear,
    this.triggerYearMax,
    required this.triggerScenarioIds,
    this.triggerCondition,
    required this.storyText,
    required this.affectedIndicators,
    required this.impacts,
    required this.choices,
    required this.priority,
    this.isUnique = false,
    this.followUpEventId,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'packId': packId,
      'title': title,
      'description': description,
      'eventType': eventType,
      'theme': theme,
      'triggerYear': triggerYear,
      'triggerYearMax': triggerYearMax,
      'triggerScenarioIds': triggerScenarioIds,
      'triggerCondition': triggerCondition,
      'storyText': storyText,
      'affectedIndicators': affectedIndicators,
      'impacts': impacts,
      'choices': choices.map((c) => c.toMap()).toList(),
      'priority': priority,
      'isUnique': isUnique,
      'followUpEventId': followUpEventId,
      'tags': tags,
    };
  }

  factory StoryPackEvent.fromMap(Map<String, dynamic> map) {
    return StoryPackEvent(
      id: map['id'] as String,
      packId: map['packId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      eventType: map['eventType'] as String,
      theme: map['theme'] as String,
      triggerYear: map['triggerYear'] as int?,
      triggerYearMax: map['triggerYearMax'] as int?,
      triggerScenarioIds: List<String>.from(map['triggerScenarioIds'] as List),
      triggerCondition: map['triggerCondition'] as String?,
      storyText: map['storyText'] as String,
      affectedIndicators: List<String>.from(map['affectedIndicators'] as List),
      impacts: map['impacts'] as Map<String, dynamic>,
      choices: (map['choices'] as List)
          .map((c) => StoryPackEventChoice.fromMap(c as Map<String, dynamic>))
          .toList(),
      priority: map['priority'] as int,
      isUnique: map['isUnique'] as bool? ?? false,
      followUpEventId: map['followUpEventId'] as String?,
      tags: List<String>.from(map['tags'] as List),
    );
  }
}

/// イベント選択肢
class StoryPackEventChoice {
  final String id;
  final String title;
  final String description; // 選択肢の説明
  final Map<String, dynamic> outcomes; // 選択の結果（影響値）
  final String? consequenceText; // 選択後のテキスト
  final String? followUpEventId; // この選択による後続イベント
  final int difficulty; // 1-5: この選択の難易度

  const StoryPackEventChoice({
    required this.id,
    required this.title,
    required this.description,
    required this.outcomes,
    this.consequenceText,
    this.followUpEventId,
    required this.difficulty,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'outcomes': outcomes,
      'consequenceText': consequenceText,
      'followUpEventId': followUpEventId,
      'difficulty': difficulty,
    };
  }

  factory StoryPackEventChoice.fromMap(Map<String, dynamic> map) {
    return StoryPackEventChoice(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      outcomes: map['outcomes'] as Map<String, dynamic>,
      consequenceText: map['consequenceText'] as String?,
      followUpEventId: map['followUpEventId'] as String?,
      difficulty: map['difficulty'] as int,
    );
  }
}

/// イベント進捗追跡
class StoryPackEventProgress {
  final String eventId;
  final bool isTriggered;
  final DateTime? triggeredAt;
  final String? selectedChoiceId;
  final bool isCompleted;

  const StoryPackEventProgress({
    required this.eventId,
    required this.isTriggered,
    this.triggeredAt,
    this.selectedChoiceId,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'isTriggered': isTriggered,
      'triggeredAt': triggeredAt?.toIso8601String(),
      'selectedChoiceId': selectedChoiceId,
      'isCompleted': isCompleted,
    };
  }

  factory StoryPackEventProgress.fromMap(Map<String, dynamic> map) {
    return StoryPackEventProgress(
      eventId: map['eventId'] as String,
      isTriggered: map['isTriggered'] as bool,
      triggeredAt: map['triggeredAt'] != null
          ? DateTime.parse(map['triggeredAt'] as String)
          : null,
      selectedChoiceId: map['selectedChoiceId'] as String?,
      isCompleted: map['isCompleted'] as bool,
    );
  }
}
