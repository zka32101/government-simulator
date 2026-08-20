import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:government_simulator/config/firebase_options.dart';
import 'package:government_simulator/models/historical_scenario.dart';
import 'package:government_simulator/models/country_stage.dart';
import 'package:government_simulator/providers/game_provider.dart';
import 'package:government_simulator/utils/constants.dart';
import 'package:government_simulator/utils/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Firebase未設定でもデモ動作させる
  }
  runApp(const ProviderScope(child: GovernmentSimulator()));
}

class GovernmentSimulator extends ConsumerWidget {
  const GovernmentSimulator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const _AppRoot(),
    );
  }

}

class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot({Key? key}) : super(key: key);

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  bool _initialized = false;
  bool _hasSession = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final auth = ref.read(authServiceProvider);
    var user = auth.currentUser;
    user ??= await auth.signInAnonymously();

    if (user != null) {
      await ref.read(userProfileProvider.notifier).loadOrCreate();
      // セッションがあれば自動ロード
      final firestore = ref.read(firestoreServiceProvider);
      final session = await firestore.getLatestSession(user.uid);
      if (session != null && mounted) {
        final decisions =
            await firestore.getSessionDecisions(session.id);
        ref.read(gameSessionProvider.notifier);
        // state を直接ロードする代わりにフラグで分岐
        if (mounted) {
          setState(() {
            _initialized = true;
            _hasSession = true;
          });
          // Notifier に状態を注入（既存セッション）
          ref.read(gameSessionProvider.notifier).loadExisting(session, decisions);
          return;
        }
      }
    }

    if (mounted) {
      setState(() {
        _initialized = true;
        _hasSession = false;
      });
    }
  }

  void _onOnboardingComplete(String countryName, String difficulty) async {
    final auth = ref.read(authServiceProvider);
    final userId = auth.userId ?? 'demo';
    await ref.read(gameSessionProvider.notifier).loadOrCreate(
          userId: userId,
          countryName: countryName,
          difficulty: difficulty,
          forceNew: true,
        );
    if (mounted) setState(() => _hasSession = true);
  }

  Future<void> _onScenarioStart(
      String countryName, HistoricalScenario scenario) async {
    final auth = ref.read(authServiceProvider);
    final userId = auth.userId ?? 'demo';
    await ref.read(gameSessionProvider.notifier).loadOrCreateFromScenario(
          userId: userId,
          countryName: countryName,
          scenario: scenario,
        );
    if (mounted) setState(() => _hasSession = true);
  }

  Future<void> _onStageStart(String countryName, CountryStage stage) async {
    final auth = ref.read(authServiceProvider);
    final userId = auth.userId ?? 'demo';
    await ref.read(gameSessionProvider.notifier).loadOrCreateFromStage(
          userId: userId,
          countryName: countryName,
          stage: stage,
        );
    if (mounted) setState(() => _hasSession = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('国家を準備中...'),
            ],
          ),
        ),
      );
    }

    if (!_hasSession) {
      return OnboardingScreen(
        onStart: _onOnboardingComplete,
        onStartScenario: _onScenarioStart,
        onStartStage: _onStageStart,
      );
    }

    return const HomeScreen();
  }
}
