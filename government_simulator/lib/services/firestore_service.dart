import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:government_simulator/models/user_profile.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/decision.dart';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/event.dart';
import 'package:government_simulator/utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =================== User Profile ===================

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc =
          await _db.collection(FirebaseCollections.users).doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      return UserProfile(
        id: userId,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
        isPurchased: data['isPurchased'] ?? false,
        unlockedDlcScenarios:
            List<String>.from(data['unlockedDlcScenarios'] ?? []),
        totalGamesCreated: data['totalGamesCreated'] ?? 0,
        totalGameHours: (data['totalGameHours'] ?? 0).toInt(),
        soundEnabled: data['soundEnabled'] ?? true,
        notificationsEnabled: data['notificationsEnabled'] ?? true,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> createUserProfile(UserProfile profile) async {
    await _db
        .collection(FirebaseCollections.users)
        .doc(profile.id)
        .set(_userProfileToMap(profile));
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _db
        .collection(FirebaseCollections.users)
        .doc(profile.id)
        .set(_userProfileToMap(profile), SetOptions(merge: true));
  }

  Map<String, dynamic> _userProfileToMap(UserProfile p) => {
        'createdAt': Timestamp.fromDate(p.createdAt),
        'lastLoginAt': Timestamp.fromDate(p.lastLoginAt),
        'isPurchased': p.isPurchased,
        'unlockedDlcScenarios': p.unlockedDlcScenarios,
        'totalGamesCreated': p.totalGamesCreated,
        'totalGameHours': p.totalGameHours,
        'soundEnabled': p.soundEnabled,
        'notificationsEnabled': p.notificationsEnabled,
      };

  // =================== Game Session ===================

  Future<GameSession?> getLatestSession(String userId) async {
    try {
      final query = await _db
          .collection(FirebaseCollections.gameSessions)
          .where('userId', isEqualTo: userId)
          .orderBy('lastPlayedAt', descending: true)
          .limit(1)
          .get();
      if (query.docs.isEmpty) return null;
      return _docToSession(query.docs.first);
    } catch (_) {
      return null;
    }
  }

  Future<GameSession?> getGameSession(String sessionId) async {
    try {
      final doc = await _db
          .collection(FirebaseCollections.gameSessions)
          .doc(sessionId)
          .get();
      if (!doc.exists) return null;
      return _docToSession(doc);
    } catch (_) {
      return null;
    }
  }

  Future<String> createGameSession(GameSession session) async {
    await _db
        .collection(FirebaseCollections.gameSessions)
        .doc(session.id)
        .set(_sessionToMap(session));
    return session.id;
  }

  Future<void> updateGameSession(GameSession session) async {
    await _db
        .collection(FirebaseCollections.gameSessions)
        .doc(session.id)
        .set(_sessionToMap(session), SetOptions(merge: true));
  }

  Future<List<GameSession>> getUserGameSessions(String userId) async {
    try {
      final query = await _db
          .collection(FirebaseCollections.gameSessions)
          .where('userId', isEqualTo: userId)
          .orderBy('lastPlayedAt', descending: true)
          .get();
      return query.docs.map(_docToSession).toList();
    } catch (_) {
      return [];
    }
  }

  GameSession _docToSession(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameSession(
      id: doc.id,
      userId: data['userId'],
      countryName: data['countryName'],
      status: _mapToStatus(data['status'] as Map<String, dynamic>),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastPlayedAt: (data['lastPlayedAt'] as Timestamp).toDate(),
      difficulty: data['difficulty'] ?? 'normal',
      totalDecisions: data['totalDecisions'] ?? 0,
      positiveOutcomes: data['positiveOutcomes'] ?? 0,
      negativeOutcomes: data['negativeOutcomes'] ?? 0,
    );
  }

  Map<String, dynamic> _sessionToMap(GameSession s) => {
        'userId': s.userId,
        'countryName': s.countryName,
        'status': _statusToMap(s.status),
        'createdAt': Timestamp.fromDate(s.createdAt),
        'lastPlayedAt': Timestamp.fromDate(s.lastPlayedAt),
        'difficulty': s.difficulty,
        'totalDecisions': s.totalDecisions,
        'positiveOutcomes': s.positiveOutcomes,
        'negativeOutcomes': s.negativeOutcomes,
      };

  // =================== Decision ===================

  Future<void> saveDecision(Decision decision) async {
    await _db
        .collection(FirebaseCollections.decisions)
        .doc(decision.id)
        .set(_decisionToMap(decision));
  }

  Future<List<Decision>> getSessionDecisions(String sessionId) async {
    try {
      final query = await _db
          .collection(FirebaseCollections.decisions)
          .where('sessionId', isEqualTo: sessionId)
          .orderBy('decidedAt', descending: false)
          .get();
      return query.docs.map(_docToDecision).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> batchUpdateSession(
      GameSession session, Decision decision) async {
    final batch = _db.batch();
    batch.set(
      _db.collection(FirebaseCollections.gameSessions).doc(session.id),
      _sessionToMap(session),
      SetOptions(merge: true),
    );
    batch.set(
      _db.collection(FirebaseCollections.decisions).doc(decision.id),
      _decisionToMap(decision),
    );
    await batch.commit();
  }

  Decision _docToDecision(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final impactData = data['appliedImpact'] as Map<String, dynamic>?;
    return Decision(
      id: doc.id,
      sessionId: data['sessionId'],
      eventId: data['eventId'],
      chosenChoiceId: data['chosenChoiceId'] ?? '',
      decidedAt: (data['decidedAt'] as Timestamp).toDate(),
      narrative: data['narrative'] ?? '',
      impactScore: (data['impactScore'] ?? 0).toDouble(),
      appliedImpact: impactData != null ? Impact.fromMap(impactData) : Impact(),
      wasPositiveOutcome: data['wasPositiveOutcome'] ?? false,
      beforeStatus: _mapToStatus(data['beforeStatus'] as Map<String, dynamic>),
      afterStatus: _mapToStatus(data['afterStatus'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> _decisionToMap(Decision d) => {
        'sessionId': d.sessionId,
        'eventId': d.eventId,
        'chosenChoiceId': d.chosenChoiceId,
        'decidedAt': Timestamp.fromDate(d.decidedAt),
        'narrative': d.narrative,
        'impactScore': d.impactScore,
        'appliedImpact': d.appliedImpact.toMap(),
        'wasPositiveOutcome': d.wasPositiveOutcome,
        'beforeStatus': _statusToMap(d.beforeStatus),
        'afterStatus': _statusToMap(d.afterStatus),
      };

  // =================== Status helpers ===================

  CountryStatus _mapToStatus(Map<String, dynamic> d) => CountryStatus(
        gdp: (d['gdp'] ?? AppConstants.initialGdp).toDouble(),
        unemployment:
            (d['unemployment'] ?? AppConstants.initialUnemployment).toDouble(),
        satisfaction:
            (d['satisfaction'] ?? AppConstants.initialSatisfaction).toDouble(),
        nationalPower:
            (d['nationalPower'] ?? AppConstants.initialNationalPower).toDouble(),
        inflationRate:
            (d['inflationRate'] ?? AppConstants.initialInflationRate).toDouble(),
        publicDebt:
            (d['publicDebt'] ?? AppConstants.initialPublicDebt).toDouble(),
        stability:
            (d['stability'] ?? AppConstants.initialStability).toDouble(),
        year: d['year'] ?? 1,
        day: d['day'] ?? 1,
        lastUpdated: d['lastUpdated'] != null
            ? (d['lastUpdated'] as Timestamp).toDate()
            : DateTime.now(),
      );

  Map<String, dynamic> _statusToMap(CountryStatus s) => {
        'gdp': s.gdp,
        'unemployment': s.unemployment,
        'satisfaction': s.satisfaction,
        'nationalPower': s.nationalPower,
        'inflationRate': s.inflationRate,
        'publicDebt': s.publicDebt,
        'stability': s.stability,
        'year': s.year,
        'day': s.day,
        'lastUpdated': Timestamp.fromDate(s.lastUpdated),
      };
}
