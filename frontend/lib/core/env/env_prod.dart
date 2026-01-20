/// Production environment configuration
/// Used when running in release mode (kReleaseMode)
/// TODO(cyb): configure the correct supabase url and key
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

  // RevenueCat API Keys
  // TODO: Add your actual RevenueCat production API keys from dashboard
  static const String revenueCatAppleApiKey = 'appl_production_xxx';
  static const String revenueCatGoogleApiKey = 'goog_production_xxx';

  // Debug flags - always false in production
  /// Force cloud TTS should always be false in production
  static const bool forceCloudTTS = false;

  // Scene Assets (Cloudflare R2)
  /// Base URL for scene icon assets stored on R2
  /// TODO: Production should bind a custom domain (e.g. https://assets.tritalk.com/)
  /// Currently using development R2 URL
  static const String sceneAssetsBaseUrl =
      'https://pub-a8095655217d4956a5672905a708a218.r2.dev/tritalk/dev/assets/';
}
