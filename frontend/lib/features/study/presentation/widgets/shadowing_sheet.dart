import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shimmer/shimmer.dart';

import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/core/auth/auth_provider.dart';
import 'package:frontend/core/mixins/tts_playback_mixin.dart';
import 'package:frontend/core/services/streaming_tts_service.dart';
import 'package:frontend/core/widgets/top_toast.dart';
import 'package:frontend/features/study/data/shadowing_history_service.dart';
import 'package:frontend/features/speech/speech.dart';
import 'package:frontend/features/chat/domain/models/message.dart';

class ShadowingSheet extends ConsumerStatefulWidget {
  final String targetText;
  final String messageId; // Message ID for file naming
  final VoiceFeedback? initialFeedback; // Previous shadowing result to display
  final String? initialTtsAudioPath; // Previous TTS audio path (cached)

  // Practice context for history tracking
  final String
  sourceType; // 'ai_message', 'native_expression', 'reference_answer'
  final String? sourceId;
  final String? sceneKey;

  final Function(VoiceFeedback, String?)?
  onFeedbackUpdate; // Callback with feedback and local audio path
  final Function(String)? onTtsUpdate; // Callback when TTS audio is generated

  // Async loading support
  final bool
  isLoadingInitialData; // Show skeleton loader while loading cloud data
  final Future<({VoiceFeedback? feedback})?> Function()?
  onLoadInitialData; // Callback to load cloud data

  const ShadowingSheet({
    super.key,
    required this.targetText,
    required this.messageId,
    this.initialFeedback,
    this.initialTtsAudioPath,
    this.sourceType = 'ai_message',
    this.sourceId,
    this.sceneKey,
    this.onFeedbackUpdate,
    this.onTtsUpdate,
    this.isLoadingInitialData = false,
    this.onLoadInitialData,
  });

  @override
  ConsumerState<ShadowingSheet> createState() => _ShadowingSheetState();
}

