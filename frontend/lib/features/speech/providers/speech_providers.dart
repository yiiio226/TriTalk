import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/speech_assessment_service.dart';
import '../domain/models/pronunciation_result.dart';

/// Provider for the SpeechAssessmentService singleton
final speechAssessmentServiceProvider = Provider<SpeechAssessmentService>((
  ref,
) {
  return SpeechAssessmentService();
});

/// State for ongoing pronunciation assessment
class PronunciationAssessmentState {
  final bool isLoading;
  final PronunciationResult? result;
  final String? error;

  const PronunciationAssessmentState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  PronunciationAssessmentState copyWith({
    bool? isLoading,
    PronunciationResult? result,
    String? error,
  }) {
    return PronunciationAssessmentState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
    );
  }
}

/// Notifier for managing pronunciation assessment state
class PronunciationAssessmentNotifier
    extends StateNotifier<PronunciationAssessmentState> {
  final SpeechAssessmentService _service;

  PronunciationAssessmentNotifier(this._service)
    : super(const PronunciationAssessmentState());

  /// Assess pronunciation from an audio file path
  Future<PronunciationResult?> assessFromPath({
    required String audioPath,
    required String referenceText,
    String language = 'en-US',
    bool enableProsody = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _service.assessPronunciationFromPath(
        audioPath: audioPath,
        referenceText: referenceText,
        language: language,
        enableProsody: enableProsody,
      );

      state = state.copyWith(isLoading: false, result: result);
      return result;
    } on SpeechAssessmentException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Assess pronunciation from audio bytes
  Future<PronunciationResult?> assessFromBytes({
    required List<int> audioBytes,
    required String referenceText,
    String language = 'en-US',
    bool enableProsody = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _service.assessPronunciationFromBytes(
        audioBytes: audioBytes,
        referenceText: referenceText,
        language: language,
        enableProsody: enableProsody,
      );

      state = state.copyWith(isLoading: false, result: result);
      return result;
    } on SpeechAssessmentException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Clear the current result
  void clearResult() {
    state = const PronunciationAssessmentState();
  }
}

/// Provider for the pronunciation assessment notifier
final pronunciationAssessmentProvider =
    StateNotifierProvider<
      PronunciationAssessmentNotifier,
      PronunciationAssessmentState
    >((ref) {
      final service = ref.watch(speechAssessmentServiceProvider);
      return PronunciationAssessmentNotifier(service);
    });
