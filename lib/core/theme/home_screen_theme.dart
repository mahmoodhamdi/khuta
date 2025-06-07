import 'package:flutter/material.dart';

class HomeScreenTheme {
  static Color backgroundColor(bool isDark) =>
      isDark ? const Color(0xFF1A202C) : const Color(0xFFF8F9FA);

  static Color cardBackground(bool isDark) =>
      isDark ? const Color(0xFF2D3748) : Colors.white;

  static Color primaryText(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF2D3748);

  static Color secondaryText(bool isDark) =>
      isDark ? Colors.grey[400]! : Colors.grey[600]!;

  static Color accentBlue(bool isDark) =>
      isDark ? const Color(0xFF63B3ED) : const Color(0xFF4299E1);

  static Color accentPink(bool isDark) =>
      isDark ? const Color(0xFFF687B3) : const Color(0xFFED64A6);

  static Color accentGreen(bool isDark) =>
      isDark ? const Color(0xFF68D391) : const Color(0xFF48BB78);

  static Color accentOrange(bool isDark) =>
      isDark ? const Color(0xFFF6AD55) : const Color(0xFFED8936);

  static Color accentRed(bool isDark) =>
      isDark ? const Color(0xFFFC8181) : const Color(0xFFE53E3E);

  static BoxShadow cardShadow(bool isDark) => BoxShadow(
    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
    blurRadius: isDark ? 20 : 10,
    offset: const Offset(0, 4),
  );

  static Color getScoreColor(double score, bool isDark) {
    if (score >= 80) {
      return accentGreen(isDark);
    }
    if (score >= 60) {
      return accentOrange(isDark);
    }
    return accentRed(isDark);
  }
}
