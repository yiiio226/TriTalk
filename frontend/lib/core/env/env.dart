import 'env_config.dart';
import 'env_dev.dart';
import 'env_local.dart';
import 'env_prod.dart';

/// Environment configuration that selects local/dev/prod based on
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
  /// Current environment type
  static Environment get current => EnvConfig.current;

  /// Environment name for logging
  static String get name => EnvConfig.name;

  static String get supabaseUrl {
    switch (EnvConfig.current) {
      case Environment.local:
        return EnvLocal.supabaseUrl;
      case Environment.dev:
        return EnvDev.supabaseUrl;
      case Environment.prod:
        return EnvProd.supabaseUrl;
    }
  }

  static String get supabaseAnonKey {
    switch (EnvConfig.current) {
      case Environment.local:
        return EnvLocal.supabaseAnonKey;
      case Environment.dev:
        return EnvDev.supabaseAnonKey;
      case Environment.prod:
        return EnvProd.supabaseAnonKey;
    }
  }

  static String get backendUrl {
    switch (EnvConfig.current) {
      case Environment.local:
        return EnvLocal.backendUrl;
      case Environment.dev:
        return EnvDev.backendUrl;
      case Environment.prod:
        return EnvProd.backendUrl;
    }
  }

  static String get googleOAuthIosClientId {
    switch (EnvConfig.current) {
      case Environment.local:
        return EnvLocal.googleOAuthIosClientId;
      case Environment.dev:
        return EnvDev.googleOAuthIosClientId;
      case Environment.prod:
        return EnvProd.googleOAuthIosClientId;
    }
  }

  static String get googleOAuthWebClientId {
    switch (EnvConfig.current) {
      case Environment.local:
        return EnvLocal.googleOAuthWebClientId;
      case Environment.dev:
        return EnvDev.googleOAuthWebClientId;
      case Environment.prod:
        return EnvProd.googleOAuthWebClientId;
    }
  }

  static bool get forceCloudTTS {
    switch (EnvConfig.current) {
      case Environment.local:
        return EnvLocal.forceCloudTTS;
      case Environment.dev:
        return EnvDev.forceCloudTTS;
      case Environment.prod:
        return EnvProd.forceCloudTTS;
    }
  }

  static String get revenueCatAppleApiKey {
    switch (EnvConfig.current) {
      case Environment.local:
        return EnvLocal.revenueCatAppleApiKey;
      case Environment.dev:
        return EnvDev.revenueCatAppleApiKey;
      case Environment.prod:
        return EnvProd.revenueCatAppleApiKey;
    }
  }

  static String get revenueCatGoogleApiKey {
    switch (EnvConfig.current) {
      case Environment.local:
        return EnvLocal.revenueCatGoogleApiKey;
      case Environment.dev:
        return EnvDev.revenueCatGoogleApiKey;
      case Environment.prod:
        return EnvProd.revenueCatGoogleApiKey;
    }
  }

  /// Base URL for scene assets on Cloudflare R2
  static String get sceneAssetsBaseUrl {
    switch (EnvConfig.current) {
      case Environment.local:
        return EnvLocal.sceneAssetsBaseUrl;
      case Environment.dev:
        return EnvDev.sceneAssetsBaseUrl;
      case Environment.prod:
        return EnvProd.sceneAssetsBaseUrl;
    }
  }
}
