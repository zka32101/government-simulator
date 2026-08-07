import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:government_simulator/models/user_profile.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/decision.dart';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/utils/constants.dart';

/// Firestore とのやり取りを担うサービス。
///
/// シリアライズは各モデル自身の `toMap()`/`fromMap()` を単一ソースとして
/// 委譲する。ここでは Firestore の `Timestamp` 型 ⇄ モデルの ISO8601
/// 文字列表現の変換のみを橋渡しする。
///
/// 以前はここで各モデルのフィールドを手動で列挙してマップを組み立てて
/// おり、モデルにフィールドが増えるたび（factions・unlockedAchievements・
/// email 等）に追従できず、アプリ再起動のたびにそれらが静かにデフォルト
/// 値へリセットされるバグがあった。
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Map<String, dynamic> _withTimestamp(
      Map<String, dynamic> map, String key, DateTime value) {
    final copy = Map<String, dynamic>.from(map);
    copy[key] = Timestamp.fromDate(value);
    return copy;
  }

  Map<String, dynamic> _isoFromTimestamp(
      Map<String, dynamic> map, String key) {
    final copy = Map<String, dynamic>.from(map);
    final v = copy[key];
    if (v is Timestamp) copy[key] = v.toDate().toIso8601String();
    return copy;
  }

  Map<String, dynamic> _statusToMap(CountryStatus s) =>
      _withTimestamp(s.toMap(), 'lastUpdated', s.lastUpdated);

  // =================== User Profile ===================

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc =
          await _db.collection(FirebaseCollections.users).doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      var map = Map<String, dynamic>.from(doc.data()!);
      map = _isoFromTimestamp(map, 'createdAt');
      map = _isoFromTimestamp(map, 'lastLoginAt');
      map['id'] = userId;
      return UserProfile.fromMap(map);
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

  Map<String, dynamic> _userProfileToMap(UserProfile p) {
    var map = p.toMap();
    map = _withTimestamp(map, 'createdAt', p.createdAt);
    map = _withTimestamp(map, 'lastLoginAt', p.lastLoginAt);
    return map;
  }

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
    var map = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
    map = _isoFromTimestamp(map, 'createdAt');
    map = _isoFromTimestamp(map, 'lastPlayedAt');
    if (map['status'] is Map<String, dynamic>) {
      map['status'] = _isoFromTimestamp(
          map['status'] as Map<String, dynamic>, 'lastUpdated');
    }
    map['id'] = doc.id;
    return GameSession.fromMap(map);
  }

  Map<String, dynamic> _sessionToMap(GameSession s) {
    var map = s.toMap();
    map = _withTimestamp(map, 'createdAt', s.createdAt);
    map = _withTimestamp(map, 'lastPlayedAt', s.lastPlayedAt);
    map['status'] = _statusToMap(s.status);
    return map;
  }

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
    var map = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
    map = _isoFromTimestamp(map, 'decidedAt');
    if (map['beforeStatus'] is Map<String, dynamic>) {
      map['beforeStatus'] = _isoFromTimestamp(
          map['beforeStatus'] as Map<String, dynamic>, 'lastUpdated');
    }
    if (map['afterStatus'] is Map<String, dynamic>) {
      map['afterStatus'] = _isoFromTimestamp(
          map['afterStatus'] as Map<String, dynamic>, 'lastUpdated');
    }
    map['id'] = doc.id;
    return Decision.fromMap(map);
  }

  Map<String, dynamic> _decisionToMap(Decision d) {
    var map = d.toMap();
    map = _withTimestamp(map, 'decidedAt', d.decidedAt);
    map['beforeStatus'] = _statusToMap(d.beforeStatus);
    map['afterStatus'] = _statusToMap(d.afterStatus);
    return map;
  }

  // =================== Weekly Poll ===================
  //
  // 週替わり全国民投票。全プレイヤーが同じ週は同じ設問に投票し、
  // 投票は weekId+userId をドキュメントIDにして二重投票を防ぐ。
  // 集計はプレイヤー数分の全投票ドキュメントを毎回読むのではなく、
  // 週ごとの集計ドキュメントをトランザクションでインクリメントする。

  static const String _weeklyPollVotesCollection = 'weekly_poll_votes';
  static const String _weeklyPollCountsCollection = 'weekly_poll_counts';

  /// このユーザーが指定週にどちらへ投票したか（未投票なら null）。
  Future<String?> getUserVote(String weekId, String userId) async {
    try {
      final doc = await _db
          .collection(_weeklyPollVotesCollection)
          .doc('${weekId}_$userId')
          .get();
      if (!doc.exists) return null;
      return doc.data()?['choice'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// 指定週の選択肢A/Bそれぞれの投票数。
  Future<Map<String, int>> getPollCounts(String weekId) async {
    try {
      final doc =
          await _db.collection(_weeklyPollCountsCollection).doc(weekId).get();
      final data = doc.data();
      return {
        'A': ((data?['A'] ?? 0) as num).toInt(),
        'B': ((data?['B'] ?? 0) as num).toInt(),
      };
    } catch (_) {
      return {'A': 0, 'B': 0};
    }
  }

  /// 投票を記録する。既に投票済みなら false を返し、二重投票を防ぐ。
  Future<bool> submitVote(String weekId, String userId, String choice) async {
    final voteRef =
        _db.collection(_weeklyPollVotesCollection).doc('${weekId}_$userId');
    final countRef = _db.collection(_weeklyPollCountsCollection).doc(weekId);
    try {
      return await _db.runTransaction<bool>((tx) async {
        final existingVote = await tx.get(voteRef);
        if (existingVote.exists) return false;

        final countDoc = await tx.get(countRef);
        final currentCount =
            ((countDoc.data()?[choice] ?? 0) as num).toInt();

        tx.set(voteRef, {
          'weekId': weekId,
          'userId': userId,
          'choice': choice,
          'votedAt': Timestamp.now(),
        });
        tx.set(
          countRef,
          {choice: currentCount + 1},
          SetOptions(merge: true),
        );
        return true;
      });
    } catch (_) {
      return false;
    }
  }
}
