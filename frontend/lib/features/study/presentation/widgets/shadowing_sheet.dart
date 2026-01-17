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
      final List<String> audioChunks = [];

      // Use streaming API to receive audio chunks
      await for (final chunk in apiService.generateTTSStream(
        widget.targetText,
        messageId: widget.messageId,
      )) {
        if (!mounted) break;

        switch (chunk.type) {
          case TTSChunkType.audioChunk:
            if (chunk.audioBase64 != null) {
              audioChunks.add(chunk.audioBase64!);
            }
            break;
          case TTSChunkType.info:
            // Duration info received
            break;
          case TTSChunkType.done:
            // All chunks received
            break;
          case TTSChunkType.error:
            throw Exception(chunk.error ?? 'TTS generation failed');
        }
      }

      if (!mounted) return;

      if (audioChunks.isEmpty) {
        throw Exception('No audio received');
      }

      // Combine all base64 chunks and decode
      final combinedBase64 = audioChunks.join('');
      final audioBytes = base64Decode(combinedBase64);

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
      final safeFileName = widget.messageId.replaceAll(
        RegExp(r'[^a-zA-Z0-9-_]'),
        '_',
      );
      final audioFile = File('${ttsCacheDir.path}/$safeFileName.mp3');
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
    final cleanWord = word
        .replaceAll(RegExp(r'[.,!?;:"]'), '')
        .trim();
    if (cleanWord.isEmpty) return;

    try {
      await _wordTtsService.speakWord(cleanWord, language: 'en-US');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Word TTS error: $e');
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
            showTopToast(context, 'Recording too short, please try again', isError: true);
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
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxSheetHeight,
        ),
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
                      color: Colors.grey[300],
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
                                  ? AppColors.lightSuccess.withValues(alpha: 0.1)
                                  : AppColors.lightError.withValues(alpha: 0.1))
                              : Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: _feedback != null
                            ? Text(
                                _feedback!.pronunciationScore >= 80 ? '🎉' : '😔',
                                style: const TextStyle(fontSize: 20, height: 1),
                              )
                            : Icon(
                                Icons.record_voice_over_rounded,
                                color: AppColors.secondary,
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 12),
                      if (_feedback != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lightSuccess,
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
                          _feedback!.pronunciationScore >= 80 ? 'Great Job!' : 'Keep Practicing!',
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
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Target Text - Show only when idle or recording
                  if (!isAnalyzing && _feedback == null)
                    _buildTargetTextView(),
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
                        _isTTSPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        size: 28,
                        color: AppColors.lightTextPrimary,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Listen',
              style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
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
                  color: _isRecording ? AppColors.lightError : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? AppColors.lightError : AppColors.primary)
                          .withValues(alpha: 0.3),
                      blurRadius: 12, 
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _feedback == null ? 'Hold to Record' : 'Record Again',
              style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
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
                        color: AppColors.lightSuccess, // Green
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${_feedback!.pronunciationScore}',
                        style: const TextStyle(
                          color:  Colors.white,
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
              style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
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
        if (feedback.azureProsodyScore != null)
          _buildProsodySection(feedback),
        const SizedBox(height: 32),
        _buildAzureWordFeedback(feedback),
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
    
    // Determine status text based on score
    String statusText;
    if (score >= 80) {
      statusText = 'Great intonation! You sound natural.';
    } else if (score >= 60) {
      statusText = 'Good start. Try to express more emotion.';
    } else {
      statusText = 'Too flat. Mimic the ups and downs.';
    }

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightDivider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  size: 20,
                  color: Colors.blue,
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
          // Pitch Contour Visualization
          SizedBox(
            height: 80,
            width: double.infinity,
            child: CustomPaint(
              painter: IntonationPainter(
                score: score,
                primaryColor: AppColors.primary,
                userColor: _getScoreColor(score),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Native Speaker', AppColors.primary.withValues(alpha: 0.3)),
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
            child: Text(
              statusText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _getScoreColor(score), // Matches the user curve color
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
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
     if (score >= 80) return const Color(0xFF10B981); // Green
     if (score >= 60) return const Color(0xFFF59E0B); // Orange
     return const Color(0xFFEF4444); // Red
  }

  Widget _buildStatItem(String label, double? score) {
    final value = score?.round() ?? 0;
    Color valueColor;
    if (value >= 80) {
      valueColor = const Color(0xFF10B981); // Green
    } else if (value >= 60) {
      valueColor = const Color(0xFFF59E0B); // Orange
    } else {
      valueColor = const Color(0xFFEF4444); // Red
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
            color: Color(0xFF6B7280),
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
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Azure AI',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: words.map((word) {
            Color color;
            switch (word.level) {
              case 'perfect':
                color = Colors.green;
                break;
              case 'warning':
                color = Colors.orange;
                break;
              case 'error':
                color = Colors.red;
                break;
              case 'missing':
                color = Colors.grey;
                break;
              default:
                color = Colors.grey;
            }

            return GestureDetector(
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
                            ? Colors.grey
                            : Colors.black87,
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
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAzureScores(VoiceFeedback feedback) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
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
      color = Colors.green;
    } else if (displayScore >= 60) {
      color = Colors.orange;
    } else {
      color = Colors.red;
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
      baseColor: AppColors.lightDivider,
      highlightColor: AppColors.lightSurface,
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
          
          // Words Skeleton
          Row(
            children: [
              _buildSkeletonBox(height: 16, width: 80, radius: 4),
              const SizedBox(width: 8),
              _buildSkeletonBox(height: 20, width: 60, radius: 4),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(8, (index) {
               final width = 40.0 + (index % 3) * 20.0;
               return Column(
                 children: [
                   _buildSkeletonBox(height: 20, width: width, radius: 4),
                   const SizedBox(height: 4),
                   _buildSkeletonBox(height: 4, width: 20, radius: 2),
                   const SizedBox(height: 2),
                   _buildSkeletonBox(height: 10, width: 15, radius: 2),
                 ],
               );
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

  Widget _buildSkeletonBox({required double height, required double width, double radius = 4}) {
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

/// Custom painter for drawing pitch contour visualization
class IntonationPainter extends CustomPainter {
  final double score;
  final Color primaryColor;
  final Color userColor;

  IntonationPainter({
    required this.score,
    required this.primaryColor,
    required this.userColor,
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
      final y = size.height * 0.5 + 
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
      
      final aiY = size.height * 0.5 + 
                 (math.sin(normalizedX * math.pi * 2) * size.height * 0.2) +
                 (math.sin(normalizedX * math.pi * 6) * size.height * 0.1);
      
      double userY;
      if (score >= 90) {
        userY = aiY + (math.sin(x * 0.1) * 2); 
      } else if (score >= 60) {
        userY = size.height * 0.5 + 
               (aiY - size.height * 0.5) * 0.7 +
               (math.sin(x * 0.05) * 5);
      } else {
        userY = size.height * 0.5 + 
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
  }

  @override
  bool shouldRepaint(covariant IntonationPainter oldDelegate) {
    return oldDelegate.score != score ||
           oldDelegate.primaryColor != primaryColor ||
           oldDelegate.userColor != userColor;
  }
}
