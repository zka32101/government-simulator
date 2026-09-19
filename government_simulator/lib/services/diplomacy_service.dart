/// 外交サービス
/// 国家間の関係、貿易、イベント生成を管理

library;

import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:government_simulator/models/international_relations.dart';

/// 外交サービス
class DiplomacyService {
  static final Random _random = Random();
  static const _uuid = Uuid();
  /// 各国との関係
  final Map<String, NationRelationship> nationRelationships;

  /// アクティブな外交イベント
  final List<DiplomaticEvent> activeEvents;

  /// 過去の外交イベント
  final List<DiplomaticEvent> pastEvents;

  /// 現在の戦争情報
  String? warEnemyId;
  DateTime? warStartDate;

  /// 現在の制裁
  final List<DiplomaticSanction> activeSanctions;

  /// 貿易協定
  final List<TradeAgreement> tradeAgreements;

  DiplomacyService({
    Map<String, NationRelationship>? nationRelationships,
    List<DiplomaticEvent>? activeEvents,
    List<DiplomaticEvent>? pastEvents,
    this.warEnemyId,
    this.warStartDate,
    List<DiplomaticSanction>? activeSanctions,
    List<TradeAgreement>? tradeAgreements,
  })  : nationRelationships = nationRelationships ?? {},
        activeEvents = activeEvents ?? [],
        pastEvents = pastEvents ?? [],
        activeSanctions = activeSanctions ?? [],
        tradeAgreements = tradeAgreements ?? [];

  /// 国家関係を取得
  NationRelationship? getNationRelationship(String nationId) {
    return nationRelationships[nationId];
  }

  /// 関係スコアを更新
  void updateRelationship(String nationId, double change) {
    if (nationRelationships.containsKey(nationId)) {
      nationRelationships[nationId]!.changeStanding(change);
    }
  }

  /// 同盟を結ぶ
  void makeAlliance(String allyNationId) {
    if (nationRelationships.containsKey(allyNationId)) {
      final ally = nationRelationships[allyNationId]!;
      final updated = ally.copyWith(
        isAlly: true,
        allianceChangeDate: DateTime.now(),
        militaryAllianceLevel: (ally.militaryAllianceLevel + 50).clamp(0.0, 100.0),
      );
      nationRelationships[allyNationId] = updated;
    }
  }

  /// 同盟を破棄
  void breakAlliance(String allyNationId) {
    if (nationRelationships.containsKey(allyNationId)) {
      final ally = nationRelationships[allyNationId]!;
      final updated = ally.copyWith(
        isAlly: false,
        allianceChangeDate: DateTime.now(),
        standingScore: ally.standingScore - 30, // 大きなペナルティ
      );
      nationRelationships[allyNationId] = updated;
    }
  }

  /// 宣戦布告
  void declareWar(String enemyNationId) {
    if (nationRelationships.containsKey(enemyNationId)) {
      warEnemyId = enemyNationId;
      warStartDate = DateTime.now();

      final enemy = nationRelationships[enemyNationId]!;
      final updated = enemy.copyWith(
        isAtWar: true,
        standingScore: -100,
      );
      nationRelationships[enemyNationId] = updated;
    }
  }

  /// 平和を提案
  void proposePeace(String enemyNationId) {
    if (nationRelationships.containsKey(enemyNationId)) {
      final enemy = nationRelationships[enemyNationId]!;
      final updated = enemy.copyWith(
        isAtWar: false,
        standingScore: -30, // 敵対的だが戦争ではない
      );
      nationRelationships[enemyNationId] = updated;

      if (warEnemyId == enemyNationId) {
        warEnemyId = null;
        warStartDate = null;
      }
    }
  }

  /// 外交的恩義を追加
  void addDiplomaticFavor(String nationId, double amount) {
    if (nationRelationships.containsKey(nationId)) {
      final nation = nationRelationships[nationId]!;
      final updated = nation.copyWith(
        favorOwedToMe: (nation.favorOwedToMe + amount).clamp(0.0, 100.0),
      );
      nationRelationships[nationId] = updated;
    }
  }

  /// 外交的恩義を使用
  void useDiplomaticFavor(String nationId, double amount) {
    if (nationRelationships.containsKey(nationId)) {
      final nation = nationRelationships[nationId]!;
      final updated = nation.copyWith(
        favorOwedToMe: (nation.favorOwedToMe - amount).clamp(0.0, 100.0),
      );
      nationRelationships[nationId] = updated;
    }
  }

