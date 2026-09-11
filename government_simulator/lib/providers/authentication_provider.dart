import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:government_simulator/services/authentication_service.dart' show AuthenticationService, AuthException;

// =================== Service Provider ===================

/// Authentication service singleton
final authenticationServiceProvider = Provider<AuthenticationService>((ref) {
  return AuthenticationService();
});

// =================== Authentication State ===================

/// Current Firebase user stream
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.authStateChanges;
});

/// Current authenticated user ID (null if not authenticated)
final userIdProvider = StateProvider<String?>((ref) {
  final user = ref.watch(authStateProvider).value;
  return user?.uid;
});

/// Whether current user is authenticated
final isAuthenticatedProvider = StateProvider<bool>((ref) {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.isAuthenticated;
});

/// Whether current user is anonymous
final isAnonymousProvider = StateProvider<bool>((ref) {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.isAnonymous;
});

/// Current user's email (null if not available)
final userEmailProvider = StateProvider<String?>((ref) {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.userEmail;
});

// =================== Authentication Actions ===================

/// Anonymous sign-in
final anonymousSignInProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.signInAnonymously();
});

/// Sign up with email and password
class SignUpRequest {
  final String email;
  final String password;

  const SignUpRequest({
    required this.email,
    required this.password,
  });
}

final signUpProvider = FutureProvider.family<User?, SignUpRequest>((ref, request) async {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.signUpWithEmail(
    email: request.email,
    password: request.password,
  );
});

/// Sign in with email and password
class SignInRequest {
  final String email;
  final String password;

  const SignInRequest({
    required this.email,
    required this.password,
  });
}

final signInProvider = FutureProvider.family<User?, SignInRequest>((ref, request) async {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.signInWithEmail(
    email: request.email,
    password: request.password,
  );
});

/// Sign in with Google
final signInWithGoogleProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.signInWithGoogle();
});

/// Sign in with Apple
final signInWithAppleProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.signInWithApple();
});

/// Send password reset email
class PasswordResetRequest {
  final String email;

  const PasswordResetRequest(this.email);
}

final sendPasswordResetProvider =
    FutureProvider.family<void, PasswordResetRequest>((ref, request) async {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.sendPasswordResetEmail(request.email);
});

// =================== Account Linking ===================

/// Link anonymous account to email
class LinkToEmailRequest {
  final String email;
  final String password;

  const LinkToEmailRequest({
    required this.email,
    required this.password,
  });
}

final linkAnonymousToEmailProvider =
    FutureProvider.family<User?, LinkToEmailRequest>((ref, request) async {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.linkAnonymousToEmail(
    email: request.email,
    password: request.password,
  );
});

/// Link anonymous account to Google
final linkAnonymousToGoogleProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.linkAnonymousToGoogle();
});

/// Link anonymous account to Apple
final linkAnonymousToAppleProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.linkAnonymousToApple();
});

// =================== Profile Management ===================

/// Update user profile
class UpdateProfileRequest {
  final String? displayName;
  final String? photoURL;

  const UpdateProfileRequest({
    this.displayName,
    this.photoURL,
  });
}

final updateUserProfileProvider =
    FutureProvider.family<void, UpdateProfileRequest>((ref, request) async {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.updateUserProfile(
    displayName: request.displayName,
    photoURL: request.photoURL,
  );
});

/// Update email address
class UpdateEmailRequest {
  final String newEmail;

  const UpdateEmailRequest(this.newEmail);
}

final updateEmailProvider =
    FutureProvider.family<void, UpdateEmailRequest>((ref, request) async {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.updateEmail(request.newEmail);
});

/// Delete user account
final deleteAccountProvider = FutureProvider<void>((ref) async {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.deleteAccount();
});

// =================== Sign Out ===================

/// Sign out from all providers
final signOutProvider = FutureProvider<void>((ref) async {
  final authService = ref.watch(authenticationServiceProvider);
  return authService.signOut();
});

