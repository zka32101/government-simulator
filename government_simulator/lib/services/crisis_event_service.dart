/// 危機イベント生成サービス
/// 承認度とゲーム状態に基づいて危機イベントを生成・管理

import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:government_simulator/models/crisis.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/scenario.dart';
import 'package:government_simulator/services/approval_service.dart';

/// 危機イベント表示情報
class CrisisEventDisplay {
  final String title;
  final String description;
  final List<CrisisOption> options;
  final double timeUrgencyFactor; // 0.0 (十分な時間) ～ 1.0 (緊急)

  const CrisisEventDisplay({
    required this.title,
    required this.description,
    required this.options,
    this.timeUrgencyFactor = 0.5,
  });
}

/// 危機対応選択肢
class CrisisOption {
  final CrisisResponse response;
  final String label;
  final String description;
  final double costEstimate; // 推定コスト（百万単位）
  final double approvalRecovery; // 承認度回復
  final String? sideEffect; // 副作用の説明

  const CrisisOption({
    required this.response,
    required this.label,
    required this.description,
    required this.costEstimate,
    required this.approvalRecovery,
    this.sideEffect,
  });
}

/// 危機イベント生成・管理サービス
class CrisisEventService {
  final _uuid = const Uuid();
  final _random = Random();

  /// ゲーム状態に基づいて危機を生成
  /// シナリオがある場合、そのシナリオ固有の危機タイプをフィルタリング
  Crisis? generateCrisis(
    GameSession session,
    ApprovalService approvalService, {
    GameScenario? scenario,
  }) {
    final approval = approvalService.currentApproval;
    final riskLevel = approvalService.getRiskLevel();

    // 危機リスクレベルに応じて危機タイプを決定
    var probableCrises = approvalService.getProbableCrises();

    // シナリオがある場合、そのシナリオ固有の危機タイプでフィルタリング
    if (scenario != null && scenario.uniqueCrises.isNotEmpty) {
      probableCrises = probableCrises
          .where((crisis) => scenario.uniqueCrises.contains(crisis))
          .toList();
    }

    if (probableCrises.isEmpty) return null;

    // ランダムに危機タイプを選択
    final selectedType =
        probableCrises[_random.nextInt(probableCrises.length)];

    // 各危機タイプの具体的な詳細を生成
    return switch (selectedType) {
      CrisisType.demonstration => _generateDemonstration(approval),
      CrisisType.riot => _generateRiot(approval),
      CrisisType.laborStrike => _generateLaborStrike(approval),
      CrisisType.economicCrisis => _generateEconomicCrisis(approval),
      CrisisType.militaryCoup => _generateMilitaryCoup(approval),
    };
  }

  /// デモ危機を生成
  Crisis _generateDemonstration(double approval) {
    return Crisis(
      id: _uuid.v4(),
      type: CrisisType.demonstration,
      startDate: DateTime.now(),
      durationDays: 7,
      approvalImpact: -3.0, // -3%～-5%
      description: '労働者が政府に対してデモを実施。首都に集結。',
      triggers: ['低い承認度', '経済不満'],
      escalationRisk: (60 - approval.clamp(0, 60)) / 60 * 0.3,
    );
  }

  /// 暴動危機を生成
  Crisis _generateRiot(double approval) {
    return Crisis(
      id: _uuid.v4(),
      type: CrisisType.riot,
      startDate: DateTime.now(),
      durationDays: 14,
      approvalImpact: -7.0, // -5%～-10%
      economicImpact: 500.0, // $500K損害
      description: '主要都市で大規模な市民暴動が発生。警察が対応中。',
      triggers: ['非常に低い承認度', 'デモ未解決'],
      escalationRisk: (45 - approval.clamp(0, 45)) / 45 * 0.5,
    );
  }

  /// ストライキ危機を生成
  Crisis _generateLaborStrike(double approval) {
    return Crisis(
      id: _uuid.v4(),
      type: CrisisType.laborStrike,
      startDate: DateTime.now(),
      durationDays: 21,
      approvalImpact: -4.0,
      economicImpact: 300.0, // $300K/週の損害
      description: '全国の輸送労働者が賃金改善を求めてストライキを開始。',
      triggers: ['労働者不満'],
      escalationRisk: 0.3,
    );
  }

