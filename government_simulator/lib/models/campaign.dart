/// 選挙キャンペーン・システム
/// プレイヤーと対立候補者がキャンペーンを実施して支持率に影響を与える

library;

enum CampaignType {
  tvAds('📺 TV Ads', 50.0, 8.0),
  rallies('🎤 Rallies', 30.0, 6.0),
  socialMedia('📱 Social Media', 20.0, 5.0),
  grassroots('👥 Grassroots', 25.0, 7.0),
  townHalls('🏛️ Town Halls', 35.0, 6.5);

  final String label;
  final double baseCost; // Cost in thousands
  final double baseEffectiveness; // Base effectiveness 0-100

  const CampaignType(this.label, this.baseCost, this.baseEffectiveness);
}

class Campaign {
  final String id;
  final String name;
  final CampaignType type;
  final int startWeek; // Which week campaign starts (1-52)
  final int durationWeeks; // How many weeks campaign runs
  final int startYear; // Year campaign starts
  final double effectiveness; // Actual effectiveness 0-100
  final double maxSupportBoost; // Maximum support boost this campaign can provide
  final DateTime launchedAt;

  Campaign({
    required this.id,
    required this.name,
    required this.type,
    required this.startWeek,
    required this.durationWeeks,
    required this.startYear,
    required this.effectiveness,
    required this.maxSupportBoost,
    required this.launchedAt,
  });

  /// キャンペーンが指定の週に有効か
  bool isActiveInWeek(int year, int week) {
    if (year != startYear) {
      // 年が異なる場合は有効期間外
      if (year < startYear || (year > startYear && startWeek + durationWeeks <= 52)) {
        return false;
      }
      // 複数年に跨る場合のチェック
      if (year == startYear + 1) {
        final weeksIntoNextYear = startWeek + durationWeeks - 52;
        if (week > weeksIntoNextYear) return false;
      }
      return false;
    }

    // 同じ年内の場合
    final endWeek = startWeek + durationWeeks - 1;
    return week >= startWeek && week <= endWeek;
  }

  /// その週のキャンペーン効果を計算（0-maxSupportBoost）
  double getWeeklyImpact(int year, int week) {
    if (!isActiveInWeek(year, week)) return 0.0;

    // キャンペーンの進捗に応じた効果曲線（山型）
    // 初週は効果が低い、中盤がピーク、終盤は低下
    final startWeekInCampaign = week - startWeek + 1;
    final progressRatio = startWeekInCampaign / durationWeeks;

    // 山型曲線：0.1 -> 1.0 -> 0.7
    double curve;
    if (progressRatio < 0.3) {
      // 初期段階：加速
      curve = progressRatio / 0.3 * 0.7 + 0.3;
    } else if (progressRatio < 0.7) {
      // ピーク段階
      curve = 0.7 + (progressRatio - 0.3) / 0.4 * 0.3;
    } else {
      // 終盤：減衰
      curve = 1.0 - ((progressRatio - 0.7) / 0.3) * 0.3;
    }

    return maxSupportBoost * (effectiveness / 100) * curve;
  }

  /// キャンペーンの累積効果を計算
  double calculateCumulativeImpact(int year, List<int> activeWeeks) {
    return activeWeeks.fold(0.0, (sum, week) => sum + getWeeklyImpact(year, week));
  }

  /// キャンペーンが終了しているか
  bool isCompleted(int currentYear, int currentWeek) {
    if (currentYear > startYear) return true;
    if (currentYear == startYear) {
      final endWeek = startWeek + durationWeeks - 1;
      return currentWeek > endWeek;
    }
    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'startWeek': startWeek,
      'durationWeeks': durationWeeks,
      'startYear': startYear,
      'effectiveness': effectiveness,
      'maxSupportBoost': maxSupportBoost,
      'launchedAt': launchedAt.toIso8601String(),
    };
  }

  static Campaign fromMap(Map<String, dynamic> map) {
    return Campaign(
      id: map['id'] as String,
      name: map['name'] as String,
      type: CampaignType.values.byName(map['type'] as String),
      startWeek: map['startWeek'] as int,
      durationWeeks: map['durationWeeks'] as int,
      startYear: map['startYear'] as int,
      effectiveness: (map['effectiveness'] as num).toDouble(),
      maxSupportBoost: (map['maxSupportBoost'] as num).toDouble(),
      launchedAt: DateTime.parse(map['launchedAt'] as String),
    );
  }
}

