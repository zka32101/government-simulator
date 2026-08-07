// CI-ONLY PLACEHOLDER — not a real Firebase config, and normally never
// touches the app source tree (the analyze/test workflow copies this to
// government_simulator/lib/config/firebase_options.dart, which is
// gitignored). It exists only so that `flutter analyze`/`flutter test`
// can resolve main.dart's import without a real (secret) Firebase
// project. Run `flutterfire configure` locally to generate the real
// file for development/release builds; a real release build (see
// .github/workflows/deploy.yml) requires the FIREBASE_OPTIONS_DART repo
// secret and refuses to fall back to this placeholder.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'ci-placeholder',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'ci-placeholder',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'ci-placeholder',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'ci-placeholder',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'ci-placeholder',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'ci-placeholder',
    iosBundleId: 'com.petitworks.government_simulator',
  );

  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = web;
  static const FirebaseOptions linux = web;
}
