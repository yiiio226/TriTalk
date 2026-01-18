import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:frontend/features/speech/speech.dart';
import 'package:frontend/features/chat/domain/models/message.dart';
import 'package:frontend/core/data/api/api_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/core/data/local/storage_key_service.dart';
import 'package:frontend/core/auth/auth_provider.dart';

import 'package:frontend/core/widgets/top_toast.dart';

class ShadowingSheet extends ConsumerStatefulWidget {
  final String targetText;
  final String messageId; // Message ID for file naming
  final VoiceFeedback? initialFeedback; // Previous shadowing result to display
  final String? initialAudioPath; // Previous recording path
  final String? initialTtsAudioPath; // Previous TTS audio path (cached)
  final Function(VoiceFeedback, String?)?
  onFeedbackUpdate; // Callback with feedback and audio path
  final Function(String)? onTtsUpdate; // Callback when TTS audio is generated

  const ShadowingSheet({
    super.key,
    required this.targetText,
    required this.messageId,
    this.initialFeedback,
    this.initialAudioPath,
    this.initialTtsAudioPath,
    this.onFeedbackUpdate,
    this.onTtsUpdate,
  });

  @override
  ConsumerState<ShadowingSheet> createState() => _ShadowingSheetState();
}

class _ShadowingSheetState extends ConsumerState<ShadowingSheet>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  VoiceFeedback?
  _feedback; // Use VoiceFeedback to unify with initial and new results
  // _errorMessage removed
  String? _currentRecordingPath; // Track current recording for replay/cleanup
  DateTime? _recordingStartTime; // Track recording duration

  // TTS state for "Listen" button
  bool _isTTSLoading = false;
  bool _isTTSPlaying = false;
  String? _ttsAudioPath; // Cached TTS audio file path
  final AudioPlayer _ttsPlayer = AudioPlayer(); // Separate player for TTS

  // Word TTS service for playing individual word pronunciations
  final WordTtsService _wordTtsService = WordTtsService();

  // Waveform animation controller
  late AnimationController _waveformController;

  @override
  void initState() {
    super.initState();
    // Initialize with previous feedback and audio path if available
    _feedback = widget.initialFeedback;
    _currentRecordingPath = widget.initialAudioPath;
    _ttsAudioPath = widget.initialTtsAudioPath; // Initialize cached TTS path

    // Initialize waveform animation controller
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Listen to audio player state for recording playback
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Listen to TTS audio player state
    _ttsPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isTTSPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _waveformController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _ttsPlayer.dispose(); // Dispose TTS player
    // Note: We do NOT delete the recording on dispose anymore since it's persisted
    super.dispose();
  }

  /// Play text-to-speech for the target text (correct pronunciation)
  Future<void> _playTextToSpeech() async {
    // If already playing TTS, stop it
    if (_isTTSPlaying) {
      await _ttsPlayer.stop();
      setState(() {
        _isTTSPlaying = false;
      });
      return;
    }

    // Stop recording playback if playing
    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    // If we have a cached audio file, play it directly
    if (_ttsAudioPath != null && await File(_ttsAudioPath!).exists()) {
      await _playTTSAudio(_ttsAudioPath!);
      return;
    }

    // Show loading state
    setState(() {
      _isTTSLoading = true;
    });

    try {
      final apiService = ApiService();

      // Use streaming API to receive audio chunks
      // GCP TTS returns PCM audio; the 'done' chunk has the complete WAV with header
      String? finalWavBase64;
      await for (final chunk in apiService.generateTTSStream(
        widget.targetText,
      )) {
        if (!mounted) break;

        switch (chunk.type) {
          case TTSChunkType.audioChunk:
            // PCM chunks are being collected internally
            break;
          case TTSChunkType.info:
            // Duration info received
            break;
          case TTSChunkType.done:
            // The 'done' chunk contains the complete WAV audio with header
            finalWavBase64 = chunk.audioBase64;
            break;
          case TTSChunkType.error:
            throw Exception(chunk.error ?? 'TTS generation failed');
        }
      }

      if (!mounted) return;

      if (finalWavBase64 == null) {
        throw Exception('No audio received');
      }

      // Decode the WAV audio
      final audioBytes = base64Decode(finalWavBase64);

      // Save to cache with user-scoped path
      final cacheDir = await getApplicationDocumentsDirectory();
      final storageKey = StorageKeyService();
      final ttsCacheDir = Directory(
        storageKey.getUserScopedPath(cacheDir.path, 'tts_cache'),
      );
      if (!await ttsCacheDir.exists()) {
        await ttsCacheDir.create(recursive: true);
      }

      // Use message ID as filename (sanitized)
      // Note: GCP TTS returns WAV format audio
      final safeFileName = widget.messageId.replaceAll(
        RegExp(r'[^a-zA-Z0-9-_]'),
        '_',
      );
      final audioFile = File('${ttsCacheDir.path}/$safeFileName.wav');
      await audioFile.writeAsBytes(audioBytes);

      if (mounted) {
        setState(() {
          _ttsAudioPath = audioFile.path;
          _isTTSLoading = false;
        });

        // Notify parent to persist the TTS audio path
        widget.onTtsUpdate?.call(audioFile.path);

        // Play the audio immediately
        await _playTTSAudio(audioFile.path);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTTSLoading = false;
        });
        showTopToast(context, 'Failed to generate speech: $e', isError: true);
      }
    }
  }

  /// Play TTS audio from the given file path
  Future<void> _playTTSAudio(String audioPath) async {
    try {
      await _ttsPlayer.play(UrlSource(Uri.file(audioPath).toString()));
      if (mounted) {
        setState(() {
          _isTTSPlaying = true;
        });
      }
    } catch (e) {
      if (mounted) {
        showTopToast(context, 'Failed to play audio: $e', isError: true);
      }
    }
  }

  /// Play pronunciation for a single word
  Future<void> _playWordPronunciation(String word) async {
    // Clean the word (keep hyphens and apostrophes for proper pronunciation)
    // Remove only sentence-ending punctuation like . , ! ? ; :
    final cleanWord = word.replaceAll(RegExp(r'[.,!?;:"]'), '').trim();
    if (cleanWord.isEmpty) return;

    try {
      await _wordTtsService.speakWord(cleanWord, language: 'en-US');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Word TTS error: $e');
      }
    }
  }

  /// Play audio for a specific segment of the target text using Azure TTS
  Future<void> _playSegmentAudio(int segmentIndex) async {
    // Split target text into roughly 3 equal segments by word count
    final words = widget.targetText.split(' ');
    final segmentSize = (words.length / 3).ceil();

    int startIndex, endIndex;
    switch (segmentIndex) {
      case 0: // First segment
        startIndex = 0;
        endIndex = segmentSize;
        break;
      case 1: // Middle segment
        startIndex = segmentSize;
        endIndex = segmentSize * 2;
        break;
      case 2: // Last segment
        startIndex = segmentSize * 2;
        endIndex = words.length;
        break;
      default:
        return;
    }

    final segmentText = words
        .sublist(startIndex, endIndex.clamp(0, words.length))
        .join(' ');

    if (segmentText.isEmpty) return;

    try {
      // Use GCP TTS streaming API
      final apiService = ApiService();

      // Use streaming API to receive audio chunks
      // GCP TTS returns PCM audio; the 'done' chunk has the complete WAV with header
      String? finalWavBase64;
      await for (final chunk in apiService.generateTTSStream(segmentText)) {
        if (!mounted) break;

        switch (chunk.type) {
          case TTSChunkType.audioChunk:
            // PCM chunks are being collected internally
            break;
          case TTSChunkType.done:
            // The 'done' chunk contains the complete WAV audio with header
            finalWavBase64 = chunk.audioBase64;
            break;
          case TTSChunkType.error:
            throw Exception(chunk.error ?? 'Segment TTS generation failed');
          default:
            break;
        }
      }

      if (!mounted || finalWavBase64 == null) return;

      // Decode the WAV audio
      final audioBytes = base64Decode(finalWavBase64);

      // Save to temporary file and play (WAV format)
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/segment_$segmentIndex.wav');
      await tempFile.writeAsBytes(audioBytes);

      // Play the segment audio
      await _ttsPlayer.play(DeviceFileSource(tempFile.path));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Segment TTS error: $e');
      }
    }
  }

  Future<void> _deleteCurrentRecording() async {
    if (_currentRecordingPath != null) {
      try {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
          if (kDebugMode) {
            debugPrint('🗑️ Deleted recording: $_currentRecordingPath');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Failed to delete recording: $e');
        }
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // Trigger haptic feedback
        HapticFeedback.mediumImpact();

        // Delete previous recording before starting a new one
        await _deleteCurrentRecording();

        // Save to Documents directory with message-ID-based name for persistence
        final directory = await getApplicationDocumentsDirectory();
        final shadowDir = Directory('${directory.path}/shadowing');
        if (!await shadowDir.exists()) {
          await shadowDir.create(recursive: true);
        }
        final path = '${shadowDir.path}/shadow_${widget.messageId}.wav';

        // Use WAV format with PCM encoding for better transcription accuracy
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000, // 16kHz is optimal for speech recognition
            numChannels: 1, // Mono audio
          ),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _feedback = null;
          _currentRecordingPath = null;
          _recordingStartTime = DateTime.now(); // Record start time
        });
      }
    } catch (e) {
      if (mounted) {
        showTopToast(context, 'Could not start recording: $e', isError: true);
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      // Check recording duration
      if (_recordingStartTime != null) {
        final duration = DateTime.now().difference(_recordingStartTime!);
        if (duration.inMilliseconds < 1000) {
          // Recording too short
          setState(() {
            _isRecording = false;
            _currentRecordingPath = null;
          });

          // Delete the short file
          if (path != null) {
            final file = File(path);
            if (await file.exists()) {
              await file.delete();
            }
          }

          if (mounted) {
            showTopToast(
              context,
              'Recording too short, please try again',
              isError: true,
            );
          }
          return;
        }
      }

      if (path != null) {
        setState(() {
          _isRecording = false;
          _currentRecordingPath = path; // Save path for replay
        });
        _analyzeAudio(path);
      } else {
        setState(() {
          _isRecording = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showTopToast(context, 'Error stopping recording: $e', isError: true);
      }
    }
  }

  Future<void> _playRecording() async {
    if (_currentRecordingPath == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(
          UrlSource(Uri.file(_currentRecordingPath!).toString()),
        );
      }
    } catch (e) {
      if (mounted) {
        showTopToast(context, 'Failed to play recording: $e', isError: true);
      }
    }
  }

  void _tryAgain() {
    // Stop any playing audio
    _audioPlayer.stop();
    // Delete current recording
    _deleteCurrentRecording();
    // Reset state (clear feedback to show record button)
    setState(() {
      _feedback = null;
      _currentRecordingPath = null;
      _isPlaying = false;
    });
  }

  Future<void> _analyzeAudio(String audioPath) async {
    if (kDebugMode) {
      debugPrint('🎤 ShadowingSheet: Analyzing audio via speech/assess');
      debugPrint('   audioPath: $audioPath');
      debugPrint('   referenceText: "${widget.targetText}"');
    }

    // Clear previous state and trigger new assessment
    ref.read(pronunciationAssessmentProvider.notifier).clearResult();

    final result = await ref
        .read(pronunciationAssessmentProvider.notifier)
        .assessFromPath(
          audioPath: audioPath,
          referenceText: widget.targetText,
          language: 'en-US',
          enableProsody: true,
        );

    if (mounted && result != null) {
      if (kDebugMode) {
        debugPrint('✅ ShadowingSheet: Assessment complete');
        debugPrint('   pronunciationScore: ${result.pronunciationScore}');
        debugPrint('   accuracyScore: ${result.accuracyScore}');
        debugPrint('   fluencyScore: ${result.fluencyScore}');
      }

      // Convert PronunciationResult to VoiceFeedback
      final azureWordFeedback = result.wordFeedback
          .map(
            (w) => AzureWordFeedback(
              text: w.text,
              score: w.score,
              level: w.level,
              errorType: w.errorType,
              phonemes: w.phonemes
                  .map(
                    (p) => AzurePhonemeFeedback(
                      phoneme: p.phoneme,
                      accuracyScore: p.accuracyScore,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();

      final voiceFeedback = VoiceFeedback(
        pronunciationScore: result.pronunciationScore.round(),
        correctedText: widget.targetText,
        nativeExpression: '',
        feedback: _generateFeedbackFromResult(result),
        azureAccuracyScore: result.accuracyScore,
        azureFluencyScore: result.fluencyScore,
        azureCompletenessScore: result.completenessScore,
        azureProsodyScore: result.prosodyScore,
        azureWordFeedback: azureWordFeedback,
      );

      setState(() {
        _feedback = voiceFeedback;
      });

      // Notify parent to persist the result with audio path
      widget.onFeedbackUpdate?.call(voiceFeedback, _currentRecordingPath);
    }
  }

  String _generateFeedbackFromResult(PronunciationResult result) {
    final score = result.pronunciationScore;
    final problemWords = result.wordFeedback.where((w) => w.hasIssue).toList();

    if (score >= 90) {
      return 'Excellent pronunciation! You\'re doing great!';
    } else if (score >= 70) {
      if (problemWords.isNotEmpty) {
        final wordList = problemWords
            .take(3)
            .map((w) => '"${w.text}"')
            .join(', ');
        return 'Good effort! Focus on improving: $wordList';
      }
      return 'Good progress! Keep practicing for better fluency.';
    } else {
      if (problemWords.isNotEmpty) {
        final wordList = problemWords
            .take(3)
            .map((w) => '"${w.text}"')
            .join(', ');
        return 'Keep practicing! Pay attention to: $wordList';
      }
      return 'Keep practicing! Try speaking more slowly and clearly.';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for ALL errors to show toast
    ref.listen(pronunciationAssessmentProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        String msg = next.error!;
        // Handle specific error cases for friendlier messages
        if (msg.contains('InitialSilenceTimeout') || msg.contains('500')) {
          msg = 'No voice detected, please try again';
        }
        showTopToast(context, msg, isError: true);
      }
    });
    // Watch the provider state for loading and error
    final assessmentState = ref.watch(pronunciationAssessmentProvider);
    final isAnalyzing = assessmentState.isLoading;
    // providerError handled via toaster, not displayed persistently

    final screenHeight = MediaQuery.of(context).size.height;
    final maxSheetHeight = screenHeight * 0.9;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ln100,
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed Header: Drag Handle & Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightDivider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _feedback != null
                              ? (_feedback!.pronunciationScore >= 80
                                    ? AppColors.lg50
                                    : AppColors.lr50)
                              : AppColors.ln50,
                          shape: BoxShape.circle,
                        ),
                        child: _feedback != null
                            ? Text(
                                _feedback!.pronunciationScore >= 80
                                    ? '🎉'
                                    : '😔',
                                style: const TextStyle(fontSize: 20, height: 1),
                              )
                            : Icon(
                                Icons.record_voice_over_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 12),
                      if (_feedback != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lg500,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Score: ${_feedback!.pronunciationScore}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _feedback!.pronunciationScore >= 80
                              ? 'Great Job!'
                              : 'Keep Practicing!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else
                        const Text(
                          'Shadowing Practice',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.ln50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Target Text - Show only when idle or recording
                  if (!isAnalyzing && _feedback == null) _buildTargetTextView(),
                  if (!isAnalyzing && _feedback == null)
                    const SizedBox(height: 16),
                ],
              ),
            ),

            // Scrollable Content Area
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAnalyzing)
                      _buildSkeletonLoader()
                    else if (_isRecording)
                      // Show waveform during recording
                      _buildWaveform()
                    else if (_feedback != null)
                      // Show feedback after analysis (without target text)
                      _buildVoiceFeedbackContent(_feedback!)
                    else
                      // Empty space when idle
                      const SizedBox(height: 40),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Section: Error Message + Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 64),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bottom Controls (Always visible)

                  // Bottom Controls (Always visible)
                  _buildBottomControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetTextView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightDivider),
      ),
      child: Text(
        widget.targetText,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: AppColors.lightTextPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBottomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 1. Play Original (Left)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _playTextToSpeech,
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.lightBackground,
                  shape: BoxShape.circle,
                ),
                child: _isTTSLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isTTSPlaying
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        size: 28,
                        color: AppColors.lightTextPrimary,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Listen',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),

        // 2. Record Button (Center)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _isRecording
                      ? AppColors.lightError
                      : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isRecording
                                  ? AppColors.lightError
                                  : AppColors.primary)
                              .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic_rounded,
                  size: 32,
                  color: AppColors.lightSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _feedback == null ? 'Hold to Record' : 'Record Again',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),

        // 3. Score/Status (Right)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _feedback != null
                ? GestureDetector(
                    onTap: _playRecording, // Play recording on tap
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.lg500, // Green
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${_feedback!.pronunciationScore}',
                        style: const TextStyle(
                          color: AppColors.lightSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.lightBackground,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '0',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
            const SizedBox(height: 8),
            Text(
              _feedback == null ? 'Not Rated' : 'My Score',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoiceFeedbackContent(VoiceFeedback feedback) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatsRow(feedback),
        const SizedBox(height: 32),
        _buildAzureWordFeedback(feedback),
        if (feedback.azureProsodyScore != null) _buildProsodySection(feedback),
      ],
    );
  }

  Widget _buildScoreHeader(VoiceFeedback feedback) {
    // Top Row: "Score: 91  Great Job!"
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.lightSuccess,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.lightSuccess),
          ),
          child: Text(
            'Score: ${feedback.pronunciationScore}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          feedback.pronunciationScore >= 80 ? 'Great Job!' : 'Keep Practicing!',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(VoiceFeedback feedback) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Accuracy', feedback.azureAccuracyScore),
          _buildStatItem('Fluency', feedback.azureFluencyScore),
          _buildStatItem('Complete', feedback.azureCompletenessScore),
          if (feedback.azureProsodyScore != null)
            _buildStatItem('Prosody', feedback.azureProsodyScore),
        ],
      ),
    );
  }

  Widget _buildProsodySection(VoiceFeedback feedback) {
    if (feedback.azureProsodyScore == null) return const SizedBox.shrink();

    final score = feedback.azureProsodyScore!;

    // Analyze target text for specific patterns
    final isQuestion = widget.targetText.trim().endsWith('?');
    final hasExclamation = widget.targetText.contains('!');

    // Get user's native language
    final authState = ref.watch(authProvider);
    final nativeLanguage = authState.user?.nativeLanguage ?? 'English';

    // Generate detailed feedback based on score and text pattern
    final (statusText, detailedTip) = _getLocalizedProsodyFeedback(
      score: score,
      isQuestion: isQuestion,
      hasExclamation: hasExclamation,
      nativeLanguage: nativeLanguage,
    );

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightDivider),
        boxShadow: AppShadows.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lb500.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  size: 20,
                  color: AppColors.lb500,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pitch Contour',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Pitch Contour Visualization with Interactive Segments
          GestureDetector(
            onTapDown: (details) {
              // Determine which segment was tapped
              final tapX = details.localPosition.dx;
              final width =
                  MediaQuery.of(context).size.width - 80; // Account for padding
              final segmentIndex = (tapX / width * 3).floor().clamp(0, 2);

              // Split target text into 3 segments and play the tapped segment
              _playSegmentAudio(segmentIndex);
            },
            child: SizedBox(
              height: 80,
              width: double.infinity,
              child: CustomPaint(
                painter: IntonationPainter(
                  score: score,
                  primaryColor: AppColors.primary,
                  userColor: _getScoreColor(score),
                  targetText: widget.targetText,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                'Native Speaker',
                AppColors.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 24),
              _buildLegendItem('You', _getScoreColor(score)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: _getScoreColor(score).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  statusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _getScoreColor(score),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detailedTip,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get localized prosody feedback based on user's native language
  (String, String) _getLocalizedProsodyFeedback({
    required double score,
    required bool isQuestion,
    required bool hasExclamation,
    required String nativeLanguage,
  }) {
    // Localized messages map
    final Map<String, Map<String, String>> messages = {
      'Chinese (Simplified)': {
        'great_status': '语调很棒！听起来很自然。',
        'great_tip_question': '你的疑问语调非常到位！继续保持。',
        'great_tip_default': '你的语调与母语者完美匹配。',
        'good_status': '不错的开始，尝试表达更多情感。',
        'good_tip_question': '💡 提示：在问句结尾处提高音调。',
        'good_tip_exclamation': '💡 提示：在关键词上增加更多能量和强调。',
        'good_tip_default': '💡 提示：变化你的音调，避免单调。',
        'flat_status': '太平了，模仿语调的起伏。',
        'flat_tip_question': '💡 提示：问句结尾应该上扬 ↗️。尝试夸张一点练习。',
        'flat_tip_exclamation': '💡 提示：表现出兴奋！用更高的音调强调重要的词。',
        'flat_tip_default': '💡 提示：你的声音听起来像机器人。模仿母语者的节奏和旋律。',
      },
      'Japanese': {
        'great_status': 'イントネーションが素晴らしい！自然に聞こえます。',
        'great_tip_question': '質問のイントネーションが完璧です！その調子で。',
        'great_tip_default': 'ネイティブスピーカーと完璧にマッチしています。',
        'good_status': '良いスタートです。もっと感情を込めてみましょう。',
        'good_tip_question': '💡 ヒント：質問の最後でもっとピッチを上げましょう。',
        'good_tip_exclamation': '💡 ヒント：キーワードにもっとエネルギーと強調を加えましょう。',
        'good_tip_default': '💡 ヒント：単調にならないようにピッチを変化させましょう。',
        'flat_status': '平坦すぎます。抑揚を真似しましょう。',
        'flat_tip_question': '💡 ヒント：質問は最後で上がるべきです ↗️。大げさに練習してみましょう。',
        'flat_tip_exclamation': '💡 ヒント：興奮を見せて！重要な言葉を高いピッチで強調しましょう。',
        'flat_tip_default': '💡 ヒント：ロボットのように聞こえます。ネイティブのリズムとメロディーをコピーしましょう。',
      },
      'Korean': {
        'great_status': '억양이 훌륭해요! 자연스럽게 들립니다.',
        'great_tip_question': '질문 억양이 완벽해요! 계속 유지하세요.',
        'great_tip_default': '네이티브 스피커와 완벽하게 일치합니다.',
        'good_status': '좋은 시작이에요. 더 많은 감정을 표현해 보세요.',
        'good_tip_question': '💡 팁: 질문 끝에서 음높이를 더 올리세요.',
        'good_tip_exclamation': '💡 팁: 핵심 단어에 더 많은 에너지와 강조를 추가하세요.',
        'good_tip_default': '💡 팁: 단조롭지 않게 음높이를 변화시키세요.',
        'flat_status': '너무 평평해요. 억양의 오르내림을 따라하세요.',
        'flat_tip_question': '💡 팁: 질문은 끝에서 올라가야 해요 ↗️. 과장해서 연습해 보세요.',
        'flat_tip_exclamation': '💡 팁: 흥분을 표현하세요! 중요한 단어를 높은 음으로 강조하세요.',
        'flat_tip_default': '💡 팁: 로봇처럼 들려요. 네이티브의 리듬과 멜로디를 따라하세요.',
      },
      'Spanish': {
        'great_status': '¡Excelente entonación! Suenas natural.',
        'great_tip_question':
            '¡Tu entonación de pregunta es perfecta! Sigue así.',
        'great_tip_default':
            'Tu tono coincide perfectamente con el hablante nativo.',
        'good_status': 'Buen comienzo. Intenta expresar más emoción.',
        'good_tip_question':
            '💡 Consejo: Sube más el tono al final de la pregunta.',
        'good_tip_exclamation':
            '💡 Consejo: Añade más energía y énfasis en las palabras clave.',
        'good_tip_default': '💡 Consejo: Varía tu tono para no sonar monótono.',
        'flat_status': 'Demasiado plano. Imita los altibajos.',
        'flat_tip_question':
            '💡 Consejo: Las preguntas deben subir al final ↗️. Practica con el tono exagerado.',
        'flat_tip_exclamation':
            '💡 Consejo: ¡Muestra emoción! Enfatiza las palabras importantes con un tono más alto.',
        'flat_tip_default':
            '💡 Consejo: Tu voz suena robótica. Copia el ritmo y la melodía del hablante nativo.',
      },
      'French': {
        'great_status': 'Excellente intonation ! Tu as l\'air naturel.',
        'great_tip_question':
            'Ton intonation interrogative est parfaite ! Continue comme ça.',
        'great_tip_default':
            'Ton ton correspond parfaitement au locuteur natif.',
        'good_status': 'Bon début. Essaie d\'exprimer plus d\'émotion.',
        'good_tip_question':
            '💡 Conseil : Monte ta voix davantage à la fin de la question.',
        'good_tip_exclamation':
            '💡 Conseil : Ajoute plus d\'énergie et d\'emphase sur les mots clés.',
        'good_tip_default':
            '💡 Conseil : Varie ta hauteur de voix pour éviter la monotonie.',
        'flat_status': 'Trop plat. Imite les hauts et les bas.',
        'flat_tip_question':
            '💡 Conseil : Les questions doivent monter à la fin ↗️. Pratique avec une intonation exagérée.',
        'flat_tip_exclamation':
            '💡 Conseil : Montre de l\'enthousiasme ! Accentue les mots importants avec une voix plus haute.',
        'flat_tip_default':
            '💡 Conseil : Ta voix semble robotique. Copie le rythme et la mélodie du locuteur natif.',
      },
      'German': {
        'great_status': 'Großartige Intonation! Du klingst natürlich.',
        'great_tip_question': 'Deine Frageintonation ist perfekt! Weiter so.',
        'great_tip_default': 'Dein Ton passt perfekt zum Muttersprachler.',
        'good_status': 'Guter Anfang. Versuche mehr Emotionen auszudrücken.',
        'good_tip_question':
            '💡 Tipp: Hebe deine Stimme am Ende der Frage mehr an.',
        'good_tip_exclamation':
            '💡 Tipp: Füge mehr Energie und Betonung auf Schlüsselwörter hinzu.',
        'good_tip_default':
            '💡 Tipp: Variiere deine Tonhöhe, um weniger monoton zu klingen.',
        'flat_status': 'Zu flach. Ahme die Höhen und Tiefen nach.',
        'flat_tip_question':
            '💡 Tipp: Fragen sollten am Ende steigen ↗️. Übe mit übertriebener Betonung.',
        'flat_tip_exclamation':
            '💡 Tipp: Zeige Begeisterung! Betone wichtige Wörter mit höherer Stimme.',
        'flat_tip_default':
            '💡 Tipp: Deine Stimme klingt roboterhaft. Kopiere den Rhythmus und die Melodie des Muttersprachlers.',
      },
      'English': {
        'great_status': 'Great intonation! You sound natural.',
        'great_tip_question':
            'Your question intonation is spot-on! Keep it up.',
        'great_tip_default': 'Your tone matches the native speaker perfectly.',
        'good_status': 'Good start. Try to express more emotion.',
        'good_tip_question':
            '💡 Tip: Raise your pitch more at the end of the question.',
        'good_tip_exclamation':
            '💡 Tip: Add more energy and emphasis on key words.',
        'good_tip_default': '💡 Tip: Vary your pitch to sound less monotone.',
        'flat_status': 'Too flat. Mimic the ups and downs.',
        'flat_tip_question':
            '💡 Tip: Questions should rise at the end ↗️. Practice with exaggerated pitch.',
        'flat_tip_exclamation':
            '💡 Tip: Show excitement! Emphasize important words with higher pitch.',
        'flat_tip_default':
            '💡 Tip: Your voice sounds robotic. Copy the rhythm and melody of the native speaker.',
      },
    };

    // Get messages for user's language, fallback to English
    final lang = messages.containsKey(nativeLanguage)
        ? nativeLanguage
        : 'English';
    final msgs = messages[lang]!;

    String statusText;
    String detailedTip;

    if (score >= 80) {
      statusText = msgs['great_status']!;
      detailedTip = isQuestion
          ? msgs['great_tip_question']!
          : msgs['great_tip_default']!;
    } else if (score >= 60) {
      statusText = msgs['good_status']!;
      if (isQuestion) {
        detailedTip = msgs['good_tip_question']!;
      } else if (hasExclamation) {
        detailedTip = msgs['good_tip_exclamation']!;
      } else {
        detailedTip = msgs['good_tip_default']!;
      }
    } else {
      statusText = msgs['flat_status']!;
      if (isQuestion) {
        detailedTip = msgs['flat_tip_question']!;
      } else if (hasExclamation) {
        detailedTip = msgs['flat_tip_exclamation']!;
      } else {
        detailedTip = msgs['flat_tip_default']!;
      }
    }

    return (statusText, detailedTip);
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.lg500; // Green
    if (score >= 60) return AppColors.ly500; // Warning/Orange-ish
    return AppColors.lightError; // Red
  }

  Widget _buildStatItem(String label, double? score) {
    final value = score?.round() ?? 0;
    Color valueColor;
    if (value >= 80) {
      valueColor = AppColors.lg500; // Green
    } else if (value >= 60) {
      valueColor = AppColors.ly500; // Orange
    } else {
      valueColor = AppColors.lightError; // Red
    }

    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAzureWordFeedback(VoiceFeedback feedback) {
    final words = feedback.azureWordFeedback ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Pronunciation:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.lightTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.lb100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Azure AI',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.lb500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 4,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _buildWordsWithPunctuation(words),
        ),
      ],
    );
  }

  /// Build word widgets with punctuation marks inserted
  List<Widget> _buildWordsWithPunctuation(List<AzureWordFeedback> words) {
    final List<Widget> widgets = [];

    // Parse target text to extract punctuation
    final targetWords = widget.targetText.split(RegExp(r'\s+'));

    for (int i = 0; i < words.length; i++) {
      final word = words[i];

      // Determine color based on level
      Color color;
      switch (word.level) {
        case 'perfect':
          color = AppColors.lg500;
          break;
        case 'warning':
          color = AppColors.ly500;
          break;
        case 'error':
          color = AppColors.lightError;
          break;
        case 'missing':
          color = AppColors.lightTextDisabled;
          break;
        default:
          color = AppColors.lightTextDisabled;
      }

      // Add word widget
      widgets.add(
        GestureDetector(
          onTap: () => _playWordPronunciation(word.text),
          child: IntrinsicWidth(
            child: Column(
              children: [
                Text(
                  word.text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: word.level == 'missing'
                        ? AppColors.lightTextDisabled
                        : AppColors.lightTextPrimary,
                    decoration: word.level == 'missing'
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  width: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${word.score.round()}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Extract punctuation from target text if available
      if (i < targetWords.length) {
        final targetWord = targetWords[i];
        final punctuation = targetWord.replaceAll(
          RegExp(r"[a-zA-Z0-9'\-]"),
          '',
        );

        if (punctuation.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 20),
              child: Text(
                punctuation,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  Widget _buildAzureScores(VoiceFeedback feedback) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem('Accuracy', feedback.azureAccuracyScore),
          _buildScoreItem('Fluency', feedback.azureFluencyScore),
          _buildScoreItem('Complete', feedback.azureCompletenessScore),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, double? score) {
    final displayScore = score?.round() ?? 0;
    Color color;
    if (displayScore >= 80) {
      color = AppColors.lg500;
    } else if (displayScore >= 60) {
      color = AppColors.ly500;
    } else {
      color = AppColors.lightError;
    }

    return Column(
      children: [
        Text(
          '$displayScore',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightSkeletonBase,
      highlightColor: AppColors.lightSkeletonHighlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score Header Skeleton
          Row(
            children: [
              _buildSkeletonBox(height: 32, width: 100, radius: 8),
              const SizedBox(width: 12),
              _buildSkeletonBox(height: 24, width: 120, radius: 4),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Row Skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatsSkeletonItem(),
                _buildStatsSkeletonItem(),
                _buildStatsSkeletonItem(),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Simplified Words Skeleton
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: List.generate(12, (index) {
              final width = 60.0 + (index % 4) * 20.0;
              return _buildSkeletonBox(height: 20, width: width, radius: 4);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSkeletonItem() {
    return Column(
      children: [
        _buildSkeletonBox(height: 32, width: 40, radius: 4),
        const SizedBox(height: 4),
        _buildSkeletonBox(height: 12, width: 60, radius: 4),
      ],
    );
  }

  Widget _buildSkeletonBox({
    required double height,
    required double width,
    double radius = 4,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  /// Waveform animation widget for recording state
  Widget _buildWaveform() {
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(30, (index) {
          return AnimatedBuilder(
            animation: _waveformController,
            builder: (context, child) {
              // Create a wave effect with staggered animation
              final offset = (index * 0.05) % 1.0;
              final animValue = (_waveformController.value + offset) % 1.0;
              // Use a threshold that creates a "filling" effect or large block moving
              final isDark = animValue < 0.5;

              return Container(
                width: 3,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primary : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Custom painter for drawing pitch contour visualization with key point annotations
class IntonationPainter extends CustomPainter {
  final double score;
  final Color primaryColor;
  final Color userColor;
  final String targetText;

  IntonationPainter({
    required this.score,
    required this.primaryColor,
    required this.userColor,
    required this.targetText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // AI Curve (Standard) - draw first so user curve is on top
    final aiPath = Path();
    paint.color = primaryColor.withValues(alpha: 0.3);

    for (double x = 0; x <= size.width; x += 2) {
      final normalizedX = x / size.width;
      final y =
          size.height * 0.5 +
          (math.sin(normalizedX * math.pi * 2) * size.height * 0.2) +
          (math.sin(normalizedX * math.pi * 6) * size.height * 0.1);

      if (x == 0) {
        aiPath.moveTo(x, y);
      } else {
        aiPath.lineTo(x, y);
      }
    }
    canvas.drawPath(aiPath, paint);

    // User Curve
    final userPath = Path();
    paint.color = userColor;

    for (double x = 0; x <= size.width; x += 2) {
      final normalizedX = x / size.width;

      final aiY =
          size.height * 0.5 +
          (math.sin(normalizedX * math.pi * 2) * size.height * 0.2) +
          (math.sin(normalizedX * math.pi * 6) * size.height * 0.1);

      double userY;
      if (score >= 90) {
        userY = aiY + (math.sin(x * 0.1) * 2);
      } else if (score >= 60) {
        userY =
            size.height * 0.5 +
            (aiY - size.height * 0.5) * 0.7 +
            (math.sin(x * 0.05) * 5);
      } else {
        userY =
            size.height * 0.5 +
            (aiY - size.height * 0.5) * 0.2 +
            (math.sin(x * 0.1) * 3);
      }

      if (x == 0) {
        userPath.moveTo(x, userY);
      } else {
        userPath.lineTo(x, userY);
      }
    }
    canvas.drawPath(userPath, paint);

    // Draw key point markers
    _drawKeyPointMarkers(canvas, size);
  }

  void _drawKeyPointMarkers(Canvas canvas, Size size) {
    final isQuestion = targetText.trim().endsWith('?');
    final hasExclamation = targetText.contains('!');

    final markerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.lb500; // Blue marker

    // Question mark - show rise at end
    if (isQuestion) {
      final x = size.width * 0.9; // Near the end
      final y = size.height * 0.3; // Upper part (rising pitch)

      // Draw upward arrow
      canvas.drawCircle(Offset(x, y), 4, markerPaint);

      // Draw small arrow pointing up
      final arrowPath = Path()
        ..moveTo(x, y - 8)
        ..lineTo(x - 3, y - 2)
        ..lineTo(x + 3, y - 2)
        ..close();
      canvas.drawPath(arrowPath, markerPaint);
    }

    // Exclamation - show emphasis peak
    if (hasExclamation) {
      final x = size.width * 0.5; // Middle (emphasis point)
      final y = size.height * 0.25; // High point

      // Draw emphasis marker
      canvas.drawCircle(Offset(x, y), 4, markerPaint);

      // Draw small star-like shape for emphasis
      final starPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppColors.lb500;

      for (int i = 0; i < 4; i++) {
        final angle = (i * math.pi / 2);
        final x1 = x + math.cos(angle) * 6;
        final y1 = y + math.sin(angle) * 6;
        canvas.drawLine(Offset(x, y), Offset(x1, y1), starPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant IntonationPainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.userColor != userColor ||
        oldDelegate.targetText != targetText;
  }
}
