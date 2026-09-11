/// スキャンダルシステム
/// ランダムな負のイベントがキャンペーンと支持率に影響を与える

import 'package:uuid/uuid.dart';

enum ScandalType {
  political('政治スキャンダル', 10.0),
  personal('個人スキャンダル', 8.0),
  economic('経済スキャンダル', 12.0),
  health('健康スキャンダル', 6.0);

  final String label;
  final double baseImpact; // 基本支持率低下%

  const ScandalType(this.label, this.baseImpact);
}

enum ScandalResponse {
  deny('否定・話題転換'),
  apologize('公開謝罪'),
  counterattack('反論'),
  ignore('無視・前進');

  final String label;

  const ScandalResponse(this.label);
}

class Scandal {
  final String id;
  final String title;
  final ScandalType type;
  final DateTime discoveredAt;
  final int startWeek;
  final int startYear;
  final double baseImpact; // 基本支持率低下 5-15%
  final double initialIntensity; // 初期強度 100%
  final String? involvedPersonId; // null=プレイヤー
  final ScandalResponse? playerResponse;
  final DateTime? respondedAt;

  Scandal({
    required this.id,
    required this.title,
    required this.type,
    required this.discoveredAt,
    required this.startWeek,
    required this.startYear,
    required this.baseImpact,
    required this.initialIntensity,
    this.involvedPersonId,
    this.playerResponse,
    this.respondedAt,
  });

  /// スキャンダルが指定週に有効か
  bool isActive(int year, int week) {
    if (year < startYear) return false;
    if (year > startYear) {
      // 複数年に跨る場合：最大6週間続く
      if (year == startYear + 1) {
        final weeksIntoNextYear = startWeek + 6 - 52;
        return week <= weeksIntoNextYear;
      }
      return false;
    }

    // 同じ年内：最大6週間
    final endWeek = startWeek + 5;
    return week >= startWeek && week <= endWeek;
  }

  /// 指定週のスキャンダル強度を取得（0-100）
  double getIntensityAtWeek(int year, int week) {
    if (!isActive(year, week)) return 0.0;

    // スキャンダルの進捗週数を計算
    final weekOffset = (week >= startWeek)
        ? (week - startWeek)
        : (52 - startWeek + week);

    // 強度の減衰曲線
    // 0-1週: 100%（ピーク）
    // 2-3週: 75%
    // 4-5週: 50%
    // 6週: 25%
    // 7週以降: 0%

    if (weekOffset <= 1) {
      return 100.0;
    } else if (weekOffset <= 3) {
      return 75.0;
    } else if (weekOffset <= 5) {
      return 50.0;
    } else if (weekOffset <= 6) {
      return 25.0;
    }
    return 0.0;
  }

  /// 指定週のスキャンダルの週次影響を取得
  double getWeeklyImpact(int year, int week) {
    if (!isActive(year, week)) return 0.0;

    final intensity = getIntensityAtWeek(year, week);
    double impact = baseImpact * (intensity / 100.0);

    // プレイヤーの対応による調整
    if (playerResponse != null && respondedAt != null) {
      switch (playerResponse!) {
        case ScandalResponse.deny:
          // 否定：強度を20%削減
          impact *= 0.8;
          break;
        case ScandalResponse.apologize:
          // 謝罪：強度を50%削減（ただし信頼度長期減少）
          impact *= 0.5;
          break;
        case ScandalResponse.counterattack:
          // 反論：強度を40%削減するが、反発のリスクあり
          impact *= 0.6;
          break;
        case ScandalResponse.ignore:
          // 無視：影響なし（自然に減衰）
          break;
      }
    }

    return impact.clamp(0.0, baseImpact);
  }

