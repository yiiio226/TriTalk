/// Centralized constants for cache keys and directory names.
///
/// This ensures consistency across Services (producers) and CacheProviders (consumers).
class CacheConstants {
  CacheConstants._();

  /// Directory name for TTS audio cache
  /// Format: {documentsDir}/{userId}/tts_cache/
  static const String ttsCacheDir = 'tts_cache';

  /// Key prefix for chat history
  /// Format: {userId}_chat_history_{sceneKey}
  static const String chatHistoryPrefix = 'chat_history_';

  /// Key prefix for shadowing practice
  /// Format: shadow_v2_{sourceType}_{sourceId}
  static const String shadowingPracticePrefix = 'shadow_v2_';

  /// Directory name for word TTS cache
  /// Format: {documentsDir}/word_tts_cache/
  static const String wordTtsCacheDir = 'word_tts_cache';
}
