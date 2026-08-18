import 'package:flutter/material.dart';
import 'package:government_simulator/models/minister.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 内閣（5大臣）の忠誠度を横並びで表示。低いほど裏切りのリスクが高い。
class CabinetPanel extends StatelessWidget {
  final Cabinet cabinet;

  /// 0-100。汚職度が高いほど内閣全体の忠誠が蝕まれていく
  /// （GameLogicService.deriveMinisterImpact 参照）。省略時はバッジ非表示。
  final double? corruption;

  const CabinetPanel({Key? key, required this.cabinet, this.corruption})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lowest = cabinet.mostDisloyal;
    final atRisk = lowest != null && lowest.value <= 20;
    final corruptionLevel = corruption ?? 0;
    final corrupt = corruptionLevel >= 40;

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
              const Text('🏛️ 内閣の忠誠',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              if (corrupt) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                      '🕵️ 汚職度 ${corruptionLevel.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: AppTheme.warning,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 6),
              ],
              if (atRisk)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('⚠️ 裏切りの兆候',
                      style: TextStyle(
                          color: AppTheme.danger,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: MinisterRole.values.map((role) {
              final betrayed = cabinet.betrayed.contains(role);
              final value = cabinet.of(role);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _MinisterColumn(
                    role: role,
                    value: value,
                    betrayed: betrayed,
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

class _MinisterColumn extends StatelessWidget {
  final MinisterRole role;
  final double value;
  final bool betrayed;

  const _MinisterColumn({
    required this.role,
    required this.value,
    required this.betrayed,
  });

  @override
  Widget build(BuildContext context) {
    final color = betrayed
        ? AppTheme.textSecondary
        : value >= 60
            ? AppTheme.good
            : value <= 20
                ? AppTheme.danger
                : value <= 40
                    ? AppTheme.warning
                    : AppTheme.accent;

    return Column(
      children: [
        _MinisterAvatar(role: role, betrayed: betrayed, borderColor: color),
        const SizedBox(height: 4),
        Text(role.label,
            style: const TextStyle(
                fontSize: 9, color: AppTheme.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Container(
          height: 36,
          width: 8,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: betrayed ? 0 : value / 100),
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
        Text(betrayed ? '失脚' : value.toStringAsFixed(0),
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _MinisterAvatar extends StatelessWidget {
  final MinisterRole role;
  final bool betrayed;
  final Color borderColor;

  const _MinisterAvatar({
    required this.role,
    required this.betrayed,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final image = ClipOval(
      child: Image.asset(
        role.imagePath,
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) =>
            Text(role.emoji, style: const TextStyle(fontSize: 18)),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: betrayed
          ? ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0, 0, 0, 1, 0,
              ]),
              child: Opacity(opacity: 0.5, child: image),
            )
          : image,
    );
  }
}
