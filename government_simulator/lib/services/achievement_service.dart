/// 実績・称号システム
/// 業績の追跡、進捗表示、未ロック実績の管理

library;

import 'package:government_simulator/models/achievement.dart';
import 'package:government_simulator/models/game_session.dart';

/// 実績の難易度/レアリティ
enum AchievementRarity {
  /// 一般的（ほとんどのプレイで達成可能）
  common,

  /// 稀有（意識的な努力が必要）
  uncommon,

  /// レア（困難な達成）
  rare,

  /// 伝説的（非常に稀有）
  legendary,

  /// シークレット（隠された条件）
  secret,
}

extension AchievementRarityExt on AchievementRarity {
  String get label {
    switch (this) {
      case AchievementRarity.common:
        return '一般的';
      case AchievementRarity.uncommon:
        return '稀有';
      case AchievementRarity.rare:
        return 'レア';
      case AchievementRarity.legendary:
        return '伝説的';
      case AchievementRarity.secret:
        return 'シークレット';
    }
  }

  /// 表示用の色（アンロック難易度を視覚化）
  String get colorHex {
    switch (this) {
      case AchievementRarity.common:
        return '#808080'; // グレー
      case AchievementRarity.uncommon:
        return '#00FF00'; // 緑
      case AchievementRarity.rare:
        return '#0000FF'; // 青
      case AchievementRarity.legendary:
        return '#FFD700'; // 金
      case AchievementRarity.secret:
        return '#9932CC'; // 紫
    }
  }
}

/// 実績の進捗を表す
class AchievementProgress {
  /// 実績ID
  final String achievementId;

  /// 達成の進捗（0-100%）
  final double progress;

  /// 進捗の詳細（例：GDP 1500 / 2000）
  final String? detail;

  /// 最後に更新された時刻
  final DateTime lastUpdated;

  const AchievementProgress({
    required this.achievementId,
    required this.progress,
    this.detail,
    required this.lastUpdated,
  });

