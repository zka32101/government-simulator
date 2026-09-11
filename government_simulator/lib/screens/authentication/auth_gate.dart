import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/providers/authentication_provider.dart';
import 'package:government_simulator/screens/authentication/login_screen.dart';
import 'package:government_simulator/screens/authentication/signup_screen.dart';
import 'package:government_simulator/screens/authentication/password_reset_screen.dart';

/// Authentication gate: Entry point that manages navigation based on auth state
///
/// Shows:
/// - Loading screen while initializing auth state
/// - Anonymous/Login/SignUp flow if not authenticated
/// - Main app (via callback) if authenticated
class AuthGate extends ConsumerStatefulWidget {
  /// Widget to show when user is authenticated
  final Widget authenticatedWidget;

  /// Widget to show when user is anonymous (optional)
  final Widget? anonymousWidget;

  /// Whether to allow anonymous authentication
  final bool allowAnonymous;

  const AuthGate({
    Key? key,
    required this.authenticatedWidget,
    this.anonymousWidget,
    this.allowAnonymous = true,
  }) : super(key: key);

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

enum _AuthScreen {
  anonymous,
  login,
  signup,
  passwordReset,
}

class _AuthGateState extends ConsumerState<AuthGate> {
  _AuthScreen _currentScreen = _AuthScreen.anonymous;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Auth state will be automatically loaded from Firebase
    // when the notifier is created
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);
    final authService = ref.watch(authenticationServiceProvider);

    // Still loading
    if (authState.user == null &&
        !authState.isAuthenticated &&
        authService.currentUser == null) {
      return _buildLoadingScreen();
    }

    // User is authenticated (email/password or social)
    if (authState.isAuthenticated && !authState.isAnonymous) {
      return widget.authenticatedWidget;
    }

    // User is anonymous
    if (authState.isAnonymous) {
      if (widget.anonymousWidget != null) {
        return widget.anonymousWidget!;
      }
      // If no anonymous widget, show login options
      return _buildAuthFlow();
    }

    // No user, show auth flow
    return _buildAuthFlow();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue[300]!,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '読み込み中...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthFlow() {
    return WillPopScope(
      onWillPop: () async {
        if (_currentScreen != _AuthScreen.anonymous) {
          setState(() => _currentScreen = _AuthScreen.anonymous);
          return false;
        }
        return true;
      },
      child: _buildCurrentAuthScreen(),
    );
  }

  Widget _buildCurrentAuthScreen() {
    switch (_currentScreen) {
      case _AuthScreen.anonymous:
        return _buildAnonymousStartScreen();
      case _AuthScreen.login:
        return LoginScreen(
          onSignUpTap: () {
            setState(() => _currentScreen = _AuthScreen.signup);
          },
          onPasswordResetTap: () {
            setState(() => _currentScreen = _AuthScreen.passwordReset);
          },
        );
      case _AuthScreen.signup:
        return SignUpScreen(
          onLoginTap: () {
            setState(() => _currentScreen = _AuthScreen.login);
          },
        );
      case _AuthScreen.passwordReset:
        return PasswordResetScreen(
          onBackTap: () {
            setState(() => _currentScreen = _AuthScreen.login);
          },
        );
    }
  }

  Widget _buildAnonymousStartScreen() {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Center(
                child: Icon(
                  Icons.public,
                  size: 80,
                  color: Colors.blue[300],
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                '政治シミュレーター',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'あなたは国の指導者です。\n政策決定を通じて国を導きましょう。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),

              // Anonymous play button
              if (widget.allowAnonymous)
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(authStateNotifierProvider.notifier)
                        .signInAnonymously();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'ゲストプレイ',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              if (widget.allowAnonymous) const SizedBox(height: 12),

              // Login button
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _currentScreen = _AuthScreen.login);
                },
                icon: const Icon(Icons.email),
                label: const Text('メールでログイン'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 12),

              // Sign up button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _currentScreen = _AuthScreen.signup);
                },
                icon: const Icon(Icons.person_add),
                label: const Text('新規登録'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),

              // Social sign-in section
              Text(
                'または',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),

              // Google sign-in
              OutlinedButton.icon(
                onPressed: () {
                  ref
                      .read(authStateNotifierProvider.notifier)
                      .signInWithGoogle();
                },
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Googleでログイン'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              // Apple sign-in
              OutlinedButton.icon(
                onPressed: () {
                  ref
                      .read(authStateNotifierProvider.notifier)
                      .signInWithApple();
                },
                icon: const Icon(Icons.apple),
                label: const Text('Appleでログイン'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
