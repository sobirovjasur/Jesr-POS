import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../providers/theme/theme_state.dart';

final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);

/// Provides the application theme.
///
/// The app is light-only (dark mode was removed in the redesign), so this
/// notifier simply exposes the single light [ThemeData].
class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return ThemeState(themeData: AppTheme().init());
  }
}
