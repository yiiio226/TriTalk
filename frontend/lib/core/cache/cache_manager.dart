// lib/core/cache/cache_manager.dart
import 'package:flutter/foundation.dart';

/// Supported cache types in the application.
///
/// Each type corresponds to a specific CacheProvider implementation:
/// - [chatHistory]: Chat message history (JSON in SharedPreferences)
/// - [shadowCache]: Shadowing practice results (JSON in SharedPreferences)
/// - [ttsCache]: TTS audio files (WAV files on disk)
/// - [wordTts]: Word pronunciation audio (WAV files on disk)
enum CacheType {
  /// Chat history cache - stores conversation messages per scene
  chatHistory,

  /// Shadowing practice cache - stores practice results
  shadowCache,

  /// TTS audio cache - stores streamed TTS audio files
  ttsCache,

  /// Word TTS cache - stores word pronunciation audio files
  wordTts,
}

/// Abstract interface for cache providers.
///
/// Each cache type (audio files, JSON data, etc.) implements this interface
/// to provide a unified way to check, clear, and measure cache.
///
/// Provider implementations should:
/// - Handle errors gracefully (silent failures)
/// - Support partial or full cache clearing
/// - Return accurate size measurements in bytes
abstract class CacheProvider {
  /// The type of cache this provider manages.
  CacheType get type;

  /// Check if cache exists for a specific identifier.
  ///
  /// [id] is the unique identifier for the cached item.
  /// Returns true if the cache exists, false otherwise.
  Future<bool> hasCache(String id);

  /// Clear cache for a specific identifier, or all cache if [id] is null.
  ///
  /// [id] - specific cache item to clear, or null to clear all.
  Future<void> clearCache(String? id);

  /// Get the total size of this cache in bytes.
  ///
  /// Returns 0 if the cache is empty or cannot be measured.
  Future<int> getCacheSize();
}

/// Centralized cache management coordinator.
///
/// This is a **lightweight coordination layer** that provides:
/// - Unified cache key generation
/// - Cache existence checking
/// - Global cache clearing (e.g., on logout)
/// - Cache size statistics
///
/// **Design Philosophy**:
/// This is NOT a "one size fits all" cache manager that handles all read/write
/// operations. Each service retains its own cache logic because:
/// - Different data types (JSON vs audio) have different storage needs
/// - Different sync strategies (cloud-first vs local-first) are required
/// - Different serialization formats are used
///
/// Instead, CacheManager serves as a **registry and coordinator** that enables:
/// - Consistent cache key naming
/// - Centralized logout cleanup
/// - Settings page cache display/clearing
///
/// Usage:
/// ```dart
/// // During service initialization
/// CacheManager().register(myCacheProvider);
///
/// // Check if cache exists
/// final exists = await CacheManager().hasCache(CacheType.ttsCache, 'msg_001');
///
/// // Clear all caches on logout
/// await CacheManager().clearAllUserCache();
/// ```
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final Map<CacheType, CacheProvider> _providers = {};

  /// Register a cache provider.
  ///
  /// This should be called during service initialization.
  /// Each cache type can only have one provider.
  void register(CacheProvider provider) {
    _providers[provider.type] = provider;
    debugPrint('CacheManager: Registered provider for ${provider.type.name}');
  }

  /// Unregister a cache provider.
  ///
  /// This is useful for testing or when a service is disposed.
  void unregister(CacheType type) {
    _providers.remove(type);
    debugPrint('CacheManager: Unregistered provider for ${type.name}');
  }

  /// Check if a provider is registered for a cache type.
  bool isRegistered(CacheType type) => _providers.containsKey(type);

  /// Get all registered cache types.
  List<CacheType> get registeredTypes => _providers.keys.toList();

  /// Check if cache exists for a specific type and identifier.
  ///
  /// Returns false if no provider is registered for the type.
  Future<bool> hasCache(CacheType type, String id) async {
    final provider = _providers[type];
    if (provider == null) {
      debugPrint('CacheManager: No provider for ${type.name}');
      return false;
    }
    return provider.hasCache(id);
  }

  /// Clear cache for a specific type.
  ///
  /// [type] - the cache type to clear
  /// [id] - specific cache item to clear, or null to clear all of this type
  Future<void> clearCache(CacheType type, {String? id}) async {
    final provider = _providers[type];
    if (provider == null) {
      debugPrint('CacheManager: No provider for ${type.name}');
      return;
    }
    await provider.clearCache(id);
    debugPrint(
      'CacheManager: Cleared cache for ${type.name}${id != null ? ' (id: $id)' : ' (all)'}',
    );
  }

  /// Clear all user caches across all registered providers.
  ///
  /// This should be called during logout to ensure no user data remains.
  Future<void> clearAllUserCache() async {
    debugPrint('CacheManager: Clearing all user caches...');

    // Execute all clear operations in parallel
    final cleanupTasks = _providers.entries.map((entry) async {
      try {
        await entry.value.clearCache(null);
        debugPrint('CacheManager: Cleared ${entry.key.name} cache');
      } catch (e) {
        debugPrint('CacheManager: Error clearing ${entry.key.name}: $e');
        // Continue even if one fails
      }
    });

    await Future.wait(cleanupTasks);
    debugPrint('CacheManager: All user caches cleared');
  }

  /// Get the cache size for a specific type.
  ///
  /// Returns 0 if no provider is registered or if the cache is empty.
  Future<int> getCacheSize(CacheType type) async {
    final provider = _providers[type];
    if (provider == null) return 0;
    return provider.getCacheSize();
  }

  /// Get cache sizes for all registered providers.
  ///
  /// Returns a map of cache type to size in bytes.
  Future<Map<CacheType, int>> getAllCacheSizes() async {
    final sizes = <CacheType, int>{};
    for (final entry in _providers.entries) {
      try {
        sizes[entry.key] = await entry.value.getCacheSize();
      } catch (e) {
        debugPrint(
          'CacheManager: Error getting size for ${entry.key.name}: $e',
        );
        sizes[entry.key] = 0;
      }
    }
    return sizes;
  }

  /// Get total cache size across all providers.
  ///
  /// Returns the sum of all cache sizes in bytes.
  Future<int> getTotalCacheSize() async {
    final sizes = await getAllCacheSizes();
    int total = 0;
    for (final size in sizes.values) {
      total += size;
    }
    return total;
  }

  /// Format bytes to human-readable string.
  ///
  /// Examples: "1.5 MB", "256 KB", "0 B"
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(size >= 10 ? 0 : 1)} ${suffixes[i]}';
  }
}
