import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/swagger_generated_code/swagger.swagger.dart';
import 'auth_interceptor.dart';
import 'package:frontend/core/env/env.dart';

/// Provides a singleton instance of the generated Swagger API client.
///
/// Environment switching:
/// - Debug mode (flutter run): Uses [Env.localBackendUrl]
/// - Release mode (flutter build): Uses [Env.prodBackendUrl]
///
/// To force production URL in debug mode, use:
/// ```bash
/// flutter run --dart-define=USE_PROD=true
/// ```
class ClientProvider {
  static Swagger? _instance;

  /// Whether to use production URL (can be overridden via --dart-define=USE_PROD=true)
  static const bool _useProd = bool.fromEnvironment(
    'USE_PROD',
    defaultValue: false,
  );

  /// The base URL determined by environment
  static String get _baseUrl {
    // Use production URL if:
    // 1. Running in release mode, OR
    // 2. USE_PROD=true is explicitly set
    if (kReleaseMode || _useProd) {
      return Env.prodBackendUrl;
    }
    return Env.localBackendUrl;
  }

  /// Returns the singleton Swagger API client instance.
  static Swagger get client {
    _instance ??= Swagger.create(
      baseUrl: Uri.parse(_baseUrl),
      interceptors: [
        AuthInterceptor(),
        // Only enable HTTP logging in debug mode
        if (kDebugMode) HttpLoggingInterceptor(),
      ],
    );
    return _instance!;
  }

  /// Resets the client instance (useful for testing or re-initialization).
  @visibleForTesting
  static void reset() {
    _instance = null;
  }
}
