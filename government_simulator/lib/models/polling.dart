/// 世論調査：選挙時の予測支持率を追跡
class Poll {
  final String id;
  final int year;
  final int week; // 年間何週目か（1-52）
  final double playerSupport; // プレイヤーの支持率
  final double marginOfError; // 誤差範囲（±）
  final int sampleSize; // サンプル数
  final DateTime conductedAt;

  // ライバル候補者の支持率（複数候補の場合）
  final Map<String, double> rivalSupport;

  Poll({
    required this.id,
    required this.year,
    required this.week,
    required this.playerSupport,
    required this.marginOfError,
    required this.sampleSize,
    required this.conductedAt,
    this.rivalSupport = const {},
  });

  /// 調査の信頼度スコア（0-100）
  /// サンプル数が大きいほど信頼度が高い
  double get confidenceScore {
    // サンプル数が1000以上で信頼度100
    // 300未満で信頼度50
    return (sampleSize / 1000 * 100).clamp(0, 100);
  }

  /// 誤差範囲を考慮した最大支持率
  double get maxEstimate => (playerSupport + marginOfError).clamp(0, 100);

  /// 誤差範囲を考慮した最小支持率
  double get minEstimate => (playerSupport - marginOfError).clamp(0, 100);

  /// 勝利の可能性（%）
  /// 50%以上の支持率がどれくらいの確率か
  double get winProbability {
    // 正規分布を仮定して計算（簡易版）
    if (playerSupport >= 50) {
      // 支持率50%以上の場合、誤差範囲内で50%未満になる確率を計算
      final zScore = (playerSupport - 50) / marginOfError;
      // zスコアが大きいほど勝つ確率が高い
      return (50 + (zScore / 4 * 50)).clamp(0, 100);
    } else {
      // 支持率50%未満の場合
      final zScore = (50 - playerSupport) / marginOfError;
      return (50 - (zScore / 4 * 50)).clamp(0, 100);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'week': week,
      'playerSupport': playerSupport,
      'marginOfError': marginOfError,
      'sampleSize': sampleSize,
      'conductedAt': conductedAt.toIso8601String(),
      'rivalSupport': rivalSupport,
    };
  }

  static Poll fromMap(Map<String, dynamic> map) {
    return Poll(
      id: map['id'] as String,
      year: map['year'] as int,
      week: map['week'] as int,
      playerSupport: (map['playerSupport'] as num).toDouble(),
      marginOfError: (map['marginOfError'] as num).toDouble(),
      sampleSize: map['sampleSize'] as int,
      conductedAt: DateTime.parse(map['conductedAt'] as String),
      rivalSupport: Map<String, double>.from(
        (map['rivalSupport'] as Map?)?.map((k, v) => MapEntry(k as String, (v as num).toDouble())) ?? {},
      ),
    );
  }
}

/// 世論調査トレンド分析
class PollingTrend {
  final List<Poll> polls;

  PollingTrend(this.polls);

  /// 最新の世論調査を取得
  Poll? get latest => polls.isNotEmpty ? polls.last : null;

  /// 最初の世論調査を取得
  Poll? get earliest => polls.isNotEmpty ? polls.first : null;

  /// 支持率のトレンド（上昇/下降/変化なし）
  TrendDirection get direction {
    if (polls.length < 2) return TrendDirection.stable;
    final recent = polls.sublist((polls.length ~/ 2).clamp(1, polls.length));
    if (recent.length < 2) return TrendDirection.stable;

    final change = recent.last.playerSupport - recent.first.playerSupport;
    if (change > 2) return TrendDirection.rising;
    if (change < -2) return TrendDirection.falling;
    return TrendDirection.stable;
  }

  /// 平均支持率
  double get averageSupport {
    if (polls.isEmpty) return 0;
    return polls.map((p) => p.playerSupport).reduce((a, b) => a + b) / polls.length;
  }

  /// 最高支持率
  double get maxSupport => polls.isEmpty ? 0 : polls.map((p) => p.playerSupport).reduce((a, b) => a > b ? a : b);

  /// 最低支持率
  double get minSupport => polls.isEmpty ? 0 : polls.map((p) => p.playerSupport).reduce((a, b) => a < b ? a : b);

  /// 支持率の変動幅
  double get volatility => maxSupport - minSupport;
}

/// トレンドの方向
enum TrendDirection {
  rising, // 上昇傾向
  falling, // 下降傾向
  stable, // 横ばい
}

extension TrendDirectionExt on TrendDirection {
  String get emoji {
    switch (this) {
      case TrendDirection.rising:
        return '📈';
      case TrendDirection.falling:
        return '📉';
      case TrendDirection.stable:
        return '➡️';
    }
  }

  String get label {
    switch (this) {
      case TrendDirection.rising:
        return '上昇傾向';
      case TrendDirection.falling:
        return '下降傾向';
      case TrendDirection.stable:
        return '横ばい';
    }
  }
}
