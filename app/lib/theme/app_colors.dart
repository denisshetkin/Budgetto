import 'package:flutter/material.dart';

@immutable
class AppPalette {
  const AppPalette({
    required this.background,
    required this.surface1,
    required this.surface2,
    required this.stroke,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentExpense,
    required this.accentIncome,
    required this.chipBlue,
    required this.accentNeutral,
    required this.accentTotal,
    required this.accentDisplay,
    required this.categoryPalette,
  });

  final Color background;
  final Color surface1;
  final Color surface2;
  final Color stroke;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentExpense;
  final Color accentIncome;
  final Color chipBlue;
  final Color accentNeutral;
  final Color accentTotal;
  final Color accentDisplay;
  final List<Color> categoryPalette;
}

class AppColors {
  static const AppPalette dark = AppPalette(
    background: Color(0xFF0B1220),
    surface1: Color(0xFF16213A),
    surface2: Color(0xFF1E2B4C),
    stroke: Color(0xFF2B3A5C),
    textPrimary: Color(0xFFE6EAF2),
    textSecondary: Color(0xFFF2F5FB),
    accentExpense: Color(0xFFFF6B6B),
    accentIncome: Color(0xFF6C8BF5),
    chipBlue: Color(0xFF3E6CFF),
    accentNeutral: Color(0xFF5C6B86),
    accentTotal: Color(0xFFF2D16B),
    accentDisplay: Color(0xFF7EDB6A),
    categoryPalette: [
      Color(0xFFFF8C8C),
      Color(0xFFF4B266),
      Color(0xFFF2D16B),
      Color(0xFF9AD27A),
      Color(0xFF6CBAD9),
      Color(0xFF8C9BFF),
      Color(0xFFC08CFF),
      Color(0xFFFF9FD2),
      Color(0xFF7BD3C2),
      Color(0xFFB0B7C3),
    ],
  );

  static const AppPalette light = AppPalette(
    background: Color(0xFFF6F7FB),
    surface1: Color(0xFFFFFFFF),
    surface2: Color(0xFFF0F3FA),
    stroke: Color(0xFFD7DDE8),
    textPrimary: Color(0xFF1C2432),
    textSecondary: Color(0xFF51607A),
    accentExpense: Color(0xFFE25555),
    accentIncome: Color(0xFF4B6FE8),
    chipBlue: Color(0xFF3E6CFF),
    accentNeutral: Color(0xFF6B7A95),
    accentTotal: Color(0xFFD9B95A),
    accentDisplay: Color(0xFF3F9E5C),
    categoryPalette: [
      Color(0xFFE96969),
      Color(0xFFE09A4C),
      Color(0xFFD9B95A),
      Color(0xFF6FB36E),
      Color(0xFF4FA7C7),
      Color(0xFF5B74E6),
      Color(0xFF8A63E6),
      Color(0xFFE27DB2),
      Color(0xFF53B7A6),
      Color(0xFF9099AA),
    ],
  );

  static AppPalette _palette = dark;

  static void setThemeMode(ThemeMode mode) {
    _palette = mode == ThemeMode.light ? light : dark;
  }

  static Color get background => _palette.background;
  static Color get surface1 => _palette.surface1;
  static Color get surface2 => _palette.surface2;
  static Color get stroke => _palette.stroke;
  static Color get textPrimary => _palette.textPrimary;
  static Color get textSecondary => _palette.textSecondary;
  static Color get accentExpense => _palette.accentExpense;
  static Color get accentIncome => _palette.accentIncome;
  static Color get chipBlue => _palette.chipBlue;
  static Color get accentNeutral => _palette.accentNeutral;
  static Color get accentTotal => _palette.accentTotal;
  static Color get accentDisplay => _palette.accentDisplay;
  static List<Color> get categoryPalette => _palette.categoryPalette;
}
