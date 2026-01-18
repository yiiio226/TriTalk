// Cache module barrel file.
//
// This module provides centralized cache management for TriTalk.
//
// Usage:
// ```dart
// import 'package:frontend/core/cache/cache.dart';
//
// // Initialize cache system (call once at app startup)
// await initializeCacheSystem();
//
// // Check cache existence
// final exists = await CacheManager().hasCache(CacheType.ttsCache, 'msg_001');
//
// // Clear all caches on logout
// await CacheManager().clearAllUserCache();
//
// // Get cache statistics
// final sizes = await CacheManager().getAllCacheSizes();
// ```

export 'cache_manager.dart';
export 'cache_initializer.dart';
export 'cache_constants.dart';
export 'providers/tts_cache_provider.dart';
export 'providers/shadowing_cache_provider.dart';
export 'providers/word_tts_cache_provider.dart';
export 'providers/chat_history_cache_provider.dart';
