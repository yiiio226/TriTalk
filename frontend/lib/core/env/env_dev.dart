/// Development environment configuration
/// Used when running in kDebugMode
class EnvDev {
  static const String supabaseUrl = 'https://adrbhdqyrnwoxlszzzsd.supabase.co';
  // AnnonKey is legacy, now it is recommend to use PublishableKey based on supabase doc.
  // And this is not sensitive information, so it is safe to shared publicly
  static const String supabaseAnonKey =
      'sb_publishable_nRj0KP57IDdQ7558VhbN-w_Oqvtrl9O';

  // For local development, you can use your local backend URL
  // static const String backendUrl = 'http://192.168.1.3:8787';
  // Or use the deployed backend for development
  static const String backendUrl =
      'https://tritalk-backend.tristart226.workers.dev';

  static const String googleOAuthIosClientId =
      '23529939770-aimiq75b1piq14d9mtusdqvfs2mf1mj1.apps.googleusercontent.com';
  static const String googleOAuthWebClientId =
      '23529939770-sb285ba3t0s286si1ip3ln773d80911l.apps.googleusercontent.com';

  // Debug flags
  /// When true, Word TTS will skip local cache and local TTS engine,
  /// always using cloud API (GCP Vertex AI) for testing purposes.
  static const bool forceCloudTTS = false;
}
