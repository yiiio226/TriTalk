import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:frontend/features/speech/speech.dart';

class ShadowingSheet extends ConsumerStatefulWidget {
  final String targetText;

  const ShadowingSheet({super.key, required this.targetText});

  @override
  ConsumerState<ShadowingSheet> createState() => _ShadowingSheetState();
}

class _ShadowingSheetState extends ConsumerState<ShadowingSheet> {
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  PronunciationResult? _result;
  String _errorMessage = '';

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/shadow_${DateTime.now().millisecondsSinceEpoch}.wav';

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
          _result = null;
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
      setState(() {
        _isRecording = false;
      });
      if (path != null) {
        _analyzeAudio(path);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error stopping recording: $e');
    }
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

      setState(() {
        _result = result;
      });
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

          if (isAnalyzing)
            const CircularProgressIndicator()
          else if (_result != null)
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
    final overallScore = _result!.pronunciationScore.round();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  '$overallScore',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(overallScore),
                  ),
                ),
                Text('Score', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(width: 32),
            Column(
              children: [
                _buildMiniScore('Fluency', _result!.fluencyScore),
                const SizedBox(height: 8),
                _buildMiniScore('Accuracy', _result!.accuracyScore),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Word-level feedback
        if (_result!.wordFeedback.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _result!.wordFeedback.map((word) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: word.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: word.color.withAlpha(100)),
                ),
                child: Text(
                  word.text,
                  style: TextStyle(
                    color: word.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Feedback tip
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.tips_and_updates, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _generateFeedback(),
                  style: const TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () {
            setState(() {
              _result = null;
            });
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh),
              SizedBox(width: 8),
              Text('Try Again'),
            ],
          ),
        ),
      ],
    );
  }

  String _generateFeedback() {
    final score = _result!.pronunciationScore;
    final problemWords = _result!.wordFeedback
        .where((w) => w.hasIssue)
        .toList();

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

  Widget _buildMiniScore(String label, double score) {
    final intScore = score.round();
    return Row(
      children: [
        SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey.shade200,
            color: _getScoreColor(intScore),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}
