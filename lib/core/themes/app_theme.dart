import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_sizes.dart';
import 'app_typography.dart';

/// Application theme (Figma Draft — purple + neutral, light-only).
///
/// The color scheme is built explicitly (not via `ColorScheme.fromSeed`) so the
/// neutral design tokens map 1:1 to Material slots. Every existing
/// `Theme.of(context).colorScheme.*` read therefore picks up the redesign with
/// no per-screen change. Dark mode was intentionally removed.
class AppTheme {
  // Make [AppTheme] to be singleton
  static final AppTheme _instance = AppTheme._();

  factory AppTheme() => _instance;

  AppTheme._();

  /// Builds the light theme. [brightness] is accepted for backward
  /// compatibility but ignored — the app is light-only.
  ThemeData init({
    Color? primaryColor,
    Color? secondaryColor,
    Color? tertiaryColor,
    Color? neutralColor,
    Brightness? brightness,
    TextTheme? primaryTextTheme,
    TextTheme? secondaryTextTheme,
  }) {
    return _base(_lightScheme);
  }

  /// Explicit light color scheme mapping design tokens to Material slots.
  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: Color(0xFFF1E2FC),
    onPrimaryContainer: AppColors.primary,
    secondary: AppColors.primary,
    onSecondary: AppColors.onPrimary,
    secondaryContainer: Color(0xFFF1E2FC),
    onSecondaryContainer: AppColors.primary,
    tertiary: AppColors.textSecondary,
    onTertiary: AppColors.onPrimary,
    error: AppColors.error,
    onError: AppColors.onPrimary,
    errorContainer: Color(0xFFFCE8E9),
    onErrorContainer: AppColors.error,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.textSecondary,
    outlineVariant: AppColors.textTertiary,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.surface,
    inversePrimary: Color(0xFFE0B6F8),
    surfaceTint: AppColors.primary,
    // Neutral surface ramp — backs scaffolds, fields, dividers, borders.
    surfaceDim: AppColors.border,
    surfaceBright: AppColors.surface,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.surfaceSubtle,
    surfaceContainer: AppColors.surfaceSubtle,
    surfaceContainerHigh: AppColors.surfaceAlt,
    surfaceContainerHighest: AppColors.border,
  );

  ThemeData _base(ColorScheme colorScheme) {
    final textTheme = AppTypography.textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
      decorationColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      fontFamily: AppTypography.fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shadowColor: colorScheme.outlineVariant,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleSpacing: AppSizes.padding,
        titleTextStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        indicatorColor: colorScheme.primaryContainer,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.surfaceContainerHighest,
        thickness: 0.5,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.primary,
        contentTextStyle: textTheme.labelSmall?.copyWith(color: colorScheme.onPrimary),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
        showCloseIcon: true,
        elevation: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
      ),
    );
  }
}