  /// 貿易協定を追加
  void addTradeAgreement(TradeAgreement agreement) {
    tradeAgreements.add(agreement);

    // 相手国の関係を更新
    if (nationRelationships.containsKey(agreement.partnerId)) {
      final partner = nationRelationships[agreement.partnerId]!;
      final updated = partner.copyWith(
        tradeVolume: (partner.tradeVolume + 20).clamp(0.0, 100.0),
        standingScore: partner.standingScore + 10,
      );
      nationRelationships[agreement.partnerId] = updated;
    }
  }

  /// 貿易協定を終了
  void endTradeAgreement(TradeAgreement agreement) {
    tradeAgreements.remove(agreement);

    // 相手国の関係を低下
    if (nationRelationships.containsKey(agreement.partnerId)) {
      final partner = nationRelationships[agreement.partnerId]!;
      final updated = partner.copyWith(
        tradeVolume: (partner.tradeVolume - 15).clamp(0.0, 100.0),
        standingScore: partner.standingScore - 15,
      );
      nationRelationships[agreement.partnerId] = updated;
    }
  }

  /// 制裁を実行
  void imposeSanction(String targetNationId, SanctionLevel level) {
    final sanction = DiplomaticSanction(
      targetNationId: targetNationId,
      level: level,
      startDate: DateTime.now(),
      reason: '国際的非難',
      monthlyEconomicImpact: _getSanctionImpact(level),
      plannedEndDate: DateTime.now().add(Duration(days: 180 * (level.index + 1))),
    );

    activeSanctions.add(sanction);

    // 対象国の関係を大幅に低下
    if (nationRelationships.containsKey(targetNationId)) {
      final target = nationRelationships[targetNationId]!;
      final standingChange = -30 - (10 * level.index);
      final updated = target.copyWith(
        standingScore: (target.standingScore + standingChange).clamp(-100.0, 100.0),
      );
      nationRelationships[targetNationId] = updated;
    }
  }

  /// 制裁を解除
  void removeSanction(String targetNationId) {
    activeSanctions.removeWhere((s) => s.targetNationId == targetNationId);

    // 対象国の関係をやや回復
    if (nationRelationships.containsKey(targetNationId)) {
      final target = nationRelationships[targetNationId]!;
      final updated = target.copyWith(
        standingScore: (target.standingScore + 20).clamp(-100.0, 100.0),
      );
      nationRelationships[targetNationId] = updated;
    }
  }

  /// 制裁の経済影響を計算
  double _getSanctionImpact(SanctionLevel level) {
    return switch (level) {
      SanctionLevel.light => 100000,      // $100K/月
      SanctionLevel.moderate => 500000,   // $500K/月
      SanctionLevel.severe => 2000000,    // $2M/月
      SanctionLevel.total => 5000000,     // $5M/月
    };
  }

  /// 全ての制裁の月間経済影響を計算
  double getTotalSanctionImpact() {
    return activeSanctions.fold<double>(
      0.0,
      (sum, sanction) => sum + sanction.monthlyEconomicImpact,
    );
  }

  /// 全ての貿易協定の年間収入を計算
  double getTotalTradeIncome() {
    return tradeAgreements.fold<double>(
      0.0,
      (sum, agreement) => sum + (agreement.isActive ? agreement.yearlyIncome : 0),
    );
  }

  /// 全ての貿易協定の年間支出を計算
  double getTotalTradeExpense() {
    return tradeAgreements.fold<double>(
      0.0,
      (sum, agreement) => sum + (agreement.isActive ? agreement.yearlyExpense : 0),
    );
  }

  /// 国際的スタンディングを計算
  double calculateInternationalStanding() {
    if (nationRelationships.isEmpty) {
      return 50.0; // デフォルト中立
    }

    // 全ての国との平均関係を計算し、0-100スケールに変換
    final averageStanding = nationRelationships.values.fold<double>(
          0.0,
          (sum, rel) => sum + rel.standingScore,
        ) /
        nationRelationships.length;

    // -100～+100を0～100に変換
    return ((averageStanding + 100) / 2).clamp(0.0, 100.0);
  }

  /// 戦争中か
  bool isAtWar() => warEnemyId != null && warStartDate != null;

