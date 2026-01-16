import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:frontend/features/chat/domain/models/message.dart';
import 'package:frontend/features/speech/speech.dart';
import 'package:frontend/core/widgets/styled_drawer.dart';

class VoiceFeedbackSheet extends ConsumerStatefulWidget {
  final VoiceFeedback feedback;
  final ScrollController? scrollController;
  final String? audioPath; // For calling speech/assess
  final String? transcript; // Reference text for assessment
  final Function(VoiceFeedback)?
  onFeedbackUpdate; // Callback when Azure data arrives

  const VoiceFeedbackSheet({
    super.key,
    required this.feedback,
    this.scrollController,
    this.audioPath,
    this.transcript,
    this.onFeedbackUpdate,
  });

  @override
  ConsumerState<VoiceFeedbackSheet> createState() => _VoiceFeedbackSheetState();
}

class _VoiceFeedbackSheetState extends ConsumerState<VoiceFeedbackSheet> {
  late VoiceFeedback _feedback;
  bool _hasTriggeredAssessment = false;

  // Word TTS service for playing word pronunciations
  final WordTtsService _wordTtsService = WordTtsService();

  @override
  void initState() {
    super.initState();
    _feedback = widget.feedback;

    // Schedule the assessment after build to access ref safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerAssessmentIfNeeded();
    });
  }

  void _triggerAssessmentIfNeeded() {
    // If we don't have Azure data yet and have audio/transcript, fetch it
    if (!_hasTriggeredAssessment &&
        !_feedback.hasAzureData &&
        widget.audioPath != null &&
        widget.transcript != null &&
        widget.transcript!.isNotEmpty) {
      _hasTriggeredAssessment = true;

      if (kDebugMode) {
        debugPrint(
          '🎤 VoiceFeedbackSheet: Triggering speech/assess via provider',
        );
        debugPrint('   audioPath: ${widget.audioPath}');
        debugPrint('   transcript: "${widget.transcript}"');
      }

      // Clear previous state and trigger new assessment
      ref.read(pronunciationAssessmentProvider.notifier).clearResult();

      ref
          .read(pronunciationAssessmentProvider.notifier)
          .assessFromPath(
            audioPath: widget.audioPath!,
            referenceText: widget.transcript!,
            language: 'en-US',
            enableProsody: true,
          )
          .then((result) {
            if (result != null && mounted) {
              _handleAssessmentResult(result);
            }
          });
    }
  }

  void _handleAssessmentResult(PronunciationResult result) {
    if (kDebugMode) {
      debugPrint('✅ Speech/Assess Response:');
      debugPrint('   isSuccess: ${result.isSuccess}');
      debugPrint('   pronunciationScore: ${result.pronunciationScore}');
      debugPrint('   accuracyScore: ${result.accuracyScore}');
      debugPrint('   fluencyScore: ${result.fluencyScore}');
      debugPrint('   completenessScore: ${result.completenessScore}');
      debugPrint('   prosodyScore: ${result.prosodyScore}');
      debugPrint('   wordFeedback: ${result.wordFeedback.length} words');
      for (final word in result.wordFeedback) {
        debugPrint(
          '     - "${word.text}": score=${word.score}, level=${word.level}, errorType=${word.errorType}',
        );
      }
    }

    if (!result.isSuccess) {
      return;
    }

    // Convert to our model format
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

    final updatedFeedback = _feedback.copyWithAzureData(
      pronunciationScore: result.pronunciationScore.round(),
      azureAccuracyScore: result.accuracyScore,
      azureFluencyScore: result.fluencyScore,
      azureCompletenessScore: result.completenessScore,
      azureProsodyScore: result.prosodyScore,
      azureWordFeedback: azureWordFeedback,
    );

    setState(() {
      _feedback = updatedFeedback;
    });

    // Notify parent to persist the update
    widget.onFeedbackUpdate?.call(updatedFeedback);
  }

  /// Play pronunciation for a word
  Future<void> _playWordPronunciation(String word) async {
    // Clean the word (remove punctuation)
    final cleanWord = word.replaceAll(RegExp(r'[^\w\s\u4e00-\u9fff]'), '').trim();
    if (cleanWord.isEmpty) return;

    try {
      await _wordTtsService.speakWord(cleanWord, language: 'en-US');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Word TTS error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider state for loading and error
    final assessmentState = ref.watch(pronunciationAssessmentProvider);
    final isLoading = assessmentState.isLoading;
    final error = assessmentState.error;

    return StyledDrawer(
      padding: EdgeInsets.zero,
      child: ListView(
        shrinkWrap: true,
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          _buildHeader(),
          const SizedBox(height: 24),

          // Show loading indicator for Azure assessment
          if (isLoading) _buildLoadingIndicator(),

          // Show error if Azure assessment failed
          if (error != null) _buildErrorBanner(error),

          // Show Azure word feedback if available
          if (_feedback.hasAzureData)
            _buildAzureWordFeedback()
          else
            _buildSentenceBreakdown(),

          if (widget.feedback.errorFocus != null) ...[
            const SizedBox(height: 24),
            _buildErrorFocus(),
          ],
          const SizedBox(height: 24),
          _buildIntonation(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Analyzing pronunciation...'),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Assessment failed: $error',
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAzureWordFeedback() {
    final words = _feedback.azureWordFeedback ?? [];

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

        // Show Azure scores
        const SizedBox(height: 16),
        _buildAzureScores(),
      ],
    );
  }

  Widget _buildAzureScores() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem('Accuracy', _feedback.azureAccuracyScore),
          _buildScoreItem('Fluency', _feedback.azureFluencyScore),
          _buildScoreItem('Complete', _feedback.azureCompletenessScore),
          if (_feedback.azureProsodyScore != null)
            _buildScoreItem('Prosody', _feedback.azureProsodyScore),
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

  Widget _buildHeader() {
    final score = widget.feedback.pronunciationScore;
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scoreColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Text(
                    'Score: $score',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            // In a real app, this might trigger a recording mode or callback
          },
          icon: const Icon(Icons.mic, size: 16),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentenceBreakdown() {
    // If we have detailed breakdown, use it. Otherwise fall back to simple text.
    if (widget.feedback.sentenceBreakdown == null ||
        widget.feedback.sentenceBreakdown!.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sentence:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.feedback.correctedText,
            style: const TextStyle(fontSize: 18, height: 1.5),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sentence:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.feedback.sentenceBreakdown!.map((wordData) {
            Color color;
            if (wordData.score >= 80) {
              color = Colors.green;
            } else if (wordData.score >= 60) {
              color = Colors.orange;
            } else {
              color = Colors.red;
            }

            return IntrinsicWidth(
              child: Column(
                children: [
                  Text(
                    wordData.word,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 4,
                    width: 20, // Min width
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorFocus() {
    final error = widget.feedback.errorFocus!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Error Focus: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '"${error.word}"',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAudioRow('You said:', error.userIpa, true),
                const Divider(height: 24),
                _buildAudioRow('Correct:', error.correctIpa, false),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 18,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tip: ${error.tip}',
                          style: TextStyle(
                            color: Colors.brown[800],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioRow(String label, String ipa, bool isUser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isUser)
                  const Text('👂 ', style: TextStyle(fontSize: 16))
                else
                  const Text('🤖 ', style: TextStyle(fontSize: 16)),
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              ipa,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Courier', // Monospace for IPA often looks better
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Mock play functionality
          },
          icon: const Icon(Icons.volume_up_rounded, size: 16),
          label: Text(
            isUser ? 'Play Yours' : 'Play Correct',
            style: const TextStyle(fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            side: const BorderSide(color: Colors.grey),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildIntonation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🌊 Intonation (语调):',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 80,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomPaint(painter: WavePainter()),
        ),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Draw a smooth wave
    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x++) {
      // Create a wave that tapers off or changes frequency
      // y = A * sin(kx)
      double y =
          size.height / 2 +
          15 *
              math.sin((x / size.width) * 4 * math.pi) *
              (1 - (x / size.width) * 0.3); // Slight amplitude decay
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Draw endpoint indicator (as per user request "show you didn't rise")
    final endX = size.width - 10;
    final endY =
        size.height / 2 + 15 * math.sin(4 * math.pi) * 0.7; // Approx end Y

    final dotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(endX, endY), 4, dotPaint);

    // Add text label near end
    // (This requires TextPainter)
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
