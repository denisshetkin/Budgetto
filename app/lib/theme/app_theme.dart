import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

TextTheme _bumpTextTheme(TextTheme theme, double delta) {
  TextStyle? bump(TextStyle? style) {
    if (style == null || style.fontSize == null) {
      return style;
    }
    return style.copyWith(fontSize: style.fontSize! + delta);
  }

  return theme.copyWith(
    displayLarge: bump(theme.displayLarge),
    displayMedium: bump(theme.displayMedium),
    displaySmall: bump(theme.displaySmall),
    headlineLarge: bump(theme.headlineLarge),
    headlineMedium: bump(theme.headlineMedium),
    headlineSmall: bump(theme.headlineSmall),
    titleLarge: bump(theme.titleLarge),
    titleMedium: bump(theme.titleMedium),
    titleSmall: bump(theme.titleSmall),
    bodyLarge: bump(theme.bodyLarge),
    bodyMedium: bump(theme.bodyMedium),
    bodySmall: bump(theme.bodySmall),
    labelLarge: bump(theme.labelLarge),
    labelMedium: bump(theme.labelMedium),
    labelSmall: bump(theme.labelSmall),
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final textTheme = GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );
  final scaledTextTheme = _bumpTextTheme(textTheme, 1.5);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentIncome,
      secondary: AppColors.accentExpense,
      surface: AppColors.surface1,
      onPrimary: AppColors.textPrimary,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: scaledTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: scaledTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface1,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.stroke, width: 1),
      ),
    ),
    dividerColor: AppColors.stroke,
    iconTheme: const IconThemeData(color: AppColors.textSecondary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: scaledTextTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.surface2
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.textPrimary
              : AppColors.textSecondary,
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppColors.stroke, width: 1),
        ),
      ),
    ),
  );
}
