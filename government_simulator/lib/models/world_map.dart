import 'package:government_simulator/models/country_status.dart';

/// 外交関係の分類。
enum RelationType { ally, neutral, rival }

extension RelationTypeExt on RelationType {
  String get label {
    switch (this) {
      case RelationType.ally:
        return '同盟国';
      case RelationType.neutral:
        return '中立';
      case RelationType.rival:
        return '敵対国';
    }
  }

  String get emoji {
    switch (this) {
      case RelationType.ally:
        return '🤝';
      case RelationType.neutral:
        return '➖';
      case RelationType.rival:
        return '⚔️';
    }
  }
}

/// 近隣の架空諸国。位置は抽象的な世界地図キャンバス上の相対座標(0.0-1.0)。
class NeighborNation {
  final String id;
  final String name;
  final String emoji;
  final double x;
  final double y;
  final double bias; // 性格バイアス（-30〜+30, 高いほど友好的になりやすい）
  final String description;

  const NeighborNation({
    required this.id,
    required this.name,
    required this.emoji,
    required this.x,
    required this.y,
    required this.bias,
    required this.description,
  });

  /// AI生成紋章画像のアセットパス
  String get imagePath => 'assets/images/neighbors/neighbor_$id.png';

  static const List<NeighborNation> all = [
    NeighborNation(
      id: 'northern_power',
      name: '北方大国',
      emoji: '🐻',
      x: 0.5,
      y: 0.12,
      bias: -15,
      description: '強大な軍事力を持つ北の大国。力の均衡に敏感で、'
          'こちらの国力増強を警戒しがち。',
    ),
    NeighborNation(
      id: 'eastern_ally',
      name: '東方連邦',
      emoji: '🌸',
      x: 0.85,
      y: 0.45,
      bias: 20,
      description: '長年の友好関係にある東の隣国。安定した統治を歓迎し、'
          '協力関係を築きやすい。',
    ),
    NeighborNation(
      id: 'southern_trade',
      name: '南方通商圏',
      emoji: '🌴',
      x: 0.55,
      y: 0.85,
      bias: 10,
      description: '貿易を重視する南の国々。経済的な繁栄には友好的だが、'
          '不安定な統治には距離を置く。',
    ),
    NeighborNation(
      id: 'western_confederation',
      name: '西方諸国連合',
      emoji: '🦅',
      x: 0.12,
      y: 0.5,
      bias: 0,
      description: '複数の小国からなる連合体。是々非々の現実的な外交姿勢を取る。',
    ),
    NeighborNation(
      id: 'island_nation',
      name: '孤島共和国',
      emoji: '🏝️',
      x: 0.2,
      y: 0.85,
      bias: 8,
      description: '海を隔てた小さな島国。直接の脅威になりにくく、'
          '穏やかな関係を保ちやすい。',
    ),
  ];

  /// 現在の国家ステータスから、この隣国との関係値（0-100）を算出する。
  double relationScore(CountryStatus status) {
    final score = 50 +
        bias -
        (status.nationalPower - 50) * 0.4 +
        (status.stability - 50) * 0.2;
    return score.clamp(0, 100).toDouble();
  }

  RelationType relationType(CountryStatus status) {
    final score = relationScore(status);
    if (score >= 65) return RelationType.ally;
    if (score <= 35) return RelationType.rival;
    return RelationType.neutral;
  }
}
