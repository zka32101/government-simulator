import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/election.dart';
import 'package:government_simulator/models/indicator_history.dart';
import 'package:government_simulator/models/promise.dart';
import 'package:government_simulator/models/rival_candidate.dart';
import 'package:government_simulator/models/political_party.dart';
import 'package:government_simulator/models/polling.dart';
import 'package:government_simulator/models/campaign.dart';
import 'package:government_simulator/models/scandal.dart';
import 'package:government_simulator/models/debate.dart';
import 'package:government_simulator/models/election_result.dart';

class GameSession {
  final String id;
  final String userId;
  final String countryName;
  final CountryStatus status;
  final DateTime createdAt;
  final DateTime lastPlayedAt;
  final int totalPlaySessions;
  final String difficulty; // easy, normal, hard
  final bool isActive;

  // Gameplay history
  final int totalDecisions;
  final int positiveOutcomes;
  final int negativeOutcomes;

  // Achievements & unlocks
  final List<String> unlockedAchievements;
  final bool hasSeenTutorial;

  // 二枚舌外交システム：まだ期限が来ていない公約
  final List<Promise> activePromises;

  // 国家指標の履歴（UI/UX改善用）
  final List<IndicatorSnapshot> indicatorHistory;

  // 選挙履歴
  final List<Election> elections;

  // ライバル候補者（4年ごとの選挙時に登場）
  final List<RivalCandidate> rivalCandidates;

  // 政治政党（支持率・忠誠度を追跡）
  final Map<String, PoliticalParty> politicalParties;

  // 世論調査履歴（選挙トレンド追跡用）
  final List<Poll> polls;

  // 選挙キャンペーン
  final List<Campaign> activeCampaigns;
  final List<CounterCampaign> rivalCampaigns;
  final double campaignBudget; // 利用可能な予算
  final double spentBudget; // 既に使用した予算

  // スキャンダル・システム
  final List<Scandal> activeScandalsList;
  final int playerReputation; // 0-100 (affects scandal intensity)
  final int mediaFavoring; // -50 to +50 (affects coverage)

  // 討論会・システム
  final List<Debate> debateHistory; // All debates in this session
  final Debate? upcomingDebate; // Next scheduled debate
  final double debateEffectsMultiplier; // Campaign effectiveness modifier post-debate
  final int weeksSinceDebate; // For applying/removing debate effects

  // 選挙結果・システム
  final ElectionResult? lastElectionResult;
  final int successfulTerms; // Number of terms won
  final double cumulativeElectoralScore; // Average across all elections
  final String? currentMandate; // Policy mandate from election (e.g., "economic")
  final bool gameEnded; // Whether game ended by election loss
  final GameEndReason? endReason; // Reason for game end

  const GameSession({
    required this.id,
    required this.userId,
    required this.countryName,
    required this.status,
    required this.createdAt,
    required this.lastPlayedAt,
    this.totalPlaySessions = 1,
    this.difficulty = 'normal',
    this.isActive = true,
    this.totalDecisions = 0,
    this.positiveOutcomes = 0,
    this.negativeOutcomes = 0,
    this.unlockedAchievements = const [],
    this.hasSeenTutorial = false,
    this.activePromises = const [],
    this.indicatorHistory = const [],
    this.elections = const [],
    this.rivalCandidates = const [],
    this.politicalParties = const {},
    this.polls = const [],
    this.activeCampaigns = const [],
    this.rivalCampaigns = const [],
    this.campaignBudget = 500.0, // 500万単位
    this.spentBudget = 0.0,
    this.activeScandalsList = const [],
    this.playerReputation = 50,
    this.mediaFavoring = 0,
    this.debateHistory = const [],
    this.upcomingDebate,
    this.debateEffectsMultiplier = 1.0,
    this.weeksSinceDebate = 0,
    this.lastElectionResult,
    this.successfulTerms = 0,
    this.cumulativeElectoralScore = 0.0,
    this.currentMandate,
    this.gameEnded = false,
    this.endReason,
  });

  // プレイ時間（分）
  int get totalPlayTimeMinutes {
    return lastPlayedAt.difference(createdAt).inMinutes;
  }

  // 意思決定の成功率
  double get successRate {
    if (totalDecisions == 0) return 0;
    return (positiveOutcomes / totalDecisions) * 100;
  }

  // ゲーム難易度係数
  double get difficultyMultiplier {
    switch (difficulty) {
      case 'easy':
        return 0.8;
      case 'normal':
        return 1.0;
      case 'hard':
        return 1.3;
      default:
        return 1.0;
    }
  }

