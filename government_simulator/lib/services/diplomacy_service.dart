/// 外交サービス
/// 国家間の関係、貿易、イベント生成を管理

import 'package:government_simulator/models/international_relations.dart';
import 'package:government_simulator/models/game_session.dart';

/// 外交サービス
class DiplomacyService {
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
