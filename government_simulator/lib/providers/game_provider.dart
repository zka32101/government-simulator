import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/decision.dart';
import 'package:government_simulator/models/user_profile.dart';
import 'package:government_simulator/models/event.dart';
import 'package:government_simulator/models/achievement.dart';
import 'package:government_simulator/models/faction.dart';
import 'package:government_simulator/models/indicator_history.dart';
import 'package:government_simulator/models/minister.dart';
import 'package:government_simulator/models/promise.dart';
import 'package:government_simulator/models/historical_scenario.dart';
import 'package:government_simulator/models/country_stage.dart';
import 'package:government_simulator/models/campaign.dart';
import 'package:government_simulator/models/political_party.dart';
import 'package:government_simulator/models/international_relations.dart';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/debate.dart';
import 'package:government_simulator/models/crisis.dart';
import 'package:government_simulator/models/election_result.dart';
import 'package:government_simulator/services/auth_service.dart';
import 'package:government_simulator/services/firestore_service.dart';
import 'package:government_simulator/services/purchase_service.dart';
import 'package:government_simulator/services/game_logic_service.dart';
import 'package:government_simulator/services/analytics_service.dart';
import 'package:government_simulator/services/scenario_service.dart';
import 'package:government_simulator/models/story_pack.dart';
import 'package:government_simulator/services/story_pack_service.dart';
import 'package:government_simulator/services/pack_event_engine.dart';
import 'package:government_simulator/models/story_pack_event.dart';
import 'package:government_simulator/services/scandal_service.dart';
import 'package:government_simulator/services/diplomacy_service.dart';
import 'package:government_simulator/services/cabinet_infighting_service.dart';
import 'package:government_simulator/services/achievement_service.dart';
import 'package:government_simulator/services/random_crisis_generator.dart';
import 'package:government_simulator/services/citizen_survey_service.dart';
import 'package:government_simulator/models/scenario.dart';
import 'package:government_simulator/models/scandal.dart';
import 'package:uuid/uuid.dart';

/// applyChoice の結果（実績解除・ゲームオーバー・内閣裏切り・公約の顛末）
class ChoiceResult {
  final List<Achievement> newAchievements;
  final GameOverType gameOver;
  final MinisterRole? betrayedMinister;
  final List<PromiseResolution> promiseResolutions;
  final Scandal? newScandal;