/// 対立候補者のキャンペーン応答
class CounterCampaign extends Campaign {
  final String rivalId;
  final bool isRetaliatory; // プレイヤーキャンペーンへの応答か

  CounterCampaign({
    required super.id,
    required super.name,
    required super.type,
    required super.startWeek,
    required super.durationWeeks,
    required super.startYear,
    required super.effectiveness,
    required super.maxSupportBoost,
    required super.launchedAt,
    required this.rivalId,
    required this.isRetaliatory,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'rivalId': rivalId,
      'isRetaliatory': isRetaliatory,
    });
    return map;
  }

  static CounterCampaign fromMap(Map<String, dynamic> map) {
    return CounterCampaign(
      id: map['id'] as String,
      name: map['name'] as String,
      type: CampaignType.values.byName(map['type'] as String),
      startWeek: map['startWeek'] as int,
      durationWeeks: map['durationWeeks'] as int,
      startYear: map['startYear'] as int,
      effectiveness: (map['effectiveness'] as num).toDouble(),
      maxSupportBoost: (map['maxSupportBoost'] as num).toDouble(),
      launchedAt: DateTime.parse(map['launchedAt'] as String),
      rivalId: map['rivalId'] as String,
      isRetaliatory: map['isRetaliatory'] as bool,
    );
  }
}

/// キャンペーン管理用クラス
class CampaignManager {
  /// キャンペーンコストテーブル（難易度別）
  static const Map<String, Map<CampaignType, double>> costByDifficulty = {
    'easy': {
      CampaignType.tvAds: 40.0,
      CampaignType.rallies: 24.0,
      CampaignType.socialMedia: 16.0,
      CampaignType.grassroots: 20.0,
      CampaignType.townHalls: 28.0,
    },
    'normal': {
      CampaignType.tvAds: 50.0,
      CampaignType.rallies: 30.0,
      CampaignType.socialMedia: 20.0,
      CampaignType.grassroots: 25.0,
      CampaignType.townHalls: 35.0,
    },
    'hard': {
      CampaignType.tvAds: 60.0,
      CampaignType.rallies: 36.0,
      CampaignType.socialMedia: 24.0,
      CampaignType.grassroots: 30.0,
      CampaignType.townHalls: 42.0,
    },
  };

  /// キャンペーンの初期効果度を計算
  static double calculateInitialEffectiveness({
    required CampaignType type,
    required double budgetSpent, // 実際に支出した額（千単位）
    required String difficulty,
  }) {
    // 基本効果度
    double base = type.baseEffectiveness;

    // 難易度による調整
    double difficultyMult = difficulty == 'easy'
        ? 1.2
        : difficulty == 'hard'
            ? 0.85
            : 1.0;

    // 予算による追加効果度（基本コストを超える分）
    final baseCost = costByDifficulty[difficulty]![type]!;
    double budgetBonus = 0;
    if (budgetSpent > baseCost) {
      // 基本コストを超える分の50%を効果度に追加
      budgetBonus = (budgetSpent - baseCost) * 0.5;
    }

    return (base * difficultyMult + budgetBonus).clamp(0, 100);
  }

  /// 最大支持率上昇を計算
  static double calculateMaxSupportBoost(CampaignType type) {
    switch (type) {
      case CampaignType.tvAds:
        return 12.0; // TV広告は最大12%支持率アップ
      case CampaignType.rallies:
        return 8.0;
      case CampaignType.socialMedia:
        return 6.0;
      case CampaignType.grassroots:
        return 10.0;
      case CampaignType.townHalls:
        return 9.0;
    }
  }
}
