/// ランダム危機生成サービス
/// 複数の要因に基づいた危機の確率的生成と連鎖効果

library;

import 'dart:math';
import 'package:government_simulator/models/crisis.dart';

/// 危機の連鎖イベント
class CrisisChain {
  /// 初期危機
  final Crisis initialCrisis;

  /// 続く危機（連鎖可能性）
  final List<Crisis> followUpCrises;

  /// 総合影響度（複合的なダメージ）
  double totalImpact;

  CrisisChain({
    required this.initialCrisis,
    this.followUpCrises = const [],
    this.totalImpact = 0.0,
  });

  /// 危機チェーンの長さ
  int get chainLength => 1 + followUpCrises.length;

  /// 全危機の承認度への影響を合計
  double calculateTotalApprovalImpact() {
    return initialCrisis.getApprovalImpact() +
        followUpCrises.fold(0.0, (sum, c) => sum + c.getApprovalImpact());
  }
}

/// 危機の厳しさレベル
enum CrisisSeverity {
  /// 軽度：容易に対応可能
  mild,

  /// 中度：標準的な対応が必要
  moderate,

  /// 重度：複雑で多方面の対応が必要
  severe,

  /// 致命的：政権崩壊の可能性
  critical,
}

extension CrisisSeverityExt on CrisisSeverity {
  String get label {
    switch (this) {
      case CrisisSeverity.mild:
        return '軽度';
      case CrisisSeverity.moderate:
        return '中度';
      case CrisisSeverity.severe:
        return '重度';
      case CrisisSeverity.critical:
        return '致命的';
    }
  }

  /// 承認度ダメージ乗数
  double get damageMultiplier {
    switch (this) {
      case CrisisSeverity.mild:
        return 0.5;
      case CrisisSeverity.moderate:
        return 1.0;
      case CrisisSeverity.severe:
        return 1.5;
      case CrisisSeverity.critical:
        return 2.5;
    }
  }
}

/// ランダム危機生成サービス
class RandomCrisisGenerator {
  /// 危機発生確率を計算（0-1）
  double calculateCrisisProbability({
    required double approval,
    required double stability,
    required double gdp,
    required double unemployment,
    required int activeCrisisCount,
    required double internationalTension,
  }) {
    // 基本確率：1%
    double probability = 0.01;

    // 承認度が低いほど危機が起こりやすい
    if (approval < 60) {
      probability += (60 - approval) / 100 * 0.15;
    }

    // 安定度が低いほど危機が起こりやすい
    if (stability < 60) {
      probability += (60 - stability) / 100 * 0.1;
    }

    // GDP低下で危機リスク上昇
    if (gdp < 1000) {
      probability += (1000 - gdp) / 1000 * 0.08;
    }

    // 失業率が高いほど危機が起こりやすい
    if (unemployment > 3) {
      probability += (unemployment - 3) / 10 * 0.1;
    }

    // 既存の危機がある場合、新たな危機が起こりやすい（複合危機）
    probability += activeCrisisCount * 0.03;

    // 国際的緊張が高いほど危機が起こりやすい
    probability += internationalTension / 100 * 0.08;

    return probability.clamp(0.0, 1.0);
  }

  /// 危機の厳しさを決定
  CrisisSeverity determineSeverity({
    required double approval,
    required double stability,
    required Random random,
  }) {
    // 承認度と安定度が低いほど重大な危機
    final severityScore = ((60 - approval) + (60 - stability)) / 120;

    // ランダム要素を加える
    final randomFactor = random.nextDouble();
    final finalScore = (severityScore * 0.7) + (randomFactor * 0.3);

    return switch (finalScore) {
      < 0.25 => CrisisSeverity.mild,
      < 0.50 => CrisisSeverity.moderate,
      < 0.75 => CrisisSeverity.severe,
      _ => CrisisSeverity.critical,
    };
  }

  /// 危機の連鎖発生確率を計算
  double calculateChainProbability(CrisisSeverity severity) {
    return switch (severity) {
      CrisisSeverity.mild => 0.05,
      CrisisSeverity.moderate => 0.15,
      CrisisSeverity.severe => 0.35,
      CrisisSeverity.critical => 0.60,
    };
  }