  ChoiceResult({
    required this.newAchievements,
    required this.gameOver,
    this.betrayedMinister,
    this.promiseResolutions = const [],
    this.newScandal,
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

  /// 以前は Firestore への書き込みを await せず投げっぱなし（fire-and-forget）
  /// にしていたため、書き込みが失敗してもローカルの state だけが更新され、
  /// 実際に永続化された内容との乖離に誰も気づけなかった。呼び出し側が
  /// エラーハンドリングできるよう Future を返すようにした。
  Future<void> update(UserProfile profile) async {
    state = profile;
    await _firestore.updateUserProfile(profile);
  }
}

// Game session + decisions
final gameSessionProvider =
    StateNotifierProvider<GameSessionNotifier, GameSessionState>((ref) {
  return GameSessionNotifier(
    ref.watch(firestoreServiceProvider),
    ref.watch(gameLogicProvider),
    AnalyticsService(),
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
  final AnalyticsService _analytics;
  final _uuid = const Uuid();

  // applyChoice の多重実行を防ぐガード。連打やダブルタップで同じ選択が
  // 二重に適用され、片方のセッション更新が silently 失われるバグが
  // あったため、処理中は以降の呼び出しを無視する。
  bool _applyingChoice = false;

  GameSessionNotifier(this._firestore, this._logic, this._analytics)
      : super(const GameSessionState());

  Future<void> loadOrCreate({
    required String userId,
    required String countryName,
    required String difficulty,
    bool forceNew = false,
  }) async {
    try {
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
          previousSessionId: state.session?.id,
        );
        await _firestore.createGameSession(session);
      }

      state = GameSessionState(
        session: session,
        decisions: decisions,
        isLoading: false,
      );

      // Track game started event
      await _analytics.trackGameStarted(
        countryName: countryName,
        difficulty: difficulty,
        scenarioId: 'standard',
      );
    } catch (e) {
      // Error tracking for session loading
      unawaited(_analytics.trackError(
        errorCode: 'session_load_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.loadOrCreate',
      ));
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// 「歴史のif」チャレンジ：シナリオの固定初期ステータスで新規セッションを開始する。
  Future<void> loadOrCreateFromScenario({
    required String userId,
    required String countryName,
    required HistoricalScenario scenario,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      final previousSessionId = state.session?.id;
      var session = _logic.createSessionFromScenario(
        userId: userId,
        countryName: countryName,
        scenario: scenario,
        previousSessionId: previousSessionId,
      );

      // シナリオの初期状態をスナップショットとして記録
      final initialSnapshot = IndicatorSnapshot(
        year: session.status.year,
        day: session.status.day,
        gdp: session.status.gdp,
        unemployment: session.status.unemployment,
        satisfaction: session.status.satisfaction,
        nationalPower: session.status.nationalPower,
        inflationRate: session.status.inflationRate,
        publicDebt: session.status.publicDebt,
        stability: session.status.stability,
      );

      session = session.copyWith(
        indicatorHistory: [initialSnapshot],
      );

      await _firestore.createGameSession(session);

      state = GameSessionState(
        session: session,
        decisions: const [],
        isLoading: false,
      );

      // アナリティクス：シナリオチャレンジ開始を追跡
      unawaited(_analytics.trackGameStarted(
        countryName: countryName,
        difficulty: 'scenario',
        scenarioId: scenario.id,
      ));
    } catch (e) {
      // Error tracking for scenario load
      unawaited(_analytics.trackError(
        errorCode: 'scenario_load_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.loadOrCreateFromScenario',
      ));
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// シナリオパック：仮想国シナリオから新規セッションを開始する。
  /// プレイヤーが選択したGameScenarioをゲーム初期化に使用。
  Future<void> loadOrCreateFromGameScenario({
    required String userId,
    required String playerName,
    required GameScenario gameScenario,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      // シナリオからゲーム初期化データを生成
      final scenarioData =
          ScenarioService.createGameSessionDataFromScenario(gameScenario);

      // 難易度に基づいた乗数を計算
      final difficultyMultiplier = gameScenario.difficulty == 'hard'
          ? 0.9
          : gameScenario.difficulty == 'easy'
              ? 1.1
              : 1.0;

      // 基本GameSessionを作成
      final initialStatus = CountryStatus(
        gdp: gameScenario.gdp * difficultyMultiplier,
        unemployment: 5.0 / (gameScenario.difficulty == 'easy' ? 1.2 : 1.0),
        satisfaction: gameScenario.initialApproval * 100,
        nationalPower: 50.0,
        year: 1,
        day: 1,
        lastUpdated: DateTime.now(),
        stability: 70.0,
        isNewGame: true,
      );

      final session = GameSession(
        id: _uuid.v4(),
        userId: userId,
        countryName: gameScenario.countryName,
        status: initialStatus,
        createdAt: DateTime.now(),
        lastPlayedAt: DateTime.now(),
        difficulty: gameScenario.difficulty,
        // シナリオから初期値を設定
        nationalApproval: gameScenario.initialApproval,
        economicSatisfaction: gameScenario.economicSatisfaction,
        socialSatisfaction: gameScenario.socialSatisfaction,
        securitySatisfaction: gameScenario.securitySatisfaction,
        healthcareSatisfaction: gameScenario.healthcareSatisfaction,
        nationRelationships: scenarioData['nationRelationships'] as Map<String, NationRelationship>,
        scenarioId: gameScenario.id,
        currentPackId: StoryPackService.getPackForScenario(gameScenario.id)?.id,
      );

      // シナリオの初期状態をスナップショットとして記録
      final initialSnapshot = IndicatorSnapshot(
        year: session.status.year,
        day: session.status.day,
        gdp: session.status.gdp,
        unemployment: session.status.unemployment,
        satisfaction: session.status.satisfaction,
        nationalPower: session.status.nationalPower,
        inflationRate: session.status.inflationRate,
        publicDebt: session.status.publicDebt,
        stability: session.status.stability,
      );

      final sessionWithHistory = session.copyWith(
        indicatorHistory: [initialSnapshot],
      );

      await _firestore.createGameSession(sessionWithHistory);

      state = GameSessionState(
        session: sessionWithHistory,
        decisions: const [],
        isLoading: false,
      );

      // アナリティクス：シナリオパック開始を追跡
      unawaited(_analytics.trackGameStarted(
        countryName: gameScenario.countryName,
        difficulty: gameScenario.difficulty,
        scenarioId: gameScenario.id,
      ));
    } catch (e) {
      // Error tracking for game scenario load
      unawaited(_analytics.trackError(
        errorCode: 'game_scenario_load_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.loadOrCreateFromGameScenario',
      ));
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// 「国家ステージ」チャレンジ：選ばれたステージの固定初期ステータスで
  /// 新規セッションを開始する。
  Future<void> loadOrCreateFromStage({
    required String userId,
    required String countryName,
    required CountryStage stage,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      final previousSessionId = state.session?.id;
      var session = _logic.createSessionFromStage(
        userId: userId,
        countryName: countryName,
        stage: stage,
        previousSessionId: previousSessionId,
      );

      // ステージの初期状態をスナップショットとして記録
      final initialSnapshot = IndicatorSnapshot(
        year: session.status.year,
        day: session.status.day,
        gdp: session.status.gdp,
        unemployment: session.status.unemployment,
        satisfaction: session.status.satisfaction,
        nationalPower: session.status.nationalPower,
        inflationRate: session.status.inflationRate,
        publicDebt: session.status.publicDebt,
        stability: session.status.stability,
      );

      session = session.copyWith(
        indicatorHistory: [initialSnapshot],
      );

      await _firestore.createGameSession(session);

      state = GameSessionState(
        session: session,
        decisions: const [],
        isLoading: false,
      );

      // アナリティクス：国家ステージチャレンジ開始を追跡
      unawaited(_analytics.trackGameStarted(
        countryName: countryName,
        difficulty: 'stage',
        scenarioId: stage.id,
      ));
    } catch (e) {
      // Error tracking for stage load
      unawaited(_analytics.trackError(
        errorCode: 'stage_load_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.loadOrCreateFromStage',
      ));
      state = state.copyWith(isLoading: false);
      rethrow;
    }
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
    // 処理中に二重に呼ばれた場合（ダブルタップ等）、後発の呼び出しは
    // 古い session を基に計算してしまい、先発の呼び出しによる状態更新を
    // 上書きして消してしまう（後勝ち）レースコンディションがあったため、
    // 処理中は再入を無視する。
    if (_applyingChoice) return ChoiceResult.empty();
    _applyingChoice = true;
    try {
      return await _applyChoiceInternal(
        choiceId: choiceId,
        impact: impact,
        eventId: eventId,
        narrative: narrative,
        promiseTarget: promiseTarget,
      );
    } catch (e) {
      // Error tracking for choice application
      unawaited(_analytics.trackError(
        errorCode: 'choice_apply_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.applyChoice',
      ));
      return ChoiceResult.empty();
    } finally {
      _applyingChoice = false;
    }
  }

  Future<ChoiceResult> _applyChoiceInternal({
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

    // キャンペーン効果を適用
    var sessionWithCampaignEffects = session.copyWith(status: newStatus);
    sessionWithCampaignEffects = _logic.applyDailyCampaignEffects(
      session: sessionWithCampaignEffects,
    );
    newStatus = sessionWithCampaignEffects.status;

    // スキャンダル処理
    var sessionWithScandalEffects = sessionWithCampaignEffects;

    // スキャンダル発生判定
    final newScandal = _logic.generateRandomScandal(
      currentYear: newStatus.year,
      currentWeek: newStatus.week,
      playerSupport: newStatus.satisfaction,
      difficulty: session.difficulty,
      playerReputation: sessionWithCampaignEffects.playerReputation,
      activecampaignCount: sessionWithCampaignEffects.activeCampaigns.length,
      corruption: newStatus.corruption,
    );

    if (newScandal != null) {
      final updatedScandalsList = [...sessionWithCampaignEffects.activeScandalsList, newScandal];
      sessionWithScandalEffects = sessionWithCampaignEffects.copyWith(
        activeScandalsList: updatedScandalsList,
      );
    }

    // スキャンダルの支持率への影響を計算・適用
    final scandalImpact = _logic.calculateScandalNetImpact(
      activeScandalsList: sessionWithScandalEffects.activeScandalsList,
      year: newStatus.year,
      week: newStatus.week,
      playerReputation: sessionWithScandalEffects.playerReputation,
      mediaFavoring: sessionWithScandalEffects.mediaFavoring,
    );

    if (scandalImpact != 0.0) {
      newStatus = newStatus.copyWith(
        satisfaction: (newStatus.satisfaction + scandalImpact).clamp(0, 100),
      );
      sessionWithScandalEffects = sessionWithScandalEffects.copyWith(
        status: newStatus,
      );
    }

    // 内閣：政策の影響と汚職度から大臣忠誠度を変動させ、裏切りを判定する
    final ministerDeltas = _logic.deriveMinisterImpact(impact,
        corruption: newStatus.corruption);
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

    // インパクトスコア/成功判定は、内閣裏切り・公約破棄による追加の
    // ステータス変動まで織り込んだ「最終的な」newStatus を基に算出する。
    // 以前はこれらの効果が適用される前の中間状態から計算していたため、
    // 裏切りが起きたターンでは「決定の結果」画面の評価やAI生成される
    // 統治記録の文章が、実際の変化量と食い違うことがあった。
    final impactScore =
        _logic.calculateImpactScore(session.status, newStatus);
    final isPositive = _logic.wasPositiveOutcome(impact, session.status);

    final decision = Decision(
      // セッションID+ミリ秒タイムスタンプでは、同一ミリ秒内に2回
      // applyChoice が呼ばれた場合にIDが衝突し、Firestore上で片方の
      // Decision が silently 上書きされて消えてしまっていたため、
      // 他のモデル（セッション・公約等）と同様に UUID を用いる。
      id: _uuid.v4(),
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
      activeScandalsList: sessionWithScandalEffects.activeScandalsList,
      playerReputation: sessionWithScandalEffects.playerReputation,
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

    // アナリティクス：ポリシー選択を追跡
    unawaited(_analytics.trackPolicyChosen(
      policyId: choiceId,
      policyName: choiceId,
      eventCategory: eventId,
      impactScore: impactScore,
      year: newStatus.year,
      day: newStatus.day,
    ));

    // アナリティクス：実績解除を追跡
    for (final achievement in newAchievements) {
      unawaited(_analytics.trackAchievementUnlocked(
        achievementId: achievement.id,
        achievementName: achievement.title,
        year: newStatus.year,
      ));
    }

    return ChoiceResult(
      newAchievements: newAchievements,
      gameOver: gameOver,
      betrayedMinister: betrayedRole,
      promiseResolutions: resolution.resolutions,
      newScandal: newScandal,
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
    try {
      var newSession = _logic.createNewSession(
        userId: userId,
        countryName: countryName,
        difficulty: difficulty,
        previousSessionId: previousSessionId,
      );

      // 初期状態の国家指標をスナップショットとして記録
      final initialSnapshot = IndicatorSnapshot(
        year: newSession.status.year,
        day: newSession.status.day,
        gdp: newSession.status.gdp,
        unemployment: newSession.status.unemployment,
        satisfaction: newSession.status.satisfaction,
        nationalPower: newSession.status.nationalPower,
        inflationRate: newSession.status.inflationRate,
        publicDebt: newSession.status.publicDebt,
        stability: newSession.status.stability,
      );

      newSession = newSession.copyWith(
        indicatorHistory: [initialSnapshot],
      );

      await _firestore.createGameSession(newSession);
      state = GameSessionState(
        session: newSession,
        decisions: [],
        isLoading: false,
      );

      // アナリティクス：新年ゲーム開始を追跡
      unawaited(_analytics.trackGameStarted(
        countryName: countryName,
        difficulty: difficulty,
        scenarioId: 'continuation',
      ));
    } catch (e) {
      // Error tracking for new year start
      unawaited(_analytics.trackError(
        errorCode: 'new_year_start_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.startNewYear',
      ));
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// 外交システムの週間更新を処理
  /// 貿易収入/支出、制裁影響、戦争ダメージなどを適用
  GameSession _updateDiplomaticState(GameSession session, CountryStatus status) {
    var updatedSession = session;
    var currentStatus = status;

    // 制裁による月間経済ダメージを計算
    double totalSanctionImpact = 0;
    for (final sanction in updatedSession.activeSanctions) {
      if (sanction.plannedEndDate != null && sanction.plannedEndDate!.isAfter(DateTime.now())) {
        totalSanctionImpact += sanction.monthlyEconomicImpact;
      }
    }

    // 戦争中の場合、軍事ダメージと経済ダメージを適用
    double warDamage = 0;
    if (updatedSession.warEnemyId != null && updatedSession.warStartDate != null) {
      // 戦争での月間コスト（戦争中の毎月）
      warDamage = 200000; // $200K/月の基本戦争コスト
    }

    // GDP の経済マイナスを計算
    final totalMonthlyDamage = totalSanctionImpact + warDamage;

    // 満足度への影響（戦争と制裁）
    double satisfactionImpact = 0;
    if (updatedSession.warEnemyId != null) {
      satisfactionImpact -= 1; // 毎月-1%の満足度低下
    }
    if (updatedSession.activeSanctions.isNotEmpty) {
      satisfactionImpact -= 0.5;
    }

    // ステータスを更新（貿易収入と戦争/制裁ダメージを反映）
    currentStatus = currentStatus.copyWith(
      gdp: (currentStatus.gdp - (totalMonthlyDamage / 1000000)).clamp(0.1, double.infinity),
      satisfaction:
          (currentStatus.satisfaction + satisfactionImpact).clamp(0.0, 100.0),
    );

    updatedSession = updatedSession.copyWith(
      status: currentStatus,
      economicDamageFromWar: updatedSession.economicDamageFromWar + warDamage,
      foreignDebt: updatedSession.foreignDebt + totalSanctionImpact,
    );

    // 国際スタンディングを計算
    final nationsCount = updatedSession.nationRelationships.length;
    if (nationsCount > 0) {
      double totalStanding = 0;
      for (final rel in updatedSession.nationRelationships.values) {
        totalStanding += rel.standingScore;
      }
      final avgStanding = totalStanding / nationsCount;
      final internationalStanding = ((avgStanding + 100) / 2).clamp(0.0, 100.0);

      updatedSession = updatedSession.copyWith(
        internationalStanding: internationalStanding,
      );
    }

    return updatedSession;
  }

  /// 年を1つ進める。この年が選挙年であれば選挙を実施し、その結果を返す
  /// （呼び出し側で選挙結果画面・落選時のゲームオーバー表示に使う）。
  /// 選挙年でなければ null を返す。
  Future<ElectionResult?> continueToNextYear() async {
    try {
      final session = state.session;
      if (session == null) return null;

      final yearEndStatus = _logic.simulateYearPassed(session.status);

      // 外交システムの状態を更新（貿易収入/支出、戦争ダメージ、制裁影響）
      var sessionWithDiplomacy = _updateDiplomaticState(session, yearEndStatus);
      var finalYearEndStatus = sessionWithDiplomacy.status;

      // 年末の国家指標をスナップショットとして記録（UI/UX改善用）
      final snapshot = IndicatorSnapshot(
        year: finalYearEndStatus.year,
        day: finalYearEndStatus.day,
        gdp: finalYearEndStatus.gdp,
        unemployment: finalYearEndStatus.unemployment,
        satisfaction: finalYearEndStatus.satisfaction,
        nationalPower: finalYearEndStatus.nationalPower,
        inflationRate: finalYearEndStatus.inflationRate,
        publicDebt: finalYearEndStatus.publicDebt,
        stability: finalYearEndStatus.stability,
      );

      final updatedHistory = List<IndicatorSnapshot>.from(session.indicatorHistory)
        ..add(snapshot);

      // 選挙チェック：4年ごとに実施
      var finalSession = sessionWithDiplomacy.copyWith(
        status: finalYearEndStatus,
        lastPlayedAt: DateTime.now(),
        indicatorHistory: updatedHistory,
      );

      // キャンペーンのクリーンアップ：完了したキャンペーンを削除
      final activeCampaigns = session.activeCampaigns
          .where((c) => !c.isCompleted(finalYearEndStatus.year, finalYearEndStatus.week))
          .toList();

      final rivalCampaigns = session.rivalCampaigns
          .where((c) => !c.isCompleted(finalYearEndStatus.year, finalYearEndStatus.week))
          .toList();

      // スキャンダルのクリーンアップ：解決済みスキャンダルを削除
      final activeScandalsList = session.activeScandalsList
          .where((s) => !s.isResolved(finalYearEndStatus.year, finalYearEndStatus.week))
          .toList();

      // 政治政党の状態を毎年更新
      final updatedParties = Map<String, PoliticalParty>.from(session.politicalParties);

      GameLogicService.updatePoliticalPartyStates(finalSession);

      // 選挙年の場合は予算を補充
      double newCampaignBudget = session.campaignBudget;
      double newSpentBudget = 0;
      if (GameLogicService.shouldHoldElection(finalSession)) {
        // 選挙年：予算を リセット
        newCampaignBudget = 500.0; // 500万単位
        newSpentBudget = 0.0;
      } else {
        // 非選挙年の場合も予算を少し補充
        newCampaignBudget = 250.0;
        newSpentBudget = 0.0;
      }

      // 討論会効果の減衰（4週間後に効果が切れる）
      int updatedWeeksSinceDebate = finalSession.weeksSinceDebate + 1;
      double debateEffectsMultiplier = 1.0;
      if (updatedWeeksSinceDebate <= 4 && finalSession.upcomingDebate != null) {
        debateEffectsMultiplier =
            finalSession.upcomingDebate!.outcome?.campaignMultiplier ?? 1.0;
      } else {
        updatedWeeksSinceDebate = 0;
      }

      finalSession = finalSession.copyWith(
        politicalParties: updatedParties,
        activeCampaigns: activeCampaigns,
        rivalCampaigns: rivalCampaigns,
        campaignBudget: newCampaignBudget,
        spentBudget: newSpentBudget,
        activeScandalsList: activeScandalsList,
        debateEffectsMultiplier: debateEffectsMultiplier,
        weeksSinceDebate: updatedWeeksSinceDebate,
      );

      if (GameLogicService.shouldHoldElection(finalSession)) {
        // 選挙年：ライバル候補者を初期化
        final rivalCandidates = GameLogicService.initializeRivalCandidatesForElection(finalSession);

        // 討論会をスケジュール設定（最初のライバルとの討論）
        Debate? scheduledDebate;
        if (rivalCandidates.isNotEmpty) {
          scheduledDebate = _logic.scheduleDebate(
            session: finalSession,
            opponent: rivalCandidates.first,
            electionYear: finalYearEndStatus.year,
          );
        }

        final electionResult = _logic.calculateElectionResult(
          sessionId: session.id,
          year: finalYearEndStatus.year,
          session: finalSession,
          rivals: rivalCandidates,
          difficulty: session.difficulty,
        );

        // 選挙スコアの累積平均を計算
        final previousScore = session.cumulativeElectoralScore * session.successfulTerms;
        final newCumulativeScore = (previousScore + electionResult.electoralScore) /
            (session.successfulTerms + (electionResult.playerWon ? 1 : 0));

        final newSuccessfulTerms = electionResult.playerWon ? session.successfulTerms + 1 : session.successfulTerms;

        finalSession = finalSession.copyWith(
          lastElectionResult: electionResult,
          successfulTerms: newSuccessfulTerms,
          cumulativeElectoralScore: newCumulativeScore,
          rivalCandidates: rivalCandidates,
          upcomingDebate: scheduledDebate,
        );

        await _firestore.updateGameSession(finalSession);
        state = state.copyWith(session: finalSession);

        unawaited(_analytics.trackEvent(
          name: 'election_held',
          parameters: {
            'year': finalYearEndStatus.year,
            'player_won': electionResult.playerWon,
            'vote_share': electionResult.playerVoteShare,
          },
        ));

        // 選挙結果（当選/落選いずれも）はUI層で結果画面・ゲームオーバー処理に使う
        return electionResult;
      }

      await _firestore.updateGameSession(finalSession);
      state = state.copyWith(session: finalSession);

      // アナリティクス：年終了イベントを追跡
      final satisfactionChangeAnalytics = yearEndStatus.satisfaction - session.status.satisfaction;
      final gdpChangeAnalytics = yearEndStatus.gdp - session.status.gdp;
      unawaited(_analytics.trackYearEnd(
        year: yearEndStatus.year - 1, // 終了した年を記録
        satisfactionChange: satisfactionChangeAnalytics,
        gdpChange: gdpChangeAnalytics,
        decisionsInYear: session.status.decisionsCount,
      ));
      return null;
    } catch (e) {
      // Error tracking for year progression
      unawaited(_analytics.trackError(
        errorCode: 'year_continue_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.continueToNextYear',
      ));
      rethrow;
    }
  }

  /// キャンペーンを開始する
  Future<void> launchCampaign({
    required CampaignType type,
    required int durationWeeks,
    required double budgetSpent,
  }) async {
    try {
      final session = state.session;
      if (session == null) return;

      // 予算チェック
      final availableBudget = session.campaignBudget - session.spentBudget;
      if (budgetSpent > availableBudget) {
        throw Exception('予算不足です');
      }

      // キャンペーンを作成
      final campaign = _logic.launchCampaign(
        sessionId: session.id,
        type: type,
        durationWeeks: durationWeeks,
        currentYear: session.status.year,
        currentWeek: session.status.week,
      );

      // ゲームセッションを更新
      final updatedCampaigns = List<Campaign>.from(session.activeCampaigns)
        ..add(campaign);

      final updatedSession = session.copyWith(
        activeCampaigns: updatedCampaigns,
        spentBudget: session.spentBudget + budgetSpent,
        lastPlayedAt: DateTime.now(),
      );

      await _firestore.updateGameSession(updatedSession);
      state = state.copyWith(session: updatedSession);

      // アナリティクス：キャンペーン開始を追跡
      unawaited(_analytics.trackEvent(
        name: 'campaign_launched',
        parameters: {
          'campaign_type': type.name,
          'duration_weeks': durationWeeks,
          'budget_spent': budgetSpent.toInt(),
        },
      ));
    } catch (e) {
      // Error tracking for campaign launch
      unawaited(_analytics.trackError(
        errorCode: 'campaign_launch_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.launchCampaign',
      ));
      rethrow;
    }
  }

  /// スキャンダルシステム：月間スキャンダル処理
  Future<void> processMonthlyScandalCheck(GameSession session) async {
    try {
      final scandalService = ScandalService(allScandals: session.activeScandalsList);

      // スキャンダル発生確率を計算
      final occurenceProbability = scandalService.calculateScandalOccurrenceProbability(
        playerApproval: session.nationalApproval,
        activePolicies: session.activeCampaigns.length,
        difficulty: session.difficulty,
        month: DateTime.now().month,
      );

      // スキャンダル発生判定
      if (Random().nextDouble() < occurenceProbability) {
        // 新しいスキャンダルを生成
        final scandalType = ScandalType.values[Random().nextInt(ScandalType.values.length)];
        final severity = ScandalManager.determineSeverity(
          scandalType,
          Random().nextDouble(),
        );

        final scandal = Scandal(
          id: const Uuid().v4(),
          title: ScandalManager.getScandalTitle(scandalType),
          description: ScandalManager.getScandalDescription(scandalType, severity),
          type: scandalType,
          severity: severity,
          discoveredAt: DateTime.now(),
          startWeek: ((DateTime.now().month - 1) ~/ 4) + 1,
          startYear: DateTime.now().year,
          baseImpact: scandalType.baseImpact,
          initialIntensity: 100.0,
          involvedPersonId: null,
          trustDamage: severity.weeksActive * 5.0,
        );

        // スキャンダルをセッションに追加
        final updatedScandals = [...session.activeScandalsList, scandal];
        final updatedSession = session.copyWith(activeScandalsList: updatedScandals);

        await _firestore.updateGameSession(updatedSession);
        state = state.copyWith(session: updatedSession);

        // アナリティクス：スキャンダル発生を追跡
        unawaited(_analytics.trackEvent(
          name: 'scandal_occurred',
          parameters: {
            'scandal_type': scandalType.name,
            'severity': severity.name,
          },
        ));
      }
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'scandal_check_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.processMonthlyScandalCheck',
      ));
    }
  }

  /// スキャンダルに応答
  Future<void> respondToScandale(
    GameSession session,
    String scandalId,
    ScandalResponse response,
  ) async {
    try {
      final scandal = session.activeScandalsList.firstWhere(
        (s) => s.id == scandalId,
      );

      final scandalService = ScandalService(allScandals: session.activeScandalsList);
      final respondedScandale = scandalService.respondToScandale(
        scandal,
        response,
        playerApproval: session.nationalApproval,
        difficulty: session.difficulty == 'hard' ? 2 : session.difficulty == 'easy' ? 0 : 1,
      );

      // スキャンダルを更新
      final updatedScandals = session.activeScandalsList.map((s) {
        return s.id == scandalId ? respondedScandale : s;
      }).toList();

      // 政治的信頼度を更新
      final newApproval = (session.nationalApproval - (respondedScandale.baseImpact * 0.5))
          .clamp(0.0, 100.0);

      final updatedSession = session.copyWith(
        activeScandalsList: updatedScandals,
        nationalApproval: newApproval,
      );

      await _firestore.updateGameSession(updatedSession);
      state = state.copyWith(session: updatedSession);

      // アナリティクス：スキャンダル応答を追跡
      unawaited(_analytics.trackEvent(
        name: 'scandal_responded',
        parameters: {
          'response_type': response.name,
          'success_probability': scandalService
              .calculateResponseSuccessRate(
                response: response,
                severity: scandal.severity,
                playerApproval: session.nationalApproval,
                politicalTrust: 80.0,
                difficulty: session.difficulty == 'hard' ? 2 : session.difficulty == 'easy' ? 0 : 1,
              )
              .toInt(),
        },
      ));
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'scandal_response_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.respondToScandale',
      ));
      rethrow;
    }
  }

  /// 外交システム：月間外交イベント処理
  Future<List<DiplomaticEvent>> processMonthlyDiplomacy(GameSession session) async {
    try {
      // 初回は近隣諸国との関係を初期化する
      var nationRelationships = session.nationRelationships;
      if (nationRelationships.isEmpty) {
        nationRelationships = _seedNationRelationships();
        session = session.copyWith(nationRelationships: nationRelationships);
      }

      final diplomacyService = DiplomacyService(
        nationRelationships: nationRelationships,
        activeEvents: session.activeInternationalEvents,
        activeSanctions: session.activeSanctions,
        tradeAgreements: session.activeTradeDeals,
      );

      // 関係の自然減衰を適用
      final updatedRelationships = <String, NationRelationship>{};
      for (final entry in session.nationRelationships.entries) {
        final nation = entry.value;
        final decay = diplomacyService.calculateRelationshipDecay(nation, 4);
        if (decay > 0) {
          nation.changeStanding(-decay);
        }
        updatedRelationships[entry.key] = nation;
      }

      // 月間外交イベントをシミュレーション
      final diplomaticEvents = diplomacyService.simulateMonthlyDiplomacy(
        month: DateTime.now().month,
        year: DateTime.now().year,
      );

      final updatedSession = session.copyWith(
        nationRelationships: updatedRelationships,
        activeInternationalEvents: [...session.activeInternationalEvents, ...diplomaticEvents],
      );

      await _firestore.updateGameSession(updatedSession);
      state = state.copyWith(session: updatedSession);

      // アナリティクス：外交イベント発生を追跡
      unawaited(_analytics.trackEvent(
        name: 'diplomacy_events_processed',
        parameters: {
          'event_count': diplomaticEvents.length,
          'international_standing': diplomacyService.calculateInternationalStanding(),
        },
      ));

      return diplomaticEvents;
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'diplomacy_check_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.processMonthlyDiplomacy',
      ));
      return const [];
    }
  }

  /// 外交イベントに対する選択を処理
  Future<void> respondToDiplomaticEvent(
    GameSession session,
    String eventId,
    DiplomaticOption choice,
    String targetNationId,
  ) async {
    try {
      final event = session.activeInternationalEvents.firstWhere(
        (e) => e.id == eventId,
      );

      final diplomacyService = DiplomacyService(
        nationRelationships: session.nationRelationships,
        activeEvents: session.activeInternationalEvents,
        activeSanctions: session.activeSanctions,
        tradeAgreements: session.activeTradeDeals,
      );

      // 外交選択を処理
      final updatedNation = diplomacyService.respondToDiplomaticEvent(
        targetNationId,
        choice,
      );

      // 国家関係を更新
      final updatedRelationships = {...session.nationRelationships};
      updatedRelationships[targetNationId] = updatedNation;

      // イベントを解決済みに
      final resolvedEvent = event.copyWith(
        playerChoice: choice,
        resolvedDate: DateTime.now(),
      );
      final updatedEvents = session.activeInternationalEvents.map((e) {
        return e.id == eventId ? resolvedEvent : e;
      }).toList();
      final historicalEvents = [...session.historicalInternationalEvents, resolvedEvent];

      // 承認度への影響を反映
      final newApproval = (session.nationalApproval + choice.approvalImpact).clamp(0.0, 100.0);

      // 経済コストを反映（負の値は収入）
      final newForeignDebt = (session.foreignDebt + choice.economicCost).clamp(0.0, double.infinity);

      final updatedSession = session.copyWith(
        nationRelationships: updatedRelationships,
        activeInternationalEvents: updatedEvents.where((e) => e.resolvedDate == null).toList(),
        historicalInternationalEvents: historicalEvents,
        nationalApproval: newApproval,
        foreignDebt: newForeignDebt,
      );

      await _firestore.updateGameSession(updatedSession);
      state = state.copyWith(session: updatedSession);

      // アナリティクス：外交選択を追跡
      unawaited(_analytics.trackEvent(
        name: 'diplomatic_event_resolved',
        parameters: {
          'target_nation': targetNationId,
          'choice_label': choice.label,
          'relationship_change': choice.relationshipChange,
          'approval_impact': choice.approvalImpact,
        },
      ));
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'diplomacy_response_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.respondToDiplomaticEvent',
      ));
      rethrow;
    }
  }

  /// 初期の周辺諸国関係を生成
  Map<String, NationRelationship> _seedNationRelationships() {
    const seeds = [
      ('nation_ally', '友邦連合'),
      ('nation_neighbor', '隣国連邦'),
      ('nation_trade', '通商共和国'),
      ('nation_rival', '対立国家群'),
    ];
    final rng = Random();
    return {
      for (final (id, name) in seeds)
        id: NationRelationship(
          nationId: id,
          nationName: name,
          standingScore: rng.nextDouble() * 60 - 20, // -20 ～ +40
        ),
    };
  }

  /// 内閣システム：月間内閣確執チェック
  Future<(BetrayalEvent?, MinisterConflict?)> processMonthlyCabinetInfighting(
      GameSession session) async {
    BetrayalEvent? firstBetrayal;
    MinisterConflict? firstConflict;
    try {
      final infightingService = CabinetInfightingService(
        cabinet: session.status.cabinet,
      );

      // 背信の確率をチェック
      for (final role in MinisterRole.values) {
        if (session.status.cabinet.betrayed.contains(role)) continue;

        final betrayalProb = infightingService.calculateBetrayalProbability(role);
        if (Random().nextDouble() < betrayalProb) {
          // 背信が発生
          final betrayalReasons = [
            '権力の衰退に不満を持つようになった',
            '他勢力との秘密交渉に発覚した',
            '政策の不一致が深刻化した',
            '個人的な欲望が優先されるようになった',
            '外国勢力に買収されていた',
          ];

          final betrayalEvent = BetrayalEvent(
            id: const Uuid().v4(),
            traitor: role,
            reason: betrayalReasons[Random().nextInt(betrayalReasons.length)],
            discoveredDate: DateTime.now(),
            approvalDamage: Random().nextDouble() * 20 + 10, // 10-30%
            trustDamage: Random().nextDouble() * 40 + 20, // 20-60%
            economicLoss: Random().nextDouble() * 5000000 + 1000000, // $1-6M
          );

          // キャビネットを更新（背信マーク）
          final updatedCabinet = session.status.cabinet.markBetrayed(role);
          final updatedStatus = session.status.copyWith(cabinet: updatedCabinet);
          var updatedSession = session.copyWith(status: updatedStatus);

          // 承認度と信頼度にダメージを適用
          updatedSession = updatedSession.copyWith(
            nationalApproval: (updatedSession.nationalApproval - betrayalEvent.approvalDamage)
                .clamp(0.0, 100.0),
          );

          await _firestore.updateGameSession(updatedSession);
          state = state.copyWith(session: updatedSession);
          session = updatedSession;
          firstBetrayal ??= betrayalEvent;

          // アナリティクス
          unawaited(_analytics.trackEvent(
            name: 'minister_betrayal',
            parameters: {
              'minister': role.name,
              'reason': betrayalEvent.reason,
              'approval_damage': betrayalEvent.approvalDamage,
            },
          ));
        }
      }

      // 大臣間の対立をチェック
      final rolePairs = <(MinisterRole, MinisterRole)>[];
      for (int i = 0; i < MinisterRole.values.length; i++) {
        for (int j = i + 1; j < MinisterRole.values.length; j++) {
          rolePairs.add((MinisterRole.values[i], MinisterRole.values[j]));
        }
      }

      // 既に対立中の大臣ペアには新たな対立を生成しない
      final pairsAlreadyInConflict = session.activeMinisterConflicts
          .where((c) => !c.isResolved)
          .map((c) => {c.minister1, c.minister2})
          .toList();

      for (final (role1, role2) in rolePairs) {
        final alreadyInConflict =
            pairsAlreadyInConflict.any((pair) => pair.contains(role1) && pair.contains(role2));
        if (alreadyInConflict) continue;

        final conflictProb = infightingService.calculateConflictProbability(role1, role2);
        if (Random().nextDouble() < conflictProb) {
          // 対立が発生
          final conflictDescriptions = [
            '${role1.label}と${role2.label}が予算配分を巡って対立',
            '${role1.label}と${role2.label}の方針の相違が表面化',
            '${role1.label}と${role2.label}の権力争いが激化',
            '${role1.label}が${role2.label}の政策を公然と批判',
            '${role1.label}と${role2.label}の派閥が衝突',
          ];

          final conflict = MinisterConflict(
            id: const Uuid().v4(),
            minister1: role1,
            minister2: role2,
            description: conflictDescriptions[Random().nextInt(conflictDescriptions.length)],
            tensionLevel: Random().nextDouble() * 40 + 30, // 30-70%
            occurredDate: DateTime.now(),
          );

          // 対立は内閣の安定度をわずかに損なう
          final updatedStatus = session.status.copyWith(
            stability: (session.status.stability - conflict.tensionLevel * 0.05)
                .clamp(0.0, 100.0),
          );
          final updatedSession = session.copyWith(
            status: updatedStatus,
            activeMinisterConflicts: [...session.activeMinisterConflicts, conflict],
          );

          await _firestore.updateGameSession(updatedSession);
          state = state.copyWith(session: updatedSession);
          session = updatedSession;
          firstConflict ??= conflict;

          unawaited(_analytics.trackEvent(
            name: 'minister_conflict',
            parameters: {
              'minister1': role1.name,
              'minister2': role2.name,
              'tension_level': conflict.tensionLevel,
            },
          ));

          // 1回の呼び出しで複数の対立が重複して発生するのを避ける
          break;
        }
      }

      // 既存の未解決対立の自然な推移（緊張緩和による自然解決の判定）
      if (session.activeMinisterConflicts.any((c) => !c.isResolved)) {
        var anyResolved = false;
        final updatedConflicts = session.activeMinisterConflicts.map((c) {
          if (c.isResolved) return c;
          if (infightingService.shouldConflictResolve(c)) {
            anyResolved = true;
            return c.copyWith(isResolved: true);
          }
          return c;
        }).toList();

        if (anyResolved) {
          final updatedSession = session.copyWith(activeMinisterConflicts: updatedConflicts);
          await _firestore.updateGameSession(updatedSession);
          state = state.copyWith(session: updatedSession);
          session = updatedSession;
        }
      }

      return (firstBetrayal, firstConflict);
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'cabinet_infighting_check_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.processMonthlyCabinetInfighting',
      ));
      return (firstBetrayal, firstConflict);
    }
  }

  /// 大臣の忠誠度を調整
  Future<void> adjustMinisterLoyalty(
    GameSession session,
    MinisterRole role,
    double delta,
  ) async {
    try {
      final deltas = {role: delta};
      final updatedCabinet = session.status.cabinet.applyDeltas(deltas);
      final updatedStatus = session.status.copyWith(cabinet: updatedCabinet);
      final updatedSession = session.copyWith(status: updatedStatus);

      await _firestore.updateGameSession(updatedSession);
      state = state.copyWith(session: updatedSession);

      unawaited(_analytics.trackEvent(
        name: 'minister_loyalty_adjusted',
        parameters: {
          'minister': role.name,
          'delta': delta,
          'new_loyalty': updatedCabinet.of(role),
        },
      ));
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'loyalty_adjustment_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.adjustMinisterLoyalty',
      ));
      rethrow;
    }
  }

  /// 大臣間の対立への対応を処理
  Future<void> respondToCabinetConflict(
    GameSession session,
    String conflictId,
    CabinetConflictResponse response,
  ) async {
    try {
      final conflict =
          session.activeMinisterConflicts.firstWhere((c) => c.id == conflictId);
      final infightingService = CabinetInfightingService(cabinet: session.status.cabinet);

      var updatedStatus = session.status;
      MinisterConflict updatedConflict;

      switch (response) {
        case CabinetConflictResponse.mediate:
          updatedConflict = infightingService.deescalateConflict(conflict, 35);
          updatedStatus = updatedStatus.copyWith(
            stability: (updatedStatus.stability + 5).clamp(0.0, 100.0),
          );
        case CabinetConflictResponse.favorFirst:
          updatedStatus = updatedStatus.copyWith(
            cabinet: updatedStatus.cabinet.applyDeltas({
              conflict.minister1: 10,
              conflict.minister2: -15,
            }),
          );
          updatedConflict = infightingService.deescalateConflict(conflict, 20);
        case CabinetConflictResponse.favorSecond:
          updatedStatus = updatedStatus.copyWith(
            cabinet: updatedStatus.cabinet.applyDeltas({
              conflict.minister2: 10,
              conflict.minister1: -15,
            }),
          );
          updatedConflict = infightingService.deescalateConflict(conflict, 20);
        case CabinetConflictResponse.ignore:
          updatedConflict = infightingService.escalateConflict(conflict, 20);
          updatedStatus = updatedStatus.copyWith(
            stability: (updatedStatus.stability - 5).clamp(0.0, 100.0),
          );
      }

      if (updatedConflict.tensionLevel <= 10) {
        updatedConflict = updatedConflict.copyWith(isResolved: true);
      }

      final updatedConflicts = session.activeMinisterConflicts
          .map((c) => c.id == conflictId ? updatedConflict : c)
          .toList();

      final updatedSession = session.copyWith(
        status: updatedStatus,
        activeMinisterConflicts: updatedConflicts,
      );

      await _firestore.updateGameSession(updatedSession);
      state = state.copyWith(session: updatedSession);

      unawaited(_analytics.trackEvent(
        name: 'cabinet_conflict_responded',
        parameters: {
          'response': response.name,
          'tension_level': updatedConflict.tensionLevel,
          'resolved': updatedConflict.isResolved,
        },
      ));
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'cabinet_conflict_response_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.respondToCabinetConflict',
      ));
      rethrow;
    }
  }

  /// 実績システム：新規実績をチェック
  Future<List<Achievement>> checkNewAchievements(GameSession session) async {
    try {
      final achievementService = AchievementService(
        unlockedAchievements: session.unlockedAchievements
            .map((id) => AchievementUnlock(
                  achievementId: id,
                  unlockedAt: DateTime.now(),
                  gameStateSnapshot: {},
                ))
            .toList(),
      );

      // 新規アンロック実績を検出
      final newUnlocks = achievementService.detectNewAchievements(
        session,
        session.unlockedAchievements,
      );

      // 新規実績がある場合、セッションを更新
      if (newUnlocks.isNotEmpty) {
        final updatedIds = [
          ...session.unlockedAchievements,
          ...newUnlocks.map((u) => u.achievementId),
        ];

        final updatedSession = session.copyWith(
          unlockedAchievements: updatedIds,
        );

        await _firestore.updateGameSession(updatedSession);
        state = state.copyWith(session: updatedSession);

        // アナリティクス：実績アンロックを追跡
        for (final unlock in newUnlocks) {
          unawaited(_analytics.trackEvent(
            name: 'achievement_unlocked',
            parameters: {
              'achievement_id': unlock.achievementId,
              'unlocked_at': unlock.unlockedAt.toIso8601String(),
              'year': unlock.gameStateSnapshot['year'],
            },
          ));
        }
      }

      // 新規アンロック実績に対応するAchievementオブジェクトを返す
      return Achievements.all
          .where((a) => newUnlocks.any((u) => u.achievementId == a.id))
          .toList();
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'achievement_check_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.checkNewAchievements',
      ));
      return [];
    }
  }

  /// 実績進捗を取得
  Map<String, AchievementProgress> getAchievementProgress(GameSession session) {
    try {
      final achievementService = AchievementService();
      return achievementService.calculateAllProgress(session);
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'achievement_progress_calculation_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.getAchievementProgress',
      ));
      return {};
    }
  }

  /// 実績達成率を計算
  double getAchievementCompletionRate(GameSession session) {
    try {
      final allAchievementIds = Achievements.all.map((a) => a.id).toList();
      final achievementService = AchievementService(
        unlockedAchievements: session.unlockedAchievements
            .map((id) => AchievementUnlock(
                  achievementId: id,
                  unlockedAt: DateTime.now(),
                  gameStateSnapshot: {},
                ))
            .toList(),
      );

      return achievementService.calculateCompletionRate(allAchievementIds);
    } catch (e) {
      return 0.0;
    }
  }

  /// 危機システム：月間ランダム危機チェック
  Future<Crisis?> processMonthlyRandomCrises(GameSession session) async {
    try {
      final crisisGenerator = RandomCrisisGenerator();

      // 危機発生確率を計算（汚職度が高いほど発生しやすい）
      final crisisProbability = crisisGenerator.calculateCrisisProbability(
        approval: session.nationalApproval,
        stability: session.status.stability,
        gdp: session.status.gdp,
        unemployment: session.status.unemployment,
        activeCrisisCount: session.activeCrises.length,
        internationalTension:
            session.internationalStanding > 50 ? 30 : (100 - session.internationalStanding),
        corruption: session.status.corruption,
      );

      // 危機発生判定
      if (Random().nextDouble() < crisisProbability) {
        // 危機のタイプを派閥の離反状況から選択（軍部の離反が進んでいればクーデター寄りに）
        final crisisType = crisisGenerator.selectCrisisType(
          militarySupport: session.status.factions.support[Faction.military] ?? 50.0,
          laborSupport: session.status.factions.support[Faction.labor] ?? 50.0,
          unemployment: session.status.unemployment,
          random: Random(),
        );

        // 危機の厳しさを決定
        final severity = crisisGenerator.determineSeverity(
          approval: session.nationalApproval,
          stability: session.status.stability,
          random: Random(),
        );

        // 新しい危機を生成
        final newCrisis = Crisis(
          id: const Uuid().v4(),
          type: crisisType,
          startDate: DateTime.now(),
          durationDays: crisisGenerator.calculateDuration(severity),
          approvalImpact: -10.0 * severity.damageMultiplier, // 重大度に応じたダメージ
          description: _generateCrisisDescription(crisisType, severity),
          triggers: [
            '承認度: ${session.nationalApproval.toStringAsFixed(1)}%',
            '安定度: ${session.status.stability.toStringAsFixed(1)}%',
          ],
          escalationRisk: crisisGenerator.calculateChainProbability(severity),
        );

        // 新しい危機をセッションに追加
        var updatedSession = session.copyWith(
          activeCrises: [...session.activeCrises, newCrisis],
        );

        // 承認度に即座のダメージを適用
        updatedSession = updatedSession.copyWith(
          nationalApproval:
              (updatedSession.nationalApproval + newCrisis.getApprovalImpact()).clamp(0.0, 100.0),
        );

        await _firestore.updateGameSession(updatedSession);
        state = state.copyWith(session: updatedSession);

        // アナリティクス：危機発生を追跡
        unawaited(_analytics.trackEvent(
          name: 'crisis_occurred',
          parameters: {
            'crisis_type': crisisType.name,
            'severity': severity.label,
            'approval_impact': newCrisis.getApprovalImpact(),
          },
        ));

        return newCrisis;
      }
      return null;
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'crisis_generation_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.processMonthlyRandomCrises',
      ));
      return null;
    }
  }

  /// 危機に対する対応を処理
  Future<void> respondToCrisis(
    GameSession session,
    String crisisId,
    CrisisResponse response,
  ) async {
    try {
      final crisis = session.activeCrises.firstWhere((c) => c.id == crisisId);

      // 危機を更新（対応内容を記録、解決日時を設定）
      final respondedCrisis = crisis.copyWith(
        playerResponse: response,
        resolvedDate: DateTime.now(),
      );

      // 危機を更新
      final updatedCrises = session.activeCrises.map((c) {
        return c.id == crisisId ? respondedCrisis : c;
      }).toList();

      // 承認度への影響を計算
      final approvalImpact = respondedCrisis.getApprovalImpact();
      final newApproval = (session.nationalApproval + approvalImpact).clamp(0.0, 100.0);

      // 経済的影響を計算（該当する場合）
      final economicImpact = crisis.economicImpact ?? 0.0;

      var updatedSession = session.copyWith(
        activeCrises: updatedCrises.where((c) => !c.isResolved).toList(),
        nationalApproval: newApproval,
      );

      // 経済的影響を反映
      if (economicImpact > 0) {
        final updatedStatus = updatedSession.status.copyWith(
          gdp: (updatedSession.status.gdp - (economicImpact / 1000000000)).clamp(0.1, double.infinity),
        );
        updatedSession = updatedSession.copyWith(status: updatedStatus);
      }

      await _firestore.updateGameSession(updatedSession);
      state = state.copyWith(session: updatedSession);

      // アナリティクス：危機対応を追跡
      unawaited(_analytics.trackEvent(
        name: 'crisis_responded',
        parameters: {
          'crisis_type': crisis.type.name,
          'response_type': response.name,
          'approval_impact': approvalImpact,
        },
      ));
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'crisis_response_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.respondToCrisis',
      ));
      rethrow;
    }
  }

  /// 危機の説明文を生成
  String _generateCrisisDescription(CrisisType type, CrisisSeverity severity) {
    final severityPrefix = switch (severity) {
      CrisisSeverity.mild => '軽微な',
      CrisisSeverity.moderate => '',
      CrisisSeverity.severe => '深刻な',
      CrisisSeverity.critical => '致命的な',
    };

    return switch (type) {
      CrisisType.demonstration =>
        '$severityPrefix デモが首都で発生。市民が政府の政策に反発している。',
      CrisisType.riot =>
        '$severityPrefix 暴動が複数地域で発生。警察と市民が対立。秩序が崩壊している。',
      CrisisType.laborStrike =>
        '$severityPrefix 労働者ストライキが全土に広がる。主要産業が停止。',
      CrisisType.economicCrisis =>
        '$severityPrefix 経済危機が発生。市場が混乱し、失業が急増している。',
      CrisisType.militaryCoup =>
        '$severityPrefix クーデターの兆候が報告される。軍部が不満を募らせている。',
    };
  }

  /// 世論システム：国民世論調査を実施
  Future<SurveyResult> conductCitizenSurvey(GameSession session) async {
    try {
      final surveyService = CitizenSurveyService();

      // 調査を実施
      final surveyResult = surveyService.conductSurvey(
        approval: session.nationalApproval,
        gdp: session.status.gdp,
        unemployment: session.status.unemployment,
        stability: session.status.stability,
        sampleSize: 1500, // サンプルサイズ
      );

      // 調査結果をセッションに保存
      final updatedSession = session.copyWith(latestSurvey: surveyResult);
      await _firestore.updateGameSession(updatedSession);
      state = state.copyWith(session: updatedSession);

      // アナリティクス：調査実施を追跡
      unawaited(_analytics.trackEvent(
        name: 'citizen_survey_conducted',
        parameters: {
          'sample_size': surveyResult.sampleSize,
          'average_satisfaction': surveyResult.averageSatisfaction,
          'confidence_level': surveyResult.confidenceLevel,
          'top_priority': surveyResult.topPriority?.name ?? 'unknown',
        },
      ));

      return surveyResult;
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'survey_conduction_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.conductCitizenSurvey',
      ));
      rethrow;
    }
  }

  /// 特定のトピックへの対応を実施（満足度向上）
  Future<void> addressPublicOpinion(
    GameSession session,
    OpinionTopic topic,
    double investmentAmount,
  ) async {
    try {
      // まだ調査を実施していない場合は、このトピックへの投資を機に暫定調査を作る
      final currentSurvey = session.latestSurvey ??
          CitizenSurveyService().conductSurvey(
            approval: session.nationalApproval,
            gdp: session.status.gdp,
            unemployment: session.status.unemployment,
            stability: session.status.stability,
          );

      // 投資額に基づいて満足度を上昇
      final satisfactionIncrease = (investmentAmount / 1000000000) * 100; // $1B = 100%向上
      final cappedIncrease = satisfactionIncrease.clamp(0.0, 30.0); // 最大30%

      final updatedOpinions =
          Map<OpinionTopic, CitizenOpinion>.from(currentSurvey.opinions);
      final currentOpinion = updatedOpinions[topic];
      if (currentOpinion != null) {
        updatedOpinions[topic] = currentOpinion.copyWith(
          satisfaction: (currentOpinion.satisfaction + cappedIncrease).clamp(0.0, 100.0),
        );
      }
      final updatedSurvey = SurveyResult(
        id: currentSurvey.id,
        surveyDate: currentSurvey.surveyDate,
        sampleSize: currentSurvey.sampleSize,
        opinions: updatedOpinions,
      );

      // 承認度にも反映
      final approvalBoost = cappedIncrease * 0.3; // 30%の効果
      var updatedSession = session.copyWith(
        nationalApproval: (session.nationalApproval + approvalBoost).clamp(0.0, 100.0),
        latestSurvey: updatedSurvey,
      );

      // 予算から投資額を差し引く
      final updatedStatus = updatedSession.status.copyWith(
        gdp: (updatedSession.status.gdp - (investmentAmount / 1000000000))
            .clamp(0.1, double.infinity),
      );
      updatedSession = updatedSession.copyWith(status: updatedStatus);

      await _firestore.updateGameSession(updatedSession);
      state = state.copyWith(session: updatedSession);

      // アナリティクス：施策実施を追跡
      unawaited(_analytics.trackEvent(
        name: 'public_opinion_policy_implemented',
        parameters: {
          'topic': topic.name,
          'investment_amount': investmentAmount,
          'satisfaction_increase': cappedIncrease,
          'approval_boost': approvalBoost,
        },
      ));
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'opinion_addressing_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.addressPublicOpinion',
      ));
      rethrow;
    }
  }

  /// 月間世論の自然な変動を処理
  Future<void> processMonthlyOpinionShifts(GameSession session) async {
    try {
      final survey = session.latestSurvey;
      // 調査未実施の場合、変動させる対象がないためスキップ
      if (survey == null || survey.opinions.isEmpty) return;

      // 優先度の時間経過による減衰を計算（人々の関心の移ろい）
      final decayedOpinions = survey.opinions.map(
        (topic, opinion) => MapEntry(
          topic,
          opinion.copyWith(priority: opinion.priority * 0.95),
        ),
      );
      final decayedSurvey = SurveyResult(
        id: survey.id,
        surveyDate: survey.surveyDate,
        sampleSize: survey.sampleSize,
        opinions: decayedOpinions,
      );

      // 世論の分裂度を計算（政治的分断の度合い）
      final priorities = decayedOpinions.values.map((o) => o.priority).toList();
      final mean = priorities.fold(0.0, (sum, p) => sum + p) / priorities.length;
      final variance =
          priorities.fold(0.0, (sum, p) => sum + (p - mean) * (p - mean)) / priorities.length;
      final polarization = (sqrt(variance) / 50).clamp(0.0, 100.0);

      var updatedSession = session.copyWith(latestSurvey: decayedSurvey);

      // 分裂度が高い場合、承認度に悪影響
      if (polarization > 70) {
        updatedSession = updatedSession.copyWith(
          nationalApproval: (updatedSession.nationalApproval - (polarization - 70) * 0.1)
              .clamp(0.0, 100.0),
        );
      }

      await _firestore.updateGameSession(updatedSession);
      state = state.copyWith(session: updatedSession);

      if (polarization > 70) {
        // アナリティクス
        unawaited(_analytics.trackEvent(
          name: 'opinion_polarization_detected',
          parameters: {
            'polarization_level': polarization,
            'approval_impact': polarization - 70 * 0.1,
          },
        ));
      }
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'opinion_shift_processing_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.processMonthlyOpinionShifts',
      ));
    }
  }

  /// ストーリーパックイベント：現在のシナリオ・年で発生すべきイベントが
  /// あれば、それを「発生済み」として記録した上で返す（優先度が最も
  /// 高いもの1件のみ）。プレイヤーへの提示は呼び出し側の責務。
  Future<StoryPackEvent?> checkAndStartStoryPackEvent(GameSession session) async {
    try {
      final packId = session.currentPackId;
      final scenarioId = session.scenarioId;
      if (packId == null || scenarioId == null) return null;

      final triggered = PackEventEngine.getTriggeredEvents(
        packId,
        scenarioId,
        session.status.year,
        session.packEventProgress,
      );
      if (triggered.isEmpty) return null;

      final event = triggered.first;
      final progress = PackEventEngine.startEvent(event.id);
      final updatedProgress =
          PackEventEngine.updateEventProgress(session.packEventProgress, progress);
      final updatedHistory = Map<String, int>.from(session.packEventHistory);
      updatedHistory[packId] = (updatedHistory[packId] ?? 0) + 1;

      final updatedSession = session.copyWith(
        packEventProgress: updatedProgress,
        packEventHistory: updatedHistory,
      );

      await _firestore.updateGameSession(updatedSession);
      state = state.copyWith(session: updatedSession);

      unawaited(_analytics.trackEvent(
        name: 'story_pack_event_triggered',
        parameters: {
          'pack_id': packId,
          'event_id': event.id,
          'event_type': event.eventType,
        },
      ));

      return event;
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'story_pack_event_check_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.checkAndStartStoryPackEvent',
      ));
      return null;
    }
  }

  /// ストーリーパックイベントへのプレイヤーの選択を処理し、結果をセッションに適用する。
  /// この選択でパック内の全イベントが完了した場合、そのパックIDを返す（呼び出し側で
  /// 次のおすすめパックの提示に使える）。まだ完了していなければ null を返す。
  Future<String?> respondToStoryPackEvent(
    GameSession session,
    String eventId,
    String choiceId,
  ) async {
    try {
      var updatedSession = PackEventEngine.applyEventOutcomes(session, eventId, choiceId);

      final existingProgress = updatedSession.packEventProgress.firstWhere(
        (p) => p.eventId == eventId,
        orElse: () => PackEventEngine.startEvent(eventId),
      );
      final completed = PackEventEngine.completeEvent(existingProgress, choiceId);
      final updatedProgress =
          PackEventEngine.updateEventProgress(updatedSession.packEventProgress, completed);

      updatedSession = updatedSession.copyWith(packEventProgress: updatedProgress);

      await _firestore.updateGameSession(updatedSession);
      state = state.copyWith(session: updatedSession);

      unawaited(_analytics.trackEvent(
        name: 'story_pack_event_resolved',
        parameters: {
          'event_id': eventId,
          'choice_id': choiceId,
        },
      ));

      final packId = updatedSession.currentPackId;
      if (packId != null) {
        final completedCount =
            PackEventEngine.getCompletedEventCountInPack(packId, updatedProgress);
        final totalCount = PackEventEngine.getTotalEventCountInPack(packId);
        if (totalCount > 0 && completedCount >= totalCount) {
          return packId;
        }
      }
      return null;
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'story_pack_event_response_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.respondToStoryPackEvent',
      ));
      rethrow;
    }
  }

  /// パック完走時に、次にプレイすべきおすすめパックを1件返す。
  /// このプレイヤーが未プレイのパックを優先し、全パック既プレイなら
  /// 今回完走したパック以外から提案する（提案できるパックがなければ null）。
  Future<StoryPack?> getRecommendedNextPack(String justCompletedPackId) async {
    try {
      final session = state.session;
      if (session == null) return null;

      final pastSessions = await _firestore.getUserGameSessions(session.userId);
      final playedPackIds = <String>{justCompletedPackId};
      for (final past in pastSessions) {
        final pastScenarioId = past.scenarioId;
        final pid = past.currentPackId ??
            (pastScenarioId != null
                ? StoryPackService.getPackForScenario(pastScenarioId)?.id
                : null);
        if (pid != null) playedPackIds.add(pid);
      }

      final candidates = StoryPackService.getUnlockedPacks();
      final unplayed = candidates.where((p) => !playedPackIds.contains(p.id)).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      if (unplayed.isNotEmpty) return unplayed.first;

      final others = candidates.where((p) => p.id != justCompletedPackId).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      return others.isEmpty ? null : others.first;
    } catch (e) {
      unawaited(_analytics.trackError(
        errorCode: 'recommend_next_pack_failed',
        errorMessage: e.toString(),
        context: 'GameSessionNotifier.getRecommendedNextPack',
      ));
      return null;
    }
  }

  /// 外交・内閣・危機の各システムをまとめて処理し、プレイヤーに通知すべき
  /// 新規イベントを返す。ターンの度に呼び出す想定。
  Future<MonthlySystemsResult> processMonthlySystems() async {
    var session = state.session;
    if (session == null) return MonthlySystemsResult.empty();

    final diplomaticEvents = await processMonthlyDiplomacy(session);

    session = state.session;
    if (session == null) return MonthlySystemsResult(newDiplomaticEvents: diplomaticEvents);
    final (betrayal, conflict) = await processMonthlyCabinetInfighting(session);

    session = state.session;
    if (session == null) {
      return MonthlySystemsResult(
        newDiplomaticEvents: diplomaticEvents,
        newBetrayal: betrayal,
        newConflict: conflict,
      );
    }
    final newCrisis = await processMonthlyRandomCrises(session);

    session = state.session;
    if (session != null) {
      await processMonthlyOpinionShifts(session);
    }

    return MonthlySystemsResult(
      newDiplomaticEvents: diplomaticEvents,
      newBetrayal: betrayal,
      newConflict: conflict,
      newCrisis: newCrisis,
    );
  }
}

/// 外交・内閣・危機の月次処理でプレイヤーに通知すべき新規イベント
class MonthlySystemsResult {
  final List<DiplomaticEvent> newDiplomaticEvents;
  final BetrayalEvent? newBetrayal;
  final MinisterConflict? newConflict;
  final Crisis? newCrisis;

  MonthlySystemsResult({
    this.newDiplomaticEvents = const [],
    this.newBetrayal,
    this.newConflict,
    this.newCrisis,
  });

  factory MonthlySystemsResult.empty() => MonthlySystemsResult();
}