  /// 戦争継続週数を計算
  int getWeeksAtWar() {
    if (!isAtWar()) return 0;
    final weeksDiff = DateTime.now().difference(warStartDate!).inDays ~/ 7;
    return weeksDiff;
  }

  /// 外交イベントを追加
  void addDiplomaticEvent(DiplomaticEvent event) {
    activeEvents.add(event);
  }

  /// 外交イベントを解決
  void resolveDiplomaticEvent(DiplomaticEvent event) {
    activeEvents.remove(event);
    pastEvents.add(event.copyWith(
      resolvedDate: DateTime.now(),
    ));
  }

  /// 関係の自然減衰を計算（放置された良好な関係は中立に向かって緩やかに冷める）
  /// 敵対関係や戦争中の関係は減衰しない（対応しない限り改善しない）
  double calculateRelationshipDecay(NationRelationship nation, int weeks) {
    if (nation.isAtWar) return 0.0;
    if (nation.standingScore <= 5) return 0.0;
    return (weeks * 0.5).clamp(0.0, nation.standingScore);
  }

  /// 月間の外交イベントをシミュレーション（確率的に1件まで発生）
  List<DiplomaticEvent> simulateMonthlyDiplomacy({
    required int month,
    required int year,
  }) {
    if (nationRelationships.isEmpty) return const [];

    // 既に未解決のイベントが2件以上ある場合は新規発生を抑制
    if (activeEvents.length >= 2) return const [];

    // 20%の確率で新しい外交イベントが発生
    if (_random.nextDouble() > 0.2) return const [];

    final candidates = nationRelationships.values.toList();
    final nation = candidates[_random.nextInt(candidates.length)];
    final event = _generateEventForNation(nation);

    activeEvents.add(event);
    return [event];
  }

  /// 特定の国との関係に応じた外交イベントを生成
  DiplomaticEvent _generateEventForNation(NationRelationship nation) {
    final status = nation.getStatus();

    final DiplomaticEventType type;
    if (status == RelationshipStatus.allied || status == RelationshipStatus.cordial) {
      type = _random.nextBool()
          ? DiplomaticEventType.tradeNegotiation
          : DiplomaticEventType.culturalExchange;
    } else if (status == RelationshipStatus.hostile || status == RelationshipStatus.enemy) {
      type = _random.nextBool()
          ? DiplomaticEventType.borderIncident
          : DiplomaticEventType.sanctions;
    } else {
      type = _random.nextBool()
          ? DiplomaticEventType.tradeNegotiation
          : DiplomaticEventType.humanitarianAid;
    }

    return DiplomaticEvent(
      id: _uuid.v4(),
      type: type,
      title: _titleForType(type, nation.nationName),
      description: _descriptionForType(type, nation.nationName),
      involvedNations: nation.nationName,
      occurredDate: DateTime.now(),
      availableOptions: _optionsForType(type),
    );
  }

  String _titleForType(DiplomaticEventType type, String nationName) {
    return switch (type) {
      DiplomaticEventType.tradeNegotiation => '$nationNameとの貿易交渉',
      DiplomaticEventType.borderIncident => '$nationNameとの国境紛争',
      DiplomaticEventType.allianceProposal => '$nationNameからの同盟提案',
      DiplomaticEventType.sanctions => '$nationNameへの制裁要求',
      DiplomaticEventType.culturalExchange => '$nationNameとの文化交流',
      DiplomaticEventType.humanitarianAid => '$nationNameへの人道支援要請',
      DiplomaticEventType.warDeclaration => '$nationNameとの軍事的緊張',
      DiplomaticEventType.peaceTreaty => '$nationNameとの和平交渉',
    };
  }