// =================== Authentication Notifier ===================

/// Comprehensive authentication state with user profile
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;
  bool get isAnonymous => user?.isAnonymous ?? false;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );

  AuthState clearError() => copyWith(error: null);
}

/// Authentication state notifier for managing auth state and profile sync
final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.watch(authenticationServiceProvider));
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthenticationService _authService;

  AuthStateNotifier(this._authService) : super(const AuthState()) {
    _initializeAuthState();
  }

  /// Initialize auth state from Firebase
  Future<void> _initializeAuthState() async {
    state = state.copyWith(isLoading: true);
    try {
      final currentUser = _authService.currentUser;
      state = AuthState(
        user: currentUser,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = AuthState(
        user: null,
        isLoading: false,
        error: 'Failed to initialize auth state: $e',
      );
    }
  }

  /// Handle sign in with email
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      state = AuthState(
        user: user,
        isLoading: false,
        error: null,
      );
    } on AuthException catch (e) {
      state = AuthState(
        user: null,
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = AuthState(
        user: null,
        isLoading: false,
        error: 'Sign in failed: $e',
      );
    }
  }

  /// Handle sign up with email
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      state = AuthState(
        user: user,
        isLoading: false,
        error: null,
      );
    } on AuthException catch (e) {
      state = AuthState(
        user: null,
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = AuthState(
        user: null,
        isLoading: false,
        error: 'Sign up failed: $e',
      );
    }
  }

  /// Handle sign in with Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signInWithGoogle();
      state = AuthState(
        user: user,
        isLoading: false,
        error: null,
      );
    } on AuthException catch (e) {
      state = AuthState(
        user: null,
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = AuthState(
        user: null,
        isLoading: false,
        error: 'Google sign in failed: $e',
      );
    }
  }

  /// Handle sign in with Apple
  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signInWithApple();
      state = AuthState(
        user: user,
        isLoading: false,
        error: null,
      );
    } on AuthException catch (e) {
      state = AuthState(
        user: null,
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = AuthState(
        user: null,
        isLoading: false,
        error: 'Apple sign in failed: $e',
      );
    }
  }

  /// Handle anonymous sign in
  Future<void> signInAnonymously() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signInAnonymously();
      state = AuthState(
        user: user,
        isLoading: false,
        error: null,
      );
    } on AuthException catch (e) {
      state = AuthState(
        user: null,
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = AuthState(
        user: null,
        isLoading: false,
        error: 'Anonymous sign in failed: $e',
      );
    }
  }

  /// Handle sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signOut();
      state = const AuthState(
        user: null,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = AuthState(
        user: state.user,
        isLoading: false,
        error: 'Sign out failed: $e',
      );
    }
  }

  /// Handle link anonymous to email
  Future<void> linkAnonymousToEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.linkAnonymousToEmail(
        email: email,
        password: password,
      );
      state = AuthState(
        user: user,
        isLoading: false,
        error: null,
      );
    } on AuthException catch (e) {
      state = AuthState(
        user: state.user,
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = AuthState(
        user: state.user,
        isLoading: false,
        error: 'Linking failed: $e',
      );
    }
  }

  /// Handle link anonymous to Google
  Future<void> linkAnonymousToGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.linkAnonymousToGoogle();
      state = AuthState(
        user: user,
        isLoading: false,
        error: null,
      );
    } on AuthException catch (e) {
      state = AuthState(
        user: state.user,
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = AuthState(
        user: state.user,
        isLoading: false,
        error: 'Google linking failed: $e',
      );
    }
  }

  /// Handle link anonymous to Apple
  Future<void> linkAnonymousToApple() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.linkAnonymousToApple();
      state = AuthState(
        user: user,
        isLoading: false,
        error: null,
      );
    } on AuthException catch (e) {
      state = AuthState(
        user: state.user,
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = AuthState(
        user: state.user,
        isLoading: false,
        error: 'Apple linking failed: $e',
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.clearError();
  }
}
