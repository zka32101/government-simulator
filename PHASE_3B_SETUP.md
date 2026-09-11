# Phase 3B: Firebase Analytics Integration Setup Guide

## Overview

Phase 3B implements Firebase Analytics for tracking user behavior, game events, and error logging. This infrastructure enables data-driven improvements and user engagement metrics.

## Architecture

### Components

#### 1. AnalyticsService (`lib/services/analytics_service.dart`)
Thin wrapper around Firebase Analytics providing:
- **Event Tracking**: Game lifecycle events (start, policy choice, year end, game over)
- **Screen Tracking**: Navigation and screen view analytics
- **User Properties**: User identification and profile attributes
- **Error Logging**: Application error event tracking
- **Utility Methods**: Enable/disable analytics, session management

#### 2. AnalyticsProvider (`lib/providers/analytics_provider.dart`)
Riverpod integration layer providing:
- **Service Provider**: Singleton AnalyticsService
- **User Property Providers**: Setters for user identification and properties
- **Event Tracking Providers**: FutureProviders for all event types
- **Request Classes**: Type-safe parameters for complex events

### Key Features

#### Event Tracking
```dart
// Game started
trackGameStarted(countryName, difficulty, scenarioId)

// Policy chosen (integrated with decision-making)
trackPolicyChosen(policyId, policyName, eventCategory, impactScore, year, day)

// Game ended
trackGameOver(gameOverType, year, totalDecisions, finalHealthScore, finalSatisfaction, finalGdp)

// Year progression
trackYearEnd(year, satisfactionChange, gdpChange, decisionsInYear)

// Error logging
trackError(errorCode, errorMessage, context)

// Screen navigation
trackScreenView(screenName)

// User settings changes
trackUserSettings(settingKey, settingValue)

// Achievement unlocks
trackAchievementUnlocked(achievementId, achievementName, year)
```

#### User Properties
```dart
setUserId(userId)                    // Identify authenticated users
setUserAuthenticated(isAuthenticated) // Auth state
setUserGameStyle(style)              // 'aggressive', 'balanced', 'conservative'
setUserPlaytime(minutes)             // Total playtime in minutes
setUserGameCompletions(count)        // Number of completed games
```

## Integration Points

### Phase 3B.2: Authentication Flow (lib/providers/authentication_provider.dart)
✓ **COMPLETE** - Updated AuthStateNotifier with full analytics integration

```dart
// AuthStateNotifier constructor
AuthStateNotifier(this._authService, this._analytics) : super(const AuthState())

// On successful sign-in/sign-up:
await _analytics.setUserId(user.uid);
await _analytics.setUserAuthenticated(true);
await _analytics.trackScreenView('home_screen');

// On authentication failure:
await _analytics.trackError(
  errorCode: 'email_signin_failed',
  errorMessage: e.message,
  context: 'AuthStateNotifier.signInWithEmail',
);

// On sign-out:
await _analytics.setUserAuthenticated(false);
```

### Phase 3B.3: Game Session (lib/providers/game_provider.dart)
✓ **COMPLETE** - Full analytics event tracking for game lifecycle

```dart
// Game start events
await _analytics.trackGameStarted(
  countryName: countryName,
  difficulty: difficulty,
  scenarioId: scenarioId, // 'standard', 'scenario', 'stage', or 'continuation'
);

// Policy choice tracking
unawaited(_analytics.trackPolicyChosen(
  policyId: choiceId,
  policyName: choiceId,
  eventCategory: eventId,
  impactScore: impactScore,
  year: newStatus.year,
  day: newStatus.day,
));

// Achievement unlock tracking
unawaited(_analytics.trackAchievementUnlocked(
  achievementId: achievement.id,
  achievementName: achievement.name,
  year: newStatus.year,
));

// Year end tracking
unawaited(_analytics.trackYearEnd(
  year: yearEndStatus.year - 1,
  satisfactionChange: satisfactionChange,
  gdpChange: gdpChange,
  decisionsInYear: session.status.decisionsCount,
));
```

### Phase 3B.3: HomeScreen (lib/screens/home_screen.dart)
✓ **COMPLETE** - Screen view tracking

```dart
// In initState with WidgetsBinding callback:
ref.read(analyticsServiceProvider).trackScreenView('home_screen');
```

### Phase 3B.3: SettingsScreen (lib/screens/settings_screen.dart)
✓ **COMPLETE** - Converted to ConsumerStatefulWidget with tracking

