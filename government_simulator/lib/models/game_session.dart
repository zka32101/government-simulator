import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/promise.dart';

class GameSession {
  final String id;
  final String userId;
  final String countryName;
  final CountryStatus status;
  final DateTime createdAt;
  final DateTime lastPlayedAt;
  final int totalPlaySessions;
  final String difficulty; // easy, normal, hard
  final bool isActive;

  // Gameplay history
  final int totalDecisions;
  final int positiveOutcomes;
  final int negativeOutcomes;

  // Achievements & unlocks
  final List<String> unlockedAchievements;
  final bool hasSeenTutorial;

  // 二枚舌外交システム：まだ期限が来ていない公約
  final List<Promise> activePromises;

  const GameSession({
    required this.id,
    required this.userId,
    required this.countryName,
    required this.status,
    required this.createdAt,
    required this.lastPlayedAt,
    this.totalPlaySessions = 1,
    this.difficulty = 'normal',
    this.isActive = true,
    this.totalDecisions = 0,
    this.positiveOutcomes = 0,
    this.negativeOutcomes = 0,
    this.unlockedAchievements = const [],
    this.hasSeenTutorial = false,
    this.activePromises = const [],
  });

  // プレイ時間（分）
  int get totalPlayTimeMinutes {
    return lastPlayedAt.difference(createdAt).inMinutes;
  }

  // 意思決定の成功率
  double get successRate {
    if (totalDecisions == 0) return 0;
    return (positiveOutcomes / totalDecisions) * 100;
  }

  // ゲーム難易度係数
  double get difficultyMultiplier {
    switch (difficulty) {
      case 'easy':
        return 0.8;
      case 'normal':
        return 1.0;
      case 'hard':
        return 1.3;
      default:
        return 1.0;
    }
  }

  GameSession copyWith({
    String? id,
    String? userId,
    String? countryName,
    CountryStatus? status,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    int? totalPlaySessions,
    String? difficulty,
    bool? isActive,
    int? totalDecisions,
    int? positiveOutcomes,
    int? negativeOutcomes,
    List<String>? unlockedAchievements,
    bool? hasSeenTutorial,
    List<Promise>? activePromises,
  }) {
    return GameSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      countryName: countryName ?? this.countryName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      totalPlaySessions: totalPlaySessions ?? this.totalPlaySessions,
      difficulty: difficulty ?? this.difficulty,
      isActive: isActive ?? this.isActive,
      totalDecisions: totalDecisions ?? this.totalDecisions,
      positiveOutcomes: positiveOutcomes ?? this.positiveOutcomes,
      negativeOutcomes: negativeOutcomes ?? this.negativeOutcomes,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
      activePromises: activePromises ?? this.activePromises,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'countryName': countryName,
      'status': status.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      'totalPlaySessions': totalPlaySessions,
      'difficulty': difficulty,
      'isActive': isActive,
      'totalDecisions': totalDecisions,
      'positiveOutcomes': positiveOutcomes,
      'negativeOutcomes': negativeOutcomes,
      'unlockedAchievements': unlockedAchievements,
      'hasSeenTutorial': hasSeenTutorial,
      'activePromises': activePromises.map((p) => p.toMap()).toList(),
    };
  }

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      countryName: map['countryName'] ?? 'New Country',
      status: map['status'] != null
          ? CountryStatus.fromMap(map['status'])
          : CountryStatus(
              gdp: 1000,
              unemployment: 5,
              satisfaction: 50,
              nationalPower: 50,
              year: 1,
              day: 1,
              lastUpdated: DateTime.now(),
            ),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastPlayedAt: map['lastPlayedAt'] != null
          ? DateTime.parse(map['lastPlayedAt'])
          : DateTime.now(),
      totalPlaySessions: map['totalPlaySessions'] ?? 1,
      difficulty: map['difficulty'] ?? 'normal',
      isActive: map['isActive'] ?? true,
      totalDecisions: map['totalDecisions'] ?? 0,
      positiveOutcomes: map['positiveOutcomes'] ?? 0,
      negativeOutcomes: map['negativeOutcomes'] ?? 0,
      unlockedAchievements:
          List<String>.from(map['unlockedAchievements'] ?? []),
      hasSeenTutorial: map['hasSeenTutorial'] ?? false,
      activePromises: (map['activePromises'] as List?)
              ?.map((p) => Promise.fromMap(p as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

// Difficulty enum
enum DifficultyLevel {
  easy('easy', 'イージー'),
  normal('normal', 'ノーマル'),
  hard('hard', 'ハード');

  final String value;
  final String label;

  const DifficultyLevel(this.value, this.label);
}
