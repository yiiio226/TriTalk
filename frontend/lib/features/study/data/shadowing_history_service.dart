import 'package:frontend/core/data/api/api_service.dart';
import 'package:frontend/features/chat/domain/models/message.dart';
import '../domain/models/shadowing_practice.dart';
import 'shadowing_cache_service.dart';

/// Service for shadowing practice data operations
///
/// Uses cache-first pattern:
/// - Save: Update local cache immediately, then async sync to cloud
/// - Get: Return cached data immediately if available, optionally sync from cloud
class ShadowingHistoryService {
  final ApiService _apiService = ApiService();
  final ShadowingCacheService _cacheService = ShadowingCacheService();

  static final ShadowingHistoryService _instance =
      ShadowingHistoryService._internal();
  factory ShadowingHistoryService() => _instance;
  ShadowingHistoryService._internal();

  /// Save or update a shadowing practice record
  ///
  /// Uses UPSERT pattern: each user + source_type + source_id has only one record.
  /// Saves to local cache immediately, then syncs to cloud asynchronously.
  Future<String> upsertPractice({
    required String targetText,
    required String sourceType,
    required String sourceId,
    String? sceneKey,
    required int pronunciationScore,
    double? accuracyScore,
    double? fluencyScore,
    double? completenessScore,
    double? prosodyScore,
    List<AzureWordFeedback>? wordFeedback,
    String? feedbackText,
    List<SmartSegmentFeedback>? segments,
  }) async {
    // Create local practice object for caching
    final practice = ShadowingPractice(
      id: '${sourceType}_$sourceId', // Local ID
      targetText: targetText,
      sourceType: sourceType,
      sourceId: sourceId,
      sceneKey: sceneKey,
      pronunciationScore: pronunciationScore,
      accuracyScore: accuracyScore,
      fluencyScore: fluencyScore,
      completenessScore: completenessScore,
      prosodyScore: prosodyScore,
      wordFeedback: wordFeedback,
      feedbackText: feedbackText,
      segments: segments,
      practicedAt: DateTime.now(),
    );

    // Save to local cache immediately
    await _cacheService.set(
      sourceType,
      sourceId,
      ShadowingCacheData(
        practice: practice,
        practicedAt: DateTime.now(),
        syncedAt: null, // Not synced yet
      ),
    );

    // Sync to cloud asynchronously (fire and forget, or with retry logic)
    try {
      final response = await _apiService.put('/shadowing/upsert', {
        'target_text': targetText,
        'source_type': sourceType,
        'source_id': sourceId,
        'scene_key': sceneKey,
        'pronunciation_score': pronunciationScore,
        'accuracy_score': accuracyScore,
        'fluency_score': fluencyScore,
        'completeness_score': completenessScore,
        'prosody_score': prosodyScore,
        'word_feedback': wordFeedback?.map((w) => w.toJson()).toList(),
        'feedback_text': feedbackText,
        'segments': segments?.map((s) => s.toJson()).toList(),
      });

      final cloudId = response['data']['id'];

      // Update cache with sync time
      await _cacheService.set(
        sourceType,
        sourceId,
        ShadowingCacheData(
          practice: practice,
          practicedAt: DateTime.now(),
          syncedAt: DateTime.now(),
        ),
      );

      return cloudId;
    } catch (e) {
      // Cloud sync failed, but local cache is saved
      // Could implement retry logic here
      rethrow;
    }
  }

  /// Get latest practice for a specific source
  ///
  /// Uses cache-first pattern:
  /// 1. Check local cache
  /// 2. If cache exists, return immediately
  /// 3. Optionally fetch from cloud in background
  Future<ShadowingPractice?> getLatestPractice(
    String sourceType,
    String sourceId, {
    bool fetchFromCloud = false,
  }) async {
    // Try local cache first
    final cached = await _cacheService.get(sourceType, sourceId);
    if (cached != null) {
      return cached.practice;
    }

    // If no cache and requested, fetch from cloud
    if (fetchFromCloud) {
      try {
        final response = await _apiService.get('/shadowing/get', {
          'source_type': sourceType,
          'source_id': sourceId,
        });

        final data = response['data'];
        if (data != null) {
          final practice = ShadowingPractice.fromJson(data);

          // Save to local cache
          await _cacheService.set(
            sourceType,
            sourceId,
            ShadowingCacheData(
              practice: practice,
              practicedAt: practice.practicedAt,
              syncedAt: DateTime.now(),
            ),
          );

          return practice;
        }
      } catch (e) {
        // Cloud fetch failed, return null
      }
    }

    return null;
  }

  /// Clear all local shadowing cache (for logout, etc.)
  Future<void> clearCache() async {
    await _cacheService.clearAll();
  }

  /// Legacy method for backward compatibility
  /// @deprecated Use upsertPractice instead
  Future<String> savePractice({
    required String targetText,
    required String sourceType,
    String? sourceId,
    String? sceneKey,
    required int pronunciationScore,
    double? accuracyScore,
    double? fluencyScore,
    double? completenessScore,
    double? prosodyScore,
    List<AzureWordFeedback>? wordFeedback,
    String? feedbackText,
    List<SmartSegmentFeedback>? segments,
  }) async {
    // Route to new upsert method
    return upsertPractice(
      targetText: targetText,
      sourceType: sourceType,
      sourceId: sourceId ?? '', // Default to empty string if not provided
      sceneKey: sceneKey,
      pronunciationScore: pronunciationScore,
      accuracyScore: accuracyScore,
      fluencyScore: fluencyScore,
      completenessScore: completenessScore,
      prosodyScore: prosodyScore,
      wordFeedback: wordFeedback,
      feedbackText: feedbackText,
      segments: segments,
    );
  }
}
