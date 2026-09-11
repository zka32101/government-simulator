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

### 1. Authentication Flow (lib/providers/authentication_provider.dart)
```dart
// In AuthStateNotifier methods:
ref.read(analyticsServiceProvider).setUserId(user.uid);
ref.read(analyticsServiceProvider).setUserAuthenticated(true);
ref.read(analyticsServiceProvider).setUserAuthenticated(false); // on signOut
```

### 2. Game Session (lib/providers/game_provider.dart)
```dart
// Track game start
await ref.read(trackGameStartedProvider(request).future);

// Track policy decisions in _handleChoice
await ref.read(trackPolicyChosenProvider(request).future);

// Track year end in _onContinueYear
await ref.read(trackYearEndProvider(request).future);

// Track game over in _onRestartGame
await ref.read(trackGameOverProvider(request).future);
```

### 3. Home Screen (lib/screens/home_screen.dart)
```dart
// Track screen view on build
ref.read(analyticsServiceProvider).trackScreenView('home_screen');

// Track policy choices
ref.read(analyticsServiceProvider).trackPolicyChosen(...);
```

### 4. Achievement System (lib/models/achievement.dart)
```dart
// When achievement unlocks
await ref.read(trackAchievementUnlockedProvider(request).future);
```

### 5. Settings Screen (lib/screens/settings_screen.dart)
```dart
// Track setting changes
ref.read(analyticsServiceProvider).trackUserSettings('setting_key', 'new_value');

// Track analytics enable/disable
ref.read(analyticsServiceProvider).setAnalyticsEnabled(enabled);
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
2. **3B2**: Authentication Integration (Next)
   - Track sign-in/sign-up events
   - Set user ID and authenticated property
   
3. **3B3**: Game Session Integration
   - Track game start, policy choices, year end, game over
   - Track achievement unlocks
   
4. **3B4**: Error Handling Integration
   - Integrate analytics error logging into exception handlers
   
5. **3B5**: Dashboard & Analytics Report
   - Create analytics dashboard documentation
   - Guide for viewing user insights

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

### Analytics Service Resilience
- All analytics calls are non-blocking (async/Future)
- Failures don't crash the game (wrapped in try-catch at UI layer)
- Games continue even if analytics is disabled
- Optional logging with `AnalyticsException` handling (future enhancement)

### Error Logging
When errors occur:
```dart
ref.read(analyticsServiceProvider).trackError(
  errorCode: 'invalid_policy_choice',
  errorMessage: 'Policy validation failed',
  context: 'HomeScreen._handleChoice',
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

---

**Status**: ✓ Phase 3B.1 Complete - Ready for integration into game flows

**Next Steps**: Integrate analytics into AuthStateNotifier, GameSessionProvider, and HomeScreen
