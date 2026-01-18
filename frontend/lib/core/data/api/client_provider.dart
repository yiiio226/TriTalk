import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/swagger_generated_code/swagger.swagger.dart';
import 'auth_interceptor.dart';
import 'package:frontend/core/env/env.dart';

/// Provides a singleton instance of the generated Swagger API client.
///
/// Environment switching is handled automatically by [Env.backendUrl]:
/// - Debug mode (flutter run): Uses development backend URL
/// - Release mode (flutter build): Uses production backend URL
class ClientProvider {
  static Swagger? _instance;

  /// Returns the singleton Swagger API client instance.
  static Swagger get client {
    _instance ??= Swagger.create(
      baseUrl: Uri.parse(Env.backendUrl),
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
