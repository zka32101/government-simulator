import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/services/analytics_service.dart';

// =================== Service Provider ===================

/// Analytics service singleton
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

// =================== User Property Setters ===================

/// ユーザー ID を設定
final setUserIdProvider = FutureProvider.family<void, String>((ref, userId) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.setUserId(userId);
});

/// ユーザー認証状態を設定
final setUserAuthenticatedProvider = FutureProvider.family<void, bool>((ref, isAuthenticated) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.setUserAuthenticated(isAuthenticated);
});

/// ユーザーのゲームスタイルを設定
final setUserGameStyleProvider = FutureProvider.family<void, String>((ref, style) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.setUserGameStyle(style);
});

/// ユーザーの総プレイ時間を設定
final setUserPlaytimeProvider = FutureProvider.family<void, int>((ref, minutes) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.setUserPlaytime(minutes);
});

/// ユーザーの総ゲーム完了数を設定
final setUserGameCompletionsProvider = FutureProvider.family<void, int>((ref, count) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.setUserGameCompletions(count);
});

// =================== Event Tracking Providers ===================

/// ゲーム開始イベントを追跡
class GameStartedRequest {
  final String countryName;
  final String difficulty;
  final String scenarioId;

  const GameStartedRequest({
    required this.countryName,
    required this.difficulty,
    required this.scenarioId,
  });
}

final trackGameStartedProvider = FutureProvider.family<void, GameStartedRequest>((ref, request) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.trackGameStarted(
    countryName: request.countryName,
    difficulty: request.difficulty,
    scenarioId: request.scenarioId,
  );
});

/// ポリシー選択イベントを追跡
class PolicyChosenRequest {
  final String policyId;
  final String policyName;
  final String eventCategory;
  final double impactScore;
  final int year;
  final int day;

  const PolicyChosenRequest({
    required this.policyId,
    required this.policyName,
    required this.eventCategory,
    required this.impactScore,
    required this.year,
    required this.day,
  });
}

final trackPolicyChosenProvider = FutureProvider.family<void, PolicyChosenRequest>((ref, request) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.trackPolicyChosen(
    policyId: request.policyId,
    policyName: request.policyName,
    eventCategory: request.eventCategory,
    impactScore: request.impactScore,
    year: request.year,
    day: request.day,
  );
});

/// ゲームオーバーイベントを追跡
class GameOverRequest {
  final String gameOverType;
  final int year;
  final int totalDecisions;
  final double finalHealthScore;
  final double finalSatisfaction;
  final double finalGdp;

  const GameOverRequest({
    required this.gameOverType,
    required this.year,
    required this.totalDecisions,
    required this.finalHealthScore,
    required this.finalSatisfaction,
    required this.finalGdp,
  });
}

final trackGameOverProvider = FutureProvider.family<void, GameOverRequest>((ref, request) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.trackGameOver(
    gameOverType: request.gameOverType,
    year: request.year,
    totalDecisions: request.totalDecisions,
    finalHealthScore: request.finalHealthScore,
    finalSatisfaction: request.finalSatisfaction,
    finalGdp: request.finalGdp,
  );
});

/// 年終了イベントを追跡
class YearEndRequest {
  final int year;
  final double satisfactionChange;
  final double gdpChange;
  final int decisionsInYear;

  const YearEndRequest({
    required this.year,
    required this.satisfactionChange,
    required this.gdpChange,
    required this.decisionsInYear,
  });
}

final trackYearEndProvider = FutureProvider.family<void, YearEndRequest>((ref, request) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.trackYearEnd(
    year: request.year,
    satisfactionChange: request.satisfactionChange,
    gdpChange: request.gdpChange,
    decisionsInYear: request.decisionsInYear,
  );
});

/// 画面表示イベントを追跡
final trackScreenViewProvider = FutureProvider.family<void, String>((ref, screenName) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.trackScreenView(screenName);
});

/// エラーイベントを追跡
class ErrorEventRequest {
  final String errorCode;
  final String errorMessage;
  final String? context;

  const ErrorEventRequest({
    required this.errorCode,
    required this.errorMessage,
    this.context,
  });
}

final trackErrorProvider = FutureProvider.family<void, ErrorEventRequest>((ref, request) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.trackError(
    errorCode: request.errorCode,
    errorMessage: request.errorMessage,
    context: request.context,
  );
});

/// ユーザー設定変更イベントを追跡
class UserSettingsChangedRequest {
  final String settingKey;
  final String settingValue;

  const UserSettingsChangedRequest({
    required this.settingKey,
    required this.settingValue,
  });
}

final trackUserSettingsProvider = FutureProvider.family<void, UserSettingsChangedRequest>((ref, request) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.trackUserSettings(
    settingKey: request.settingKey,
    settingValue: request.settingValue,
  );
});

/// アチーブメント解除イベントを追跡
class AchievementUnlockedRequest {
  final String achievementId;
  final String achievementName;
  final int year;

  const AchievementUnlockedRequest({
    required this.achievementId,
    required this.achievementName,
    required this.year,
  });
}

final trackAchievementUnlockedProvider = FutureProvider.family<void, AchievementUnlockedRequest>((ref, request) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.trackAchievementUnlocked(
    achievementId: request.achievementId,
    achievementName: request.achievementName,
    year: request.year,
  );
});

// =================== Analytics Control ===================

/// アナリティクス収集を有効/無効にする
final setAnalyticsEnabledProvider = FutureProvider.family<void, bool>((ref, enabled) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.setAnalyticsEnabled(enabled);
});
