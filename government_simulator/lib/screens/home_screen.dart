import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/event.dart';
import 'package:government_simulator/models/decision.dart';
import 'package:government_simulator/models/faction.dart';
import 'package:government_simulator/models/minister.dart';
import 'package:government_simulator/models/user_profile.dart';
import 'package:government_simulator/models/scandal.dart';
import 'package:government_simulator/models/international_relations.dart';
import 'package:government_simulator/models/crisis.dart';
import 'package:government_simulator/models/election_result.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/achievement.dart';
import 'package:government_simulator/providers/game_provider.dart';
import 'package:government_simulator/providers/analytics_provider.dart';
import 'package:government_simulator/services/game_logic_service.dart';
import 'package:government_simulator/services/crisis_event_service.dart';
import 'package:government_simulator/services/cabinet_infighting_service.dart';
import 'package:government_simulator/utils/app_theme.dart';
import 'package:government_simulator/utils/constants.dart';
import 'package:government_simulator/widgets/policy_card.dart';
import 'package:government_simulator/widgets/policy_preview_dialog.dart';
import 'package:government_simulator/widgets/status_dashboard.dart';
import 'package:government_simulator/widgets/faction_bar.dart';
import 'package:government_simulator/widgets/cabinet_panel.dart';
import 'package:government_simulator/widgets/news_ticker.dart';
import 'package:government_simulator/widgets/achievement_popup.dart';
import 'package:government_simulator/widgets/tutorial_overlay.dart';
import 'event_detail_screen.dart';
import 'graph_screen.dart';
import 'country_history_screen.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'year_end_screen.dart';
import 'game_over_screen.dart';
import 'ending_screen.dart';
import 'world_map_screen.dart';
import 'weekly_poll_screen.dart';
import 'campaign_screen.dart';
import 'diplomatic_event_screen.dart';
import 'crisis_alert_screen.dart';
import 'election_screen.dart';
import 'citizen_survey_screen.dart';
import 'story_pack_event_screen.dart';
import 'package:government_simulator/models/story_pack_event.dart';
import 'package:government_simulator/models/story_pack.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late GameLogicService _gameLogic;
  GameEvent? _currentEvent;
  CountryStatus? _previousStatus;
  final Set<String> _recentEventIds = {};
  bool _showingYearEnd = false;

  // 各種ボタンの連打（ダブルタップ）による二重実行を防ぐガード。
  bool _processingChoice = false;
  bool _continuingYear = false;
  bool _restarting = false;

  // イベントカテゴリ別の大臣アバター
  static const Map<EventCategory, String> _advisors = {
    EventCategory.economic: '💼',
    EventCategory.employment: '🔧',
    EventCategory.social: '🧑‍🤝‍🧑',
    EventCategory.political: '🎩',
    EventCategory.environmental: '🌿',
    EventCategory.military: '🎖️',
    EventCategory.external: '🌐',
  };

  @override
  void initState() {
    super.initState();
    _gameLogic = GameLogicService();
    // Track screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(analyticsServiceProvider).trackScreenView('home_screen');
      }
    });
  }

  void _pickNextEvent(CountryStatus status) {
    final event = _gameLogic.generateRandomEvent(
      status,
      recentIds: _recentEventIds,
    );
    _recentEventIds.add(event.id);
    // イベントプールの規模に対して直近履歴が大きすぎないよう、
    // プールの半分程度を上限に「しばらく同じイベントが出ない」体験を作る。
    final maxRecent = (_gameLogic.eventPoolSize / 2).floor().clamp(3, 20);
    while (_recentEventIds.length > maxRecent) {
      _recentEventIds.remove(_recentEventIds.first);
    }
    setState(() => _currentEvent = event);
  }

  Future<void> _handleChoice(Choice choice) async {
    // カードのスワイプ確定演出やボタン連打で同じ選択が二重に発火すると、
    // 同一イベントに対する EventDetailScreen が二重に積まれたり、
    // applyChoice が二重適用されうるため、処理中は再入を無視する。
    if (_processingChoice) return;
    _processingChoice = true;
    try {
      final sessionState = ref.read(gameSessionProvider);
      final session = sessionState.session;
      if (session == null) return;

      final beforeStatus = session.status;
      _previousStatus = beforeStatus;

      // 政策プレビューダイアログを表示して、ユーザーに確認させる
      if (!mounted) return;
      final preview = _gameLogic.createPolicyPreview(
        choiceId: choice.id,
        choiceText: choice.text,
        currentStatus: beforeStatus,
        impact: choice.impact,
      );

      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PolicyPreviewDialog(
          preview: preview,
          onCommit: () => Navigator.pop(ctx, true),
          onCancel: () => Navigator.pop(ctx, false),
        ),
      );

      if (confirmed != true || !mounted) {
        _processingChoice = false;
        return;
      }

      final newStatus = _gameLogic.applyImpact(beforeStatus, choice.impact);
      final narrative =
          _gameLogic.generateNarrative(choice, beforeStatus, newStatus);
      final impactScore =
          _gameLogic.calculateImpactScore(beforeStatus, newStatus);

      if (!mounted) return;
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => EventDetailScreen(
            beforeStatus: beforeStatus,
            afterStatus: newStatus,
            choice: choice,
            impactScore: impactScore,
          ),
        ),
      );

      if (result != true || !mounted) return;

      final choiceResult =
          await ref.read(gameSessionProvider.notifier).applyChoice(
                choiceId: choice.id,
                impact: choice.impact,
                eventId: _currentEvent?.id ?? 'unknown',
                narrative: narrative,
                promiseTarget: choice.promiseTarget,
              );

      if (!mounted) return;

      // 実績解除トースト
      if (choiceResult.newAchievements.isNotEmpty) {
        AchievementPopup.show(context, choiceResult.newAchievements);
      }

      // 内閣裏切りの発覚
      final betrayed = choiceResult.betrayedMinister;
      if (betrayed != null) {
        final countryName =
            ref.read(gameSessionProvider).session?.countryName ??
                session.countryName;
        _showEventBanner(
          '🎭 内閣の裏切り',
          betrayed.betrayalNarrative(countryName),
        );
      }

      // 公約の顛末（果たされた／破られた）
      for (final r in choiceResult.promiseResolutions) {
        _showEventBanner(r.fulfilled ? '🤝 公約履行' : '💔 公約破棄', r.narrative);
      }

      // スキャンダル発生時は対応を求める
      final newScandal = choiceResult.newScandal;
      if (newScandal != null && mounted) {
        await _handleScandal(newScandal);
      }

      // 外交・内閣・危機の月次処理と、その結果の通知
      if (!mounted) return;
      final monthlyResult =
          await ref.read(gameSessionProvider.notifier).processMonthlySystems();

      final newBetrayal = monthlyResult.newBetrayal;
      if (newBetrayal != null) {
        _showEventBanner(
          '⚔️ 大臣の背信',
          '${newBetrayal.traitor.label}が背信行為に及んだ。理由：${newBetrayal.reason}',
        );
      }

      final newConflict = monthlyResult.newConflict;
      if (newConflict != null && mounted) {
        await _handleCabinetConflict(newConflict);
      }

      for (final event in monthlyResult.newDiplomaticEvents) {
        if (!mounted) break;
        await _handleDiplomaticEvent(event);
      }

      final newCrisis = monthlyResult.newCrisis;
      if (newCrisis != null && mounted) {
        await _handleCrisis(newCrisis);
      }

      // ストーリーパックの物語イベント
      if (mounted) {
        final storyEvent = await ref
            .read(gameSessionProvider.notifier)
            .checkAndStartStoryPackEvent(ref.read(gameSessionProvider).session ?? session);
        if (storyEvent != null && mounted) {
          await _handleStoryPackEvent(storyEvent);
        }
      }

      // ゲームオーバー判定
      if (choiceResult.isGameOver) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GameOverScreen(
              session: ref.read(gameSessionProvider).session!,
              type: choiceResult.gameOver,
              onRestart: _onRestartGame,
            ),
          ),
        );
        return;
      }

      if (!mounted) return;
      final updatedState = ref.read(gameSessionProvider);
      final updatedStatus = updatedState.session?.status;
      if (updatedStatus == null) return;

      // 年末チェック
      if (updatedStatus.day >= AppConstants.daysPerYear && !_showingYearEnd) {
        _showingYearEnd = true;
        try {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => YearEndScreen(
                session: updatedState.session!,
                decisions: updatedState.decisions,
                onContinue: _onContinueYear,
                onRestart: _onRestartGame,
                onRetire: _onRetire,
              ),
            ),
          );
        } finally {
          // mounted が false になっていたり push が例外を投げた場合でも、
          // このフラグが true のまま固定化されると、以後このセッションでは
          // 二度と年末画面が表示されなくなってしまうため、必ず解除する。
          _showingYearEnd = false;
        }
      } else {
        _pickNextEvent(updatedStatus);
      }
    } finally {
      _processingChoice = false;
    }
  }

  Future<void> _onContinueYear() async {
    // 「続行」ボタンの連打で continueToNextYear/pop が二重発火すると、
    // 2回目の pop が YearEndScreen ではなく既にその下にある HomeScreen
    // （Navigator のルート）に対して行われてしまうため、処理中は無視する。
    if (_continuingYear) return;
    _continuingYear = true;
    try {
      final electionResult =
          await ref.read(gameSessionProvider.notifier).continueToNextYear();
      final updatedSession = ref.read(gameSessionProvider).session;
      final updatedStatus = updatedSession?.status;
      if (updatedStatus != null && mounted) {
        Navigator.of(context).pop();

        if (electionResult != null) {
          await _handleElectionResult(electionResult, updatedSession!);
          if (!mounted || !electionResult.playerWon) return;
        }

        _pickNextEvent(updatedStatus);
      }
    } finally {
      _continuingYear = false;
    }
  }

  /// 選挙結果画面を表示し、落選していればゲームオーバー画面に遷移する
  Future<void> _handleElectionResult(
      ElectionResult result, GameSession session) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ElectionScreen(
          result: result,
          countryName: session.countryName,
          rivals: session.rivalCandidates,
        ),
      ),
    );

    if (!result.playerWon && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GameOverScreen(
            session: session,
            type: GameOverType.electionLoss,
            onRestart: _onRestartGame,
          ),
        ),
      );
    }
  }

  Future<void> _onRestartGame() async {
    // GameOverScreen/EndingScreen/SettingsScreen のいずれからも呼ばれうる
    // ため、連打で startNewYear が二重発火し、Firestore 上に余分な
    // セッションが作られてしまうことを防ぐ。
    if (_restarting) return;
    _restarting = true;
    try {
      final auth = ref.read(authServiceProvider);
      final userId = auth.userId ?? 'demo';
      final currentSession = ref.read(gameSessionProvider).session;
      final countryName = currentSession?.countryName ?? '新興共和国';
      final difficulty = currentSession?.difficulty ?? 'normal';

      await ref.read(gameSessionProvider.notifier).startNewYear(
            userId: userId,
            countryName: countryName,
            difficulty: difficulty,
            previousSessionId: currentSession?.id,
          );

      final newStatus = ref.read(gameSessionProvider).session?.status;
      if (newStatus != null && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        _recentEventIds.clear();
        _previousStatus = null;
        _pickNextEvent(newStatus);
      }
    } finally {
      _restarting = false;
    }
  }

  void _onRetire() {
    final session = ref.read(gameSessionProvider).session;
    if (session == null || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EndingScreen(
          session: session,
          onRestart: _onRestartGame,
        ),
      ),
    );
  }

  void _onTutorialFinish() {
    ref.read(gameSessionProvider.notifier).markTutorialSeen();
  }

  void _showEventBanner(String title, String body) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(body),
          ],
        ),
      ),
    );
  }

  /// スキャンダル発生時の対応選択ダイアログ
  Future<void> _handleScandal(Scandal scandal) async {
    final response = await showDialog<ScandalResponse>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('📰 ${scandal.title}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(scandal.description),
              const SizedBox(height: 8),
              Text('深刻度：${scandal.severity.label}',
                  style: Theme.of(ctx).textTheme.labelMedium),
            ],
          ),
        ),
        actions: ScandalResponse.values
            .map(
              (r) => TextButton(
                onPressed: () => Navigator.pop(ctx, r),
                child: Text(r.label),
              ),
            )
            .toList(),
      ),
    );

    if (response == null || !mounted) return;
    final session = ref.read(gameSessionProvider).session;
    if (session == null) return;

    await ref.read(gameSessionProvider.notifier).respondToScandale(
          session,
          scandal.id,
          response,
        );
  }

  /// 内閣内の大臣対立への対応ダイアログ
  Future<void> _handleCabinetConflict(MinisterConflict conflict) async {
    final response = await showDialog<CabinetConflictResponse>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('🔥 内閣内の対立'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(conflict.description),
              const SizedBox(height: 8),
              Text('緊張度：${conflict.tensionLevel.toStringAsFixed(0)}%',
                  style: Theme.of(ctx).textTheme.labelMedium),
            ],
          ),
        ),
        actions: CabinetConflictResponse.values.map((r) {
          final label = switch (r) {
            CabinetConflictResponse.favorFirst => '${conflict.minister1.label}を支持する',
            CabinetConflictResponse.favorSecond => '${conflict.minister2.label}を支持する',
            _ => r.label,
          };
          return TextButton(
            onPressed: () => Navigator.pop(ctx, r),
            child: Text(label),
          );
        }).toList(),
      ),
    );

    if (response == null || !mounted) return;
    final session = ref.read(gameSessionProvider).session;
    if (session == null) return;

    await ref.read(gameSessionProvider.notifier).respondToCabinetConflict(
          session,
          conflict.id,
          response,
        );
  }

  /// 外交イベントの対応画面を表示
  Future<void> _handleDiplomaticEvent(DiplomaticEvent event) async {
    final session = ref.read(gameSessionProvider).session;
    if (session == null || !mounted) return;

    // イベントに紐づく国家IDを、国名の一致から逆引きする
    final matches = session.nationRelationships.entries
        .where((e) => e.value.nationName == event.involvedNations);
    final targetNationId =
        matches.isNotEmpty ? matches.first.key : event.involvedNations;

    final choice = await Navigator.of(context).push<DiplomaticOption>(
      MaterialPageRoute(
        builder: (_) => DiplomaticEventScreen(event: event),
      ),
    );

    if (choice == null || !mounted) return;
    await ref.read(gameSessionProvider.notifier).respondToDiplomaticEvent(
          ref.read(gameSessionProvider).session ?? session,
          event.id,
          choice,
          targetNationId,
        );
  }

  /// 危機の対応画面を表示
  Future<void> _handleCrisis(Crisis crisis) async {
    final display = CrisisEventService().generateEventDisplay(crisis);
    CrisisOption? selected;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CrisisAlertScreen(
          crisis: crisis,
          crisisDisplay: display,
          onResponseSelected: (option) => selected = option,
        ),
      ),
    );

    if (selected == null || !mounted) return;
    final session = ref.read(gameSessionProvider).session;
    if (session == null) return;

    await ref.read(gameSessionProvider.notifier).respondToCrisis(
          session,
          crisis.id,
          selected!.response,
        );
  }

  /// ストーリーパックの物語イベントの対応画面を表示
  Future<void> _handleStoryPackEvent(StoryPackEvent event) async {
    final choice = await Navigator.of(context).push<StoryPackEventChoice>(
      MaterialPageRoute(
        builder: (_) => StoryPackEventScreen(event: event),
      ),
    );

    if (choice == null || !mounted) return;
    final session = ref.read(gameSessionProvider).session;
    if (session == null) return;

    final completedPackId =
        await ref.read(gameSessionProvider.notifier).respondToStoryPackEvent(
              session,
              event.id,
              choice.id,
            );

    if (choice.consequenceText != null && mounted) {
      _showEventBanner('📖 ${event.title}', choice.consequenceText!);
    }

    if (completedPackId != null && mounted) {
      final recommended = await ref
          .read(gameSessionProvider.notifier)
          .getRecommendedNextPack(completedPackId);
      if (recommended != null && mounted) {
        await _showRecommendedPackDialog(recommended);
      }
    }
  }

  /// ストーリーパック完走時に、次にプレイすべきおすすめパックを提示する
  Future<void> _showRecommendedPackDialog(StoryPack pack) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 パック完走！'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('次におすすめのパックはこちら：'),
              const SizedBox(height: 12),
              Text('${pack.emoji} ${pack.title}',
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(pack.description),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('後で'),
          ),
        ],
      ),
    );
  }

  List<String> _buildHeadlines(CountryStatus s, String country) {
    return [
      'GDP \$${s.gdp.toStringAsFixed(0)}B｜失業率 ${s.unemployment.toStringAsFixed(1)}%',
      '$country、国民満足度 ${s.satisfaction.toStringAsFixed(0)}％を記録',
      '${s.crisisLevel.emoji} 国家情勢：${s.crisisLevel.label}',
      if (s.factions.isCoupRisk)
        '⚠️ ${s.factions.mostHostile.key.label}の不満が頂点に',
      'インフレ率 ${s.inflationRate.toStringAsFixed(1)}％｜安定度 ${s.stability.toStringAsFixed(0)}',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(gameSessionProvider);
    final userProfile = ref.watch(userProfileProvider);

    if (sessionState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final session = sessionState.session;
    if (session == null) {
      return const Scaffold(
        body: Center(child: Text('セッションを読み込めませんでした')),
      );
    }

    _currentEvent ??= _gameLogic.generateRandomEvent(session.status);

    final status = session.status;
    final decisionHistory = DecisionHistory(sessionState.decisions);
    final advisor =
        _advisors[_currentEvent!.category] ?? '🏛️';

    final home = Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.crisisGradient(status.crisisLevel),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ヘッダー
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.countryName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '${status.year}年目 · ${status.day}/${AppConstants.daysPerYear}日',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.public,
                          color: AppTheme.textSecondary),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WorldMapScreen(
                            status: status,
                            countryName: session.countryName,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.how_to_vote,
                          color: AppTheme.textSecondary),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WeeklyPollScreen(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.campaign,
                          color: AppTheme.textSecondary),
                      tooltip: 'キャンペーン',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CampaignScreen(
                            countryName: session.countryName,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.show_chart,
                          color: AppTheme.textSecondary),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              GraphScreen(decisionHistory: decisionHistory),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.history,
                          color: AppTheme.textSecondary),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CountryHistoryScreen(
                            gameSession: session,
                            decisionHistory: decisionHistory,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.emoji_events,
                          color: AppTheme.textSecondary),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AchievementsScreen(session: session),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.groups,
                          color: AppTheme.textSecondary),
                      tooltip: '国民世論調査',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CitizenSurveyScreen(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.trending_up,
                          color: AppTheme.textSecondary),
                      tooltip: '国家統計',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StatisticsScreen(gameSession: session),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings,
                          color: AppTheme.textSecondary),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(
                            userProfile: userProfile ??
                                UserProfile(
                                  id: 'guest',
                                  createdAt: DateTime.now(),
                                  lastLoginAt: DateTime.now(),
                                ),
                            onProfileChanged: (p) => ref
                                .read(userProfileProvider.notifier)
                                .update(p),
                            onReset: _onRestartGame,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // メインコンテンツ
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      // ステータスダッシュボード
                      StatusDashboard(
                        status: status,
                        previous: _previousStatus,
                      ),
                      const SizedBox(height: 14),

                      // 派閥バー
                      FactionBars(factions: status.factions),
                      const SizedBox(height: 14),

                      // 内閣の忠誠
                      CabinetPanel(
                        cabinet: status.cabinet,
                        corruption: status.corruption,
                      ),
                      const SizedBox(height: 20),

                      // スワイプ政策カード
                      PolicyCard(
                        key: ValueKey(_currentEvent!.id),
                        event: _currentEvent!,
                        advisorEmoji: advisor,
                        onChoose: _handleChoice,
                      ),
                    ],
                  ),
                ),
              ),

              // ニュースティッカー
              NewsTicker(
                key: ValueKey('${status.year}_${status.day}'),
                headlines: _buildHeadlines(status, session.countryName),
              ),
            ],
          ),
        ),
      ),
    );

    // 初回プレイ時のみ操作チュートリアルを重ねて表示する。
    if (!session.hasSeenTutorial) {
      return Stack(
        children: [
          home,
          TutorialOverlay(onFinish: _onTutorialFinish),
        ],
      );
    }
    return home;
  }
}