  /// スキャンダルが解決済みか（6週間以上経過）
  bool isResolved(int currentYear, int currentWeek) {
    if (currentYear > startYear) return true;
    if (currentYear == startYear) {
      final endWeek = startWeek + 5;
      return currentWeek > endWeek;
    }
    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'discoveredAt': discoveredAt.toIso8601String(),
      'startWeek': startWeek,
      'startYear': startYear,
      'baseImpact': baseImpact,
      'initialIntensity': initialIntensity,
      'involvedPersonId': involvedPersonId,
      'playerResponse': playerResponse?.name,
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  static Scandal fromMap(Map<String, dynamic> map) {
    return Scandal(
      id: map['id'] as String,
      title: map['title'] as String,
      type: ScandalType.values.byName(map['type'] as String),
      discoveredAt: DateTime.parse(map['discoveredAt'] as String),
      startWeek: map['startWeek'] as int,
      startYear: map['startYear'] as int,
      baseImpact: (map['baseImpact'] as num).toDouble(),
      initialIntensity: (map['initialIntensity'] as num).toDouble(),
      involvedPersonId: map['involvedPersonId'] as String?,
      playerResponse: map['playerResponse'] != null
          ? ScandalResponse.values.byName(map['playerResponse'] as String)
          : null,
      respondedAt: map['respondedAt'] != null
          ? DateTime.parse(map['respondedAt'] as String)
          : null,
    );
  }
}

/// スキャンダル生成と管理用クラス
class ScandalManager {
  static const List<String> playerScandalTitles = [
    '政策判断の誤りが発覚',
    '汚職疑惑が浮上',
    '元側近による告発',
    '不正経理の疑い',
    '政治資金の不透明な流れ',
    'ロビイングスキャンダル',
    '利益相反疑惑',
    '情報漏洩事件',
  ];

  static const List<String> personalScandalTitles = [
    '私生活スキャンダル報道',
    '家族メンバーの問題発覚',
    '過去の発言が炎上',
    'SNSでの不適切投稿',
    'プライベート画像流出',
    '交友関係の問題',
    '学歴詐称疑惑',
    '前科の発覚',
  ];

  static const List<String> economicScandalTitles = [
    '資産隠蔽疑惑',
    '脱税容疑',
    '不動産取引の問題',
    'ペーパーカンパニー関連',
    '企業献金の不正',
    '予算流用疑惑',
    '契約便宜供与疑惑',
    'インサイダー取引疑い',
  ];

  static const List<String> healthScandalTitles = [
    '健康問題が報道される',
    '通院記録の漏洩',
    '薬物使用疑惑',
    '精神疾患の推測報道',
    '手術履歴の公開',
    '認知機能の懸念',
    '入院報道',
    '医療隠蔽の指摘',
  ];

  /// スキャンダルタイトルを取得
  static String getScandalTitle(ScandalType type) {
    final titles = switch (type) {
      ScandalType.political => playerScandalTitles,
      ScandalType.personal => personalScandalTitles,
      ScandalType.economic => economicScandalTitles,
      ScandalType.health => healthScandalTitles,
    };

    final random = DateTime.now().microsecond % titles.length;
    return titles[random];
  }

  /// スキャンダル発生確率を計算
  static double calculateScandalProbability({
    required double playerSupport,
    required int activecampaignCount,
    required String difficulty,
    required int playerReputation,
  }) {
    // 基本確率：2-5%
    double baseProbability = 0.03;

    // キャンペーン激化で確率上昇（激しいほど注視される）
    baseProbability += activecampaignCount * 0.01;

    // 高い支持率は高い注視につながる（50%以上で加算）
    if (playerSupport > 50) {
      baseProbability += (playerSupport - 50) * 0.002;
    }

    // 難易度による調整
    final difficultyMult = difficulty == 'hard'
        ? 2.0
        : difficulty == 'easy'
            ? 0.5
            : 1.0;
    baseProbability *= difficultyMult;

    // 評判が良いほどスキャンダルが発生しにくい
    baseProbability *= (1.0 - (playerReputation / 100) * 0.3);

    return baseProbability.clamp(0.0, 1.0);
  }

  /// スキャンダルの媒体報道乗数を計算
  /// 評判とメディア好意度に基づく
  static double calculateMediaCoverageMultiplier({
    required int playerReputation,
    required int mediaFavoring,
  }) {
    // ベース: 1.0x
    double multiplier = 1.0;

    // 評判が低いほど、より大きく報道される
    multiplier *= (1.0 + (50 - playerReputation) * 0.01);

    // メディア好意度による調整 (-50 to +50)
    multiplier *= (1.0 - (mediaFavoring / 100));

    return multiplier.clamp(0.5, 1.5);
  }
}