  /// コピー・変更用メソッド
  AchievementProgress copyWith({
    String? achievementId,
    double? progress,
    String? detail,
    DateTime? lastUpdated,
  }) {
    return AchievementProgress(
      achievementId: achievementId ?? this.achievementId,
      progress: progress ?? this.progress,
      detail: detail ?? this.detail,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// 辞書に変換
  Map<String, dynamic> toMap() {
    return {
      'achievementId': achievementId,
      'progress': progress,
      'detail': detail,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// 辞書から生成
  factory AchievementProgress.fromMap(Map<String, dynamic> map) {
    return AchievementProgress(
      achievementId: map['achievementId'] as String? ?? '',
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      detail: map['detail'] as String?,
      lastUpdated: DateTime.tryParse(map['lastUpdated'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// 実績アンロック記録
class AchievementUnlock {
  /// 実績ID
  final String achievementId;

  /// アンロック日時
  final DateTime unlockedAt;

  /// アンロック時の状態（ゲーム進行状況）
  final Map<String, dynamic> gameStateSnapshot;

  const AchievementUnlock({
    required this.achievementId,
    required this.unlockedAt,
    required this.gameStateSnapshot,
  });

  /// 辞書に変換
  Map<String, dynamic> toMap() {
    return {
      'achievementId': achievementId,
      'unlockedAt': unlockedAt.toIso8601String(),
      'gameStateSnapshot': gameStateSnapshot,
    };
  }

  /// 辞書から生成
  factory AchievementUnlock.fromMap(Map<String, dynamic> map) {
    return AchievementUnlock(
      achievementId: map['achievementId'] as String? ?? '',
      unlockedAt: DateTime.tryParse(map['unlockedAt'] as String? ?? '') ?? DateTime.now(),
      gameStateSnapshot: map['gameStateSnapshot'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// 実績管理サービス
class AchievementService {
  /// アンロック済みの実績
  final List<AchievementUnlock> unlockedAchievements;

  /// 進捗中の実績
  final Map<String, AchievementProgress> achievementProgress;

  AchievementService({
    this.unlockedAchievements = const [],
    this.achievementProgress = const {},
  });

  /// 新しくアンロックされた実績を検出
  List<AchievementUnlock> detectNewAchievements(
    GameSession session,
    List<String> alreadyUnlockedIds,
  ) {
    final newAchievements = <AchievementUnlock>[];
    final newUnlockedIds = Achievements.checkNew(session, alreadyUnlockedIds);

    for (final achievement in newUnlockedIds) {
      newAchievements.add(
        AchievementUnlock(
          achievementId: achievement.id,
          unlockedAt: DateTime.now(),
          gameStateSnapshot: {
            'year': session.status.year,
            'day': session.status.day,
            'gdp': session.status.gdp,
            'satisfaction': session.status.satisfaction,
            'stability': session.status.stability,
            'nationalPower': session.status.nationalPower,
            'totalDecisions': session.totalDecisions,
          },
        ),
      );
    }

    return newAchievements;
  }

  /// 実績のレアリティを取得
  AchievementRarity getAchievementRarity(String achievementId) {
    return switch (achievementId) {
      'first_year' => AchievementRarity.common,
      'economic_boom' => AchievementRarity.rare,
      'beloved_leader' => AchievementRarity.rare,
      'full_employment' => AchievementRarity.uncommon,
      'superpower' => AchievementRarity.legendary,
      'iron_stability' => AchievementRarity.uncommon,
      'veteran_leader' => AchievementRarity.uncommon,
      'perfect_score' => AchievementRarity.rare,
      'decisive' => AchievementRarity.common,
      'high_success' => AchievementRarity.uncommon,
      _ => AchievementRarity.common,
    };
  }

  /// 実績進捗を更新
  AchievementProgress updateProgress(
    String achievementId,
    double progress,
    String? detail,
  ) {
    final updated = AchievementProgress(
      achievementId: achievementId,
      progress: progress.clamp(0.0, 100.0),
      detail: detail,
      lastUpdated: DateTime.now(),
    );

    return updated;
  }

  /// 全実績の進捗を計算
  Map<String, AchievementProgress> calculateAllProgress(GameSession session) {
    final progress = <String, AchievementProgress>{};

    // GDP進捗
    progress['economic_boom'] = AchievementProgress(
      achievementId: 'economic_boom',
      progress: (session.status.gdp / 2000 * 100).clamp(0.0, 100.0),
      detail: 'GDP: ${session.status.gdp.toStringAsFixed(1)}B / 2000B',
      lastUpdated: DateTime.now(),
    );

    // 満足度進捗
    progress['beloved_leader'] = AchievementProgress(
      achievementId: 'beloved_leader',
      progress: session.status.satisfaction,
      detail: '満足度: ${session.status.satisfaction.toStringAsFixed(1)}% / 90%',
      lastUpdated: DateTime.now(),
    );

    // 失業率進捗
    progress['full_employment'] = AchievementProgress(
      achievementId: 'full_employment',
      progress: ((2 - session.status.unemployment) / 2 * 100).clamp(0.0, 100.0),
      detail: '失業率: ${session.status.unemployment.toStringAsFixed(2)}% / 2%未満',
      lastUpdated: DateTime.now(),
    );

    // 国力進捗
    progress['superpower'] = AchievementProgress(
      achievementId: 'superpower',
      progress: (session.status.nationalPower / 90 * 100).clamp(0.0, 100.0),
      detail: '国力: ${session.status.nationalPower.toStringAsFixed(1)} / 90',
      lastUpdated: DateTime.now(),
    );

    // 安定度進捗
    progress['iron_stability'] = AchievementProgress(
      achievementId: 'iron_stability',
      progress: session.status.stability,
      detail: '安定度: ${session.status.stability.toStringAsFixed(1)}% / 95%',
      lastUpdated: DateTime.now(),
    );

    // 健全度進捗
    progress['perfect_score'] = AchievementProgress(
      achievementId: 'perfect_score',
      progress: (session.status.healthScore / 85 * 100).clamp(0.0, 100.0),
      detail: '健全度: ${session.status.healthScore.toStringAsFixed(1)} / 85',
      lastUpdated: DateTime.now(),
    );

    // 決定数進捗
    progress['decisive'] = AchievementProgress(
      achievementId: 'decisive',
      progress: (session.totalDecisions / 50 * 100).clamp(0.0, 100.0),
      detail: '決定数: ${session.totalDecisions} / 50',
      lastUpdated: DateTime.now(),
    );

    return progress;
  }

  /// 実績達成率を計算
  double calculateCompletionRate(List<String> allAchievementIds) {
    if (allAchievementIds.isEmpty) return 0.0;

    final unlockedCount = unlockedAchievements
        .where((u) => allAchievementIds.contains(u.achievementId))
        .length;

    return (unlockedCount / allAchievementIds.length) * 100;
  }

  /// 実績のカテゴリ別統計
  Map<String, int> getAchievementStats() {
    final stats = <String, int>{
      'common': 0,
      'uncommon': 0,
      'rare': 0,
      'legendary': 0,
      'secret': 0,
    };

    for (final unlock in unlockedAchievements) {
      final rarity = _mockGetRarity(unlock.achievementId);
      stats[rarity]= (stats[rarity] ?? 0) + 1;
    }

    return stats;
  }

  /// モック：実績のレアリティを取得（本来はサーバーから取得）
  String _mockGetRarity(String id) {
    return switch (id) {
      'first_year' => 'common',
      'economic_boom' => 'rare',
      'beloved_leader' => 'rare',
      'full_employment' => 'uncommon',
      'superpower' => 'legendary',
      'iron_stability' => 'uncommon',
      'veteran_leader' => 'uncommon',
      'perfect_score' => 'rare',
      'decisive' => 'common',
      'high_success' => 'uncommon',
      _ => 'common',
    };
  }

  /// コピー・変更用メソッド
  AchievementService copyWith({
    List<AchievementUnlock>? unlockedAchievements,
    Map<String, AchievementProgress>? achievementProgress,
  }) {
    return AchievementService(
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      achievementProgress: achievementProgress ?? this.achievementProgress,
    );
  }

  /// シリアライゼーション
  Map<String, dynamic> toMap() {
    return {
      'unlockedAchievements': unlockedAchievements.map((u) => u.toMap()).toList(),
      'achievementProgress': achievementProgress
          .map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory AchievementService.fromMap(Map<String, dynamic> map) {
    return AchievementService(
      unlockedAchievements: (map['unlockedAchievements'] as List?)
              ?.map((u) => AchievementUnlock.fromMap(u as Map<String, dynamic>))
              .toList() ??
          [],
      achievementProgress: (map['achievementProgress'] as Map<String, dynamic>?)
              ?.map((key, value) =>
                  MapEntry(key, AchievementProgress.fromMap(value as Map<String, dynamic>))) ??
          {},
    );
  }
}
