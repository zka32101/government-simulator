import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/event.dart';
import 'package:government_simulator/models/decision.dart';
import 'package:government_simulator/models/faction.dart';
import 'package:government_simulator/models/minister.dart';
import 'package:government_simulator/models/user_profile.dart';
import 'package:government_simulator/providers/game_provider.dart';
import 'package:government_simulator/services/game_logic_service.dart';
import 'package:government_simulator/utils/app_theme.dart';
import 'package:government_simulator/utils/constants.dart';
import 'package:government_simulator/widgets/policy_card.dart';
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
import 'year_end_screen.dart';
import 'game_over_screen.dart';
import 'ending_screen.dart';
import 'world_map_screen.dart';
import 'weekly_poll_screen.dart';

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
  }

  void _pickNextEvent(CountryStatus status) {
    final event = _gameLogic.generateRandomEvent(
      status,
      recentIds: _recentEventIds,
    );
    _recentEventIds.add(event.id);
    if (_recentEventIds.length > 3) {
      _recentEventIds.remove(_recentEventIds.first);
    }
    setState(() => _currentEvent = event);
  }

  void _handleChoice(Choice choice) async {
    final sessionState = ref.read(gameSessionProvider);
    final session = sessionState.session;
    if (session == null) return;

    final beforeStatus = session.status;
    _previousStatus = beforeStatus;

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

    // 実績解除トースト
    if (choiceResult.newAchievements.isNotEmpty && mounted) {
      AchievementPopup.show(context, choiceResult.newAchievements);
    }

    // 内閣裏切りの発覚
    final betrayed = choiceResult.betrayedMinister;
    if (betrayed != null && mounted) {
      final countryName = ref.read(gameSessionProvider).session?.countryName ??
          session.countryName;
      _showEventBanner(
        '🎭 内閣の裏切り',
        betrayed.betrayalNarrative(countryName),
      );
    }

    // 公約の顛末（果たされた／破られた）
    for (final r in choiceResult.promiseResolutions) {
      if (mounted) {
        _showEventBanner(r.fulfilled ? '🤝 公約履行' : '💔 公約破棄', r.narrative);
      }
    }

    // ゲームオーバー判定
    if (choiceResult.isGameOver && mounted) {
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

    final updatedState = ref.read(gameSessionProvider);
    final updatedStatus = updatedState.session?.status;
    if (updatedStatus == null) return;

    // 年末チェック
    if (updatedStatus.day >= AppConstants.daysPerYear && !_showingYearEnd) {
      _showingYearEnd = true;
      if (mounted) {
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
        _showingYearEnd = false;
      }
    } else {
      _pickNextEvent(updatedStatus);
    }
  }

  void _onContinueYear() async {
    await ref.read(gameSessionProvider.notifier).continueToNextYear();
    final updatedStatus = ref.read(gameSessionProvider).session?.status;
    if (updatedStatus != null && mounted) {
      Navigator.of(context).pop();
      _pickNextEvent(updatedStatus);
    }
  }

  void _onRestartGame() async {
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
