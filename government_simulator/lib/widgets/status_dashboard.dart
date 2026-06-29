import 'package:flutter/material.dart';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/utils/app_theme.dart';
import 'package:government_simulator/widgets/animated_counter.dart';

/// 国家ステータスのコンパクトなダッシュボード（横スクロールのスタットチップ）。
class StatusDashboard extends StatelessWidget {
  final CountryStatus status;
  final CountryStatus? previous; // 前回値（差分アニメ用）

  const StatusDashboard({Key? key, required this.status, this.previous})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HealthGauge(status: status),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _StatChip(
                icon: '💰',
                label: 'GDP',
                from: previous?.gdp ?? status.gdp,
                to: status.gdp,
                suffix: 'B',
                prefix: '\$',
                good: status.gdp > 1000,
              ),
              _StatChip(
                icon: '👷',
                label: '失業率',
                from: previous?.unemployment ?? status.unemployment,
                to: status.unemployment,
                suffix: '%',
                decimals: 1,
                good: status.unemployment < 7,
                lowerIsBetter: true,
              ),
              _StatChip(
                icon: '😊',
                label: '満足度',
                from: previous?.satisfaction ?? status.satisfaction,
                to: status.satisfaction,
                good: status.satisfaction > 50,
              ),
              _StatChip(
                icon: '⚔️',
                label: '国力',
                from: previous?.nationalPower ?? status.nationalPower,
                to: status.nationalPower,
                good: status.nationalPower > 50,
              ),
              _StatChip(
                icon: '📈',
                label: 'インフレ',
                from: previous?.inflationRate ?? status.inflationRate,
                to: status.inflationRate,
                suffix: '%',
                decimals: 1,
                good: status.inflationRate < 3 && status.inflationRate > 0,
              ),
              _StatChip(
                icon: '🏛️',
                label: '安定度',
                from: previous?.stability ?? status.stability,
                to: status.stability,
                good: status.stability > 60,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HealthGauge extends StatelessWidget {
  final CountryStatus status;

  const _HealthGauge({required this.status});

  @override
  Widget build(BuildContext context) {
    final score = status.healthScore;
    final color = AppTheme.scoreColor(score);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('国家健全度',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AnimatedCounter(
                    value: score,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const Text(' /100',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: score / 100),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (context, frac, _) => LinearProgressIndicator(
                      value: frac,
                      minHeight: 12,
                      backgroundColor: Colors.black.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${status.crisisLevel.emoji} ${status.crisisLevel.label}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final double from;
  final double to;
  final String prefix;
  final String suffix;
  final int decimals;
  final bool good;
  final bool lowerIsBetter;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.from,
    required this.to,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
    required this.good,
    this.lowerIsBetter = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = good ? AppTheme.good : AppTheme.warning;
    final delta = to - from;
    final showDelta = delta.abs() > 0.05;
    final deltaGood = lowerIsBetter ? delta < 0 : delta > 0;

    return Container(
      width: 104,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          TransitionCounter(
            from: from,
            to: to,
            prefix: prefix,
            suffix: suffix,
            decimals: decimals,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          if (showDelta)
            Text(
              '${delta > 0 ? '▲' : '▼'}${delta.abs().toStringAsFixed(decimals == 0 ? 0 : 1)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: deltaGood ? AppTheme.good : AppTheme.danger,
              ),
            )
          else
            const Text('—',
                style: TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
