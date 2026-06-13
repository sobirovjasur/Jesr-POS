/// A selectable phone country code shown in the phone-number field.
class CountryCode {
  final String name;
  final String dialCode;
  final String flag;
  final int phoneLength;

  const CountryCode({
    required this.name,
    required this.dialCode,
    required this.flag,
    required this.phoneLength,
  });
}

/// Supported country codes (Uzbekistan first / default).
const List<CountryCode> kCountryCodes = [
  CountryCode(name: 'Uzbekistan', dialCode: '+998', flag: '🇺🇿', phoneLength: 9),
  CountryCode(name: 'Russia', dialCode: '+7', flag: '🇷🇺', phoneLength: 10),
  CountryCode(name: 'Kazakhstan', dialCode: '+7', flag: '🇰🇿', phoneLength: 10),
  CountryCode(name: 'Kyrgyzstan', dialCode: '+996', flag: '🇰🇬', phoneLength: 9),
  CountryCode(name: 'Tajikistan', dialCode: '+992', flag: '🇹🇯', phoneLength: 9),
  CountryCode(name: 'Turkmenistan', dialCode: '+993', flag: '🇹🇲', phoneLength: 8),
  CountryCode(name: 'Turkey', dialCode: '+90', flag: '🇹🇷', phoneLength: 10),
  CountryCode(name: 'United States', dialCode: '+1', flag: '🇺🇸', phoneLength: 10),
];
