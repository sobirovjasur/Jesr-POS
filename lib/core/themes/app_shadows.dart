import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Design-system shadow tokens.
///
/// The Figma Draft is intentionally flat: most cards use a 1px border
/// ([AppColors.border]) and little-to-no elevation. Use [card] for the rare
/// surface that needs a soft lift; prefer a border for everything else.
class AppShadows {
  // Prevents instantiation and extension
  AppShadows._();

  /// Soft card shadow: ~6% black, blur 14, y-offset 3.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F000000), // #000 @ ~6%
      blurRadius: 14,
      offset: Offset(0, 3),
    ),
  ];

  /// Slightly stronger lift for sheets / floating surfaces.
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x14000000), // #000 @ ~8%
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Standard hairline border used in place of a shadow on flat cards.
  static Border get border => Border.all(color: AppColors.border, width: 1);
}
