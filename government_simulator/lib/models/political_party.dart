/// 政治政党：プレイヤーと関連する政党データ
library;

class PoliticalParty {
  final String id;
  final String name;
  final String emoji;
  final String color; // HEX color code
  final String ideology; // 政党のイデオロジー説明
  final double economicPolicy; // -100（左）から +100（右）
  final double socialPolicy; // -100（福祉重視）から +100（市場重視）
  final double militaryPolicy; // -100（平和重視）から +100（防衛重視）

  double support; // 党の支持率 0-100%
  double loyalty; // プレイヤーへの党の忠誠度 0-100%
  int seats; // 議会内の議席数
  List<String> allies; // 同盟政党のID

  PoliticalParty({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.ideology,
    required this.economicPolicy,
    required this.socialPolicy,
    required this.militaryPolicy,
    this.support = 30.0,
    this.loyalty = 80.0,
    this.seats = 150,
    this.allies = const [],
  });

  /// 政党の平均政策位置
  double get averagePolicy =>
      (economicPolicy + socialPolicy + militaryPolicy) / 3;

  /// プレイヤー政策との相性度（政策の距離が近いほど忠誠度に好影響）
  double calculatePolicyAffinity(
    double playerEconomic,
    double playerSocial,
    double playerMilitary,
  ) {
    final economicDiff = (economicPolicy - playerEconomic).abs();
    final socialDiff = (socialPolicy - playerSocial).abs();
    final militaryDiff = (militaryPolicy - playerMilitary).abs();
    final totalDiff = (economicDiff + socialDiff + militaryDiff) / 6;
    return 100 - totalDiff; // 距離が近いほど高い値
  }

  /// 党の忠誠度を更新
  /// - プレイヤーの成績が良いと忠誠度が上がる
  /// - 政策の不一致があると忠誠度が下がる
  /// - 他党への投票が多いと忠誠度が下がる
  void updateLoyalty(
    double playerSatisfaction,
    double policyAffinity,
    double govermentStability,
    double competitorSupport,
  ) {
    double loyaltyChange = 0;

    // 満足度が高いほど忠誠度アップ
    loyaltyChange += (playerSatisfaction - 50) / 20; // ±2.5

    // 政策相性が高いほど忠誠度アップ
    loyaltyChange += (policyAffinity - 50) / 20; // ±2.5

    // 安定度が高いほど忠誠度アップ
    loyaltyChange += (govermentStability - 50) / 30; // ±1.67

    // ライバル候補への投票が増えると忠誠度ダウン
    loyaltyChange -= competitorSupport / 50; // ±2

    loyalty = (loyalty + loyaltyChange).clamp(0, 100);
  }

  /// 党の支持率を更新（世論の変化を反映）
  void updateSupport(
    double economicTrend, // 経済成長率の変化
    double satisfactionChange, // 国民満足度の変化
    double eventImpact, // イベントによる影響 -20～+20
  ) {
    double supportChange = 0;

    // 経済が好調なら支持率アップ
    supportChange += economicTrend / 10;

    // 満足度上昇で支持率アップ
    supportChange += satisfactionChange / 15;

    // イベント影響を直接反映
    supportChange += eventImpact;

    support = (support + supportChange).clamp(0, 100);
  }

  /// 政党が議会内で安定多数を保有しているか（過半数以上）
  bool hasParliamentaryMajority(int totalSeats) {
    return seats > totalSeats ~/ 2;
  }

