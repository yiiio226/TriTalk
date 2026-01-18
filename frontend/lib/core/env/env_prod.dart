/// Production environment configuration
/// Used when running in release mode (kReleaseMode)
class EnvProd {
  static const String supabaseUrl = 'https://adrbhdqyrnwoxlszzzsd.supabase.co';
  // AnnonKey is legacy, now it is recommend to use PublishableKey based on supabase doc.
  // And this is not sensitive information, so it is safe to shared publicly
  static const String supabaseAnonKey =
      'sb_publishable_nRj0KP57IDdQ7558VhbN-w_Oqvtrl9O';

  static const String backendUrl =
      'https://tritalk-backend.tristart226.workers.dev';

  static const String googleOAuthIosClientId =
      '23529939770-aimiq75b1piq14d9mtusdqvfs2mf1mj1.apps.googleusercontent.com';
  static const String googleOAuthWebClientId =
      '23529939770-sb285ba3t0s286si1ip3ln773d80911l.apps.googleusercontent.com';

  // Debug flags - always false in production
  /// Force cloud TTS should always be false in production
  static const bool forceCloudTTS = false;
}