  String _descriptionForType(DiplomaticEventType type, String nationName) {
    return switch (type) {
      DiplomaticEventType.tradeNegotiation =>
        '$nationNameが新たな貿易協定の締結を提案してきた。応じ方によって両国の経済関係が変化する。',
      DiplomaticEventType.borderIncident =>
        '$nationNameとの国境付近で小規模な衝突が発生した。対応を誤れば関係が更に悪化する。',
      DiplomaticEventType.allianceProposal =>
        '$nationNameが軍事同盟の締結を打診してきた。受け入れれば安全保障が強化されるが、他国との関係に影響する。',
      DiplomaticEventType.sanctions =>
        '国際社会が$nationNameへの制裁を求めている。同調するかどうかの判断が迫られている。',
      DiplomaticEventType.culturalExchange =>
        '$nationNameから文化交流プログラムの提案があった。国民感情の改善が期待できる。',
      DiplomaticEventType.humanitarianAid =>
        '$nationNameが人道支援を要請してきた。応じるかどうかで国際的評価が変わる。',
      DiplomaticEventType.warDeclaration =>
        '$nationNameとの緊張が高まっている。対応を誤れば軍事衝突に発展しかねない。',
      DiplomaticEventType.peaceTreaty =>
        '$nationNameが和平交渉を持ちかけてきた。',
    };
  }

  List<DiplomaticOption> _optionsForType(DiplomaticEventType type) {
    return switch (type) {
      DiplomaticEventType.tradeNegotiation => const [
          DiplomaticOption(
            label: '協定に合意する',
            description: '有利な条件で貿易協定を締結する。',
            economicCost: 0,
            relationshipChange: 12,
            approvalImpact: 1.5,
          ),
          DiplomaticOption(
            label: '交渉を打ち切る',
            description: '協定の締結を見送る。',
            economicCost: 0,
            relationshipChange: -6,
            approvalImpact: 0,
          ),
        ],
      DiplomaticEventType.borderIncident => const [
          DiplomaticOption(
            label: '外交的に解決する',
            description: '交渉団を派遣し、平和的な解決を目指す。',
            economicCost: 50000000,
            relationshipChange: 8,
            approvalImpact: -1.0,
          ),
          DiplomaticOption(
            label: '強硬姿勢を取る',
            description: '軍を展開し、断固とした対応を示す。',
            economicCost: 150000000,
            relationshipChange: -20,
            approvalImpact: 3.0,
            sideEffect: '国際的な緊張が高まる可能性がある。',
          ),
        ],
      DiplomaticEventType.allianceProposal => const [
          DiplomaticOption(
            label: '同盟を受け入れる',
            description: '軍事同盟を締結し、安全保障を強化する。',
            economicCost: 0,
            relationshipChange: 30,
            approvalImpact: 2.0,
            sideEffect: '他国からの信頼度に影響する可能性がある。',
          ),
          DiplomaticOption(
            label: '提案を辞退する',
            description: '中立の立場を維持する。',
            economicCost: 0,
            relationshipChange: -10,
            approvalImpact: 0,
          ),
        ],
      DiplomaticEventType.sanctions => const [
          DiplomaticOption(
            label: '制裁に同調する',
            description: '国際社会と足並みを揃える。',
            economicCost: 30000000,
            relationshipChange: -25,
            approvalImpact: 1.0,
          ),
          DiplomaticOption(
            label: '同調しない',
            description: '独自路線を維持し、二国間関係を優先する。',
            economicCost: 0,
            relationshipChange: 10,
            approvalImpact: -2.0,
            sideEffect: '国際的な評価が下がる可能性がある。',
          ),
        ],
      DiplomaticEventType.culturalExchange => const [
          DiplomaticOption(
            label: '交流を推進する',
            description: '文化交流プログラムに予算を投じる。',
            economicCost: 10000000,
            relationshipChange: 15,
            approvalImpact: 1.0,
          ),
          DiplomaticOption(
            label: '見送る',
            description: '予算上の理由で見送る。',
            economicCost: 0,
            relationshipChange: -3,
            approvalImpact: 0,
          ),
        ],
      DiplomaticEventType.humanitarianAid => const [
          DiplomaticOption(
            label: '支援を送る',
            description: '人道支援物資と資金を提供する。',
            economicCost: 80000000,
            relationshipChange: 20,
            approvalImpact: 2.0,
          ),
          DiplomaticOption(
            label: '要請を断る',
            description: '国内事情を優先し、要請を断る。',
            economicCost: 0,
            relationshipChange: -12,
            approvalImpact: -1.0,
          ),
        ],
      DiplomaticEventType.warDeclaration => const [
          DiplomaticOption(
            label: '緊張緩和に努める',
            description: '外交チャネルを通じて事態の沈静化を図る。',
            economicCost: 20000000,
            relationshipChange: 10,
            approvalImpact: -1.0,
          ),
          DiplomaticOption(
            label: '軍事的圧力で応じる',
            description: '国境部隊を増強し、強い姿勢を示す。',
            economicCost: 200000000,
            relationshipChange: -30,
            approvalImpact: 4.0,
            sideEffect: '全面的な軍事衝突に発展するリスクがある。',
          ),
        ],
      DiplomaticEventType.peaceTreaty => const [
          DiplomaticOption(
            label: '和平を受け入れる',
            description: '和平条約に署名し、敵対関係を終わらせる。',
            economicCost: 0,
            relationshipChange: 40,
            approvalImpact: 2.0,
          ),
          DiplomaticOption(
            label: '交渉を拒否する',
            description: '敵対関係を継続する。',
            economicCost: 0,
            relationshipChange: -15,
            approvalImpact: -1.0,
          ),
        ],
    };
  }

