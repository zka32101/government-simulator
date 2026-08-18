import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/decision.dart';
import 'package:government_simulator/models/user_profile.dart';
import 'package:government_simulator/models/event.dart';
import 'package:government_simulator/models/achievement.dart';
import 'package:government_simulator/models/faction.dart';
import 'package:government_simulator/models/minister.dart';
import 'package:government_simulator/models/promise.dart';
import 'package:government_simulator/models/historical_scenario.dart';
import 'package:government_simulator/services/auth_service.dart';
import 'package:government_simulator/services/firestore_service.dart';
import 'package:government_simulator/services/purchase_service.dart';
import 'package:government_simulator/services/game_logic_service.dart';

/// applyChoice の結果（実績解除・ゲームオーバー・内閣裏切り・公約の顛末）
class ChoiceResult {
  final List<Achievement> newAchievements;
  final GameOverType gameOver;
  final MinisterRole? betrayedMinister;
  final List<PromiseResolution> promiseResolutions;

  ChoiceResult({
    required this.newAchievements,
    required this.gameOver,
    this.betrayedMinister,
    this.promiseResolutions = const [],
  });

  factory ChoiceResult.empty() => ChoiceResult(
        newAchievements: const [],
        gameOver: GameOverType.none,
      );

  bool get isGameOver => gameOver != GameOverType.none;
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());
final purchaseServiceProvider =
    Provider<PurchaseService>((ref) => PurchaseService());
final gameLogicProvider =
    Provider<GameLogicService>((ref) => GameLogicService());

// Current user ID (null = not signed in)
final userIdProvider = StateProvider<String?>((ref) => null);

// User profile state
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier(
    ref.watch(firestoreServiceProvider),
    ref.watch(authServiceProvider),
  );
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final FirestoreService _firestore;
  final AuthService _auth;

  UserProfileNotifier(this._firestore, this._auth) : super(null);

  Future<void> loadOrCreate() async {
    final userId = _auth.userId;
    if (userId == null) return;

    var profile = await _firestore.getUserProfile(userId);
    if (profile == null) {
      profile = UserProfile(
        id: userId,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      await _firestore.createUserProfile(profile);
    } else {
      profile = profile.copyWith(lastLoginAt: DateTime.now());
      await _firestore.updateUserProfile(profile);
    }
    state = profile;
  }

  Future<void> markPurchased() async {
    if (state == null) return;
    final updated = state!.copyWith(isPurchased: true);
    await _firestore.updateUserProfile(updated);
    state = updated;
  }

  void update(UserProfile profile) {
    state = profile;
    _firestore.updateUserProfile(profile);
  }
}

// Game session + decisions
final gameSessionProvider =
    StateNotifierProvider<GameSessionNotifier, GameSessionState>((ref) {
  return GameSessionNotifier(
    ref.watch(firestoreServiceProvider),
    ref.watch(gameLogicProvider),
  );
});

class GameSessionState {
  final GameSession? session;
  final List<Decision> decisions;
  final bool isLoading;

  const GameSessionState({
    this.session,
    this.decisions = const [],
    this.isLoading = true,
  });

  GameSessionState copyWith({
    GameSession? session,
    List<Decision>? decisions,
    bool? isLoading,
  }) =>
      GameSessionState(
        session: session ?? this.session,
        decisions: decisions ?? this.decisions,
        isLoading: isLoading ?? this.isLoading,
      );
}

class GameSessionNotifier extends StateNotifier<GameSessionState> {
  final FirestoreService _firestore;
  final GameLogicService _logic;

  GameSessionNotifier(this._firestore, this._logic)
      : super(const GameSessionState());

  Future<void> loadOrCreate({
    required String userId,
    required String countryName,
    required String difficulty,
    bool forceNew = false,
  }) async {
    state = state.copyWith(isLoading: true);

    GameSession? session;
    List<Decision> decisions = [];

    if (!forceNew) {
      session = await _firestore.getLatestSession(userId);
      if (session != null) {
        decisions = await _firestore.getSessionDecisions(session.id);
      }
    }

    if (session == null) {
      session = _logic.createNewSession(
        userId: userId,
        countryName: countryName,
        difficulty: difficulty,
      );
      await _firestore.createGameSession(session);
    }

    state = GameSessionState(
      session: session,
      decisions: decisions,
      isLoading: false,
    );
  }

  /// 「歴史のif」チャレンジ：シナリオの固定初期ステータスで新規セッションを開始する。
  Future<void> loadOrCreateFromScenario({
    required String userId,
    required String countryName,
    required HistoricalScenario scenario,
  }) async {
    state = state.copyWith(isLoading: true);

    final previousSessionId = state.session?.id;
    final session = _logic.createSessionFromScenario(
      userId: userId,
      countryName: countryName,
      scenario: scenario,
      previousSessionId: previousSessionId,
    );
    await _firestore.createGameSession(session);

    state = GameSessionState(
      session: session,
      decisions: const [],
      isLoading: false,
    );
  }