  /// 経済危機を生成
  Crisis _generateEconomicCrisis(double approval) {
    return Crisis(
      id: _uuid.v4(),
      type: CrisisType.economicCrisis,
      startDate: DateTime.now(),
      durationDays: 30,
      approvalImpact: -10.0,
      economicImpact: 2000.0, // $2M損害
      description: '株式市場が急落。銀行危機の警告。投資家が逃げ出す。',
      triggers: ['経済的弱さ', '外国資本流出'],
      escalationRisk: 0.6,
    );
  }

  /// クーデター危機を生成
  Crisis _generateMilitaryCoup(double approval) {
    return Crisis(
      id: _uuid.v4(),
      type: CrisisType.militaryCoup,
      startDate: DateTime.now(),
      durationDays: 3, // 3日でゲームオーバー
      approvalImpact: -50.0, // 極端な影響
      description:
          '【緊急】軍部がクーデターを企図。政府機関の掌握を試みている。',
      triggers: ['危機的な承認度', '軍部の不満'],
      escalationRisk: 1.0, // 最高リスク
    );
  }

  /// 危機の表示情報を生成
  CrisisEventDisplay generateEventDisplay(Crisis crisis) {
    final options = _generateOptionsForCrisis(crisis);
    final urgency = _calculateUrgency(crisis);

    return CrisisEventDisplay(
      title: _getTitleForCrisis(crisis),
      description: crisis.description,
      options: options,
      timeUrgencyFactor: urgency,
    );
  }

  /// 危機タイプのタイトルを取得
  String _getTitleForCrisis(Crisis crisis) {
    return switch (crisis.type) {
      CrisisType.demonstration => '【警告】市民デモ発生',
      CrisisType.riot => '【警告】暴動が拡大',
      CrisisType.laborStrike => '【警告】全国ストライキ',
      CrisisType.economicCrisis => '【警告】経済危機',
      CrisisType.militaryCoup => '【緊急】クーデター試行',
    };
  }

