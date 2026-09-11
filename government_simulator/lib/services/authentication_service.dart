import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Firebase認証を管理するサービス。
/// メール/パスワード、Google、Appleでの認証をサポート。
/// 匿名ユーザーをメール認証にリンク可能。
class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 現在のユーザー
  User? get currentUser => _auth.currentUser;

  // ユーザーID
  String? get userId => _auth.currentUser?.uid;

  // ユーザーメール
  String? get userEmail => _auth.currentUser?.email;

  // 認証状態変更ストリーム
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ユーザーが認証済みか
  bool get isAuthenticated => _auth.currentUser != null;

  // ユーザーが匿名か
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;

  // =================== Anonymous Sign-In ===================

  /// 匿名でサインイン
  Future<User?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // =================== Email/Password Authentication ===================

  /// メールアドレスとパスワードでサインアップ
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// メールアドレスとパスワードでサインイン
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// パスワードリセットメール送信
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // =================== Google Sign-In ===================

  /// Googleでサインイン
  Future<User?> signInWithGoogle() async {
    try {
      // Googleサインインダイアログを表示
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // ユーザーがキャンセル
        throw AuthException('Google sign-in cancelled');
      }

      // Google認証トークンを取得
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase用のクレデンシャルを作成
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebaseでサインイン
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }

  // =================== Apple Sign-In ===================

  /// Appleでサインイン (iOS のみ)
  Future<User?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(scopes: []);

      // Firebase用のクレデンシャルを作成
      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // Firebaseでサインイン
      final userCredential = await _auth.signInWithCredential(oAuthCredential);
      return userCredential.user;
    } on SignInWithAppleException catch (e) {
      throw AuthException('Apple sign-in failed: $e');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('Apple sign-in failed: $e');
    }
  }

  // =================== Account Linking ===================

  /// 匿名アカウントをメールアドレスにリンク
  /// 匿名ユーザーのゲーム進捗を保持したまま認証されたユーザーに昇格
  Future<User?> linkAnonymousToEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (!isAnonymous) {
        throw AuthException('User is not anonymous');
      }

      // 匿名ユーザーのクレデンシャルを作成
      final emailCredential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );

      // リンク実行
      final userCredential = await currentUser!.linkWithCredential(emailCredential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// 匿名アカウントをGoogleアカウントにリンク
  Future<User?> linkAnonymousToGoogle() async {
    try {
      if (!isAnonymous) {
        throw AuthException('User is not anonymous');
      }

      // Googleサインイン
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google sign-in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // リンク実行
      final userCredential = await currentUser!.linkWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('Google linking failed: $e');
    }
  }

  /// 匿名アカウントをAppleアカウントにリンク
  Future<User?> linkAnonymousToApple() async {
    try {
      if (!isAnonymous) {
        throw AuthException('User is not anonymous');
      }

      final credential = await SignInWithApple.getAppleIDCredential(scopes: []);

      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // リンク実行
      final userCredential = await currentUser!.linkWithCredential(oAuthCredential);
      return userCredential.user;
    } on SignInWithAppleException catch (e) {
      throw AuthException('Apple linking failed: $e');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('Apple linking failed: $e');
    }
  }

  // =================== Profile Management ===================

  /// プロフィール情報を更新 (表示名、プロフィール画像など)
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (currentUser == null) {
        throw AuthException('No user signed in');
      }

      await currentUser!.updateDisplayName(displayName);
      if (photoURL != null) {
        await currentUser!.updatePhotoURL(photoURL);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// メールアドレスを変更 (再認証が必要な場合がある)
  Future<void> updateEmail(String newEmail) async {
    try {
      if (currentUser == null) {
        throw AuthException('No user signed in');
      }

      await currentUser!.updateEmail(newEmail.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw AuthException(
          'Please sign out and sign in again before changing email',
        );
      }
      throw _handleAuthException(e);
    }
  }

  // =================== Account Deletion ===================

  /// ユーザーアカウントを削除
  /// 警告: この操作は取り消せません。すべてのユーザーデータが削除されます。
  Future<void> deleteAccount() async {
    try {
      if (currentUser == null) {
        throw AuthException('No user signed in');
      }

      await currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw AuthException('Please sign out and sign in again before deleting account');
      }
      throw _handleAuthException(e);
    }
  }

  // =================== Sign Out ===================

  /// すべてのプロバイダーからサインアウト
  Future<void> signOut() async {
    try {
      // Googleサインアウト (Google認証を使用している場合)
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Firebase Auth サインアウト
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  // =================== Helper Methods ===================

  /// Firebase認証例外を処理してユーザーフレンドリーなメッセージを返す
  AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return AuthException('パスワードが弱すぎます。6文字以上で設定してください。');
      case 'email-already-in-use':
        return AuthException('このメールアドレスは既に使用されています。');
      case 'invalid-email':
        return AuthException('メールアドレスが無効です。');
      case 'user-disabled':
        return AuthException('このアカウントは無効化されています。');
      case 'user-not-found':
        return AuthException('ユーザーが見つかりません。');
      case 'wrong-password':
        return AuthException('パスワードが間違っています。');
      case 'account-exists-with-different-credential':
        return AuthException(
          'このメールアドレスは異なるプロバイダーで既に使用されています。',
        );
      case 'credential-already-in-use':
        return AuthException('このクレデンシャルは既に使用されています。');
      case 'invalid-credential':
        return AuthException('クレデンシャルが無効です。');
      case 'operation-not-allowed':
        return AuthException('この操作は許可されていません。');
      case 'requires-recent-login':
        return AuthException('再度サインインしてください。');
      case 'network-request-failed':
        return AuthException('ネットワークエラーが発生しました。インターネット接続を確認してください。');
      default:
        return AuthException('認証エラーが発生しました: ${e.message}');
    }
  }
}

/// 認証関連のカスタム例外
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
