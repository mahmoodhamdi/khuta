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
    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
    blurRadius: isDark ? 20 : 10,
    offset: const Offset(0, 4),
  );

  /// Returns color based on T-Score interpretation
  /// Lower T-scores are better (less ADHD symptoms)
  /// Higher T-scores indicate more concern
  static Color getScoreColor(double tScore, bool isDark) {
    if (tScore < 45) {
      // Below average - good, fewer symptoms
      return accentGreen(isDark);
    } else if (tScore <= 55) {
      // Average range - neutral
      return accentBlue(isDark);
    } else if (tScore <= 65) {
      // Above average - some concern
      return accentOrange(isDark);
    } else {
      // Significantly elevated - needs attention
      return accentRed(isDark);
    }
  }

  /// Returns a severity level string for the score
  static String getScoreSeverity(double tScore) {
    if (tScore < 45) return 'low';
    if (tScore <= 55) return 'average';
    if (tScore <= 65) return 'elevated';
    return 'high';
  }
}