/// ライバル候補者：選挙に対抗する野党候補者
library;

class RivalCandidate {
  final String id;
  final String name;
  final String emoji;
  final String affiliation; // 政党名
  final double economicPolicy; // -100（左）から +100（右）
  final double socialPolicy; // -100（福祉重視）から +100（市場重視）
  final double militaryPolicy; // -100（平和重視）から +100（防衛重視）
  final String description;

  double popularity; // 0-100%
  double momentum; // 支持率の変動傾向

  RivalCandidate({
    required this.id,
    required this.name,
    required this.emoji,
    required this.affiliation,
    required this.economicPolicy,
    required this.socialPolicy,
    required this.militaryPolicy,
    required this.description,
    this.popularity = 25.0,
    this.momentum = 0.0,
  });

  /// 候補者の平均政策位置（政治的スペクトラム上の位置）
  double get averagePolicy =>
      (economicPolicy + socialPolicy + militaryPolicy) / 3;

  /// 対プレイヤー相性スコア（プレイヤーの政策との距離）
  /// 値が高いほどプレイヤーの政策と異なる（対抗馬として強い）
  double calculateAffinity(double playerEconomic, double playerSocial,
      double playerMilitary) {
    final economicDiff = (economicPolicy - playerEconomic).abs();
    final socialDiff = (socialPolicy - playerSocial).abs();
    final militaryDiff = (militaryPolicy - playerMilitary).abs();
    return (economicDiff + socialDiff + militaryDiff) / 6; // 0-100に正規化
  }

  /// 選挙時の支持率を計算（公開支持率は実際と異なる可能性）
  double calculatePublicSupport(
    double actualPopularity,
    double campaignIntensity, // 0-1
    double mediaFavor, // -1(負) から +1(正)
  ) {
    double adjusted = actualPopularity;
    adjusted += campaignIntensity * 15; // キャンペーンで最大+15ポイント
    adjusted += mediaFavor * 10; // メディア好感度で±10ポイント
    return (adjusted).clamp(0, 100);
  }

  /// 期間ごとの支持率更新
  void updatePopularity(
    double playerSatisfaction,
    double playerStability,
    bool campaignActive,
  ) {
    // プレイヤーの満足度が高いほど対抗馬は不利
    double satisfactionEffect = (100 - playerSatisfaction) / 100 * 5;

    // 安定度が低いと対抗馬が有利
    double stabilityEffect = (100 - playerStability) / 100 * 3;

    // キャンペーン中は加速
    double campaignBoost = campaignActive ? 2.0 : -0.5;

    momentum = satisfactionEffect + stabilityEffect + campaignBoost;
    popularity = (popularity + momentum).clamp(0, 100);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'affiliation': affiliation,
      'economicPolicy': economicPolicy,
      'socialPolicy': socialPolicy,
      'militaryPolicy': militaryPolicy,
      'description': description,
      'popularity': popularity,
      'momentum': momentum,
    };
  }

  static RivalCandidate fromMap(Map<String, dynamic> map) {
    return RivalCandidate(
      id: map['id'] as String,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      affiliation: map['affiliation'] as String,
      economicPolicy: (map['economicPolicy'] as num).toDouble(),
      socialPolicy: (map['socialPolicy'] as num).toDouble(),
      militaryPolicy: (map['militaryPolicy'] as num).toDouble(),
      description: map['description'] as String,
      popularity: (map['popularity'] as num?)?.toDouble() ?? 25.0,
      momentum: (map['momentum'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// デフォルトのライバル候補者セット
class RivalCandidates {
  static List<RivalCandidate> createDefault() {
    return [
      RivalCandidate(
        id: 'candidate_left',
        name: '佐藤太郎',
        emoji: '🔴',
        affiliation: '民主進歩党',
        economicPolicy: -60,
        socialPolicy: -50,
        militaryPolicy: -70,
        description: '社会福祉と平和を重視する左派系政治家。大企業への規制強化と軍事費削減を主張。',
        popularity: 20.0,
      ),
      RivalCandidate(
        id: 'candidate_right',
        name: '山田花子',
        emoji: '🔵',
        affiliation: '国民連合党',
        economicPolicy: 70,
        socialPolicy: 60,
        militaryPolicy: 70,
        description: '市場経済と国防強化を重視する右派系政治家。民間企業への規制緩和と防衛費増額を主張。',
        popularity: 25.0,
      ),
      RivalCandidate(
        id: 'candidate_centrist',
        name: '中野健二',
        emoji: '🟡',
        affiliation: '改革新党',
        economicPolicy: 10,
        socialPolicy: -20,
        militaryPolicy: 20,
        description: 'バランスの取れた実用的政策を掲げる中道系政治家。既得権の打破と効率的な行政改革を主張。',
        popularity: 30.0,
      ),
    ];
  }
}
