/// 討論会の選択肢・システム
/// プレイヤーのラウンドごとの戦略的選択

library;

enum ArgumentTone {
  aggressive,   // 攻撃的：相手の弱点を攻撃
  defensive,    // 防御的：自分の立場を守る
  diplomatic;   // 外交的：妥協を探る

  String get label {
    switch (this) {
      case ArgumentTone.aggressive:
        return '攻撃的';
      case ArgumentTone.defensive:
        return '防御的';
      case ArgumentTone.diplomatic:
        return '外交的';
    }
  }

  String get description {
    switch (this) {
      case ArgumentTone.aggressive:
        return 'リスク: 成功時+20、失敗時-15\n相手の弱点を攻撃します';
      case ArgumentTone.defensive:
        return '安定: +10〜+15\n自分の立場を守ります';
      case ArgumentTone.diplomatic:
        return '安全: +5〜+10\n共通点を見つけます';
    }
  }

  /// トーンのスコア影響（-15 to +20）
  double getScoreModifier({
    required bool isPlayerWinning,
    required bool isPlayerStrong,
    required bool isOpponentWeak,
  }) {
    switch (this) {
      case ArgumentTone.aggressive:
        if (isOpponentWeak) return 20.0;
        if (isPlayerWinning) return 10.0;
        return -15.0;

      case ArgumentTone.defensive:
        if (isPlayerStrong) return 15.0;
        if (isPlayerWinning) return 10.0;
        return 5.0;

      case ArgumentTone.diplomatic:
        if (isPlayerWinning) return 10.0;
        return 8.0;
    }
  }
}

enum EmphasisType {
  strength,     // 強みを強調：最高の統計を使う
  weakness,     // 弱みに対処：最低の統計を認める
  opposition;   // 相手の弱みを攻撃

  String get label {
    switch (this) {
      case EmphasisType.strength:
        return '強みを強調';
      case EmphasisType.weakness:
        return '弱みに対処';
      case EmphasisType.opposition:
        return '相手の弱みを攻撃';
    }
  }

  String get description {
    switch (this) {
      case EmphasisType.strength:
        return 'ボーナス: +8（安全）\n自分の最高の統計を強調します';
      case EmphasisType.weakness:
        return 'ボーナス: +5（リスク）\n弱みを認めて誠実さを示します';
      case EmphasisType.opposition:
        return 'ボーナス: +8（安全）\n相手の弱点を指摘します';
    }
  }

  /// 強調のスコア影響（-5 to +8）
  double getScoreModifier({
    required bool isTopicMatch,
    required bool isPlayerWeak,
    required bool isOpponentWeak,
  }) {
    switch (this) {
      case EmphasisType.strength:
        if (isTopicMatch) return 8.0;
        if (isPlayerWeak) return -5.0;
        return 5.0;

      case EmphasisType.weakness:
        if (isPlayerWeak) return 5.0; // 誠実さのボーナス
        return -5.0; // 不自然に見える

      case EmphasisType.opposition:
        if (isOpponentWeak) return 8.0;
        return 0.0;
    }
  }
}