class _ShadowingSheetState extends ConsumerState<ShadowingSheet>
    with TickerProviderStateMixin, TtsPlaybackMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  VoiceFeedback?
  _feedback; // Use VoiceFeedback to unify with initial and new results
  // _errorMessage removed
  String? _currentRecordingPath; // Track current recording for replay/cleanup
  DateTime? _recordingStartTime; // Track recording duration

  // Loading state for initial data
  bool _isLoadingInitialData = false;

  // Drag state for recording button
  double _dragOffset = 0; // Horizontal offset during drag
  String? _dragAction; // 'cancel' or 'complete' based on drag direction
  static const double _dragThreshold = 90; // Threshold to trigger action

  // TTS state for "Listen" button (updated by TtsPlaybackMixin callbacks)
  bool _isTTSLoading = false;
  bool _isTTSPlaying = false;
  String? _ttsAudioPath; // Cached TTS audio file path

  // Word TTS service for playing individual word pronunciations
  final WordTtsService _wordTtsService = WordTtsService();

  // Waveform animation controller
  late AnimationController _waveformController;

  @override
  void initState() {
    super.initState();
    // Initialize with previous feedback if available
    _feedback = widget.initialFeedback;
    _ttsAudioPath = widget.initialTtsAudioPath;
    _isLoadingInitialData = widget.isLoadingInitialData;

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

    // TTS state is now managed by TtsPlaybackMixin

    // Load initial data asynchronously if callback is provided
    if (widget.onLoadInitialData != null && _isLoadingInitialData) {
      _loadInitialData();
    }
  }

  /// Load initial feedback data from cloud asynchronously
  Future<void> _loadInitialData() async {
    try {
      final result = await widget.onLoadInitialData!();

      if (mounted) {
        setState(() {
          if (result != null) {
            // Cloud data found - show historical feedback
            _feedback = result.feedback;
          }
          // Always stop loading, whether data was found or not
          _isLoadingInitialData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
      if (kDebugMode) {
        debugPrint('⚠️ Failed to load initial data: $e');
      }
    }
  }

  /// Stop all audio playback and perform cleanup before closing the sheet.
  /// This ensures a clean experience when the sheet is dismissed.
  Future<void> _stopAllAudioAndCleanup() async {
    // Stop StreamingTtsService (main TTS and segment TTS)
    final streamingTts = StreamingTtsService.instance;
    if (streamingTts.isPlaying) {
      await streamingTts.stop();
    }

    // Stop recording playback
    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    // Stop recording if in progress
    if (_isRecording) {
      try {
        await _audioRecorder.stop();
      } catch (e) {
        // Ignore errors during cleanup
      }
    }

    // Stop word TTS (may throw if player not initialized)
    try {
      await _wordTtsService.stop();
    } catch (e) {
      // Ignore errors - player may not be initialized
    }

    // Update state
    if (mounted) {
      setState(() {
        _isTTSLoading = false;
        _isTTSPlaying = false;
        _isPlaying = false;
        _isRecording = false;
      });
    }
  }

  /// Close the sheet with proper cleanup
  Future<void> _closeSheet() async {
    await _stopAllAudioAndCleanup();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    // Stop StreamingTtsService synchronously (best effort)
    final streamingTts = StreamingTtsService.instance;
    if (streamingTts.isPlaying) {
      streamingTts.stop(); // Fire and forget - can't await in dispose
    }

    _waveformController.dispose();

    // Wrap dispose calls in try-catch to handle uninitialized resources
    try {
      _audioRecorder.dispose();
    } catch (e) {
      // Ignore - recorder may not have been initialized
    }

    try {
      _audioPlayer.dispose();
    } catch (e) {
      // Ignore - player may not have been initialized
    }

    try {
      _wordTtsService.dispose();
    } catch (e) {
      // Ignore - service may not have been used
    }

    disposeTtsPlayback(); // Clean up TTS mixin resources
    // Note: We do NOT delete the recording on dispose anymore since it's persisted
    super.dispose();
  }

  /// Play text-to-speech for the target text (correct pronunciation)
  /// Delegates to TtsPlaybackMixin for streaming and caching logic
  Future<void> _playTextToSpeech() async {
    await playTts(
      text: widget.targetText,
      cacheKey: widget.messageId,
      cachedPath: _ttsAudioPath,
      isMounted: () => mounted,
      onStateChange: (loading, playing) {
        setState(() {
          _isTTSLoading = loading;
          _isTTSPlaying = playing;
        });
      },
      beforePlay: () async {
        // Stop recording playback if playing
        if (_isPlaying) {
          await _audioPlayer.stop();
        }
      },
      onCacheSaved: (cachePath) {
        setState(() => _ttsAudioPath = cachePath);
        // Notify parent to persist the TTS audio path
        widget.onTtsUpdate?.call(cachePath);
      },
      onError: (error) {
        if (mounted) {
          showTopToast(context, error, isError: true);
        }
      },
    );
  }

  // _setupTtsStateListener is now handled by TtsPlaybackMixin

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

  /// Get display segments (using smart segments or fallback)
  List<SmartSegmentFeedback> _getDisplaySegments() {
    if (_feedback?.hasSmartSegments == true) {
      return _feedback!.smartSegments!;
    }

    // Fallback logic matching _playSegmentAudio fallback
    // We create fake SmartSegmentFeedback objects dividing text into 3 parts
    final words = widget.targetText.split(' ');
    // Handle empty text
    if (words.isEmpty || (words.length == 1 && words[0].isEmpty)) {
      return [];
    }

    final segmentSize = (words.length / 3).ceil();
    final List<SmartSegmentFeedback> fallback = [];
    final currentScore = _feedback?.pronunciationScore.toDouble() ?? 0.0;

    for (int i = 0; i < 3; i++) {
      int start = i * segmentSize;
      if (start >= words.length) break;
      int end = (start + segmentSize).clamp(0, words.length); // clamp is safer

      final sublist = words.sublist(start, end);
      if (sublist.isEmpty) continue;

      final text = sublist.join(' ');
      fallback.add(
        SmartSegmentFeedback(
          text: text,
          startIndex: start,
          endIndex: end,
          score: currentScore,
          hasError: false,
          wordCount: end - start,
        ),
      );
    }
    return fallback;
  }

  /// Play audio for a specific segment of the target text using true streaming
  /// Uses StreamingTtsService for low-latency playback (audio starts as chunks arrive)
  /// When smart segments are available (from Azure Break data), uses those for precise segmentation
  /// Caches segment audio for subsequent plays
  Future<void> _playSegmentAudio(int segmentIndex) async {
    final segments = _getDisplaySegments();
    if (segmentIndex >= segments.length) return;

    final segmentText = segments[segmentIndex].text;

    if (kDebugMode) {
      debugPrint(
        '🔊 Playing segment $segmentIndex (smart=${_feedback?.hasSmartSegments}): "$segmentText"',
      );
    }

    if (segmentText.isEmpty) return;

    final streamingTts = StreamingTtsService.instance;

    // Generate consistent cache key for this segment
    final segmentCacheKey = 'seg_${widget.messageId}_$segmentIndex';

    // Stop any current playback before starting segment
    if (streamingTts.isPlaying) {
      await streamingTts.stop();
    }

    try {
      // Check if we have a cached audio file for this segment
      final cachedPath = _segmentCachePaths[segmentCacheKey];
      if (cachedPath != null && await File(cachedPath).exists()) {
        if (kDebugMode) {
          debugPrint('🔊 [Segment] Using cached audio: $cachedPath');
        }
        await streamingTts.playCached(cachedPath);
        return;
      }

      // Setup callback to save cache path when audio is saved
      streamingTts.onCacheSaved = (cachePath) {
        _segmentCachePaths[segmentCacheKey] = cachePath;
        if (kDebugMode) {
          debugPrint('🔊 [Segment] Cached segment $segmentIndex: $cachePath');
        }
      };

      // Use StreamingTtsService for streaming playback with caching
      await streamingTts.playStreaming(segmentText, messageId: segmentCacheKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Segment TTS error: $e');
      }
    }
  }

  /// Cache for segment audio file paths
  /// Key: 'seg_{messageId}_{segmentIndex}', Value: cached audio path
  final Map<String, String> _segmentCachePaths = {};

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
    // Reset drag state
    setState(() {
      _dragOffset = 0;
      _dragAction = null;
    });

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

  /// Cancel the current recording without saving or analyzing
  Future<void> _cancelRecording() async {
    // Reset drag state
    setState(() {
      _dragOffset = 0;
      _dragAction = null;
    });

    try {
      final path = await _audioRecorder.stop();

      // Delete the cancelled recording
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }

      setState(() {
        _isRecording = false;
        _currentRecordingPath = null;
      });

      if (mounted) {
        showTopToast(context, 'Recording cancelled', isError: false);
      }
    } catch (e) {
      if (mounted) {
        showTopToast(context, 'Error cancelling recording: $e', isError: true);
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

      // Convert smart segments from pronunciation result
      final smartSegments = result.segments
          .map(
            (s) => SmartSegmentFeedback(
              text: s.text,
              startIndex: s.startIndex,
              endIndex: s.endIndex,
              score: s.score,
              hasError: s.hasError,
              wordCount: s.wordCount,
            ),
          )
          .toList();

      if (kDebugMode && smartSegments.isNotEmpty) {
        debugPrint(
          '📊 Smart Segments: ${smartSegments.length} segments detected',
        );
        for (int i = 0; i < smartSegments.length; i++) {
          final seg = smartSegments[i];
          debugPrint('   Segment $i: "${seg.text}" (score: ${seg.score})');
        }
      }

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
        smartSegments: smartSegments.isNotEmpty ? smartSegments : null,
      );

      setState(() {
        _feedback = voiceFeedback;
      });

      // Save to practice history
      try {
        await ShadowingHistoryService().savePractice(
          targetText: widget.targetText,
          sourceType: widget.sourceType,
          sourceId: widget.sourceId ?? widget.messageId,
          sceneKey: widget.sceneKey,
          pronunciationScore: voiceFeedback.pronunciationScore,
          accuracyScore: voiceFeedback.azureAccuracyScore,
          fluencyScore: voiceFeedback.azureFluencyScore,
          completenessScore: voiceFeedback.azureCompletenessScore,
          prosodyScore: voiceFeedback.azureProsodyScore,
          wordFeedback: voiceFeedback.azureWordFeedback,
          feedbackText: voiceFeedback.feedback,
          segments: voiceFeedback.smartSegments,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to save practice history: $e');
        }
      }

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

    return PopScope(
      canPop: false, // We handle the pop manually to stop audio first
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // Already popped, nothing to do

        // Stop all audio before closing
        await _stopAllAudioAndCleanup();

        // Now allow the pop
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
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
            mainAxisSize: MainAxisSize.max,
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
                            color: AppColors.ln50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.record_voice_over_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Shadowing Practice',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _closeSheet,
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
                    if (!isAnalyzing &&
                        !_isLoadingInitialData &&
                        _feedback == null)
                      _buildTargetTextView(),
                    if (!isAnalyzing &&
                        !_isLoadingInitialData &&
                        _feedback == null)
                      const SizedBox(height: 16),
                  ],
                ),
              ),

              // Scrollable Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAnalyzing || _isLoadingInitialData)
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
      ), // Close PopScope child
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
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Layer 1: Side Controls (Left/Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Left Button (Listen or Cancel)
              SizedBox(
                width: 80,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _isRecording ? null : _playTextToSpeech,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? (_dragAction == 'cancel'
                                    ? AppColors.lr500
                                    : AppColors.lr50)
                              : AppColors.lightBackground,
                          shape: BoxShape.circle,
                          border: _isRecording
                              ? Border.all(
                                  color: _dragAction == 'cancel'
                                      ? AppColors.lr500
                                      : AppColors.lr200,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: _isRecording
                            ? Icon(
                                Icons.close_rounded,
                                size: 28,
                                color: _dragAction == 'cancel'
                                    ? Colors.white
                                    : AppColors.lr500,
                              )
                            : (_isTTSLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      _isTTSPlaying
                                          ? Icons.stop_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 28,
                                      color: AppColors.lightTextPrimary,
                                    )),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRecording ? 'Cancel' : 'Listen',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isRecording && _dragAction == 'cancel'
                            ? AppColors.lr500
                            : AppColors.lightTextSecondary,
                        fontWeight: _isRecording && _dragAction == 'cancel'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              // Spacer for Center Button (72 + padding)
              const SizedBox(width: 180),

              // 3. Right Button (Score or Complete)
              SizedBox(
                width: 80,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isRecording
                        ? AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: _dragAction == 'complete'
                                  ? AppColors.lg500
                                  : AppColors.lg50,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _dragAction == 'complete'
                                    ? AppColors.lg500
                                    : AppColors.lg200,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.check_rounded,
                              size: 28,
                              color: _dragAction == 'complete'
                                  ? Colors.white
                                  : AppColors.lg500,
                            ),
                          )
                        : (_feedback != null
                              ? GestureDetector(
                                  onTap: _playRecording,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: const BoxDecoration(
                                      color: AppColors.lg500,
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
                                )),
                    const SizedBox(height: 8),
                    Text(
                      _isRecording
                          ? 'Complete'
                          : (_feedback == null ? 'Not Rated' : 'My Score'),
                      style: TextStyle(
                        fontSize: 12,
                        color: _isRecording && _dragAction == 'complete'
                            ? AppColors.lg500
                            : AppColors.lightTextSecondary,
                        fontWeight: _isRecording && _dragAction == 'complete'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Layer 2: Record Button & Tail (Centered)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none, // Allow tail to draw outside
                  children: [
                    // Tail Effect (Behind Button)
                    if (_isRecording && _dragOffset.abs() > 0)
                      CustomPaint(
                        painter: DragTailPainter(
                          offset: _dragOffset,
                          color: AppColors.lg500,
                        ),
                      ),

                    // Draggable Button
                    Transform.translate(
                      offset: Offset(_dragOffset, 0),
                      child: GestureDetector(
                        onLongPressStart: (_) {
                          _startRecording();
                        },
                        onLongPressMoveUpdate: (details) {
                          if (!_isRecording) return;

                          setState(() {
                            _dragOffset = details.localOffsetFromOrigin.dx
                                .clamp(-110.0, 110.0);

                            // Determine action based on drag position
                            if (_dragOffset < -_dragThreshold) {
                              _dragAction = 'cancel';
                            } else if (_dragOffset > _dragThreshold) {
                              _dragAction = 'complete';
                            } else {
                              _dragAction = null;
                            }
                          });
                        },
                        onLongPressEnd: (_) {
                          if (!_isRecording) return;

                          if (_dragAction == 'cancel') {
                            _cancelRecording();
                          } else if (_dragAction == 'complete') {
                            _stopRecording();
                          } else {
                            _stopRecording();
                          }
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: _isRecording
                                ? AppColors.lg500
                                : AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isRecording && _dragOffset.abs() > 0)
                                    ? Colors.black.withValues(alpha: 0.2)
                                    : (_isRecording
                                              ? AppColors.lg500
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
                    ),
                  ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceFeedbackContent(VoiceFeedback feedback) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildScoreCard(feedback),
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

  Widget _buildScoreCard(VoiceFeedback feedback) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.lightDivider),
      ),
      child: Column(
        children: [
          // Header: Icon + Title + Score Badge
          Row(
            children: [
              // Icon & Title
              Text(
                feedback.pronunciationScore >= 80 ? '🎉' : '💪',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feedback.pronunciationScore >= 80
                      ? 'Great Job!'
                      : 'Keep Practicing!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
              // Score Badge
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _getScoreColor(feedback.pronunciationScore.toDouble()),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${feedback.pronunciationScore}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNewStatItem(
                  'Accuracy',
                  feedback.azureAccuracyScore?.round() ?? 0,
                ),
                _buildNewStatItem(
                  'Fluency',
                  feedback.azureFluencyScore?.round() ?? 0,
                ),
                _buildNewStatItem(
                  'Complete',
                  feedback.azureCompletenessScore?.round() ?? 0,
                ),
                if (feedback.azureProsodyScore != null)
                  _buildNewStatItem(
                    'Prosody',
                    feedback.azureProsodyScore!.round(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewStatItem(String label, int score) {
    return Column(
      children: [
        Text(
          '$score',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _getScoreColor(score.toDouble()),
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
          // Pitch Contour Visualization with Interactive Segments
          LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (details) {
                  final segments = _getDisplaySegments();
                  if (segments.isEmpty) return;

                  // Calculate geometry to find tapped segment
                  // Must match IntonationPainter's layout logic!
                  const double gap = 12.0;
                  final int count = segments.length;
                  final double totalGapWidth = gap * (count - 1);
                  final double availableWidth =
                      constraints.maxWidth - totalGapWidth;

                  int totalWords = 0;
                  for (var seg in segments) {
                    totalWords += seg.wordCount;
                  }
                  if (totalWords == 0) {
                    totalWords = count; // Avoid division by zero
                  }

                  double currentX = 0;
                  for (int i = 0; i < count; i++) {
                    final seg = segments[i];
                    final double weight = seg.wordCount > 0
                        ? seg.wordCount.toDouble()
                        : 1.0;
                    final double fraction = totalWords > 0
                        ? weight / totalWords
                        : 1.0 / count;
                    final double segWidth = availableWidth * fraction;

                    // Allow tapping slightly into the gap for easier touch
                    if (details.localPosition.dx >= currentX &&
                        details.localPosition.dx <=
                            currentX + segWidth + (gap / 2)) {
                      _playSegmentAudio(i);
                      break;
                    }
                    currentX += segWidth + gap;
                  }
                },
                child: SizedBox(
                  height: 80,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: IntonationPainter(
                      overallScore: score,
                      primaryColor: AppColors.primary,
                      userColor: _getScoreColor(score),
                      targetText: widget.targetText,
                      segments: _getDisplaySegments(),
                    ),
                  ),
                ),
              );
            },
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
          // Row(
          //   children: [
          //     _buildSkeletonBox(height: 32, width: 100, radius: 8),
          //     const SizedBox(width: 12),
          //     _buildSkeletonBox(height: 24, width: 120, radius: 4),
          //   ],
          // ),
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
  final double overallScore;
  final Color primaryColor;
  final Color userColor; // Kept for legacy/fallback usage
  final String targetText;
  final List<SmartSegmentFeedback>? segments;

  IntonationPainter({
    required this.overallScore,
    required this.primaryColor,
    required this.userColor,
    required this.targetText,
    this.segments,
  });

  // Helper for colors specific to segment
  Color _getSegmentColor(double score) {
    if (score >= 80) return AppColors.lg500;
    if (score >= 60) return AppColors.ly500;
    return AppColors.lightError;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    if (segments != null && segments!.isNotEmpty) {
      _paintSegments(canvas, size, paint);
    } else {
      _paintContinuous(canvas, size, paint);
    }

    // Draw key point markers (annotations)
    _drawKeyPointMarkers(canvas, size);
  }

  void _paintSegments(Canvas canvas, Size size, Paint paint) {
    // Determine layout
    // Gap between segments
    const double gap = 12.0;
    final int count = segments!.length;
    final double totalGapWidth = gap * (count - 1);
    final double availableWidth = size.width - totalGapWidth;

    // Calculate total weight (word count)
    int totalWords = 0;
    for (var seg in segments!) {
      totalWords += seg.wordCount;
    }
    // If no word counts, assume equal weight
    if (totalWords == 0) totalWords = count * 10;

    double currentX = 0;

    for (int i = 0; i < count; i++) {
      final seg = segments![i];
      final double weight = seg.wordCount > 0
          ? seg.wordCount.toDouble()
          : (totalWords / count);
      final double fraction = totalWords > 0
          ? weight / totalWords
          : 1.0 / count;
      final double segWidth = availableWidth * fraction;

      final segRect = Rect.fromLTWH(currentX, 0, segWidth, size.height);

      // Draw AI Curve for this segment (faint native speaker line)
      _drawCurve(
        canvas,
        segRect,
        primaryColor.withValues(alpha: 0.3),
        isAi: true,
      );

      // Draw User Curve for this segment with segment-specific color
      _drawCurve(
        canvas,
        segRect,
        _getSegmentColor(seg.score),
        isAi: false,
        score: seg.score,
      );

      // Separator UI: Draw a light vertical line in the gap to make it clearer?
      // The user asked for "gap UI more obvious". A gap is empty space.
      // Let's add a small vertical ticker in the gap.
      if (i < count - 1) {
        final sepX = currentX + segWidth + (gap / 2);
        final sepPaint = Paint()
          ..color = AppColors.lightDivider
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(sepX, size.height * 0.3),
          Offset(sepX, size.height * 0.7),
          sepPaint,
        );
      }

      currentX += segWidth + gap;
    }
  }

  void _paintContinuous(Canvas canvas, Size size, Paint paint) {
    _drawCurve(
      canvas,
      Rect.fromLTWH(0, 0, size.width, size.height),
      primaryColor.withValues(alpha: 0.3),
      isAi: true,
    );
    _drawCurve(
      canvas,
      Rect.fromLTWH(0, 0, size.width, size.height),
      userColor,
      isAi: false,
      score: overallScore,
    );
  }

  void _drawCurve(
    Canvas canvas,
    Rect rect,
    Color color, {
    required bool isAi,
    double score = 0,
  }) {
    final path = Path();
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..color = color;

    // Step size relative to width (ensure smoother curve)
    final double step = math.max(1.0, rect.width / 40.0);

    for (double localX = 0; localX <= rect.width; localX += step) {
      final double t = localX / rect.width;

      // Base curve (Standard AI intonation pattern simulation)
      // Maximize amplitude to use full height for better visibility
      final baseY =
          rect.top +
          rect.height * 0.5 +
          (math.sin(t * math.pi * 2) * rect.height * 0.30) +
          (math.sin(t * math.pi * 6) * rect.height * 0.15);

      double y = baseY;

      if (!isAi) {
        // User deviation based on score
        if (score >= 90) {
          // Close to original but with enough jitter to be visible
          y = baseY + (math.sin(t * 12) * 6);
        } else if (score >= 60) {
          // Mild distortion - flatter and more wobble
          y =
              rect.center.dy +
              (baseY - rect.center.dy) * 0.6 +
              (math.sin(t * 18) * 12);
        } else {
          // Flat/Poor - very different from native
          y =
              rect.center.dy +
              (baseY - rect.center.dy) * 0.2 +
              (math.sin(t * 10) * 10);
        }
      }

      if (localX == 0) {
        path.moveTo(rect.left + localX, y);
      } else {
        path.lineTo(rect.left + localX, y);
      }
    }

    // Ensure we draw to the very end
    if (rect.width > 0) {
      // Last point calculation
      // redundant if loop hits it, but loop might miss exact end due to step
    }

    canvas.drawPath(path, paint);
  }

  void _drawKeyPointMarkers(Canvas canvas, Size size) {
    // Draw markers on top of everything (global position)
    final isQuestion = targetText.trim().endsWith('?');
    final hasExclamation = targetText.contains('!');

    final markerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.lb500; // Blue marker

    // Question mark - show rise at end
    if (isQuestion) {
      final x = size.width * 0.95; // Near the end
      final y = size.height * 0.3; // Upper part (rising pitch)

      canvas.drawCircle(Offset(x, y), 4, markerPaint);

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

      canvas.drawCircle(Offset(x, y), 4, markerPaint);

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
    // Deep compare of segments would be expensive, but generally they don't change often
    return oldDelegate.overallScore != overallScore ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.targetText != targetText ||
        oldDelegate.segments != segments;
  }
}

/// Custom painter to draw a sticky/gooey connection tail during drag
class DragTailPainter extends CustomPainter {
  final double offset;
  final Color color;

  DragTailPainter({required this.offset, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (offset.abs() < 5) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Radius of the circle button (approx 72/2 = 36)
    const double radius = 36.0;

    // We want to draw a connection from center (0,0) to button center (offset, 0)
    // However, the button itself is drawing the circle at (offset, 0).
    // We also draw a circle at (0,0) to act as the "anchor".

    // 1. Draw Anchor Circle
    canvas.drawCircle(Offset.zero, radius, paint);

    // 2. Draw Connection
    // Calculate pinch effect
    double dist = offset.abs();
    double pinch = dist * 0.15; // Amount to pinch in y-axis
    if (pinch > radius * 0.6) pinch = radius * 0.6; // Max pinch limit

    // Midpoint x
    double midX = offset / 2;

    final path = Path();

    // Top line
    path.moveTo(0, -radius);
    path.quadraticBezierTo(midX, -radius + pinch, offset, -radius);

    // Right cap
    path.lineTo(offset, radius);

    // Bottom line
    path.quadraticBezierTo(midX, radius - pinch, 0, radius);

    // Close
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DragTailPainter oldDelegate) =>
      oldDelegate.offset != offset || oldDelegate.color != color;
}
