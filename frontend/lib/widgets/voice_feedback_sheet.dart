import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/message.dart';
import 'styled_drawer.dart';

class VoiceFeedbackSheet extends StatefulWidget {
  final VoiceFeedback feedback;
  final ScrollController? scrollController;

  const VoiceFeedbackSheet({
    super.key,
    required this.feedback,
    this.scrollController,
  });

  @override
  State<VoiceFeedbackSheet> createState() => _VoiceFeedbackSheetState();
}

class _VoiceFeedbackSheetState extends State<VoiceFeedbackSheet> {
  @override
  Widget build(BuildContext context) {
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

  Widget _buildHeader() {
    final score = widget.feedback.pronunciationScore;
    Color scoreColor;
    String label;
    IconData icon;

    if (score >= 80) {
      scoreColor = Colors.green;
      label = 'Great Job!';
      icon = Icons.check_circle;
    } else if (score >= 60) {
      scoreColor = Colors.orange;
      label = 'Needs Work';
      icon = Icons.info;
    } else {
      scoreColor = Colors.red;
      label = 'Try Again';
      icon = Icons.warning;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scoreColor.withOpacity(0.5)),
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
    if (widget.feedback.sentenceBreakdown == null || widget.feedback.sentenceBreakdown!.isEmpty) {
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
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 18, color: Colors.amber),
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
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
          child: CustomPaint(
            painter: WavePainter(),
          ),
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
      double y = size.height / 2 + 
                15 * math.sin((x / size.width) * 4 * math.pi) * 
                (1 - (x / size.width) * 0.3); // Slight amplitude decay
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
    
    // Draw endpoint indicator (as per user request "show you didn't rise")
    final endX = size.width - 10;
    final endY = size.height / 2 + 15 * math.sin(4 * math.pi) * 0.7; // Approx end Y
    
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
