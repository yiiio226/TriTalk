/// Speech Feature
///
/// This module provides pronunciation assessment functionality using
/// Azure AI Speech Pronunciation Assessment API.
///
/// ## Features
/// - Phoneme-level accuracy analysis
/// - Word-level evaluation with Traffic Light feedback
/// - Prosody (intonation) assessment
/// - Fluency detection
///
/// ## Usage
/// ```dart
/// import 'package:frontend/features/speech/speech.dart';
///
/// // Using the service directly
/// final service = SpeechAssessmentService();
/// final result = await service.assessPronunciationFromPath(
///   audioPath: '/path/to/audio.wav',
///   referenceText: 'Hello world',
/// );
///
/// // Using Riverpod provider
/// final notifier = ref.read(pronunciationAssessmentProvider.notifier);
/// await notifier.assessFromPath(
///   audioPath: audioPath,
///   referenceText: referenceText,
/// );
/// ```
library;

// Domain models
export 'domain/models/pronunciation_result.dart';

// Data services
export 'data/services/speech_assessment_service.dart';
export 'data/services/word_tts_service.dart';

// Providers
export 'providers/speech_providers.dart';
