import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/providers/authentication_provider.dart';

/// ログイン画面 (Email/Password)
class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback? onSignUpTap;
  final VoidCallback? onPasswordResetTap;

  const LoginScreen({
    Key? key,
    this.onSignUpTap,
    this.onPasswordResetTap,
  }) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('メールアドレスとパスワードを入力してください。');
      return;
    }

    final notifier = ref.read(authStateNotifierProvider.notifier);
    await notifier.signInWithEmail(email: email, password: password);

    if (mounted && ref.read(authStateNotifierProvider).isAuthenticated) {
      Navigator.of(context).pop();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon
            Center(
              child: Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.blue[300],
              ),
            ),
            const SizedBox(height: 32),

            // Email field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'メールアドレス',
                hintText: 'user@example.com',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabled: !authState.isLoading,
              ),
              enabled: !authState.isLoading,
            ),
            const SizedBox(height: 16),

            // Password field
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'パスワード',
                hintText: '6文字以上',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabled: !authState.isLoading,
              ),
              enabled: !authState.isLoading,
            ),
            const SizedBox(height: 8),

            // Password reset link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        widget.onPasswordResetTap?.call();
                      },
                child: const Text('パスワードを忘れた?'),
              ),
            ),
            const SizedBox(height: 24),

            // Error message
            if (authState.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[400]!),
                ),
                child: Text(
                  authState.error!,
                  style: TextStyle(color: Colors.red[900]),
                ),
              ),
            if (authState.error != null) const SizedBox(height: 16),

            // Sign in button
            ElevatedButton(
              onPressed: authState.isLoading ? null : _handleSignIn,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'ログイン',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 24),

            // Sign up link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('アカウントをお持ちでない?'),
                TextButton(
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          widget.onSignUpTap?.call();
                        },
                  child: const Text('サインアップ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
