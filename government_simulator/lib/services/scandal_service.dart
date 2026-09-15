/// スキャンダル管理サービス
/// スキャンダルの発生、進展、影響を管理

library;

import 'dart:math';
import 'package:government_simulator/models/scandal.dart';

/// スキャンダルの詳細な管理と分析
class ScandalService {
  final List<Scandal> allScandals;
  double playerPoliticalTrust; // 政治的信頼度（0-100）

  ScandalService({
    this.allScandals = const [],
    this.playerPoliticalTrust = 80.0,
  });

  /// アクティブなスキャンダルのリストを取得
  List<Scandal> getActiveScandals(int year, int week) {
    return allScandals.where((scandal) => scandal.isActive(year, week)).toList();
  }

  /// 指定週のスキャンダル総合影響を計算
  double calculateTotalScandalImpact(int year, int week) {
    final activeScandals = getActiveScandals(year, week);
    double totalImpact = 0.0;

    for (final scandal in activeScandals) {
      totalImpact += scandal.getWeeklyImpact(year, week);

      // 隠蔽が暴露された場合の追加ダメージ
      if (scandal.isExposed && scandal.playerResponse == ScandalResponse.coverup) {
        totalImpact += scandal.getCoverupExposurePenalty();
      }
    }

    return totalImpact.clamp(0.0, 100.0);
  }

  /// 政治的信頼度へのダメージを計算
  double calculateTrustDamage(int year, int week) {
    final activeScandals = getActiveScandals(year, week);
    double trustDamage = 0.0;

    for (final scandal in activeScandals) {
      if (scandal.playerResponse == ScandalResponse.apologize) {
        // 謝罪：短期的には影響が少ないが、信頼度は回復する
        trustDamage += scandal.trustDamage * 0.3;
      } else if (scandal.playerResponse == ScandalResponse.deny) {
        // 否定：信頼度へのダメージが増加
        trustDamage += scandal.trustDamage * 0.8;
      } else if (scandal.playerResponse == ScandalResponse.coverup) {
        // 隠蔽：暴露されるまで影響なし
        if (scandal.isExposed) {
          trustDamage += scandal.trustDamage * 1.5;
        }
      } else {
        // 無視：通常のダメージ
        trustDamage += scandal.trustDamage * 0.5;
      }
    }

    return trustDamage;
  }

  /// スキャンダル発生確率を計算
  double calculateScandalOccurrenceProbability({
    required double playerApproval,
    required int activePolicies,
    required String difficulty,
    required int month,
  }) {
    // 基本確率：2%
    double baseProbability = 0.02;

    // 月による季節変動（選挙直前は確率上昇）
    if (month == 12) {
      // 年末は報道が増える
      baseProbability *= 1.5;
    }

    // 政策激化で確率上昇
    baseProbability += activePolicies * 0.005;

    // 支持率が低いほどスキャンダル報道が増える
    if (playerApproval < 50) {
      baseProbability += (50 - playerApproval) * 0.001;
    }

    // 難易度による調整
    final difficultyMult = difficulty == 'hard'
        ? 1.8
        : difficulty == 'easy'
            ? 0.4
            : 1.0;
    baseProbability *= difficultyMult;

    return baseProbability.clamp(0.0, 1.0);
  }

  /// スキャンダル応答の成功確率を計算
  double calculateResponseSuccessRate({
    required ScandalResponse response,
    required ScandalSeverity severity,
    required double playerApproval,
    required double politicalTrust,
    required int difficulty,
  }) {
    double baseRate = switch (response) {
      ScandalResponse.deny => 0.6,
      ScandalResponse.apologize => 0.8,
      ScandalResponse.counterattack => 0.5,
      ScandalResponse.coverup => 0.4,
      ScandalResponse.ignore => 1.0,
    };

    // 重大度による調整
    final severityFactor = switch (severity) {
      ScandalSeverity.minor => 1.1,
      ScandalSeverity.moderate => 1.0,
      ScandalSeverity.serious => 0.8,
      ScandalSeverity.critical => 0.5,
    };

    // 支持率による調整
    final approvalFactor = 0.5 + (playerApproval / 200);

    // 信頼度による調整
    final trustFactor = 0.5 + (politicalTrust / 200);

    // 難易度による調整
    final difficultyFactor = difficulty == 0 ? 1.3 : difficulty == 1 ? 1.0 : 0.7;

    return (baseRate * severityFactor * approvalFactor * trustFactor * difficultyFactor)
        .clamp(0.0, 1.0);
  }

