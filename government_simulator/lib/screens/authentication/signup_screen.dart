import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/providers/authentication_provider.dart';

/// サインアップ画面 (Email/Password)
class SignUpScreen extends ConsumerStatefulWidget {
  final VoidCallback? onLoginTap;

  const SignUpScreen({
    Key? key,
    this.onLoginTap,
  }) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'メールアドレスを入力してください。';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) return '有効なメールアドレスを入力してください。';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'パスワードを入力してください。';
    if (value.length < 6) return 'パスワードは6文字以上である必要があります。';
    return null;
  }

  String? _validateConfirmPassword(String value) {
    if (value.isEmpty) return 'パスワード確認を入力してください。';
    if (value != _passwordController.text) return 'パスワードが一致しません。';
    return null;
  }

  Future<void> _handleSignUp() async {
    // Validation
    final emailError = _validateEmail(_emailController.text.trim());
    final passwordError = _validatePassword(_passwordController.text);
    final confirmError = _validateConfirmPassword(_confirmPasswordController.text);

    if (emailError != null || passwordError != null || confirmError != null) {
      _showErrorDialog(emailError ?? passwordError ?? confirmError ?? '入力エラーが発生しました。');
      return;
    }

    if (!_agreeToTerms) {
      _showErrorDialog('利用規約に同意してください。');
      return;
    }

    final notifier = ref.read(authStateNotifierProvider.notifier);
    await notifier.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

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
        title: const Text('サインアップ'),
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
                Icons.person_add,
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
            const SizedBox(height: 16),

            // Confirm password field
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'パスワード確認',
                hintText: '同じパスワードを入力',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabled: !authState.isLoading,
              ),
              enabled: !authState.isLoading,
            ),
            const SizedBox(height: 16),

            // Terms agreement checkbox
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: authState.isLoading
                      ? null
                      : (value) {
                          setState(() => _agreeToTerms = value ?? false);
                        },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: authState.isLoading
                        ? null
                        : () {
                            setState(() => _agreeToTerms = !_agreeToTerms);
                          },
                    child: const Text(
                      '利用規約とプライバシーポリシーに同意します',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
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

            // Sign up button
            ElevatedButton(
              onPressed: authState.isLoading ? null : _handleSignUp,
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
                      'サインアップ',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 24),

            // Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('既にアカウントをお持ち?'),
                TextButton(
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          widget.onLoginTap?.call();
                        },
                  child: const Text('ログイン'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
