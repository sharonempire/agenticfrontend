import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryLight = Color(0xFF5AC8FA);
  static const Color primaryDark = Color(0xFF0051D5);
  static const Color secondary = Color(0xFF5856D6);
  static const Color accent = Color(0xFFFF9500);

  // Semantic
  static const Color success = Color(0xFF34C759);
  static const Color successLight = Color(0xFFD1F2D9);
  static const Color error = Color(0xFFFF3B30);
  static const Color errorLight = Color(0xFFFFD6D4);
  static const Color warning = Color(0xFFFFCC00);
  static const Color warningLight = Color(0xFFFFF4CC);
  static const Color info = Color(0xFF5AC8FA);

  // Light neutrals
  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF9F9FB);
  static const Color separator = Color(0xFFC6C6C8);
  static const Color separatorLight = Color(0xFFE5E5EA);

  // Light text
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFAEAEB2);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textLink = Color(0xFF007AFF);

  // Dark neutrals
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkSurfaceSecondary = Color(0xFF2C2C2E);
  static const Color darkSeparator = Color(0xFF38383A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF98989D);
  static const Color darkTextTertiary = Color(0xFF636366);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color chipBg(Color color) => color.withValues(alpha: 0.1);
}
