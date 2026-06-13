import 'package:flutter/widgets.dart';

/// Centralized border-radius tokens for the design system.
///
/// Replaces scattered hardcoded `BorderRadius.circular(N)` calls. Use the
/// semantic constants below instead of raw numbers so the redesign stays 1:1
/// with Figma and any future change is made in one place.
class AppRadius {
  // Prevents instantiation and extension
  AppRadius._();

  /// Cards, buttons, inputs, sheets — the default surface radius.
  static const double card = 12;

  /// Alias of [card] for call sites that read better as a button radius.
  static const double button = 12;

  /// Alias of [card] for inputs/text fields.
  static const double input = 12;

  /// Alias of [card] for bottom sheets.
  static const double sheet = 12;

  /// Small elements: chips, stock indicators, thumbnails.
  static const double small = 4;

  /// Large bottom sheets (optional, e.g. sliding-up panels).
  static const double sheetLarge = 24;

  /// Fully rounded (pills, avatars, status dots).
  static const double pill = 100;

  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius smallAll = BorderRadius.all(Radius.circular(small));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius sheetLargeAll = BorderRadius.all(Radius.circular(sheetLarge));
}
