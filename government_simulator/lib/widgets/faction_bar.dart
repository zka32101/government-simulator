import 'package:flutter/material.dart';
import 'package:government_simulator/models/faction.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 4派閥の支持率を横並びで表示。
class FactionBars extends StatelessWidget {
  final FactionSupport factions;

  const FactionBars({Key? key, required this.factions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏛️ 派閥の支持',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              if (factions.isCoupRisk)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('⚠️ 離反の危機',
                      style: TextStyle(
                          color: AppTheme.danger,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: Faction.values.map((f) {
              final v = factions.of(f);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _FactionColumn(
                    faction: f,
                    value: v,
                    isLiarTo: factions.isLiarTo(f),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FactionColumn extends StatelessWidget {
  final Faction faction;
  final double value;
  final bool isLiarTo;

  const _FactionColumn({
    required this.faction,
    required this.value,
    this.isLiarTo = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = value >= 60
        ? AppTheme.good
        : value <= 20
            ? AppTheme.danger
            : value <= 40
                ? AppTheme.warning
                : faction.color;

    return Column(
      children: [
        Text(isLiarTo ? '${faction.emoji} 🤥' : faction.emoji,
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(faction.label,
            style: const TextStyle(
                fontSize: 10, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        // 縦バー
        Container(
          height: 44,
          width: 8,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value / 100),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (context, frac, _) => FractionallySizedBox(
                heightFactor: frac.clamp(0.02, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('${value.toStringAsFixed(0)}',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }
}
