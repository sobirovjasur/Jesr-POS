class Constants {
  // Prevents instantiation and extension
  Constants._();

  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  /// API key for remove.bg (background removal on product/profile images).
  /// Supplied via `--dart-define REMOVE_BG_API_KEY=...` (e.g. in config.json).
  static const removeBgApiKey = String.fromEnvironment('REMOVE_BG_API_KEY');

  /// Default country dialing code prefixed to phone-based logins.
  static const String phoneCountryCode = '+998';

  /// Domain for the synthetic email derived from a phone number. Firebase
  /// email/password auth backs the phone+password login, mapping each phone to
  /// a deterministic `<digits>@<domain>` address (never shown to users).
  static const String phoneAuthEmailDomain = 'pocketpos.app';

  static const String selectedDeviceIdKey = 'selected_device_id';
  static const String selectedConnectionTypeKey = 'selected_connection_type';
  static const String selectedPaperSizeKey = 'selected_paper_size';
  static const String selectedBrightnessKey = 'selected_brightness';

  static const int minSyncIntervalToleranceForCriticalInMinutes = 5;
  static const int minSyncIntervalToleranceForLessCriticalInMinutes = 100;

  // Google OAuth scopes required for user authentication
  static const List<String> authScopes = [
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/userinfo.email',
  ];

  // Non-critical error libraries that should be logged but not navigate to error screen
  static const nonCriticalErrorLibraries = {
    'image resource service',
  };
}
