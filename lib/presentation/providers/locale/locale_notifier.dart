import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/app_locale.dart';

final localeNotifierProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

/// Holds the app language. Persisted across launches via SharedPreferences.
///
/// NOTE: changing the locale currently only affects Material's built-in
/// localizations — the app's own strings are still hardcoded Russian until a
/// full i18n (ARB) pass is done. The selection is stored so that pass can apply
/// it later.
class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'locale_code';

  @override
  Locale build() {
    _load();
    return AppLocale.defaultLocale;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && code.isNotEmpty) state = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}
