import 'package:flutter/foundation.dart';
import 'cache_manager.dart';
import 'providers/tts_cache_provider.dart';
import 'providers/shadowing_cache_provider.dart';
import 'providers/word_tts_cache_provider.dart';
import 'providers/chat_history_cache_provider.dart';

/// Initialize the cache system by registering all providers.
///
/// This should be called once during app startup, after Supabase is initialized.
///
/// Usage:
/// ```dart
/// // In main.dart or app initialization
/// await initializeCacheSystem();
/// ```
Future<void> initializeCacheSystem() async {
  debugPrint('CacheInitializer: Initializing cache system...');

  final manager = CacheManager();

  // Register all cache providers
  manager.register(TtsCacheProvider());
  manager.register(ShadowingCacheProvider());
  manager.register(WordTtsCacheProvider());
  manager.register(ChatHistoryCacheProvider());

  debugPrint(
    'CacheInitializer: Cache system initialized with ${manager.registeredTypes.length} providers',
  );
}

/// Get a summary of all cache sizes.
///
/// Returns a formatted string showing each cache type and its size.
/// Useful for displaying in settings page.
Future<String> getCacheSummary() async {
  final manager = CacheManager();
  final sizes = await manager.getAllCacheSizes();
  final total = await manager.getTotalCacheSize();

  final buffer = StringBuffer();
  for (final entry in sizes.entries) {
    buffer.writeln(
      '${entry.key.toString()}: ${CacheManager.formatBytes(entry.value)}',
    );
  }
  buffer.writeln('───────────────');
  buffer.writeln('Total: ${CacheManager.formatBytes(total)}');

  return buffer.toString();
}

/// Clear all user caches.
///
/// This should be called during logout to ensure user data is cleaned up.
Future<void> clearAllUserCaches() async {
  debugPrint('CacheInitializer: Clearing all user caches...');
  await CacheManager().clearAllUserCache();
  debugPrint('CacheInitializer: All user caches cleared');
}