  /// 外交イベントへのプレイヤーの選択を処理し、対象国との関係を更新する
  NationRelationship respondToDiplomaticEvent(
    String targetNationId,
    DiplomaticOption choice,
  ) {
    final nation = nationRelationships[targetNationId] ??
        NationRelationship(nationId: targetNationId, nationName: targetNationId);
    final updated = nation.copyWith(
      standingScore: (nation.standingScore + choice.relationshipChange).clamp(-100.0, 100.0),
      lastInteraction: DateTime.now(),
    );
    nationRelationships[targetNationId] = updated;
    return updated;
  }

  /// コピー・変更用メソッド
  DiplomacyService copyWith({
    Map<String, NationRelationship>? nationRelationships,
    List<DiplomaticEvent>? activeEvents,
    List<DiplomaticEvent>? pastEvents,
    String? warEnemyId,
    DateTime? warStartDate,
    List<DiplomaticSanction>? activeSanctions,
    List<TradeAgreement>? tradeAgreements,
  }) {
    return DiplomacyService(
      nationRelationships: nationRelationships ?? this.nationRelationships,
      activeEvents: activeEvents ?? this.activeEvents,
      pastEvents: pastEvents ?? this.pastEvents,
      warEnemyId: warEnemyId ?? this.warEnemyId,
      warStartDate: warStartDate ?? this.warStartDate,
      activeSanctions: activeSanctions ?? this.activeSanctions,
      tradeAgreements: tradeAgreements ?? this.tradeAgreements,
    );
  }

  /// 辞書に変換
  Map<String, dynamic> toMap() {
    return {
      'nationRelationships': nationRelationships
          .map((key, value) => MapEntry(key, value.toMap())),
      'activeEvents': activeEvents.map((e) => e.toMap()).toList(),
      'pastEvents': pastEvents.map((e) => e.toMap()).toList(),
      'warEnemyId': warEnemyId,
      'warStartDate': warStartDate?.toIso8601String(),
      'activeSanctions': activeSanctions.map((s) => s.toMap()).toList(),
      'tradeAgreements': tradeAgreements.map((t) => t.toMap()).toList(),
    };
  }

  /// 辞書から生成
  factory DiplomacyService.fromMap(Map<String, dynamic> map) {
    final nrMap = (map['nationRelationships'] as Map<String, dynamic>?)
            ?.map((key, value) =>
                MapEntry(key, NationRelationship.fromMap(value as Map<String, dynamic>))) ??
        {};

    final activeEventsList = (map['activeEvents'] as List<dynamic>?)
            ?.map((e) => DiplomaticEvent.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    final pastEventsList = (map['pastEvents'] as List<dynamic>?)
            ?.map((e) => DiplomaticEvent.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    final sanctionsList = (map['activeSanctions'] as List<dynamic>?)
            ?.map((s) => DiplomaticSanction.fromMap(s as Map<String, dynamic>))
            .toList() ??
        [];

    final tradeList = (map['tradeAgreements'] as List<dynamic>?)
            ?.map((t) => TradeAgreement.fromMap(t as Map<String, dynamic>))
            .toList() ??
        [];

    return DiplomacyService(
      nationRelationships: nrMap,
      activeEvents: activeEventsList,
      pastEvents: pastEventsList,
      warEnemyId: map['warEnemyId'] as String?,
      warStartDate: map['warStartDate'] != null
          ? DateTime.tryParse(map['warStartDate'] as String)
          : null,
      activeSanctions: sanctionsList,
      tradeAgreements: tradeList,
    );
  }
}
