/// Environment types supported by the app
enum Environment { local, dev, prod }

/// Configuration class that reads environment type from compile-time definition.
///
/// Usage:
/// ```bash
/// # Local development (connects to localhost backend)
/// flutter run --dart-define=ENV=local
///
/// # Dev build (connects to dev backend)
/// flutter build ios --dart-define=ENV=dev
///
/// # Production build
/// flutter build ios --dart-define=ENV=prod --release
/// ```
class EnvConfig {
  /// Read ENV from --dart-define, defaults to 'local' if not specified
  static const String _envString = String.fromEnvironment(
    'ENV',
    defaultValue: 'local',
  );

  /// Get the current environment
  static Environment get current {
    switch (_envString) {
      case 'prod':
        return Environment.prod;
      case 'dev':
        return Environment.dev;
      case 'local':
      default:
        return Environment.local;
    }
  }

  /// Convenience getters
  static bool get isLocal => current == Environment.local;
  static bool get isDev => current == Environment.dev;
  static bool get isProd => current == Environment.prod;

  /// Get environment name for logging
  static String get name => _envString;
}
