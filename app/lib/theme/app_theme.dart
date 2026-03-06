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

ThemeData buildAppTheme({required AppPalette palette, required Brightness brightness}) {
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  final textTheme = GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
    bodyColor: palette.textPrimary,
    displayColor: palette.textPrimary,
  );
  final scaledTextTheme = _bumpTextTheme(textTheme, 2.5);

  return base.copyWith(
    scaffoldBackgroundColor: palette.background,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: palette.accentIncome,
      onPrimary: palette.textPrimary,
      secondary: palette.accentExpense,
      onSecondary: palette.textPrimary,
      background: palette.background,
      onBackground: palette.textPrimary,
      surface: palette.surface1,
      onSurface: palette.textPrimary,
      error: palette.accentExpense,
      onError: palette.textPrimary,
    ),
    textTheme: scaledTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: scaledTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      iconTheme: IconThemeData(color: palette.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: palette.surface1,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: palette.stroke, width: 1),
      ),
    ),
    dividerColor: palette.stroke,
    iconTheme: IconThemeData(color: palette.textSecondary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: scaledTextTheme.bodyMedium?.copyWith(
        color: palette.textSecondary,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.surface2
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.textPrimary
              : palette.textSecondary,
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: palette.stroke, width: 1),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStatePropertyAll(
        scaledTextTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  return buildAppTheme(palette: AppColors.dark, brightness: Brightness.dark);
}

ThemeData buildLightTheme() {
  return buildAppTheme(palette: AppColors.light, brightness: Brightness.light);
}
