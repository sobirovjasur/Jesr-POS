import 'package:flutter/widgets.dart';

/// Lightweight in-app translations.
///
/// Looked up by [Localizations.localeOf], so any widget that reads a string via
/// [BuildContext.tr] rebuilds automatically when the app locale changes.
///
/// NOTE: this currently covers the app chrome (navigation + key titles). The
/// remaining inline screen strings are still hardcoded Russian and will be
/// migrated here in a dedicated i18n pass.
class L10n {
  L10n._();

  static const Map<String, Map<String, String>> _values = {
    'nav_home': {'uz': 'Asosiy', 'ru': 'Главная', 'en': 'Home'},
    'nav_products': {'uz': 'Mahsulotlar', 'ru': 'Товары', 'en': 'Products'},
    'nav_receipts': {'uz': 'Cheklar', 'ru': 'Чеки', 'en': 'Receipts'},
    'nav_profile': {'uz': 'Profil', 'ru': 'Профиль', 'en': 'Profile'},
    'products_title': {'uz': 'Mahsulotlar', 'ru': 'Товары', 'en': 'Products'},
    'receipts_title': {'uz': 'Cheklar', 'ru': 'Чеки', 'en': 'Receipts'},
  };

  static String of(BuildContext context, String key) {
    final lang = Localizations.localeOf(context).languageCode;
    final entry = _values[key];
    if (entry == null) return key;
    return entry[lang] ?? entry['ru'] ?? key;
  }
}

extension L10nX on BuildContext {
  /// Translate [key] for the current locale. Falls back to Russian, then the key.
  String tr(String key) => L10n.of(this, key);
}
