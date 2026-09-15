import 'dart:async';

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
import 'package:government_simulator/models/rival_candidate.dart';
import 'package:government_simulator/models/political_party.dart';
import 'package:government_simulator/models/election_result.dart';
import 'package:government_simulator/models/international_relations.dart';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/debate.dart';
import 'package:government_simulator/services/auth_service.dart';
import 'package:government_simulator/services/firestore_service.dart';
import 'package:government_simulator/services/purchase_service.dart';
import 'package:government_simulator/services/game_logic_service.dart';
import 'package:government_simulator/services/analytics_service.dart';
import 'package:government_simulator/services/scenario_service.dart';
import 'package:government_simulator/models/scenario.dart';
import 'package:uuid/uuid.dart';

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

    // 貿易協定から年間収入を月単位で適用（概算）
    final yearlyTradeIncome =
        updatedSession.activeTradeDeals.fold<double>(0.0, (sum, deal) {
          return sum + (deal.isActive ? deal.yearlyIncome : 0);
        });
    final yearlyTradeExpense =
        updatedSession.activeTradeDeals.fold<double>(0.0, (sum, deal) {
          return sum + (deal.isActive ? deal.yearlyExpense : 0);
        });

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

  Future<void> continueToNextYear() async {
    try {
      final session = state.session;
      if (session == null) return;

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

        // 落選時はゲームオーバー
        if (!electionResult.playerWon) {
          // 選挙落選によるゲームオーバーフラグを設定
          await _firestore.updateGameSession(finalSession);
          // ゲームオーバーを通知（UI層で処理）
          return;
        }
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
}
