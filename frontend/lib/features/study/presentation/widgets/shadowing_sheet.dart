import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:io';
import 'package:frontend/features/speech/speech.dart';
import 'package:frontend/features/chat/domain/models/message.dart';

class ShadowingSheet extends ConsumerStatefulWidget {
  final String targetText;
  final String messageId; // Message ID for file naming
  final VoiceFeedback? initialFeedback; // Previous shadowing result to display
  final String? initialAudioPath; // Previous recording path
  final Function(VoiceFeedback, String?)?
  onFeedbackUpdate; // Callback with feedback and audio path

  const ShadowingSheet({
    super.key,
    required this.targetText,
    required this.messageId,
    this.initialFeedback,
    this.initialAudioPath,
    this.onFeedbackUpdate,
  });

  @override
  ConsumerState<ShadowingSheet> createState() => _ShadowingSheetState();
}

class _ShadowingSheetState extends ConsumerState<ShadowingSheet> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  VoiceFeedback?
  _feedback; // Use VoiceFeedback to unify with initial and new results
  String _errorMessage = '';
  String? _currentRecordingPath; // Track current recording for replay/cleanup

  @override
  void initState() {
    super.initState();
    // Initialize with previous feedback and audio path if available
    _feedback = widget.initialFeedback;
    _currentRecordingPath = widget.initialAudioPath;

    // Listen to audio player state
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    // Note: We do NOT delete the recording on dispose anymore since it's persisted
    super.dispose();
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
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Could not start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
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
      setState(() => _errorMessage = 'Error stopping recording: $e');
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
      setState(() => _errorMessage = 'Failed to play recording: $e');
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
    // Watch the provider state for loading and error
    final assessmentState = ref.watch(pronunciationAssessmentProvider);
    final isAnalyzing = assessmentState.isLoading;
    final providerError = assessmentState.error;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Shadowing Practice',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Only show target text when no feedback (before/during recording)
          if (_feedback == null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                widget.targetText,
                style: const TextStyle(fontSize: 18, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
          ],

          if (isAnalyzing)
            const CircularProgressIndicator()
          else if (_feedback != null)
            _buildResultView()
          else
            _buildRecordButton(),

          if (_errorMessage.isNotEmpty || providerError != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _errorMessage.isNotEmpty ? _errorMessage : providerError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red.shade100 : Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic,
              size: 40,
              color: _isRecording ? Colors.red : Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isRecording ? 'Release to Stop' : 'Hold to Record',
            style: TextStyle(
              color: _isRecording ? Colors.red : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    // Use the stored _feedback directly (either from initial or new assessment)
    return Column(
      children: [
        // Use VoiceFeedbackSheet content inline
        _buildVoiceFeedbackContent(_feedback!),
        const SizedBox(height: 20),
        // Action buttons row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replay button (only show if we have a recording)
            if (_currentRecordingPath != null) ...[
              OutlinedButton.icon(
                onPressed: _playRecording,
                icon: Icon(
                  _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 18,
                ),
                label: Text(_isPlaying ? 'Stop' : 'Replay'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _isPlaying ? Colors.red : Colors.black87,
                  side: BorderSide(
                    color: _isPlaying ? Colors.red : Colors.grey.shade400,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            // Try Again button
            ElevatedButton.icon(
              onPressed: _tryAgain,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoiceFeedbackContent(VoiceFeedback feedback) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeedbackHeader(feedback),
        const SizedBox(height: 20),
        _buildAzureWordFeedback(feedback),
        const SizedBox(height: 16),
        _buildAzureScores(feedback),
      ],
    );
  }

  Widget _buildFeedbackHeader(VoiceFeedback feedback) {
    final score = feedback.pronunciationScore;
    Color scoreColor;
    String label;

    if (score >= 80) {
      scoreColor = Colors.green;
      label = 'Great Job!';
    } else if (score >= 60) {
      scoreColor = Colors.orange;
      label = 'Needs Work';
    } else {
      scoreColor = Colors.red;
      label = 'Try Again';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scoreColor.withValues(alpha: 0.5)),
          ),
          child: Text(
            'Score: $score',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: scoreColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
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

            return IntrinsicWidth(
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
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}