  GameSession copyWith({
    String? id,
    String? userId,
    String? countryName,
    CountryStatus? status,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    int? totalPlaySessions,
    String? difficulty,
    bool? isActive,
    int? totalDecisions,
    int? positiveOutcomes,
    int? negativeOutcomes,
    List<String>? unlockedAchievements,
    bool? hasSeenTutorial,
    List<Promise>? activePromises,
    List<IndicatorSnapshot>? indicatorHistory,
    List<Election>? elections,
    List<RivalCandidate>? rivalCandidates,
    Map<String, PoliticalParty>? politicalParties,
    List<Poll>? polls,
    List<Campaign>? activeCampaigns,
    List<CounterCampaign>? rivalCampaigns,
    double? campaignBudget,
    double? spentBudget,
    List<Scandal>? activeScandalsList,
    int? playerReputation,
    int? mediaFavoring,
    List<Debate>? debateHistory,
    Debate? upcomingDebate,
    double? debateEffectsMultiplier,
    int? weeksSinceDebate,
    ElectionResult? lastElectionResult,
    int? successfulTerms,
    double? cumulativeElectoralScore,
    String? currentMandate,
    bool? gameEnded,
    GameEndReason? endReason,
  }) {
    return GameSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      countryName: countryName ?? this.countryName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      totalPlaySessions: totalPlaySessions ?? this.totalPlaySessions,
      difficulty: difficulty ?? this.difficulty,
      isActive: isActive ?? this.isActive,
      totalDecisions: totalDecisions ?? this.totalDecisions,
      positiveOutcomes: positiveOutcomes ?? this.positiveOutcomes,
      negativeOutcomes: negativeOutcomes ?? this.negativeOutcomes,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
      activePromises: activePromises ?? this.activePromises,
      indicatorHistory: indicatorHistory ?? this.indicatorHistory,
      elections: elections ?? this.elections,
      rivalCandidates: rivalCandidates ?? this.rivalCandidates,
      politicalParties: politicalParties ?? this.politicalParties,
      polls: polls ?? this.polls,
      activeCampaigns: activeCampaigns ?? this.activeCampaigns,
      rivalCampaigns: rivalCampaigns ?? this.rivalCampaigns,
      campaignBudget: campaignBudget ?? this.campaignBudget,
      spentBudget: spentBudget ?? this.spentBudget,
      activeScandalsList: activeScandalsList ?? this.activeScandalsList,
      playerReputation: playerReputation ?? this.playerReputation,
      mediaFavoring: mediaFavoring ?? this.mediaFavoring,
      debateHistory: debateHistory ?? this.debateHistory,
      upcomingDebate: upcomingDebate ?? this.upcomingDebate,
      debateEffectsMultiplier:
          debateEffectsMultiplier ?? this.debateEffectsMultiplier,
      weeksSinceDebate: weeksSinceDebate ?? this.weeksSinceDebate,
      lastElectionResult: lastElectionResult ?? this.lastElectionResult,
      successfulTerms: successfulTerms ?? this.successfulTerms,
      cumulativeElectoralScore: cumulativeElectoralScore ?? this.cumulativeElectoralScore,
      currentMandate: currentMandate ?? this.currentMandate,
      gameEnded: gameEnded ?? this.gameEnded,
      endReason: endReason ?? this.endReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'countryName': countryName,
      'status': status.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      'totalPlaySessions': totalPlaySessions,
      'difficulty': difficulty,
      'isActive': isActive,
      'totalDecisions': totalDecisions,
      'positiveOutcomes': positiveOutcomes,
      'negativeOutcomes': negativeOutcomes,
      'unlockedAchievements': unlockedAchievements,
      'hasSeenTutorial': hasSeenTutorial,
      'activePromises': activePromises.map((p) => p.toMap()).toList(),
      'indicatorHistory': indicatorHistory.map((s) => s.toMap()).toList(),
      'elections': elections.map((e) => e.toMap()).toList(),
      'rivalCandidates': rivalCandidates.map((r) => r.toMap()).toList(),
      'politicalParties': politicalParties.map((k, v) => MapEntry(k, v.toMap())),
      'polls': polls.map((p) => p.toMap()).toList(),
      'activeCampaigns': activeCampaigns.map((c) => c.toMap()).toList(),
      'rivalCampaigns': rivalCampaigns.map((c) => c.toMap()).toList(),
      'campaignBudget': campaignBudget,
      'spentBudget': spentBudget,
      'activeScandalsList': activeScandalsList.map((s) => s.toMap()).toList(),
      'playerReputation': playerReputation,
      'mediaFavoring': mediaFavoring,
      'debateHistory': debateHistory.map((d) => d.toMap()).toList(),
      'upcomingDebate': upcomingDebate?.toMap(),
      'debateEffectsMultiplier': debateEffectsMultiplier,
      'weeksSinceDebate': weeksSinceDebate,
      'lastElectionResult': lastElectionResult?.toMap(),
      'successfulTerms': successfulTerms,
      'cumulativeElectoralScore': cumulativeElectoralScore,
      'currentMandate': currentMandate,
      'gameEnded': gameEnded,
      'endReason': endReason?.name,
    };
  }

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      countryName: map['countryName'] ?? 'New Country',
      status: map['status'] != null
          ? CountryStatus.fromMap(map['status'])
          : CountryStatus(
              gdp: 1000,
              unemployment: 5,
              satisfaction: 50,
              nationalPower: 50,
              year: 1,
              day: 1,
              lastUpdated: DateTime.now(),
            ),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastPlayedAt: map['lastPlayedAt'] != null
          ? DateTime.parse(map['lastPlayedAt'])
          : DateTime.now(),
      totalPlaySessions: map['totalPlaySessions'] ?? 1,
      difficulty: map['difficulty'] ?? 'normal',
      isActive: map['isActive'] ?? true,
      totalDecisions: map['totalDecisions'] ?? 0,
      positiveOutcomes: map['positiveOutcomes'] ?? 0,
      negativeOutcomes: map['negativeOutcomes'] ?? 0,
      unlockedAchievements:
          List<String>.from(map['unlockedAchievements'] ?? []),
      hasSeenTutorial: map['hasSeenTutorial'] ?? false,
      activePromises: (map['activePromises'] as List?)
              ?.map((p) => Promise.fromMap(p as Map<String, dynamic>))
              .toList() ??
          const [],
      indicatorHistory: (map['indicatorHistory'] as List?)
              ?.map((s) => IndicatorSnapshot.fromMap(s as Map<String, dynamic>))
              .toList() ??
          const [],
      elections: (map['elections'] as List?)
              ?.map((e) => Election.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rivalCandidates: (map['rivalCandidates'] as List?)
              ?.map((r) => RivalCandidate.fromMap(r as Map<String, dynamic>))
              .toList() ??
          const [],
      politicalParties: map['politicalParties'] != null
              ? Map<String, PoliticalParty>.from(
                  (map['politicalParties'] as Map<String, dynamic>).map(
                    (k, v) => MapEntry(
                      k as String,
                      PoliticalParty.fromMap(v as Map<String, dynamic>),
                    ),
                  ),
                )
              : const {},
      polls: (map['polls'] as List?)
              ?.map((p) => Poll.fromMap(p as Map<String, dynamic>))
              .toList() ??
          const [],
      activeCampaigns: (map['activeCampaigns'] as List?)
              ?.map((c) => Campaign.fromMap(c as Map<String, dynamic>))
              .toList() ??
          const [],
      rivalCampaigns: (map['rivalCampaigns'] as List?)
              ?.map((c) => CounterCampaign.fromMap(c as Map<String, dynamic>))
              .toList() ??
          const [],
      campaignBudget: (map['campaignBudget'] as num?)?.toDouble() ?? 500.0,
      spentBudget: (map['spentBudget'] as num?)?.toDouble() ?? 0.0,
      activeScandalsList: (map['activeScandalsList'] as List?)
              ?.map((s) => Scandal.fromMap(s as Map<String, dynamic>))
              .toList() ??
          const [],
      playerReputation: map['playerReputation'] ?? 50,
      mediaFavoring: map['mediaFavoring'] ?? 0,
      debateHistory: (map['debateHistory'] as List?)
              ?.map((d) => Debate.fromMap(d as Map<String, dynamic>))
              .toList() ??
          const [],
      upcomingDebate: map['upcomingDebate'] != null
          ? Debate.fromMap(map['upcomingDebate'] as Map<String, dynamic>)
          : null,
      debateEffectsMultiplier:
          (map['debateEffectsMultiplier'] as num?)?.toDouble() ?? 1.0,
      weeksSinceDebate: map['weeksSinceDebate'] ?? 0,
      lastElectionResult: map['lastElectionResult'] != null
          ? ElectionResult.fromMap(map['lastElectionResult'] as Map<String, dynamic>)
          : null,
      successfulTerms: map['successfulTerms'] ?? 0,
      cumulativeElectoralScore: (map['cumulativeElectoralScore'] as num?)?.toDouble() ?? 0.0,
      currentMandate: map['currentMandate'] as String?,
      gameEnded: map['gameEnded'] ?? false,
      endReason: map['endReason'] != null
          ? GameEndReason.values.byName(map['endReason'] as String)
          : null,
    );
  }
}

// Game end reason enum
enum GameEndReason {
  electionLoss,
  economicCollapse,
  politicalInstability,
  playerRetirement,
}

// Difficulty enum
enum DifficultyLevel {
  easy('easy', 'イージー'),
  normal('normal', 'ノーマル'),
  hard('hard', 'ハード');

  final String value;
  final String label;

  const DifficultyLevel(this.value, this.label);
}
