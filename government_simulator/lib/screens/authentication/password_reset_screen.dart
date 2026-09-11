import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/providers/authentication_provider.dart';

/// パスワードリセット画面
class PasswordResetScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackTap;

  const PasswordResetScreen({
    Key? key,
    this.onBackTap,
  }) : super(key: key);

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  late TextEditingController _emailController;
  bool _resetSent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'メールアドレスを入力してください。';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) return '有効なメールアドレスを入力してください。';
    return null;
  }

  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();
    final error = _validateEmail(email);

    if (error != null) {
      _showErrorDialog(error);
      return;
    }

    final notifier = ref.read(authStateNotifierProvider.notifier);
    final request = PasswordResetRequest(email);

    // Note: In a real implementation, you would use:
    // final result = await ref.read(sendPasswordResetProvider(request).future);
    // For now, we'll call the service directly via the notifier concept
    try {
      final authService = ref.read(authenticationServiceProvider);
      await authService.sendPasswordResetEmail(email);
      setState(() => _resetSent = true);
    } catch (e) {
      _showErrorDialog(e.toString());
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
    if (_resetSent) {
      return _buildSuccessScreen();
    }

    return _buildResetForm();
  }

  Widget _buildResetForm() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('パスワードリセット'),
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
                Icons.vpn_key,
                size: 64,
                color: Colors.blue[300],
              ),
            ),
            const SizedBox(height: 32),

            // Description
            const Text(
              'ご登録のメールアドレスを入力してください。パスワードリセット用のメールを送信します。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
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
              ),
            ),
            const SizedBox(height: 24),

            // Reset button
            ElevatedButton(
              onPressed: _handlePasswordReset,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'リセットメールを送信',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Back button
            OutlinedButton(
              onPressed: () {
                widget.onBackTap?.call();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('戻る'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('パスワードリセット'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 48,
                    color: Colors.green[700],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Success message
              const Text(
                'メールを送信しました',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Text(
                '${_emailController.text}にパスワードリセット用のメールを送信しました。\n\nメール内のリンクをクリックして、新しいパスワードを設定してください。',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Back button
              ElevatedButton(
                onPressed: () {
                  widget.onBackTap?.call();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'ログイン画面に戻る',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
