/// Local development environment configuration
/// Used when running with --dart-define=ENV=local (or no ENV specified)
///
/// This configuration connects to a local backend for development.
class EnvLocal {
  // For local development, connect to localhost
  // Change to your machine's IP address for real device testing
  // static const String backendUrl = 'http://192.168.1.3:8787';
  static const String backendUrl = 'http://localhost:8787';

  // Supabase configuration (same as dev for now)
  static const String supabaseUrl = 'https://adrbhdqyrnwoxlszzzsd.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_nRj0KP57IDdQ7558VhbN-w_Oqvtrl9O';

  // Google OAuth configuration
  static const String googleOAuthIosClientId =
      '23529939770-aimiq75b1piq14d9mtusdqvfs2mf1mj1.apps.googleusercontent.com';
  static const String googleOAuthWebClientId =
      '23529939770-sb285ba3t0s286si1ip3ln773d80911l.apps.googleusercontent.com';

  // RevenueCat API Keys (same as dev for local testing)
  // TODO: Add your actual RevenueCat API keys from dashboard
  static const String revenueCatAppleApiKey = 'appl_xxx';
  static const String revenueCatGoogleApiKey = 'goog_xxx';

  // Debug flags
  /// When true, Word TTS will skip local cache and local TTS engine,
  /// always using cloud API (GCP Vertex AI) for testing purposes.
  static const bool forceCloudTTS = false;
}
