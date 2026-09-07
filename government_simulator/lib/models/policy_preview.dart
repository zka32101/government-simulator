import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/event.dart';

/// 政策選択による予想される影響（選択コミット前に表示）
class PolicyPreview {
  final String choiceId;
  final String choiceText;
  final CountryStatus beforeStatus;
  final CountryStatus projectedStatus;
  final Impact appliedImpact;
  final Map<String, IndicatorDelta> indicatorDeltas;
  final Map<String, MinisterLoyaltyDelta> ministerLoyaltyDeltas;
  final Map<String, FactionDelta> factionDeltas;
  final List<RiskFactor> riskFactors;

  const PolicyPreview({
    required this.choiceId,
    required this.choiceText,
    required this.beforeStatus,
    required this.projectedStatus,
    required this.appliedImpact,
    required this.indicatorDeltas,
    required this.ministerLoyaltyDeltas,
    required this.factionDeltas,
    required this.riskFactors,
  });

  /// リスク警告があるかどうか
  bool get hasWarnings => riskFactors.any((r) => r.severity == RiskSeverity.warning);

  /// 致命的なリスク（ゲームオーバーレベル）があるかどうか
  bool get hasCriticalRisks => riskFactors.any((r) => r.severity == RiskSeverity.critical);

  /// リスク無しの良好な政策かどうか
  bool get isPositiveWithoutRisks => !hasWarnings && appliedImpact.direction > 0;
}

/// 指標の変化量を表現するクラス
class IndicatorDelta {
  final String indicatorKey; // 'gdp', 'unemployment', etc.
  final String indicatorLabel; // '国内総生産', '失業率', etc.
  final double currentValue;
  final double projectedValue;
  final double delta;
  final double deltaPercent;
  final IndicatorTrend trend; // ↑ 良い, ↓ 悪い, → 中立

  const IndicatorDelta({
    required this.indicatorKey,
    required this.indicatorLabel,
    required this.currentValue,
    required this.projectedValue,
    required this.delta,
    required this.deltaPercent,
    required this.trend,
  });

  /// この指標の変化が"良い"方向かどうか
  bool get isPositive {
    // 失業率は低いほど良い（逆転）
    if (indicatorKey == 'unemployment' || indicatorKey == 'inflationRate' || indicatorKey == 'publicDebt') {
      return delta < 0;
    }
    // その他の指標は高いほど良い
    return delta > 0;
  }

  /// 表示用の矢印アイコン
  String get arrow {
    if (trend == IndicatorTrend.up) return '📈';
    if (trend == IndicatorTrend.down) return '📉';
    return '→';
  }
}

/// 大臣忠誠度の変化
class MinisterLoyaltyDelta {
  final String ministerRole; // 'Prime Minister', 'Finance Minister', etc.
  final String roleJapanese; // '首相', '財務大臣', etc.
  final String roleEmoji; // '🎩', '💼', etc.
  final double currentLoyalty;
  final double projectedLoyalty;
  final double delta;

  const MinisterLoyaltyDelta({
    required this.ministerRole,
    required this.roleJapanese,
    required this.roleEmoji,
    required this.currentLoyalty,
    required this.projectedLoyalty,
    required this.delta,
  });

  /// 忠誠度が危険な水準に達したかどうか
  bool get isBetrayed => projectedLoyalty <= 0;

  /// 忠誠度が心配なレベルかどうか
  bool get isLow => projectedLoyalty < 30;
}

/// 派閥支持率の変化
class FactionDelta {
  final String factionName; // 'Military', 'Business', 'Labor', 'Citizen'
  final String factionJapanese; // '軍部', '財界', '労働組合', '市民'
  final double currentSupport;
  final double projectedSupport;
  final double delta;

  const FactionDelta({
    required this.factionName,
    required this.factionJapanese,
    required this.currentSupport,
    required this.projectedSupport,
    required this.delta,
  });

  /// 支持率が危険な水準に達したかどうか
  bool get isCritical => projectedSupport <= 0;

  /// 支持率が低下しているかどうか
  bool get isDecreasing => delta < 0;
}

/// リスク要因（警告・アラート）
class RiskFactor {
  final RiskSeverity severity; // warning（橙）or critical（赤）
  final String message; // 「失業率が30%に達します」など
  final String affectedAspect; // 'Unemployment', 'Stability', 'Minister Loyalty', 'Faction Support'
  final String advice; // 「失業保険の拡充を検討してください」など

  const RiskFactor({
    required this.severity,
    required this.message,
    required this.affectedAspect,
    required this.advice,
  });
}

enum IndicatorTrend {
  up, // ↑ 上昇（良い方向か悪い方向かは指標による）
  down, // ↓ 下降
  neutral, // → 変化なし
}

enum RiskSeverity {
  warning, // 橙：注意が必要
  critical, // 赤：危機的状況（ゲームオーバーの可能性）
}
