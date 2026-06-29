import 'package:flutter/material.dart';
import 'package:government_simulator/models/country_status.dart';

/// 重厚な政治シミュレーターのダークテーマ。
class AppTheme {
  // パレット
  static const Color bg = Color(0xFF0E1420); // 深い紺
  static const Color surface = Color(0xFF1A2332); // カード面
  static const Color surfaceLight = Color(0xFF243044);
  static const Color gold = Color(0xFFD4AF37); // 国章ゴールド
  static const Color accent = Color(0xFF4A90D9); // 青
  static const Color good = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB300);
  static const Color danger = Color(0xFFE53935);
  static const Color textPrimary = Color(0xFFECEFF4);
  static const Color textSecondary = Color(0xFF9AA5B8);

  static ThemeData build() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: accent,
        surface: surface,
        error: danger,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
        fontFamily: 'Roboto',
      ).copyWith(
        titleLarge: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary),
        titleMedium: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary),
        bodyMedium: const TextStyle(fontSize: 14, color: textPrimary),
        bodySmall: const TextStyle(fontSize: 12, color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: bg,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// 危機レベルに応じた背景グラデーション。
  static LinearGradient crisisGradient(CrisisLevel level) {
    switch (level) {
      case CrisisLevel.stable:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF12203A), Color(0xFF0E1420)],
        );
      case CrisisLevel.medium:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A2A12), Color(0xFF0E1420)],
        );
      case CrisisLevel.high:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3A1E12), Color(0xFF0E1420)],
        );
      case CrisisLevel.critical:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A1212), Color(0xFF0E1420)],
        );
    }
  }

  /// 値の良し悪しから色を返す（0-100想定、高いほど良い指標）
  static Color scoreColor(double value, {double goodAbove = 60, double badBelow = 35}) {
    if (value >= goodAbove) return good;
    if (value <= badBelow) return danger;
    return warning;
  }
}
