import 'package:flutter/foundation.dart';

import 'env_dev.dart';
import 'env_prod.dart';

/// Environment configuration that automatically selects dev or prod
/// based on the current build mode.
///
/// - kDebugMode: Uses [EnvDev] configuration
/// - kReleaseMode/kProfileMode: Uses [EnvProd] configuration
class Env {
  static String get supabaseUrl =>
      kDebugMode ? EnvDev.supabaseUrl : EnvProd.supabaseUrl;

  static String get supabaseAnonKey =>
      kDebugMode ? EnvDev.supabaseAnonKey : EnvProd.supabaseAnonKey;

  static String get backendUrl =>
      kDebugMode ? EnvDev.backendUrl : EnvProd.backendUrl;

  static String get googleOAuthIosClientId => kDebugMode
      ? EnvDev.googleOAuthIosClientId
      : EnvProd.googleOAuthIosClientId;

  static String get googleOAuthWebClientId => kDebugMode
      ? EnvDev.googleOAuthWebClientId
      : EnvProd.googleOAuthWebClientId;

  static bool get forceCloudTTS =>
      kDebugMode ? EnvDev.forceCloudTTS : EnvProd.forceCloudTTS;
}
