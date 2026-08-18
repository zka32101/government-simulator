import 'package:flutter/material.dart';
import 'package:government_simulator/models/country_status.dart';

/// 現実世界の国家分類になぞらえた統治水準のティア。
///
/// 呼称は国連(LDC)やIMF/世界銀行(先進国・新興国)などで実際に使われている
/// 分類用語をベースにしており、特定の国・地域を名指しして序列化すること
/// は避けている。
enum CountryTierLevel {
  advanced, // 先進国 (Advanced economy)
  emerging, // 新興国 (Emerging market)
  developing, // 発展途上国 (Developing country)
  leastDeveloped, // 後発開発途上国 (LDC)
  fragile, // 破綻国家・紛争影響国 (Fragile state)
}

/// 現実の国家分類になぞらえた、あなたの国家の統治水準の評価。
class CountryTier {
  final CountryTierLevel level;
  final String label;

  /// 「〜クラス」の一言比較。
  final String comparison;
  final String description;
  final Color color;

  /// GDP・財政・物価などの個別の懸念事項（該当時のみ）。
  final List<String> warnings;

  const CountryTier({
    required this.level,
    required this.label,
    required this.comparison,
    required this.description,
    required this.color,
    this.warnings = const [],
  });

  /// [CountryStatus] から総合スコア（0-100）を算出し、ティアを判定する。
  ///
  /// healthScore（GDP・雇用・満足度・安定度の均等平均）に加えて、財政
  /// （対GDP債務比）と物価安定性（インフレ率の適正からの乖離）も加味した、
  /// より現実の国家格付けに近い複合指標を用いる。
  static double compositeScore(CountryStatus status) {
    final gdpScore = (status.gdp / 100).clamp(0, 100).toDouble();
    final employmentScore =
        ((100 - status.unemployment) / 100 * 100).clamp(0, 100).toDouble();
    // 債務対GDP比 60% を健全ラインとし、200% で 0 点になるよう線形減点。
    final fiscalScore =
        (100 - (status.publicDebt - 60).clamp(0, 140) / 140 * 100)
            .clamp(0, 100)
            .toDouble();
    // インフレ率は 2% 前後が理想。そこからの乖離が大きいほど減点。
    final priceStabilityScore =
        (100 - (status.inflationRate - 2).abs().clamp(0, 20) / 20 * 100)
            .clamp(0, 100)
            .toDouble();

    return gdpScore * 0.30 +
        employmentScore * 0.15 +
        status.satisfaction * 0.15 +
        status.stability * 0.15 +
        fiscalScore * 0.15 +
        priceStabilityScore * 0.10;
  }

  static CountryTier evaluate(CountryStatus status) {
    final composite = compositeScore(status);
    final warnings = _collectWarnings(status);

    if (composite >= 75) {
      return CountryTier(
        level: CountryTierLevel.advanced,
        label: '先進国クラス',
        comparison: 'G7・OECD加盟国のような先進国水準',
        description: '経済規模・雇用・財政・社会の安定がいずれも高水準で両立しています。'
            '現実の「先進国」と呼べる統治実績です。',
        color: const Color(0xFF2196F3),
        warnings: warnings,
      );
    } else if (composite >= 55) {
      return CountryTier(
        level: CountryTierLevel.emerging,
        label: '新興国クラス',
        comparison: '急成長を続ける新興国(エマージング・マーケット)水準',
        description: '着実な発展軌道にありますが、先進国入りにはさらなる改善が必要です。',
        color: const Color(0xFF4CAF50),
        warnings: warnings,
      );
    } else if (composite >= 35) {
      return CountryTier(
        level: CountryTierLevel.developing,
        label: '発展途上国クラス',
        comparison: '発展途上国(デベロッピング・カントリー)水準',
        description: '一定の経済基盤はあるものの、雇用・財政・社会保障などの面で'
            '課題が山積しています。',
        color: const Color(0xFFFFC107),
        warnings: warnings,
      );
    } else if (composite >= 15) {
      return CountryTier(
        level: CountryTierLevel.leastDeveloped,
        label: '後発開発途上国クラス',
        comparison: '国連分類でいう後発開発途上国(LDC)相当の水準',
        description: '経済・社会基盤が脆弱で、国際社会の支援なしには自立が困難な'
            '状況に近づいています。',
        color: const Color(0xFFFF9800),
        warnings: warnings,
      );
    } else {
      return CountryTier(
        level: CountryTierLevel.fragile,
        label: '破綻国家クラス',
        comparison: '破綻国家指数(Fragile States Index)で最上位の危機国水準',
        description: '国家としての基本機能が著しく損なわれています。抜本的な立て直しが'
            '急務です。',
        color: const Color(0xFFF44336),
        warnings: warnings,
      );
    }
  }

  static List<String> _collectWarnings(CountryStatus status) {
    final warnings = <String>[];
    if (status.inflationRate >= 10) {
      warnings.add(
          '⚠️ ハイパーインフレの兆候（インフレ率${status.inflationRate.toStringAsFixed(1)}%）');
    } else if (status.inflationRate <= -2) {
      warnings.add(
          '⚠️ デフレスパイラルの懸念（インフレ率${status.inflationRate.toStringAsFixed(1)}%）');
    }
    if (status.publicDebt >= 150) {
      warnings.add('⚠️ 財政破綻リスク（債務対GDP比${status.publicDebt.toStringAsFixed(0)}%）');
    }
    if (status.unemployment >= 15) {
      warnings.add('⚠️ 深刻な雇用危機（失業率${status.unemployment.toStringAsFixed(1)}%）');
    }
    if (status.stability <= 25) {
      warnings.add('⚠️ 統治基盤の崩壊リスク（安定度${status.stability.toStringAsFixed(0)}/100）');
    }
    return warnings;
  }
}
