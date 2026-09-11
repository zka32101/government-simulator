import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/providers/authentication_provider.dart';

/// プロフィール編集画面
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showPasswordChangeForm = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _emailController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Load current user data
    final authService = ref.read(authenticationServiceProvider);
    _displayNameController.text =
        authService.currentUser?.displayName ?? '';
    _emailController.text = authService.userEmail ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateDisplayName(String value) {
    if (value.isEmpty) return null; // Optional field
    if (value.length > 50) return '50文字以内である必要があります。';
    return null;
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
    if (value != _newPasswordController.text) return 'パスワードが一致しません。';
    return null;
  }

  Future<void> _handleUpdateProfile() async {
    final displayNameError = _validateDisplayName(_displayNameController.text);
    if (displayNameError != null) {
      _showErrorDialog(displayNameError);
      return;
    }

    final notifier = ref.read(authStateNotifierProvider.notifier);
    final request = UpdateProfileRequest(
      displayName: _displayNameController.text.isEmpty
          ? null
          : _displayNameController.text,
    );

    final authService = ref.read(authenticationServiceProvider);
    try {
      await authService.updateUserProfile(
        displayName: _displayNameController.text.isEmpty
            ? null
            : _displayNameController.text,
      );
      _showSuccessDialog('プロフィールを更新しました。');
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _handleChangeEmail() async {
    final emailError = _validateEmail(_emailController.text.trim());
    if (emailError != null) {
      _showErrorDialog(emailError);
      return;
    }

    final authService = ref.read(authenticationServiceProvider);
    try {
      await authService.updateEmail(_emailController.text.trim());
      _showSuccessDialog('メールアドレスを更新しました。');
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _handleChangePassword() async {
    final passwordError = _validatePassword(_newPasswordController.text);
    final confirmError =
        _validateConfirmPassword(_confirmPasswordController.text);

    if (passwordError != null || confirmError != null) {
      _showErrorDialog(passwordError ?? confirmError ?? 'エラーが発生しました。');
      return;
    }

    _showErrorDialog('パスワード変更機能は近日実装予定です。\n現在はFirebaseコンソールから変更してください。');
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アカウント削除'),
        content: const Text(
          'アカウントを削除すると、すべてのゲームデータが永久に削除されます。\nこの操作は取り消せません。本当に削除しますか?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final authService = ref.read(authenticationServiceProvider);
    try {
      await authService.deleteAccount();
      if (mounted) Navigator.of(context).pop();
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('完了'),
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
        title: const Text('プロフィール編集'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display name
            _buildSectionTitle('表示名'),
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: '表示名',
                hintText: '例: 日本の統治者',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              enabled: !authState.isLoading,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: authState.isLoading ? null : _handleUpdateProfile,
                child: const Text('更新'),
              ),
            ),
            const SizedBox(height: 32),

            // Email section
            _buildSectionTitle('メールアドレス'),
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
              enabled: !authState.isLoading,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: authState.isLoading ? null : _handleChangeEmail,
                child: const Text('変更'),
              ),
            ),
            const SizedBox(height: 32),

            // Password change section
            _buildSectionTitle('パスワード'),
            OutlinedButton(
              onPressed: authState.isLoading
                  ? null
                  : () {
                      setState(
                          () => _showPasswordChangeForm = !_showPasswordChangeForm);
                    },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(_showPasswordChangeForm ? 'キャンセル' : 'パスワードを変更'),
            ),
            if (_showPasswordChangeForm) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: '新しいパスワード',
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
                ),
              ),
              const SizedBox(height: 16),
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
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleChangePassword,
                  child: const Text('パスワードを変更'),
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Danger zone
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '危険ゾーン',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        authState.isLoading ? null : _handleDeleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'アカウントを削除',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
