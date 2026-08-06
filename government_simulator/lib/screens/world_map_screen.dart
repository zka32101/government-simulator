import 'package:flutter/material.dart';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/world_map.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 近隣諸国との関係を示す世界地図画面。
class WorldMapScreen extends StatelessWidget {
  final CountryStatus status;
  final String countryName;

  const WorldMapScreen({
    Key? key,
    required this.status,
    required this.countryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('🗺️ 世界における立ち位置')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _WorldMapCanvas(
                    status: status,
                    countryName: countryName,
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              flex: 2,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('📋 各国との関係',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 10),
                  ...NeighborNation.all.map((n) => _RelationRow(
                        nation: n,
                        status: status,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorldMapCanvas extends StatelessWidget {
  final CountryStatus status;
  final String countryName;

  const _WorldMapCanvas({required this.status, required this.countryName});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF12203A), Color(0xFF0E1420)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Stack(
            children: [
              CustomPaint(
                size: size,
                painter: _RelationLinesPainter(status: status),
              ),
              // 自国（中央）
              _NationMarker(
                x: 0.5,
                y: 0.5,
                size: size,
                emoji: '🏛️',
                imagePath: 'assets/images/app_icon.png',
                label: countryName,
                color: AppTheme.gold,
              ),
              // 隣国群
              ...NeighborNation.all.map((n) {
                final type = n.relationType(status);
                final color = type == RelationType.ally
                    ? AppTheme.good
                    : type == RelationType.rival
                        ? AppTheme.danger
                        : AppTheme.textSecondary;
                return _NationMarker(
                  x: n.x,
                  y: n.y,
                  size: size,
                  emoji: n.emoji,
                  imagePath: n.imagePath,
                  label: n.name,
                  color: color,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _RelationLinesPainter extends CustomPainter {
  final CountryStatus status;

  _RelationLinesPainter({required this.status});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    for (final n in NeighborNation.all) {
      final target = Offset(size.width * n.x, size.height * n.y);
      final type = n.relationType(status);
      final color = type == RelationType.ally
          ? AppTheme.good
          : type == RelationType.rival
              ? AppTheme.danger
              : AppTheme.textSecondary;
      final paint = Paint()
        ..color = color.withOpacity(0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center, target, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RelationLinesPainter oldDelegate) =>
      oldDelegate.status != status;
}

class _NationMarker extends StatelessWidget {
  final double x;
  final double y;
  final Size size;
  final String emoji;
  final String? imagePath;
  final String label;
  final Color color;

  const _NationMarker({
    required this.x,
    required this.y,
    required this.size,
    required this.emoji,
    this.imagePath,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const markerSize = 44.0;
    return Positioned(
      left: (size.width * x) - markerSize / 2,
      top: (size.height * y) - markerSize / 2,
      child: Column(
        children: [
          Container(
            width: markerSize,
            height: markerSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surface,
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.4), blurRadius: 8),
              ],
            ),
            child: imagePath == null
                ? Text(emoji, style: const TextStyle(fontSize: 20))
                : ClipOval(
                    child: Image.asset(
                      imagePath!,
                      width: markerSize - 4,
                      height: markerSize - 4,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 9, color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _RelationRow extends StatelessWidget {
  final NeighborNation nation;
  final CountryStatus status;

  const _RelationRow({required this.nation, required this.status});

  @override
  Widget build(BuildContext context) {
    final score = nation.relationScore(status);
    final type = nation.relationType(status);
    final color = type == RelationType.ally
        ? AppTheme.good
        : type == RelationType.rival
            ? AppTheme.danger
            : AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: Image.asset(
              nation.imagePath,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Text(nation.emoji,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(nation.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${type.emoji} ${type.label}',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(nation.description,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        height: 1.4)),
              ],
            ),
          ),
          Text('${score.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