  /// 同盟政党を含む議席数
  int getTotalAlliedSeats(Map<String, PoliticalParty> partyMap) {
    int total = seats;
    for (String allyId in allies) {
      if (partyMap.containsKey(allyId)) {
        total += partyMap[allyId]!.seats;
      }
    }
    return total;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'color': color,
      'ideology': ideology,
      'economicPolicy': economicPolicy,
      'socialPolicy': socialPolicy,
      'militaryPolicy': militaryPolicy,
      'support': support,
      'loyalty': loyalty,
      'seats': seats,
      'allies': allies,
    };
  }

  static PoliticalParty fromMap(Map<String, dynamic> map) {
    return PoliticalParty(
      id: map['id'] as String,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      color: map['color'] as String,
      ideology: map['ideology'] as String,
      economicPolicy: (map['economicPolicy'] as num).toDouble(),
      socialPolicy: (map['socialPolicy'] as num).toDouble(),
      militaryPolicy: (map['militaryPolicy'] as num).toDouble(),
      support: (map['support'] as num?)?.toDouble() ?? 30.0,
      loyalty: (map['loyalty'] as num?)?.toDouble() ?? 80.0,
      seats: map['seats'] as int? ?? 150,
      allies: List<String>.from(map['allies'] as List? ?? []),
    );
  }
}

/// デフォルトの政治政党セット
class PoliticalParties {
  static Map<String, PoliticalParty> createDefault() {
    return {
      'party_ruling': PoliticalParty(
        id: 'party_ruling',
        name: '与党（あなたの所属政党）',
        emoji: '🟢',
        color: '#4CAF50',
        ideology: 'プレイヤーが所属する与党。内閣を支える主要政党。',
        economicPolicy: 30,
        socialPolicy: 20,
        militaryPolicy: 30,
        support: 35.0,
        loyalty: 90.0,
        seats: 220,
        allies: ['party_coalition'],
      ),
      'party_coalition': PoliticalParty(
        id: 'party_coalition',
        name: '連立政党',
        emoji: '🟡',
        color: '#FFB300',
        ideology: '与党と連立を組む中堅政党。政権運営を支援。',
        economicPolicy: 20,
        socialPolicy: 10,
        militaryPolicy: 40,
        support: 15.0,
        loyalty: 70.0,
        seats: 80,
        allies: ['party_ruling'],
      ),
      'party_opposition_left': PoliticalParty(
        id: 'party_opposition_left',
        name: '野党（左派）',
        emoji: '🔴',
        color: '#E53935',
        ideology: '社会福祉と平和を重視する左派系野党。',
        economicPolicy: -60,
        socialPolicy: -50,
        militaryPolicy: -70,
        support: 25.0,
        loyalty: 0.0,
        seats: 130,
        allies: ['party_green'],
      ),
      'party_opposition_right': PoliticalParty(
        id: 'party_opposition_right',
        name: '野党（右派）',
        emoji: '🔵',
        color: '#2196F3',
        ideology: '市場経済と国防強化を重視する右派系野党。',
        economicPolicy: 70,
        socialPolicy: 60,
        militaryPolicy: 70,
        support: 20.0,
        loyalty: 0.0,
        seats: 100,
        allies: [],
      ),
      'party_green': PoliticalParty(
        id: 'party_green',
        name: '環境党',
        emoji: '🌿',
        color: '#4CAF50',
        ideology: '環境保全と持続可能性を重視する小政党。',
        economicPolicy: -40,
        socialPolicy: -30,
        militaryPolicy: -50,
        support: 5.0,
        loyalty: 0.0,
        seats: 20,
        allies: ['party_opposition_left'],
      ),
    };
  }

  /// 全政党の議席数の合計
  static int getTotalSeats(Map<String, PoliticalParty> parties) {
    return parties.values.fold(0, (sum, party) => sum + party.seats);
  }

  /// 与党陣営の総議席数（与党+連立政党）
  static int getRulingCoalitionSeats(Map<String, PoliticalParty> parties) {
    int total = 0;
    if (parties.containsKey('party_ruling')) {
      total += parties['party_ruling']!.getTotalAlliedSeats(parties);
    }
    return total;
  }

  /// 与党が議会内で安定多数を保有しているか
  static bool hasRulingMajority(Map<String, PoliticalParty> parties) {
    int totalSeats = getTotalSeats(parties);
    int rulingSeats = getRulingCoalitionSeats(parties);
    return rulingSeats > totalSeats ~/ 2;
  }
}
