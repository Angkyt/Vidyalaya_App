import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF1E2A4A);
  static const Color teal = Color(0xFF14857A);
  static const Color tealLight = Color(0xFFB8E4DE);

  // Light mode
  static const Color lightBackground = Color(0xFFFAF7F2);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightInput = Color(0xFFF1EDE6);
  static const Color lightBorder = Color(0xFFE5E0D8);
  static const Color lightTextPrimary = Color(0xFF1E2A4A);
  static const Color lightTextSecondary = Color(0xFF7B7F8C);
  static const Color lightTextHint = Color(0xFFB0B3BC);

  // Dark mode
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1F2937);
  static const Color darkInput = Color(0xFF273244);
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextHint = Color(0xFF6B7280);

  // Status / priority
  static const Color highPriority = Color(0xFFE74C3C);
  static const Color mediumPriority = Color(0xFFF5A623);
  static const Color lowPriority = Color(0xFF7ED321);
  static const Color completed = Color(0xFF14857A);

  // Calendar dots
  static const Color dotYellow = Color(0xFFF5C84B);
  static const Color dotBlue = Color(0xFF4A90E2);

  static const Color errorRed = Color(0xFFE74C3C);
  static const Color successGreen = Color(0xFF10B981);
}

/// Convenience extension for theme-aware colors
extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get cardColor =>
      isDark ? AppColors.darkCard : AppColors.lightCard;
  Color get inputColor =>
      isDark ? AppColors.darkInput : AppColors.lightInput;
  Color get borderColor =>
      isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get textPrimary =>
      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary =>
      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textHint =>
      isDark ? AppColors.darkTextHint : AppColors.lightTextHint;
  Color get bgColor =>
      isDark ? AppColors.darkBackground : AppColors.lightBackground;
}

class AppTheme {
  static ThemeData _base(Brightness b) {
    final isDark = b == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final txt =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sec =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      scaffoldBackgroundColor: bg,
      primaryColor: AppColors.primary,
      cardColor: card,
      colorScheme: ColorScheme(
        brightness: b,
        primary: isDark ? AppColors.teal : AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.teal,
        onSecondary: Colors.white,
        surface: card,
        onSurface: txt,
        error: AppColors.errorRed,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge:
            TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: txt),
        headlineMedium:
            TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: txt),
        titleLarge:
            TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: txt),
        titleMedium:
            TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: txt),
        bodyLarge: TextStyle(fontSize: 15, color: txt),
        bodyMedium: TextStyle(fontSize: 14, color: txt),
        bodySmall: TextStyle(fontSize: 12, color: sec),
      ),
      iconTheme: IconThemeData(color: txt),
      dividerColor:
          isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }

  static ThemeData get light => _base(Brightness.light);
  static ThemeData get dark => _base(Brightness.dark);
}
