import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:frontend/core/env/env.dart';
import '../data/local/preferences_service.dart';
import '../auth/auth_provider.dart';
import '../services/streaming_tts_service.dart';
import '../cache/cache_initializer.dart';
import 'package:frontend/features/subscription/presentation/feature_gate.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

/// Provider for app initialization status
final appInitializerProvider = FutureProvider<bool>((ref) async {
  return AppInitializer.initialize(ref);
});

/// Handles all app initialization logic
///
/// This class centralizes initialization of:
/// - Supabase client
/// - SharedPreferences
/// - Auth state
class AppInitializer {
  /// Initialize all app dependencies
  ///
  /// This should be called before the app starts rendering.
  /// Returns true if initialization was successful.
  static Future<bool> initialize(Ref ref) async {
    try {
      if (kDebugMode) {
        debugPrint('AppInitializer: Starting initialization...');
      }

      // 1. Initialize Supabase
      await _initSupabase();
      if (kDebugMode) {
        debugPrint('AppInitializer: Supabase initialized');
      }

      // 2. Initialize SharedPreferences
      await _initPreferences();
      if (kDebugMode) {
        debugPrint('AppInitializer: SharedPreferences initialized');
      }

      // 3. Initialize Auth State
      await ref.read(authProvider.notifier).initialize();
      if (kDebugMode) {
        debugPrint('AppInitializer: Auth state initialized');
      }

      if (kDebugMode) {
        debugPrint('AppInitializer: ✅ All initializations complete');
      }

      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('AppInitializer: ❌ Initialization failed: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return false;
    }
  }

  /// Initialize Supabase client
  static Future<void> _initSupabase() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      debug: kDebugMode,
      postgrestOptions: PostgrestClientOptions(schema: Env.supabaseSchema),
    );
  }

  /// Initialize SharedPreferences and PreferencesService
  static Future<void> _initPreferences() async {
    await PreferencesService().init();
  }
}

/// Alternative initialization method for use in main.dart
/// before ProviderScope is created
class AppBootstrap {
  static SharedPreferences? _prefs;

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('AppBootstrap.initialize() must be called first');
    }
    return _prefs!;
  }

  /// Bootstrap the app before creating ProviderScope
  ///
  /// This initializes dependencies that need to be available
  /// before Riverpod providers are created.
  static Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('AppBootstrap: Starting bootstrap...');
    }

    // Initialize environment configuration first (loads .env file)
    await Env.init();
    if (kDebugMode) {
      debugPrint(
        '\n\n\n ✅✅AppBootstrap: Environment loaded. with schema (${Env.name}), (${Env.supabaseSchema})',
      );
    }

    // Initialize Supabase
    // Use schema from environment variable for consistency
    if (kDebugMode) {
      debugPrint('🔍 [Supabase] Initializing with:');
      debugPrint('🔍 [Supabase] URL: ${Env.supabaseUrl}');
      debugPrint('🔍 [Supabase] Schema: ${Env.supabaseSchema}');
    }

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      debug: kDebugMode,
      postgrestOptions: PostgrestClientOptions(schema: Env.supabaseSchema),
    );

    if (kDebugMode) {
      debugPrint('🔍 [Supabase] ✅ Initialization complete');
      debugPrint(
        '🔍 [Supabase] Client schema: ${Supabase.instance.client.rest.schema}',
      );
    }

    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();

    // Initialize PreferencesService
    await PreferencesService().init();

    // Initialize Cache System
    await initializeCacheSystem();
    if (kDebugMode) {
      debugPrint('AppBootstrap: Cache system initialized');
    }

    // Initialize Feature Gate (Quota System)
    await FeatureGate().initialize();
    if (kDebugMode) {
      debugPrint('AppBootstrap: FeatureGate initialized');
    }

    // Initialize SoLoud audio engine for streaming TTS
    try {
      await StreamingTtsService.instance.initialize();
      if (kDebugMode) {
        debugPrint('AppBootstrap: SoLoud audio engine initialized');
      }
    } catch (e) {
      // Non-fatal: app can still work without streaming TTS
      if (kDebugMode) {
        debugPrint('AppBootstrap: ⚠️ SoLoud init failed (non-fatal): $e');
      }
    }

    if (kDebugMode) {
      debugPrint('AppBootstrap: ✅ Bootstrap complete');
    }
  }
}
