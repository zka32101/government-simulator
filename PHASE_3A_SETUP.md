# Phase 3A: Authentication Setup Guide

This document outlines the configuration required for Phase 3A (Authentication & Foundation) to work properly.

## Overview

Phase 3A implements comprehensive authentication with:
- Email/Password authentication
- Google Sign-In
- Apple Sign-In
- Account linking for anonymous → authenticated migration
- Profile management
- Account deletion

## Required Files & Configuration

### 1. Firebase Configuration Files

#### Android Setup
Create `android/app/google-services.json`:
- Download from Firebase Console → Project Settings → google-services.json
- Place in `android/app/` directory
- Required for Google Sign-In and Firebase Auth on Android

#### iOS Setup
Create `ios/Runner/GoogleService-Info.plist`:
- Download from Firebase Console → Project Settings → GoogleService-Info.plist
- Place in `ios/Runner/` directory via Xcode
- Required for Google Sign-In and Firebase Auth on iOS

### 2. Firebase Authentication Configuration

#### Enable Authentication Methods
1. Go to Firebase Console → Authentication
2. Enable these sign-in methods:
   - Email/Password
   - Google
   - Apple

#### Email/Password Configuration
- No additional configuration needed
- Passwords must be at least 6 characters

#### Google Sign-In Configuration
**Android:**
1. Firebase Console → Project Settings
2. Copy SHA-1 fingerprint:
   ```bash
   cd android && ./gradlew signingReport
   ```
3. Add fingerprint to Firebase Console
4. Google Sign-In will be auto-configured

**iOS:**
1. Firebase Console → Project Settings
2. iOS app should be registered with bundle ID
3. OAuth consent screen configuration in Google Cloud Console is optional for development

#### Apple Sign-In Configuration
**iOS Only:**
1. Xcode → Signing & Capabilities → + Capability → Sign in with Apple
2. Apple Developer Account:
   - Create App ID with Sign in with Apple capability
   - Create Service ID for Sign in with Apple
   - Create private key for Service ID
3. Firebase Console → Authentication → Apple → Configure
   - Enter Team ID (from Apple Developer)
   - Enter Service ID
   - Upload private key (created above)

### 3. Firestore Security Rules

The following rules should be configured in Firestore:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    // Game sessions
    match /game_sessions/{sessionId} {
      allow read, write: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.uid == request.resource.data.userId;
    }

    // Decisions
    match /decisions/{decisionId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow write: if request.auth.uid == resource.data.userId;
    }

    // Deny by default
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Note: The Firestore service already has a `FirestoreService` class that handles all reads/writes with proper error handling.

### 4. Optional: Custom Branding

#### Email Templates
1. Firebase Console → Authentication → Templates
2. Customize email templates for:
   - Password reset
   - Email verification (if enabled)

#### OAuth Consent Screen (Google)
1. Google Cloud Console → OAuth consent screen
2. Configure for your app:
   - App name
   - User support email
   - Authorized domains (if needed)

## Code Integration

### Main App Integration

Add AuthGate to your main app:

```dart
import 'package:government_simulator/screens/authentication/auth_gate.dart';
import 'package:government_simulator/screens/home_screen.dart';

// In your main app build method:
@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Government Simulator',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
    ),
    home: AuthGate(
      allowAnonymous: true,
      authenticatedWidget: HomeScreen(),
      anonymousWidget: AnonymousHomeScreen(), // Optional
    ),
  );
}
```

### Available Providers

#### State Queries
```dart
// Check if user is authenticated
final isAuth = ref.watch(isAuthenticatedProvider);

// Check if user is anonymous
final isAnon = ref.watch(isAnonymousProvider);

// Get current user ID
final userId = ref.watch(userIdProvider);

// Get current user email
final email = ref.watch(userEmailProvider);

// Watch full auth state
final authState = ref.watch(authStateProvider);
```

#### State Management
```dart
// Access auth notifier for actions
final notifier = ref.read(authStateNotifierProvider.notifier);

// Sign in with email
await notifier.signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Sign up
await notifier.signUpWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Sign in with Google
await notifier.signInWithGoogle();

// Sign in with Apple
await notifier.signInWithApple();

// Sign in anonymously
await notifier.signInAnonymously();

// Link anonymous to email
await notifier.linkAnonymousToEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Link anonymous to Google
await notifier.linkAnonymousToGoogle();

// Link anonymous to Apple
await notifier.linkAnonymousToApple();

// Sign out
await notifier.signOut();
```

## Testing

### Local Testing
1. Ensure you have `google-services.json` and `GoogleService-Info.plist` configured
2. Firebase emulator (optional):
   ```bash
   firebase emulators:start
   ```

### Testing Different Auth Flows
- **Anonymous**: Tap "ゲストプレイ" (Guest Play)
- **Email**: Sign up or log in with email/password
- **Google**: Tap "Googleでログイン"
- **Apple**: Tap "Appleでログイン" (iOS only)
- **Account Linking**: Upgrade anonymous account to email/social

### Error Scenarios to Test
- Invalid email format
- Weak password (<6 characters)
- Password mismatch during signup
- Account already exists
- Credential already in use (when linking)
- Network errors

## Troubleshooting

### "Google Sign-In configuration not found"
- Ensure `google-services.json` is in `android/app/`
- Ensure SHA-1 fingerprint is registered in Firebase Console
- Run `android/gradlew clean` in Android directory

### "Apple Sign-In failed"
- Only works on iOS
- Ensure Apple capability is enabled in Xcode
- Check Firebase Console Apple configuration
- Verify Team ID and Service ID match

### "Email already in use" when linking
- User may have already created account with this email
- Show error: "このメールアドレスは既に使用されています"

### "Re-authentication required"
- User must sign out and sign back in before changing email or deleting account
- This is a Firebase security requirement

## Security Considerations

1. **Passwords**: Minimum 6 characters enforced by Firebase
2. **Email Verification**: Currently not required (can be enabled in Firebase)
3. **Session Persistence**: Firebase Auth automatically persists session
4. **Firestore Rules**: User data is isolated by UID
5. **Password Reset**: One-time link sent via email

## Next Steps (Phase 3B)

After Phase 3A is complete:
1. **Analytics**: Track authentication events
2. **User Profiles**: Sync profile data to Firestore
3. **Statistics**: Track user engagement
4. **Monetization**: Track purchase events

See PHASE_3B_SETUP.md for next phase details.

## References

- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Sign in with Apple for Flutter](https://pub.dev/packages/sign_in_with_apple)
- [Firebase Security Rules](https://firebase.google.com/docs/firestore/security/start)
