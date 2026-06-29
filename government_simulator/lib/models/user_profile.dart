class UserProfile {
  final String id;
  final String? email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isPurchased; // 買い切り版を購入したか
  final List<String> unlockedDlcScenarios; // 購入したDLC

  // プレイ統計
  final int totalGamesCreated;
  final int totalGameHours;
  final List<String> favoriteCountryNames;

  // ゲーム設定
  final String preferredDifficulty;
  final bool soundEnabled;
  final bool notificationsEnabled;
  final bool hasCompletedTutorial;

  const UserProfile({
    required this.id,
    this.email,
    this.displayName,
    required this.createdAt,
    required this.lastLoginAt,
    this.isPurchased = false,
    this.unlockedDlcScenarios = const [],
    this.totalGamesCreated = 0,
    this.totalGameHours = 0,
    this.favoriteCountryNames = const [],
    this.preferredDifficulty = 'normal',
    this.soundEnabled = true,
    this.notificationsEnabled = true,
    this.hasCompletedTutorial = false,
  });

  // プレイ時間を日数に変換
  double get totalGameDays => totalGameHours / 24;

  // ユーザーレベル（プレイ時間ベース）
  int get userLevel {
    if (totalGameHours < 5) return 1;
    if (totalGameHours < 25) return 2;
    if (totalGameHours < 50) return 3;
    if (totalGameHours < 100) return 4;
    if (totalGameHours < 200) return 5;
    return 6;
  }

  // DLCが利用可能か
  bool isDlcAvailable(String scenarioId) {
    return unlockedDlcScenarios.contains(scenarioId);
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isPurchased,
    List<String>? unlockedDlcScenarios,
    int? totalGamesCreated,
    int? totalGameHours,
    List<String>? favoriteCountryNames,
    String? preferredDifficulty,
    bool? soundEnabled,
    bool? notificationsEnabled,
    bool? hasCompletedTutorial,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isPurchased: isPurchased ?? this.isPurchased,
      unlockedDlcScenarios: unlockedDlcScenarios ?? this.unlockedDlcScenarios,
      totalGamesCreated: totalGamesCreated ?? this.totalGamesCreated,
      totalGameHours: totalGameHours ?? this.totalGameHours,
      favoriteCountryNames: favoriteCountryNames ?? this.favoriteCountryNames,
      preferredDifficulty: preferredDifficulty ?? this.preferredDifficulty,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hasCompletedTutorial: hasCompletedTutorial ?? this.hasCompletedTutorial,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'isPurchased': isPurchased,
      'unlockedDlcScenarios': unlockedDlcScenarios,
      'totalGamesCreated': totalGamesCreated,
      'totalGameHours': totalGameHours,
      'favoriteCountryNames': favoriteCountryNames,
      'preferredDifficulty': preferredDifficulty,
      'soundEnabled': soundEnabled,
      'notificationsEnabled': notificationsEnabled,
      'hasCompletedTutorial': hasCompletedTutorial,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'])
          : DateTime.now(),
      isPurchased: map['isPurchased'] ?? false,
      unlockedDlcScenarios:
          List<String>.from(map['unlockedDlcScenarios'] ?? []),
      totalGamesCreated: map['totalGamesCreated'] ?? 0,
      totalGameHours: map['totalGameHours'] ?? 0,
      favoriteCountryNames:
          List<String>.from(map['favoriteCountryNames'] ?? []),
      preferredDifficulty: map['preferredDifficulty'] ?? 'normal',
      soundEnabled: map['soundEnabled'] ?? true,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      hasCompletedTutorial: map['hasCompletedTutorial'] ?? false,
    );
  }
}
