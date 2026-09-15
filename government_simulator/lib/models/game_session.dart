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
import 'package:government_simulator/models/international_relations.dart';
import 'package:government_simulator/models/crisis.dart';
import 'package:government_simulator/models/story_pack_event.dart';

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

  // 外交・国際関係システム
  final Map<String, NationRelationship> nationRelationships; // 各国との関係
  final List<DiplomaticEvent> activeInternationalEvents; // 現在のイベント
  final List<DiplomaticEvent> historicalInternationalEvents; // 過去のイベント
  final String? warEnemyId; // 戦争中の敵国ID（nullなら平時）
  final DateTime? warStartDate; // 戦争開始日時
  final double militaryLosses; // 累積軍事損失
  final double economicDamageFromWar; // 戦争による経済ダメージ
  final double internationalStanding; // 国際的スタンディング（0-100）
  final List<DiplomaticSanction> activeSanctions; // 現在の制裁
  final List<TradeAgreement> activeTradeDeals; // 現在の貿易協定
  final double foreignDebt; // 外国からの借金
  final double foreignCreditRating; // 国際信用格付け（0-100）

  // 危機管理・承認度システム
  final double nationalApproval; // 国民承認度（0-100）
  final List<Crisis> activeCrises; // 現在発生中の危機
  final List<Crisis> historicalCrises; // 過去の危機履歴
  final DateTime? lastCrisisTime; // 最後の危機発生時刻
  final int crisisCount; // 現在の任期中の危機数
  final double economicSatisfaction; // 経済満足度（0-100）
  final double socialSatisfaction; // 社会満足度（0-100）
  final double securitySatisfaction; // 安全保障満足度（0-100）
  final double healthcareSatisfaction; // 医療・教育満足度（0-100）
  final bool coupAttemptInProgress; // クーデター進行中か
  final DateTime? coupAttemptTime; // クーデター開始時刻
  final int daysUntilCoup; // クーデターまでの日数カウント

  // ストーリーパックイベント・システム
  final List<StoryPackEventProgress> packEventProgress; // イベント進捗追跡
  final String? currentPackId; // 現在のプレイ中のストーリーパック
  final Map<String, int> packEventHistory; // 各パックで発生したイベント数

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
    this.nationRelationships = const {},
    this.activeInternationalEvents = const [],
    this.historicalInternationalEvents = const [],
    this.warEnemyId,
    this.warStartDate,
    this.militaryLosses = 0.0,
    this.economicDamageFromWar = 0.0,
    this.internationalStanding = 50.0, // デフォルト中立
    this.activeSanctions = const [],
    this.activeTradeDeals = const [],
    this.foreignDebt = 0.0,
    this.foreignCreditRating = 80.0, // デフォルト信用度
    this.nationalApproval = 50.0, // デフォルト中立
    this.activeCrises = const [],
    this.historicalCrises = const [],
    this.lastCrisisTime,
    this.crisisCount = 0,
    this.economicSatisfaction = 50.0,
    this.socialSatisfaction = 50.0,
    this.securitySatisfaction = 50.0,
    this.healthcareSatisfaction = 50.0,
    this.coupAttemptInProgress = false,
    this.coupAttemptTime,
    this.daysUntilCoup = 0,
    this.packEventProgress = const [],
    this.currentPackId,
    this.packEventHistory = const {},
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
    Map<String, NationRelationship>? nationRelationships,
    List<DiplomaticEvent>? activeInternationalEvents,
    List<DiplomaticEvent>? historicalInternationalEvents,
    String? warEnemyId,
    DateTime? warStartDate,
    double? militaryLosses,
    double? economicDamageFromWar,
    double? internationalStanding,
    List<DiplomaticSanction>? activeSanctions,
    List<TradeAgreement>? activeTradeDeals,
    double? foreignDebt,
    double? foreignCreditRating,
    double? nationalApproval,
    List<Crisis>? activeCrises,
    List<Crisis>? historicalCrises,
    DateTime? lastCrisisTime,
    int? crisisCount,
    double? economicSatisfaction,
    double? socialSatisfaction,
    double? securitySatisfaction,
    double? healthcareSatisfaction,
    bool? coupAttemptInProgress,
    DateTime? coupAttemptTime,
    int? daysUntilCoup,
    List<StoryPackEventProgress>? packEventProgress,
    String? currentPackId,
    Map<String, int>? packEventHistory,
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
      nationRelationships: nationRelationships ?? this.nationRelationships,
      activeInternationalEvents: activeInternationalEvents ?? this.activeInternationalEvents,
      historicalInternationalEvents: historicalInternationalEvents ?? this.historicalInternationalEvents,
      warEnemyId: warEnemyId ?? this.warEnemyId,
      warStartDate: warStartDate ?? this.warStartDate,
      militaryLosses: militaryLosses ?? this.militaryLosses,
      economicDamageFromWar: economicDamageFromWar ?? this.economicDamageFromWar,
      internationalStanding: internationalStanding ?? this.internationalStanding,
      activeSanctions: activeSanctions ?? this.activeSanctions,
      activeTradeDeals: activeTradeDeals ?? this.activeTradeDeals,
      foreignDebt: foreignDebt ?? this.foreignDebt,
      foreignCreditRating: foreignCreditRating ?? this.foreignCreditRating,
      nationalApproval: nationalApproval ?? this.nationalApproval,
      activeCrises: activeCrises ?? this.activeCrises,
      historicalCrises: historicalCrises ?? this.historicalCrises,
      lastCrisisTime: lastCrisisTime ?? this.lastCrisisTime,
      crisisCount: crisisCount ?? this.crisisCount,
      economicSatisfaction: economicSatisfaction ?? this.economicSatisfaction,
      socialSatisfaction: socialSatisfaction ?? this.socialSatisfaction,
      securitySatisfaction: securitySatisfaction ?? this.securitySatisfaction,
      healthcareSatisfaction: healthcareSatisfaction ?? this.healthcareSatisfaction,
      coupAttemptInProgress: coupAttemptInProgress ?? this.coupAttemptInProgress,
      coupAttemptTime: coupAttemptTime ?? this.coupAttemptTime,
      daysUntilCoup: daysUntilCoup ?? this.daysUntilCoup,
      packEventProgress: packEventProgress ?? this.packEventProgress,
      currentPackId: currentPackId ?? this.currentPackId,
      packEventHistory: packEventHistory ?? this.packEventHistory,
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
      'nationRelationships': nationRelationships
          .map((key, value) => MapEntry(key, value.toMap())),
      'activeInternationalEvents': activeInternationalEvents
          .map((e) => e.toMap())
          .toList(),
      'historicalInternationalEvents': historicalInternationalEvents
          .map((e) => e.toMap())
          .toList(),
      'warEnemyId': warEnemyId,
      'warStartDate': warStartDate?.toIso8601String(),
      'militaryLosses': militaryLosses,
      'economicDamageFromWar': economicDamageFromWar,
      'internationalStanding': internationalStanding,
      'activeSanctions': activeSanctions.map((s) => s.toMap()).toList(),
      'activeTradeDeals': activeTradeDeals.map((t) => t.toMap()).toList(),
      'foreignDebt': foreignDebt,
      'foreignCreditRating': foreignCreditRating,
      'nationalApproval': nationalApproval,
      'activeCrises': activeCrises.map((c) => c.toMap()).toList(),
      'historicalCrises': historicalCrises.map((c) => c.toMap()).toList(),
      'lastCrisisTime': lastCrisisTime?.toIso8601String(),
      'crisisCount': crisisCount,
      'economicSatisfaction': economicSatisfaction,
      'socialSatisfaction': socialSatisfaction,
      'securitySatisfaction': securitySatisfaction,
      'healthcareSatisfaction': healthcareSatisfaction,
      'coupAttemptInProgress': coupAttemptInProgress,
      'coupAttemptTime': coupAttemptTime?.toIso8601String(),
      'daysUntilCoup': daysUntilCoup,
      'packEventProgress': packEventProgress.map((p) => p.toMap()).toList(),
      'currentPackId': currentPackId,
      'packEventHistory': packEventHistory,
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
                      k,
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
      nationRelationships: map['nationRelationships'] != null
          ? Map<String, NationRelationship>.from(
              (map['nationRelationships'] as Map<String, dynamic>).map(
                (k, v) => MapEntry(
                  k,
                  NationRelationship.fromMap(v as Map<String, dynamic>),
                ),
              ),
            )
          : const {},
      activeInternationalEvents: (map['activeInternationalEvents'] as List?)
              ?.map((e) => DiplomaticEvent.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      historicalInternationalEvents:
          (map['historicalInternationalEvents'] as List?)
                  ?.map((e) => DiplomaticEvent.fromMap(e as Map<String, dynamic>))
                  .toList() ??
              const [],
      warEnemyId: map['warEnemyId'] as String?,
      warStartDate: map['warStartDate'] != null
          ? DateTime.tryParse(map['warStartDate'] as String)
          : null,
      militaryLosses: (map['militaryLosses'] as num?)?.toDouble() ?? 0.0,
      economicDamageFromWar:
          (map['economicDamageFromWar'] as num?)?.toDouble() ?? 0.0,
      internationalStanding:
          (map['internationalStanding'] as num?)?.toDouble() ?? 50.0,
      activeSanctions: (map['activeSanctions'] as List?)
              ?.map((s) => DiplomaticSanction.fromMap(s as Map<String, dynamic>))
              .toList() ??
          const [],
      activeTradeDeals: (map['activeTradeDeals'] as List?)
              ?.map((t) => TradeAgreement.fromMap(t as Map<String, dynamic>))
              .toList() ??
          const [],
      foreignDebt: (map['foreignDebt'] as num?)?.toDouble() ?? 0.0,
      foreignCreditRating:
          (map['foreignCreditRating'] as num?)?.toDouble() ?? 80.0,
      nationalApproval: (map['nationalApproval'] as num?)?.toDouble() ?? 50.0,
      activeCrises: (map['activeCrises'] as List?)
              ?.map((c) => Crisis.fromMap(c as Map<String, dynamic>))
              .toList() ??
          const [],
      historicalCrises: (map['historicalCrises'] as List?)
              ?.map((c) => Crisis.fromMap(c as Map<String, dynamic>))
              .toList() ??
          const [],
      lastCrisisTime: map['lastCrisisTime'] != null
          ? DateTime.tryParse(map['lastCrisisTime'] as String)
          : null,
      crisisCount: map['crisisCount'] ?? 0,
      economicSatisfaction:
          (map['economicSatisfaction'] as num?)?.toDouble() ?? 50.0,
      socialSatisfaction:
          (map['socialSatisfaction'] as num?)?.toDouble() ?? 50.0,
      securitySatisfaction:
          (map['securitySatisfaction'] as num?)?.toDouble() ?? 50.0,
      healthcareSatisfaction:
          (map['healthcareSatisfaction'] as num?)?.toDouble() ?? 50.0,
      coupAttemptInProgress: map['coupAttemptInProgress'] ?? false,
      coupAttemptTime: map['coupAttemptTime'] != null
          ? DateTime.tryParse(map['coupAttemptTime'] as String)
          : null,
      daysUntilCoup: map['daysUntilCoup'] ?? 0,
      packEventProgress: (map['packEventProgress'] as List?)
              ?.map((p) => StoryPackEventProgress.fromMap(p as Map<String, dynamic>))
              .toList() ??
          const [],
      currentPackId: map['currentPackId'] as String?,
      packEventHistory: map['packEventHistory'] != null
          ? Map<String, int>.from(map['packEventHistory'] as Map<String, dynamic>)
          : const {},
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
