import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocale {
  // Prevents instantiation and extension
  AppLocale._();

  static Locale defaultLocale = const Locale('ru');
  static String defaultPhoneCode = '+998';
  static String defaultCurrencyCode = 'UZS';

  static const List<Locale> supportedLocales = [
    Locale('uz'),
    Locale('ru'),
    Locale('en'),
  ];

  static const List<LocalizationsDelegate> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
}