  /// チュートリアルの完了/スキップを記録する。
  Future<void> markTutorialSeen() async {
    final session = state.session;
    if (session == null || session.hasSeenTutorial) return;

    final updated = session.copyWith(hasSeenTutorial: true);
    await _firestore.updateGameSession(updated);
    state = state.copyWith(session: updated);
  }

  Future<ChoiceResult> applyChoice({
    required String choiceId,
    required Impact impact,
    required String eventId,
    required String narrative,
    Faction? promiseTarget,
  }) async {
    final session = state.session;
    if (session == null) return ChoiceResult.empty();

    // dayを1日進める（年末は呼び出し側でcontinueToNextYear）
    final baseStatus = session.status.copyWith(
      day: session.status.day + 1,
      decisionsCount: session.status.decisionsCount + 1,
      lastUpdated: DateTime.now(),
    );
    var newStatus = _logic.applyImpact(baseStatus, impact);
    final impactScore = _logic.calculateImpactScore(session.status, newStatus);
    final isPositive = _logic.wasPositiveOutcome(impact, session.status);

    // 内閣：政策の影響と汚職度から大臣忠誠度を変動させ、裏切りを判定する
    final ministerDeltas =
        _logic.deriveMinisterImpact(impact, corruption: newStatus.corruption);
    var newCabinet = newStatus.cabinet.applyDeltas(ministerDeltas);
    final betrayedRole = _logic.checkMinisterBetrayal(newCabinet);
    if (betrayedRole != null) {
      newCabinet = newCabinet.markBetrayed(betrayedRole);
      newStatus = newStatus.copyWith(
        stability: (newStatus.stability - 15).clamp(0, 100),
        satisfaction: (newStatus.satisfaction - 10).clamp(0, 100),
      );
    }
    newStatus = newStatus.copyWith(cabinet: newCabinet);

    // 二枚舌外交：新しい公約を記録し、期限が来た公約を判定する
    var activePromises = session.activePromises;
    if (promiseTarget != null) {
      activePromises = [
        ...activePromises,
        _logic.makePromise(promiseTarget, newStatus),
      ];
    }
    final resolution = _logic.resolvePromises(activePromises, newStatus);
    newStatus = newStatus.copyWith(factions: resolution.factions);
    activePromises = resolution.remaining;

    final decision = Decision(
      id: '${session.id}_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: session.id,
      eventId: eventId,
      chosenChoiceId: choiceId,
      decidedAt: DateTime.now(),
      narrative: narrative,
      impactScore: impactScore,
      appliedImpact: impact,
      wasPositiveOutcome: isPositive,
      beforeStatus: session.status,
      afterStatus: newStatus,
    );

    var updatedSession = session.copyWith(
      status: newStatus,
      lastPlayedAt: DateTime.now(),
      totalDecisions: session.totalDecisions + 1,
      positiveOutcomes: session.positiveOutcomes + (isPositive ? 1 : 0),
      negativeOutcomes: session.negativeOutcomes + (isPositive ? 0 : 1),
      activePromises: activePromises,
    );

    // 実績判定
    final newAchievements =
        Achievements.checkNew(updatedSession, session.unlockedAchievements);
    if (newAchievements.isNotEmpty) {
      updatedSession = updatedSession.copyWith(
        unlockedAchievements: [
          ...session.unlockedAchievements,
          ...newAchievements.map((a) => a.id),
        ],
      );
    }

    // ゲームオーバー判定
    final gameOver = _logic.checkGameOver(newStatus);

    await _firestore.batchUpdateSession(updatedSession, decision);

    state = state.copyWith(
      session: updatedSession,
      decisions: [...state.decisions, decision],
    );

    return ChoiceResult(
      newAchievements: newAchievements,
      gameOver: gameOver,
      betrayedMinister: betrayedRole,
      promiseResolutions: resolution.resolutions,
    );
  }

  void loadExisting(GameSession session, List<Decision> decisions) {
    state = GameSessionState(
      session: session,
      decisions: decisions,
      isLoading: false,
    );
  }

  Future<void> startNewYear({
    required String userId,
    required String countryName,
    required String difficulty,
    String? previousSessionId,
  }) async {
    final newSession = _logic.createNewSession(
      userId: userId,
      countryName: countryName,
      difficulty: difficulty,
      previousSessionId: previousSessionId,
    );
    await _firestore.createGameSession(newSession);
    state = GameSessionState(
      session: newSession,
      decisions: [],
      isLoading: false,
    );
  }

  Future<void> continueToNextYear() async {
    final session = state.session;
    if (session == null) return;

    final yearEndStatus = _logic.simulateYearPassed(session.status);
    final updatedSession = session.copyWith(
      status: yearEndStatus,
      lastPlayedAt: DateTime.now(),
    );
    await _firestore.updateGameSession(updatedSession);
    state = state.copyWith(session: updatedSession);
  }
}