```dart
// Screen view tracking
ref.read(analyticsServiceProvider).trackScreenView('settings_screen');

// Settings change tracking
ref.read(analyticsServiceProvider).trackUserSettings(
  settingKey: 'sound_enabled',
  settingValue: value.toString(),
);

ref.read(analyticsServiceProvider).trackUserSettings(
  settingKey: 'notifications_enabled',
  settingValue: value.toString(),
);
```

### Phase 3B.3: GameOverScreen (lib/screens/game_over_screen.dart)
✓ **COMPLETE** - Converted to ConsumerStatefulWidget with game over tracking

```dart
// Screen view tracking
ref.read(analyticsServiceProvider).trackScreenView('game_over_screen');

// Game over event tracking
await _analytics.trackGameOver(
  gameOverType: widget.type.name,
  year: s.status.year,
  totalDecisions: s.totalDecisions,
  finalHealthScore: s.status.stability,
  finalSatisfaction: s.status.satisfaction,
  finalGdp: s.status.gdp,
);
```

## Firebase Console Configuration

### 1. Enable Analytics
In Firebase Console:
1. Navigate to **Analytics** > **Events**
2. Verify custom events are appearing:
   - `game_started`
   - `policy_chosen`
   - `game_over`
   - `year_end`
   - `app_error`
   - `user_settings_changed`
   - `achievement_unlocked`

### 2. Set Up Event Parameters (Optional)
For each event, configure custom parameters:
- `country_name`, `difficulty`, `scenario_id` for `game_started`
- `policy_id`, `policy_name`, `event_category`, `impact_score` for `policy_chosen`
- `game_over_type`, `year`, `total_decisions` for `game_over`
- `satisfaction_change`, `gdp_change`, `decisions_in_year` for `year_end`

### 3. Create User Segments
In **Analytics** > **Audiences**, create segments:
- **Authenticated Users**: `authenticated` == 'true'
- **Aggressive Players**: `game_style` == 'aggressive'
- **High Engagement**: `total_playtime_minutes` > 300
- **Expert Players**: `game_completions` >= 5

### 4. Create Reports
In **Analytics** > **Custom Reports**, set up dashboards for:
- Daily active users (DAU) and monthly active users (MAU)
- Event flow analysis (game_started → policy_chosen → game_over)
- User retention by game_style
- Error trends and frequency
- Achievement unlock rates

## Implementation Timeline

### Phase 3B Timeline
1. **3B1**: Analytics Service & Provider (✓ Complete)
2. **3B2**: Authentication Integration (✓ Complete)
   - ✓ Track sign-in/sign-up events with user ID setting
   - ✓ Set user ID and authenticated property on auth success
   - ✓ Track errors on auth failure (email_signin_failed, email_signup_failed, etc.)
   - ✓ Integrated into AuthStateNotifier with full error handling
   
3. **3B3**: Game Session Integration (✓ Complete)
   - ✓ Track game_started in loadOrCreate, loadOrCreateFromScenario, loadOrCreateFromStage, startNewYear
   - ✓ Track policy_chosen with impact scores in applyChoice
   - ✓ Track achievement_unlocked when achievements are earned
   - ✓ Track year_end with satisfaction/GDP changes in continueToNextYear
   - ✓ Track home_screen, settings_screen, game_over_screen views
   - ✓ Track user_settings_changed for preference toggles
   - ✓ Track game_over with final status indicators
   - ✓ Implemented in GameSessionProvider, HomeScreen, SettingsScreen, GameOverScreen
   
4. **3B4**: Error Handling Integration (✓ Complete)
   - ✓ Integrate analytics error logging into all GameSessionNotifier methods
   - ✓ Add error tracking to Firestore operation failures with proper error codes
   - ✓ Add error tracking to game logic initialization exceptions
   - ✓ Implement proper error boundaries with try-catch-rethrow patterns
   - ✓ All error tracking uses unawaited() to prevent UI blocking
   - ✓ Loading states properly reset on error to prevent UI lockups
   
5. **3B5**: Dashboard & Analytics Report (✓ Complete)
   - ✓ Create comprehensive analytics dashboard documentation (PHASE_3B5_ANALYTICS_DASHBOARD.md)
   - ✓ Firebase Console navigation and report types
   - ✓ Custom dashboard setup for game health monitoring
   - ✓ User segmentation and audience creation
   - ✓ Funnel analysis for game flow optimization
   - ✓ Retention and churn analysis guides
   - ✓ Monthly review checklist and KPI tracking
   - ✓ Privacy and GDPR compliance documentation

