import 'package:flutter/material.dart';

/// Design-system typography (Figma Draft — SF Pro Display).
///
/// Sizes and weights map 1:1 to the design spec. The bundled font only ships
/// Regular (w400), Medium (w500) and Bold (w700); design "Semibold" (w600) is
/// therefore mapped to [semibold] = w500 until a full SF Pro pack is supplied.
/// Swap [semibold] to [FontWeight.w600] once a Semibold asset is bundled.
class AppTypography {
  // Prevents instantiation and extension
  AppTypography._();

  static const String fontFamily = 'SF Pro Display';

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;

  /// Design "Semibold". Mapped to Medium (w500) — see class doc.
  static const FontWeight semibold = FontWeight.w500;

  static const FontWeight bold = FontWeight.w700;

  /// 10/Bold — tiny labels. Not a Material slot; use directly where needed.
  static const TextStyle labelTiny = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: bold,
    height: 1.2,
  );

  /// Full Material 3 [TextTheme] built from the design spec. Colors are applied
  /// by [AppTheme] via `.apply(bodyColor:, displayColor:)`.
  static const TextTheme textTheme = TextTheme(
    // 26 / Regular — large amount / heading.
    displayLarge: TextStyle(fontFamily: fontFamily, fontSize: 26, fontWeight: regular, height: 1.2),
    displayMedium: TextStyle(fontFamily: fontFamily, fontSize: 26, fontWeight: regular, height: 1.2),
    displaySmall: TextStyle(fontFamily: fontFamily, fontSize: 26, fontWeight: regular, height: 1.2),

    // Headlines reuse the section/heading scale.
    headlineLarge: TextStyle(fontFamily: fontFamily, fontSize: 22, fontWeight: semibold, height: 1.2),
    headlineMedium: TextStyle(fontFamily: fontFamily, fontSize: 20, fontWeight: semibold, height: 1.2),
    headlineSmall: TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: semibold, height: 1.2),

    // 20 / Semibold — section title.
    titleLarge: TextStyle(fontFamily: fontFamily, fontSize: 20, fontWeight: semibold, height: 1.25),
    // 17 / Semibold — AppBar title.
    titleMedium: TextStyle(fontFamily: fontFamily, fontSize: 17, fontWeight: semibold, height: 1.25),
    titleSmall: TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: semibold, height: 1.3),

    // 16 / Regular — primary body.
    bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: regular, height: 1.4),
    // 15 / Regular — body.
    bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: regular, height: 1.4),
    // 13 / Regular — caption / secondary.
    bodySmall: TextStyle(fontFamily: fontFamily, fontSize: 13, fontWeight: regular, height: 1.35),

    // 15 / Semibold — button text / emphasis.
    labelLarge: TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: semibold, height: 1.2),
    // 10 / Bold — tiny label (mirrors [labelTiny]).
    labelMedium: TextStyle(fontFamily: fontFamily, fontSize: 10, fontWeight: bold, height: 1.2),
    // 11 / Semibold — label / overline.
    labelSmall: TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: semibold, height: 1.2),
  );
}
