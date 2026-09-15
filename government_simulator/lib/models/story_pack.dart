/// ストーリーパックモデル
/// 複数のシナリオをテーマ別に組織化し、ナラティブな体験を提供

library;

/// ストーリーパック：テーマ別にシナリオをグループ化
class StoryPack {
  final String id;
  final String title;
  final String description;
  final String theme; // economic, political, diplomatic, regional など
  final String emoji;
  final String region; // ヨーロッパ、南米、北欧 など
  final int order; // 表示順序
  final List<String> scenarioIds; // このパックに含まれるシナリオID
  final String? backgroundStory; // パック全体の背景ストーリー
  final List<String> tags; // ゲームプレイテーマ（例：経済、紛争、外交）
  final bool isLocked; // ロック状態
  final String? unlockedCondition; // アンロック条件

  const StoryPack({
    required this.id,
    required this.title,
    required this.description,
    required this.theme,
    required this.emoji,
    required this.region,
    required this.order,
    required this.scenarioIds,
    this.backgroundStory,
    required this.tags,
    this.isLocked = false,
    this.unlockedCondition,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'theme': theme,
      'emoji': emoji,
      'region': region,
      'order': order,
      'scenarioIds': scenarioIds,
      'backgroundStory': backgroundStory,
      'tags': tags,
      'isLocked': isLocked,
      'unlockedCondition': unlockedCondition,
    };
  }

  factory StoryPack.fromMap(Map<String, dynamic> map) {
    return StoryPack(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      theme: map['theme'] as String,
      emoji: map['emoji'] as String,
      region: map['region'] as String,
      order: map['order'] as int,
      scenarioIds: List<String>.from(map['scenarioIds'] as List),
      backgroundStory: map['backgroundStory'] as String?,
      tags: List<String>.from(map['tags'] as List),
      isLocked: map['isLocked'] as bool? ?? false,
      unlockedCondition: map['unlockedCondition'] as String?,
    );
  }
}

/// ストーリーパック進捗：プレイヤーの進行状況を追跡
class StoryPackProgress {
  final String packId;
  final int completedScenarios; // 完了したシナリオ数
  final double averageScore; // 平均スコア (0-100)
  final DateTime lastPlayedDate;
  final bool isCompleted; // パック全体が完了したか

  const StoryPackProgress({
    required this.packId,
    required this.completedScenarios,
    required this.averageScore,
    required this.lastPlayedDate,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'packId': packId,
      'completedScenarios': completedScenarios,
      'averageScore': averageScore,
      'lastPlayedDate': lastPlayedDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory StoryPackProgress.fromMap(Map<String, dynamic> map) {
    return StoryPackProgress(
      packId: map['packId'] as String,
      completedScenarios: map['completedScenarios'] as int,
      averageScore: (map['averageScore'] as num).toDouble(),
      lastPlayedDate: DateTime.parse(map['lastPlayedDate'] as String),
      isCompleted: map['isCompleted'] as bool,
    );
  }
}
