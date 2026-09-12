/// 選挙結果・システム
/// プレイヤーと対立候補者の得票率、勝敗、スコアを追跡

import 'package:uuid/uuid.dart';

enum ElectionVictoryType {
  dominantVictory,    // 65%+
  clearVictory,       // 55-65%
  narrowVictory,      // 50-55%
  pluralityVictory,   // 40-50%
  narrowLoss,         // 45-50% but lost
  clearLoss,          // 35-45%
  landslideDefeat;    // <35%

  String get label {
    switch (this) {
      case ElectionVictoryType.dominantVictory:
        return '圧倒的勝利';
      case ElectionVictoryType.clearVictory:
        return '明確な勝利';
      case ElectionVictoryType.narrowVictory:
        return '僅かな勝利';
      case ElectionVictoryType.pluralityVictory:
        return '相対多数の勝利';
      case ElectionVictoryType.narrowLoss:
        return '僅かな敗北';
      case ElectionVictoryType.clearLoss:
        return '明確な敗北';
      case ElectionVictoryType.landslideDefeat:
        return '地滑り的敗北';
    }
  }
}

class ElectionResult {
  final String id;
  final int year;
  final double playerVoteShare;              // 0-100
  final double playerMarginOfVictory;        // Could be negative
  final Map<String, double> rivalVotes;      // rivalId -> vote %
  final Map<String, double> minorCandidateVotes;
  final DateTime conductedAt;
  final bool playerWon;
  final ElectionVictoryType victoryType;
  final double electoralScore;               // 0-100
  final String narrativeText;                // Generated narrative

  ElectionResult({
    String? id,
    required this.year,
    required this.playerVoteShare,
    required this.playerMarginOfVictory,
    required this.rivalVotes,
    required this.minorCandidateVotes,
    DateTime? conductedAt,
    required this.playerWon,
    required this.victoryType,
    required this.electoralScore,
    required this.narrativeText,
  })  : id = id ?? const Uuid().v4(),
        conductedAt = conductedAt ?? DateTime.now();

  /// 圧倒的勝利か
  bool get isDominant => playerMarginOfVictory > 25 || playerMarginOfVictory < -25;

  /// 接戦か
  bool get isClose => playerMarginOfVictory.abs() <= 5;

  /// 最高得票者か（複数候補の場合）
  bool get isPlurality => playerVoteShare >= 40 && playerVoteShare < 50;

  /// 過半数獲得か
  bool get isMajority => playerVoteShare >= 50;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'playerVoteShare': playerVoteShare,
      'playerMarginOfVictory': playerMarginOfVictory,
      'rivalVotes': rivalVotes,
      'minorCandidateVotes': minorCandidateVotes,
      'conductedAt': conductedAt.toIso8601String(),
      'playerWon': playerWon,
      'victoryType': victoryType.name,
      'electoralScore': electoralScore,
      'narrativeText': narrativeText,
    };
  }

  static ElectionResult fromMap(Map<String, dynamic> map) {
    return ElectionResult(
      id: map['id'] as String,
      year: map['year'] as int,
      playerVoteShare: (map['playerVoteShare'] as num).toDouble(),
      playerMarginOfVictory: (map['playerMarginOfVictory'] as num).toDouble(),
      rivalVotes: Map<String, double>.from(
        (map['rivalVotes'] as Map<dynamic, dynamic>).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      ),
      minorCandidateVotes: Map<String, double>.from(
        (map['minorCandidateVotes'] as Map<dynamic, dynamic>).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      ),
      conductedAt: DateTime.parse(map['conductedAt'] as String),
      playerWon: map['playerWon'] as bool,
      victoryType: ElectionVictoryType.values.byName(map['victoryType'] as String),
      electoralScore: (map['electoralScore'] as num).toDouble(),
      narrativeText: map['narrativeText'] as String,
    );
  }
}