## Testing Analytics Locally

### 1. Enable Debug Logging
```dart
// In main.dart
FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
// In Android logcat, filter by 'FA' to see analytics events
// In iOS Console, watch for analytics events
```

### 2. Test Events
```dart
final analytics = AnalyticsService();

// Test game started
await analytics.trackGameStarted(
  countryName: 'TestCountry',
  difficulty: 'normal',
  scenarioId: 'test_scenario',
);

// Test policy chosen
await analytics.trackPolicyChosen(
  policyId: 'test_001',
  policyName: 'Test Policy',
  eventCategory: 'economic',
  impactScore: 42.0,
  year: 1,
  day: 1,
);
```

### 3. Verify in Firebase Console
1. Go to **Real-time** tab in Analytics
2. Filter by `event_name`
3. Should see custom events appearing within seconds

## Error Handling

### Phase 3B.4: Error Tracking Integration
✓ **COMPLETE** - Comprehensive error tracking in GameSessionNotifier

**Error Tracking Strategy:**
- All GameSessionNotifier methods wrapped in try-catch-rethrow blocks
- Errors logged with context information using `trackError()`
- All error tracking uses `unawaited()` to prevent UI blocking
- Loading states reset on error to prevent UI lockups
- Errors re-thrown after tracking to allow caller handling

**Error Codes and Contexts:**
```dart
// Session operations
'session_load_failed' → GameSessionNotifier.loadOrCreate
'scenario_load_failed' → GameSessionNotifier.loadOrCreateFromScenario
'stage_load_failed' → GameSessionNotifier.loadOrCreateFromStage
'new_year_start_failed' → GameSessionNotifier.startNewYear

// Game progression
'choice_apply_failed' → GameSessionNotifier.applyChoice
'year_continue_failed' → GameSessionNotifier.continueToNextYear
```

**Example Implementation:**
```dart
Future<void> loadOrCreate({...}) async {
  try {
    state = state.copyWith(isLoading: true);
    // ... session loading logic
  } catch (e) {
    unawaited(_analytics.trackError(
      errorCode: 'session_load_failed',
      errorMessage: e.toString(),
      context: 'GameSessionNotifier.loadOrCreate',
    ));
    state = state.copyWith(isLoading: false);
    rethrow;
  }
}
```

### Analytics Service Resilience
- All analytics calls are non-blocking (async/Future)
- Failures don't crash the game (wrapped in try-catch at provider layer)
- Games continue even if analytics is disabled
- Error events provide diagnostic information for debugging

### Error Logging Examples
```dart
// Session load error
await _analytics.trackError(
  errorCode: 'session_load_failed',
  errorMessage: e.toString(),
  context: 'GameSessionNotifier.loadOrCreate',
);

// Policy choice error
await _analytics.trackError(
  errorCode: 'choice_apply_failed',
  errorMessage: e.toString(),
  context: 'GameSessionNotifier.applyChoice',
);

// Year progression error
await _analytics.trackError(
  errorCode: 'year_continue_failed',
  errorMessage: e.toString(),
  context: 'GameSessionNotifier.continueToNextYear',
);
```

## Data Privacy

### Firebase Analytics Privacy
- User data is anonymized by default
- Firebase uses advertising ID (Android) / IDFA (iOS) automatically
- Enable "Analytics Opt-Out" setting in Firebase Console for GDPR compliance
- User can disable analytics in Settings screen

### Recommended Privacy Implementation
```dart
// In SettingsScreen
ListView(
  children: [
    SwitchListTile(
      title: Text('Analytics Collection'),
      subtitle: Text('Help us improve the game'),
      value: analyticsEnabled,
      onChanged: (value) async {
        await ref.read(analyticsServiceProvider)
          .setAnalyticsEnabled(value);
      },
    ),
  ],
)
```

## Performance Considerations

### Batch Operations
- Analytics calls are batched by Firebase
- No need to manually batch events
- Safe to call frequently (policy choices, etc.)

### Device Storage
- Firebase Analytics uses local SQLite database
- Max ~1MB locally before syncing to server
- Automatic sync every ~2 hours or on app foreground

### Network Usage
- Each event ~100-500 bytes
- Batched uploads every 15 mins or ~100 events
- Negligible impact on app performance

## Troubleshooting

### Events Not Appearing
1. ✓ Verify firebase_analytics in pubspec.yaml
2. ✓ Check FirebaseApp initialization in main.dart
3. ✓ Confirm Firebase Analytics enabled in Firebase Console
4. ✓ Check logcat/Console for "FA" entries
5. ✓ Allow 24 hours for events to appear in reports (real-time is immediate)

