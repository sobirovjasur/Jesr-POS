import 'package:flutter/material.dart';

/// Design-system color tokens (Figma Draft — purple + neutral system).
///
/// Prefer reading colors through `Theme.of(context).colorScheme`; the values
/// here back that scheme (see [AppTheme]). Use these raw tokens only when a
/// semantic slot does not exist on [ColorScheme] (e.g. [success]).
class AppColors {
  // Prevents instantiation and extension
  AppColors._();

  /// Accent — buttons, active state, price, active nav, chips.
  static const Color primary = Color(0xFF9103E4);

  /// Text/icon on top of [primary].
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Primary text.
  static const Color textPrimary = Color(0xFF000000);

  /// Secondary text and icons.
  static const Color textSecondary = Color(0xFF84919A);

  /// Tertiary text (hints, least-emphasis labels).
  static const Color textTertiary = Color(0xFF9AA6AC);

  /// Surfaces, cards, background.
  static const Color surface = Color(0xFFFFFFFF);

  /// Subtle field/search/sheet background.
  static const Color surfaceSubtle = Color(0xFFF4F4F4);

  /// Alternate separator block surface.
  static const Color surfaceAlt = Color(0xFFEBEBEB);

  /// Borders and dividers.
  static const Color border = Color(0xFFD9D9D9);

  /// Passive/disabled icons.
  static const Color mutedIcon = Color(0xFFB0BABF);

  /// Success / "Synced" / online state / sufficient stock.
  static const Color success = Color(0xFF48C54A);

  /// Warning / limited (low) stock indicator.
  static const Color warning = Color(0xFFF9AA00);

  /// Error (red).
  static const Color error = Color(0xFFE5484D);

  // ---------------------------------------------------------------------------
  // Legacy tokens — kept for backward compatibility during the redesign.
  // Do NOT use in new code. These map onto the new palette where sensible.
  // ---------------------------------------------------------------------------

  static const Color white = Color(0xFFFFFFFF);

  @Deprecated('Use textPrimary')
  static const Color black = Color(0xFF212121);

  @Deprecated('Use primary')
  static const Color blue = Color(0xFF3886E3);

  @Deprecated('Use textPrimary')
  static const Color darkBlue = Color(0xFF1E293B);

  @Deprecated('Use primary or a semantic warning token')
  static const Color yellow = Color(0xFFF9AA00);

  @Deprecated('Use success')
  static const Color green = success;

  @Deprecated('Use error')
  static const Color red = error;

  @Deprecated('Use primary')
  static const Color orange = Color(0xFFFF8935);

  @Deprecated('Use primary')
  static const Color purple = Color(0xFF8C62FF);

  @Deprecated('Use a semantic token')
  static const Color cyan = Color(0xff00BCD3);

  @Deprecated('Use textSecondary')
  static const Color charcoal = Color(0xff28536B);

  @Deprecated('Use a semantic token')
  static const Color zamp = Color(0xff66A182);

  @Deprecated('Use primary')
  static const Color plum = Color(0xff66A182);
}
