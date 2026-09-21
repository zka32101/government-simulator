import 'package:flutter/material.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// ゲーム画面の背景に敷く、ドラッグ・ピンチ操作で動かせる仮想地図。
/// ゲームデータとは連動しない、没入感を高めるための装飾的な地形図。
class CountryMapBackground extends StatelessWidget {
  const CountryMapBackground({super.key});

  static const double _mapSize = 1600;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.bg,
      child: InteractiveViewer(
        minScale: 0.7,
        maxScale: 2.5,
        boundaryMargin: const EdgeInsets.all(300),
        child: const SizedBox(
          width: _mapSize,
          height: _mapSize,
          child: RepaintBoundary(
            child: CustomPaint(painter: _CountryMapPainter()),
          ),
        ),
      ),
    );
  }
}

class _CityMarker {
  final Offset position;
  final String label;
  final Color color;
  final bool isCapital;

  const _CityMarker(this.position, this.label, this.color,
      {this.isCapital = false});
}

class _CountryMapPainter extends CustomPainter {
  const _CountryMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppTheme.bg);
    _drawGraticule(canvas, size);
    _drawLandmass(canvas, size);
    _drawIslands(canvas, size);
    _drawCities(canvas, size);
  }

  void _drawGraticule(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..strokeWidth = 1;
    const step = 120.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  void _drawLandmass(Canvas canvas, Size size) {
    final fill = Paint()..color = AppTheme.surface;
    final stroke = Paint()
      ..color = AppTheme.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final points = <Offset>[
      Offset(size.width * 0.18, size.height * 0.30),
      Offset(size.width * 0.30, size.height * 0.16),
      Offset(size.width * 0.52, size.height * 0.14),
      Offset(size.width * 0.70, size.height * 0.24),
      Offset(size.width * 0.82, size.height * 0.40),
      Offset(size.width * 0.78, size.height * 0.58),
      Offset(size.width * 0.66, size.height * 0.72),
      Offset(size.width * 0.50, size.height * 0.80),
      Offset(size.width * 0.34, size.height * 0.76),
      Offset(size.width * 0.22, size.height * 0.62),
      Offset(size.width * 0.16, size.height * 0.46),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawIslands(Canvas canvas, Size size) {
    final fill = Paint()..color = AppTheme.surface.withOpacity(0.8);
    for (final c in [
      Offset(size.width * 0.88, size.height * 0.72),
      Offset(size.width * 0.10, size.height * 0.82),
      Offset(size.width * 0.92, size.height * 0.20),
    ]) {
      canvas.drawCircle(c, size.width * 0.035, fill);
    }
  }

  void _drawCities(Canvas canvas, Size size) {
    final markers = <_CityMarker>[
      _CityMarker(
        Offset(size.width * 0.48, size.height * 0.46),
        '首都',
        AppTheme.gold,
        isCapital: true,
      ),
      _CityMarker(
        Offset(size.width * 0.32, size.height * 0.32),
        '工業地帯',
        AppTheme.accent,
      ),
      _CityMarker(
        Offset(size.width * 0.64, size.height * 0.58),
        '港湾都市',
        AppTheme.accent,
      ),
      _CityMarker(
        Offset(size.width * 0.40, size.height * 0.66),
        '農業地帯',
        AppTheme.good,
      ),
      _CityMarker(
        Offset(size.width * 0.60, size.height * 0.30),
        '国境の町',
        AppTheme.textSecondary,
      ),
    ];

    for (final m in markers) {
      canvas.drawCircle(m.position, m.isCapital ? 12 : 8,
          Paint()..color = m.color);

      final tp = TextPainter(
        text: TextSpan(
          text: m.label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: m.isCapital ? 26 : 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, m.position + const Offset(14, -10));
    }
  }

  @override
  bool shouldRepaint(_CountryMapPainter oldDelegate) => false;
}
