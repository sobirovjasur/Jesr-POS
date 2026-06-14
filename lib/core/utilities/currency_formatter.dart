import 'package:intl/intl.dart';

import '../locale/app_locale.dart';

/// Currency formatter. Produces space-grouped amounts with the [AppLocale]
/// currency code, e.g. `12 000 000 UZS`.
class CurrencyFormatter {
  CurrencyFormatter._();

  static const int defaultDecimalDigits = 0;

  static final NumberFormat _grouped = NumberFormat('#,##0');

  /// Groups thousands with spaces, e.g. `12000000` -> `12 000 000`.
  static String _number(num data) => _grouped.format(data).replaceAll(',', ' ');

  /// Amount with the currency suffix, e.g. `12 000 000 UZS`.
  static String format(num data, {int? decimalDigits}) => '${_number(data)} ${AppLocale.defaultCurrencyCode}';

  /// Compact amount with the currency suffix, e.g. `12 mln UZS`.
  static String compact(num data, {int? decimalDigits, bool withSymbol = true}) {
    final value = NumberFormat.compact().format(data);
    return withSymbol ? '$value ${AppLocale.defaultCurrencyCode}' : value;
  }

  /// Amount without any currency suffix, e.g. `12 000 000`.
  static String withoutSymbol(num data, {int? decimalDigits}) => _number(data);

  static String currencySymbol() => AppLocale.defaultCurrencyCode;
}