### User Properties Not Setting
1. Verify `setUserProperty()` called after Firebase initialization
2. Check Firebase Console **User Properties** report
3. Note: custom user properties available in reports after 24 hours

### Analytics Disabled
1. Check `setAnalyticsCollectionEnabled(false)` not called
2. Verify Firebase Console has analytics enabled for project
3. Check app's privacy settings in Firebase Console

## Future Enhancements

### Phase 4 Possibilities
- **Custom Dashboards**: In-game analytics dashboard showing user stats
- **A/B Testing**: Firebase Remote Config for testing policy balance
- **Crash Reporting**: Firebase Crashlytics integration
- **Performance Monitoring**: Firebase Performance Monitoring
- **Retention Cohorts**: User retention analysis by sign-up date
- **Funnels**: Track user flow from start → completion

## Phase 3B Completion Summary

### ✓ All Phases Complete

**Phase 3B Implementation Status:**
- ✓ **3B.1**: Analytics Service & Provider - Base infrastructure
- ✓ **3B.2**: Authentication Integration - User auth tracking & analytics
- ✓ **3B.3**: Game Session Integration - Game lifecycle & screen view tracking
- ✓ **3B.4**: Error Handling Integration - Comprehensive error tracking
- ✓ **3B.5**: Dashboard & Analytics Report - Firebase Analytics usage guide

### Key Files Created/Modified

**Core Analytics Infrastructure:**
- `lib/services/analytics_service.dart` (229 lines) - Event tracking service
- `lib/providers/analytics_provider.dart` (332 lines) - Riverpod integration

**Provider Integration:**
- `lib/providers/authentication_provider.dart` - Auth tracking + error logging
- `lib/providers/game_provider.dart` - Game lifecycle + error handling

**Screen Integration:**
- `lib/screens/home_screen.dart` - Screen view tracking
- `lib/screens/settings_screen.dart` - Settings tracking (ConsumerStatefulWidget)
- `lib/screens/game_over_screen.dart` - Game over tracking (ConsumerStatefulWidget)

**Documentation:**
- `PHASE_3B_SETUP.md` - Setup and integration guide
- `PHASE_3B5_ANALYTICS_DASHBOARD.md` - Firebase Console usage guide

### Event Tracking Implemented

**Event Count:** 8 custom events
- `game_started` - Game initialization (standard/scenario/stage/continuation)
- `policy_chosen` - Policy decisions with impact scores
- `year_end` - Year progression with indicator changes
- `game_over` - Game completion with final metrics
- `achievement_unlocked` - Achievement earn events
- `app_error` - Exception tracking
- `user_settings_changed` - Preference changes
- Screen view events - Navigation tracking

### User Properties Tracked

- `authenticated` - Auth status
- `game_style` - Playing preference (aggressive/balanced/conservative)
- `total_playtime_minutes` - Cumulative engagement
- `game_completions` - Finished game count

### Error Tracking Coverage

**6 Error Codes Implemented:**
- `session_load_failed` - Session initialization
- `scenario_load_failed` - Scenario challenge load
- `stage_load_failed` - Stage challenge load
- `choice_apply_failed` - Policy decision processing
- `year_continue_failed` - Year progression
- `new_year_start_failed` - New year session creation

Plus auth error tracking:
- `email_signin_failed` / `email_signin_exception`
- `email_signup_failed` / `email_signup_exception`
- `google_signin_failed` / `google_signin_exception`
- `apple_signin_failed` / `apple_signin_exception`
- `anonymous_signin_failed` / `anonymous_signin_exception`

### Implementation Patterns

**Non-Blocking Analytics:**
```dart
unawaited(_analytics.trackPolicyChosen(...));
```

**Error Boundaries:**
```dart
try {
  // ... operation
  unawaited(_analytics.trackError(...));
  rethrow; // Allow caller to handle
}
```

**Screen View Tracking:**
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (mounted) {
    ref.read(analyticsServiceProvider).trackScreenView('screen_name');
  }
});
```

---

**Status**: ✓ Phase 3B Complete - All infrastructure, integration, error handling, and documentation finished

**Next Steps**: Phase 4 opportunities
1. Advanced machine learning for churn prediction
2. A/B testing framework integration  
3. In-game analytics dashboard for players
4. Dynamic difficulty based on analytics
5. Behavioral segmentation for personalization