  /// 危機に対する対応選択肢を生成
  List<CrisisOption> _generateOptionsForCrisis(Crisis crisis) {
    return switch (crisis.type) {
      CrisisType.demonstration => [
        CrisisOption(
          response: CrisisResponse.ignore,
          label: '無視する',
          description: 'デモを無視し、通常業務を続ける。',
          costEstimate: 0,
          approvalRecovery: -3.0,
          sideEffect: 'デモが拡大して暴動に発展する可能性がある。',
        ),
        CrisisOption(
          response: CrisisResponse.negotiate,
          label: '交渉する',
          description: 'デモ指導者と交渉。時間と予算がかかるが効果的。',
          costEstimate: 150.0,
          approvalRecovery: 2.0,
        ),
        CrisisOption(
          response: CrisisResponse.military,
          label: '警察出動',
          description: '警察力でデモを鎮圧。即座だが反発が大きい。',
          costEstimate: 200.0,
          approvalRecovery: -5.0,
          sideEffect: 'メディアの強い非難。国際的批判の可能性。',
        ),
      ],
      CrisisType.riot => [
        CrisisOption(
          response: CrisisResponse.military,
          label: '軍隊投入',
          description: '軍隊を出動させて暴動を鎮圧。',
          costEstimate: 500.0,
          approvalRecovery: -10.0,
          sideEffect: '長期的な承認度低下。人権懸念が生まれる。',
        ),
        CrisisOption(
          response: CrisisResponse.emergency,
          label: '緊急措置',
          description: '夜間外出禁止令など緊急措置を導入。',
          costEstimate: 300.0,
          approvalRecovery: -3.0,
          sideEffect: '市民の自由が制限される。',
        ),
        CrisisOption(
          response: CrisisResponse.negotiate,
          label: '緊急交渉',
          description: '市民指導者との緊急交渉。',
          costEstimate: 400.0,
          approvalRecovery: 4.0,
        ),
      ],
      CrisisType.laborStrike => [
        CrisisOption(
          response: CrisisResponse.ignore,
          label: '無視',
          description: 'ストライキを無視して続行。',
          costEstimate: 0,
          approvalRecovery: -4.0,
          sideEffect: 'ストが継続。経済損害が蓄積。',
        ),
        CrisisOption(
          response: CrisisResponse.appeasement,
          label: '賃金改善',
          description: '労働者の要求をほぼ全て受け入れ。',
          costEstimate: 600.0,
          approvalRecovery: 5.0,
          sideEffect: 'インフレが加速する可能性。',
        ),
        CrisisOption(
          response: CrisisResponse.negotiate,
          label: '妥協案',
          description: '部分的な賃金改善で合意を目指す。',
          costEstimate: 350.0,
          approvalRecovery: 2.0,
        ),
      ],
      CrisisType.economicCrisis => [
        CrisisOption(
          response: CrisisResponse.emergency,
          label: '銀行救済',
          description: '危機的銀行に政府資金を注入。',
          costEstimate: 2000.0,
          approvalRecovery: -2.0,
          sideEffect: 'なし。経済が安定する。',
        ),
        CrisisOption(
          response: CrisisResponse.negotiate,
          label: '国際支援',
          description: 'IMFや国際金融機関から支援を要請。',
          costEstimate: 0,
          approvalRecovery: -5.0,
          sideEffect: '主権が制限される。国際的監視が入る。',
        ),
        CrisisOption(
          response: CrisisResponse.ignore,
          label: 'デフォルト',
          description: '外国債の返済を一時停止。',
          costEstimate: 0,
          approvalRecovery: -15.0,
          sideEffect: '国際的な信用が大きく低下。',
        ),
      ],
      CrisisType.militaryCoup => [
        CrisisOption(
          response: CrisisResponse.negotiate,
          label: '軍と交渉',
          description: '軍部指導者と直接交渉。クーデター回避を目指す。',
          costEstimate: 0,
          approvalRecovery: -5.0,
          sideEffect: '権力が大幅に軍に移譲される。',
        ),
        CrisisOption(
          response: CrisisResponse.military,
          label: '忠誠部隊派遣',
          description: '政府に忠誠な部隊でクーデターを鎮圧。',
          costEstimate: 1000.0,
          approvalRecovery: 0,
          sideEffect: '市民戦争の危険性がある。',
        ),
        CrisisOption(
          response: CrisisResponse.ignore,
          label: '降伏',
          description: 'クーデターを受け入れ、権力移譲。',
          costEstimate: 0,
          approvalRecovery: -100.0,
          sideEffect: 'ゲームオーバー。任期終了。',
        ),
      ],
    };
  }

  /// 危機の緊急度を計算
  double _calculateUrgency(Crisis crisis) {
    // 危機タイプに応じた緊急度
    double baseUrgency = switch (crisis.type) {
      CrisisType.demonstration => 0.3,
      CrisisType.riot => 0.6,
      CrisisType.laborStrike => 0.4,
      CrisisType.economicCrisis => 0.7,
      CrisisType.militaryCoup => 1.0,
    };

    // 残り時間で調整
    final daysLeft = crisis.durationDays -
        DateTime.now().difference(crisis.startDate).inDays;
    final timeAdjustment =
        1.0 - (daysLeft / crisis.durationDays).clamp(0.0, 1.0);

    return (baseUrgency + timeAdjustment * 0.3).clamp(0.0, 1.0);
  }

  /// 危機のエスカレーションを計算
  double calculateEscalationRisk(Crisis crisis, double approvalRating) {
    // エスカレーションリスク = 基本リスク + 承認度低下ボーナス
    return crisis.escalationRisk +
        ((60 - approvalRating.clamp(0, 60)) / 60 * 0.2).clamp(0.0, 1.0);
  }

  /// 危機の選択を適用
  void applyCrisisResponse(
    Crisis crisis,
    CrisisResponse response,
    GameSession session,
  ) {
    // 選択を危機に記録
    final updatedCrisis = crisis.copyWith(
      playerResponse: response,
      resolvedDate: DateTime.now(),
    );
  }
}