  /// 危機が他の危機をトリガーする可能性
  List<CrisisType> determineFollowUpCrises(
    CrisisType initialType,
    CrisisSeverity severity,
  ) {
    final followUpTypes = <CrisisType>[];

    // 特定の危機タイプの組み合わせ
    switch (initialType) {
      case CrisisType.economicCrisis:
        // 経済危機は労働争議と失業デモをトリガー
        followUpTypes.add(CrisisType.laborStrike);
        if (severity == CrisisSeverity.critical) {
          followUpTypes.add(CrisisType.demonstration);
        }
      case CrisisType.laborStrike:
        // 労働争議はデモや経済悪化をトリガー
        followUpTypes.add(CrisisType.demonstration);
        if (severity == CrisisSeverity.severe) {
          followUpTypes.add(CrisisType.economicCrisis);
        }
      case CrisisType.demonstration:
        // デモは暴動や労働争議につながる可能性
        if (severity == CrisisSeverity.severe) {
          followUpTypes.add(CrisisType.riot);
        }
        if (severity == CrisisSeverity.critical) {
          followUpTypes.add(CrisisType.laborStrike);
        }
      case CrisisType.riot:
        // 暴動は軍事クーデターのリスクを高める
        if (severity == CrisisSeverity.critical) {
          followUpTypes.add(CrisisType.militaryCoup);
        }
      case CrisisType.militaryCoup:
        // クーデターは最終段階（つながる危機なし）
        break;
    }

    return followUpTypes;
  }

  /// 危機の継続期間を計算（日数）
  int calculateDuration(CrisisSeverity severity) {
    final baseDuration = switch (severity) {
      CrisisSeverity.mild => 7,
      CrisisSeverity.moderate => 14,
      CrisisSeverity.severe => 21,
      CrisisSeverity.critical => 30,
    };

    // ランダム変動：±3日
    final variation = Random().nextInt(7) - 3;
    return baseDuration + variation;
  }

  /// 危機からの回復時間を計算
  int calculateRecoveryDays(CrisisSeverity severity, CrisisResponse response) {
    // 基本回復時間
    int recoveryDays = switch (severity) {
      CrisisSeverity.mild => 3,
      CrisisSeverity.moderate => 7,
      CrisisSeverity.severe => 14,
      CrisisSeverity.critical => 21,
    };

    // 対応方法による調整
    recoveryDays = switch (response) {
      CrisisResponse.negotiate => (recoveryDays * 0.7).toInt(),
      CrisisResponse.emergency => (recoveryDays * 0.9).toInt(),
      CrisisResponse.appeasement => (recoveryDays * 1.2).toInt(),
      CrisisResponse.military => (recoveryDays * 1.5).toInt(),
      CrisisResponse.ignore => (recoveryDays * 2.0).toInt(),
    };

    return recoveryDays;
  }

  /// 複数危機が同時発生するリスク
  bool shouldGenerateMultipleCrises(int existingCrisisCount) {
    if (existingCrisisCount >= 3) return false; // 最大3つまで

    // 既存危機数が多いほど追加危機の確率は低い
    final probability = 0.1 / (existingCrisisCount + 1);
    return Random().nextDouble() < probability;
  }

  /// 危機からの長期的な影響を計算
  Map<String, double> calculateLongTermEffects(
    CrisisSeverity severity,
    CrisisResponse response,
  ) {
    return {
      // 信頼度への影響
      'trustDamage': switch (response) {
        CrisisResponse.negotiate => 5.0,
        CrisisResponse.emergency => 8.0,
        CrisisResponse.appeasement => 3.0,
        CrisisResponse.military => 15.0,
        CrisisResponse.ignore => 25.0,
      } *
          (1 + (severity.index / 4)),
      // 国家統一度への影響
      'stabilityImpact': switch (severity) {
        CrisisSeverity.mild => -2.0,
        CrisisSeverity.moderate => -5.0,
        CrisisSeverity.severe => -10.0,
        CrisisSeverity.critical => -20.0,
      },
    };
  }
}
