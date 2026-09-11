import 'package:firebase_analytics/firebase_analytics.dart';

/// Firebase Analytics を管理するサービス。
/// ゲームイベント、ユーザー行動、エラーを追跡してゲーム改善に活用。
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // =================== Event Tracking ===================

  /// ゲーム開始イベント
  Future<void> trackGameStarted({
    required String countryName,
    required String difficulty,
    required String scenarioId,
  }) async {
    await _analytics.logEvent(
      name: 'game_started',
      parameters: {
        'country_name': countryName,
        'difficulty': difficulty,
        'scenario_id': scenarioId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// ポリシー選択イベント
  Future<void> trackPolicyChosen({
    required String policyId,
    required String policyName,
    required String eventCategory,
    required double impactScore,
    required int year,
    required int day,
  }) async {
    await _analytics.logEvent(
      name: 'policy_chosen',
      parameters: {
        'policy_id': policyId,
        'policy_name': policyName,
        'event_category': eventCategory,
        'impact_score': impactScore,
        'year': year,
        'day': day,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// ゲームオーバーイベント
  Future<void> trackGameOver({
    required String gameOverType, // 'victory', 'defeat', 'custom'
    required int year,
    required int totalDecisions,
    required double finalHealthScore,
    required double finalSatisfaction,
    required double finalGdp,
  }) async {
    await _analytics.logEvent(
      name: 'game_over',
      parameters: {
        'game_over_type': gameOverType,
        'year': year,
        'total_decisions': totalDecisions,
        'final_health_score': finalHealthScore,
        'final_satisfaction': finalSatisfaction,
        'final_gdp': finalGdp,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// 年終了イベント
  Future<void> trackYearEnd({
    required int year,
    required double satisfactionChange,
    required double gdpChange,
    required int decisionsInYear,
  }) async {
    await _analytics.logEvent(
      name: 'year_end',
      parameters: {
        'year': year,
        'satisfaction_change': satisfactionChange,
        'gdp_change': gdpChange,
        'decisions_in_year': decisionsInYear,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// 画面表示イベント
  Future<void> trackScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  /// エラーイベント
  Future<void> trackError({
    required String errorCode,
    required String errorMessage,
    String? context,
  }) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_code': errorCode,
        'error_message': errorMessage,
        'context': context ?? 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// ユーザー設定イベント
  Future<void> trackUserSettings({
    required String settingKey,
    required String settingValue,
  }) async {
    await _analytics.logEvent(
      name: 'user_settings_changed',
      parameters: {
        'setting_key': settingKey,
        'setting_value': settingValue,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// アチーブメント解除イベント
  Future<void> trackAchievementUnlocked({
    required String achievementId,
    required String achievementName,
    required int year,
  }) async {
    await _analytics.logEvent(
      name: 'achievement_unlocked',
      parameters: {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'year': year,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // =================== User Properties ===================

  /// ユーザー識別情報を設定
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// ユーザープロパティを設定
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// ユーザーが認証済みかどうかを設定
  Future<void> setUserAuthenticated(bool isAuthenticated) async {
    await _analytics.setUserProperty(
      name: 'authenticated',
      value: isAuthenticated ? 'true' : 'false',
    );
  }

  /// ユーザーの国プレイスタイルを設定
  Future<void> setUserGameStyle(String style) async {
    await _analytics.setUserProperty(
      name: 'game_style',
      value: style, // 'aggressive', 'balanced', 'conservative'
    );
  }

  /// ユーザーの総プレイ時間を記録（分単位）
  Future<void> setUserPlaytime(int minutes) async {
    await _analytics.setUserProperty(
      name: 'total_playtime_minutes',
      value: minutes.toString(),
    );
  }

  /// ユーザーの総ゲーム完了数を記録
  Future<void> setUserGameCompletions(int count) async {
    await _analytics.setUserProperty(
      name: 'game_completions',
      value: count.toString(),
    );
  }

  // =================== Utility Methods ===================

  /// アナリティクスを有効/無効にする
  Future<void> setAnalyticsEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  /// セッション ID を取得
  String get sessionId => _analytics.appInstanceId.toString();
}