  /// スキャンダル応答を実行
  Scandal respondToScandale(
    Scandal scandal,
    ScandalResponse response, {
    required double playerApproval,
    required int difficulty,
  }) {
    // 信頼度ダメージを計算
    double trustDamage = switch (response) {
      ScandalResponse.deny => 15.0,
      ScandalResponse.apologize => 5.0,
      ScandalResponse.counterattack => 20.0,
      ScandalResponse.coverup => 30.0,
      ScandalResponse.ignore => 10.0,
    };

    // 支持率が高いと信頼度ダメージが軽減
    trustDamage *= (1.0 - (playerApproval / 200));

    // 回復速度を計算
    double recoveryRate = switch (response) {
      ScandalResponse.deny => 0.8,
      ScandalResponse.apologize => 1.3,
      ScandalResponse.counterattack => 0.6,
      ScandalResponse.coverup => 0.2,
      ScandalResponse.ignore => 0.9,
    };

    // 隠蔽工作の成功判定
    bool isExposed = false;
    if (response == ScandalResponse.coverup) {
      final successRate = scandal.calculateCoverupSuccessRate(difficulty);
      isExposed = Random().nextDouble() > successRate;
    }

    return Scandal(
      id: scandal.id,
      title: scandal.title,
      description: scandal.description,
      type: scandal.type,
      severity: scandal.severity,
      discoveredAt: scandal.discoveredAt,
      startWeek: scandal.startWeek,
      startYear: scandal.startYear,
      baseImpact: scandal.baseImpact,
      initialIntensity: scandal.initialIntensity,
      involvedPersonId: scandal.involvedPersonId,
      playerResponse: response,
      respondedAt: DateTime.now(),
      trustDamage: trustDamage,
      recoveryRate: recoveryRate,
      isExposed: isExposed,
    );
  }

  /// スキャンダル信頼度の回復を計算
  double calculateTrustRecovery(Scandal scandal, int weeksElapsed) {
    if (scandal.playerResponse == null) return 0.0;

    // 回復速度に基づいて回復量を計算
    final recoveryPerWeek = scandal.recoveryRate * 1.5; // 週あたり1.5%回復
    final recovery = recoveryPerWeek * weeksElapsed;

    return recovery.clamp(0.0, scandal.trustDamage);
  }

  /// 政治的信頼度を更新
  void updatePoliticalTrust(double damage) {
    playerPoliticalTrust = (playerPoliticalTrust - damage).clamp(0.0, 100.0);
  }

  /// 政治的信頼度を回復
  void recoverPoliticalTrust(double recovery) {
    playerPoliticalTrust = (playerPoliticalTrust + recovery).clamp(0.0, 100.0);
  }

  /// スキャンダルのコピー
  ScandalService copyWith({
    List<Scandal>? allScandals,
    double? playerPoliticalTrust,
  }) {
    return ScandalService(
      allScandals: allScandals ?? this.allScandals,
      playerPoliticalTrust: playerPoliticalTrust ?? this.playerPoliticalTrust,
    );
  }

  /// シリアライゼーション
  Map<String, dynamic> toMap() {
    return {
      'allScandals': allScandals.map((s) => s.toMap()).toList(),
      'playerPoliticalTrust': playerPoliticalTrust,
    };
  }

  factory ScandalService.fromMap(Map<String, dynamic> map) {
    return ScandalService(
      allScandals: (map['allScandals'] as List?)
              ?.map((s) => Scandal.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      playerPoliticalTrust: (map['playerPoliticalTrust'] as num?)?.toDouble() ?? 80.0,
    );
  }
}
