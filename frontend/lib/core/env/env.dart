import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'env_config.dart';

/// Environment configuration that loads values from .env files based on
/// the --dart-define=ENV compile-time parameter.
///
/// Build commands:
/// ```bash
/// # Local development (connects to localhost backend)
/// flutter run --dart-define=ENV=local
///
/// # Dev build (connects to dev backend)
/// flutter run --dart-define=ENV=dev
/// flutter build ios --dart-define=ENV=dev
///
/// # Production build
/// flutter build ios --dart-define=ENV=prod --release
/// flutter build apk --dart-define=ENV=prod --release
/// ```
class Env {
  /// Track initialization state
  static bool _initialized = false;

  /// Initialize the environment configuration by loading the appropriate .env file.
  /// This must be called before accessing any environment values.
  static Future<void> init() async {
    if (_initialized) return;

    final envFile = 'assets/env/.env.${EnvConfig.name}';
    await dotenv.load(fileName: envFile);
    _initialized = true;
  }

  /// Current environment type
  static Environment get current => EnvConfig.current;

  /// Environment name for logging
  static String get name => EnvConfig.name;

  /// Supabase project URL
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase anonymous/publishable key
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Supabase db schema name
  static String get supabaseSchema => dotenv.env['SUPABASE_SCHEMA'] ?? '';

  /// Backend API URL
  static String get backendUrl => dotenv.env['BACKEND_URL'] ?? '';

  /// Google OAuth iOS Client ID
  static String get googleOAuthIosClientId =>
      dotenv.env['GOOGLE_OAUTH_IOS_CLIENT_ID'] ?? '';

  /// Google OAuth Web Client ID
  static String get googleOAuthWebClientId =>
      dotenv.env['GOOGLE_OAUTH_WEB_CLIENT_ID'] ?? '';

  /// Force Cloud TTS flag
  /// When true, Word TTS will skip local cache and local TTS engine,
  /// always using cloud API (GCP Vertex AI) for testing purposes.
  static bool get forceCloudTTS =>
      dotenv.env['FORCE_CLOUD_TTS']?.toLowerCase() == 'true';

  /// RevenueCat Apple API Key
  static String get revenueCatAppleApiKey =>
      dotenv.env['REVENUE_CAT_APPLE_API_KEY'] ?? '';

  /// RevenueCat Google API Key
  static String get revenueCatGoogleApiKey =>
      dotenv.env['REVENUE_CAT_GOOGLE_API_KEY'] ?? '';

  /// Base URL for scene assets on Cloudflare R2
  static String get sceneAssetsBaseUrl =>
      dotenv.env['SCENE_ASSETS_BASE_URL'] ?? '';

  /// Force show paywall not matter for user status.
  static bool get forcePaywall =>
      dotenv.env['FORCE_PAYWALL']?.toLowerCase() == 'true';

  /// Skip VIP check for testing purposes.
  static bool get skipVipCheck =>
      dotenv.env['SKIP_VIP_CHECK']?.toLowerCase() == 'true';
}
