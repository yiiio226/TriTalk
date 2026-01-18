import 'package:frontend/core/data/api/api_service.dart';
import 'package:frontend/features/chat/domain/models/message.dart';
import '../domain/models/shadowing_practice.dart';

class ShadowingHistoryService {
  final ApiService _apiService = ApiService();

  static final ShadowingHistoryService _instance =
      ShadowingHistoryService._internal();
  factory ShadowingHistoryService() => _instance;
  ShadowingHistoryService._internal();

  /// Save a new shadowing practice record
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
    String? audioPath,
  }) async {
    final response = await _apiService.post('/shadowing/save', {
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
      'audio_path': audioPath,
    });

    return response['data']['id'];
  }

  /// Get practice history with optional filters
  Future<List<ShadowingPractice>> getHistory({
    String? sourceId,
    String? targetText,
    String? sceneKey,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (sourceId != null) queryParams['source_id'] = sourceId;
    if (targetText != null) queryParams['target_text'] = targetText;
    if (sceneKey != null) queryParams['scene_key'] = sceneKey;

    final response = await _apiService.get('/shadowing/history', queryParams);

    final practices = (response['data']['practices'] as List)
        .map((p) => ShadowingPractice.fromJson(p))
        .toList();

    return practices;
  }

  /// Get latest practice for a specific text
  Future<ShadowingPractice?> getLatestPractice(String targetText) async {
    final practices = await getHistory(targetText: targetText, limit: 1);
    return practices.isEmpty ? null : practices.first;
  }

  /// Get practice statistics for a text
  Future<Map<String, dynamic>> getStatistics(String targetText) async {
    final practices = await getHistory(targetText: targetText, limit: 100);

    if (practices.isEmpty) {
      return {
        'total_attempts': 0,
        'average_score': 0,
        'best_score': 0,
        'latest_score': 0,
        'improvement': 0,
      };
    }

    final scores = practices.map((p) => p.pronunciationScore).toList();
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    final bestScore = scores.reduce((a, b) => a > b ? a : b);
    final latestScore = practices.first.pronunciationScore;
    final firstScore = practices.last.pronunciationScore;
    final improvement = latestScore - firstScore;

    return {
      'total_attempts': practices.length,
      'average_score': avgScore.round(),
      'best_score': bestScore,
      'latest_score': latestScore,
      'improvement': improvement,
      'first_practiced': practices.last.practicedAt,
      'last_practiced': practices.first.practicedAt,
    };
  }
}
