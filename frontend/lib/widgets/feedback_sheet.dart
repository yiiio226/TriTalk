import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/vocab_service.dart';
import 'styled_drawer.dart';

class FeedbackSheet extends StatelessWidget {
  final Message message;

  const FeedbackSheet({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.feedback == null) return const SizedBox.shrink();
    
    final feedback = message.feedback!;
    
    return StyledDrawer(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                feedback.isPerfect ? Icons.star : Icons.auto_fix_high, 
                color: feedback.isPerfect ? Colors.amber : Colors.orange
              ),
              const SizedBox(width: 8),
              Text(
                feedback.isPerfect ? 'Perfect!' : 'Feedback',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSection('Your Sentence', message.content, isError: !feedback.isPerfect),
          const SizedBox(height: 16),
          
          if (!feedback.isPerfect) ...[
            _buildSection('Corrected', feedback.correctedText, isSuccess: true),
            const SizedBox(height: 16),
          ],
          
          if (feedback.nativeExpression.isNotEmpty) ...[
             _buildSection('Native Expression', feedback.nativeExpression, isNative: true),
             const SizedBox(height: 16),
          ],

          if (feedback.exampleAnswer.isNotEmpty) ...[
             _buildSection('Possible Answer', feedback.exampleAnswer, isNative: true),
             const SizedBox(height: 16),
          ],
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feedback.explanation,
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Save mostly interesting things, like the native expression or corrected text
              final textToSave = feedback.nativeExpression.isNotEmpty 
                  ? feedback.nativeExpression 
                  : feedback.correctedText;
                  
              VocabService().add(
                textToSave,
                "Smart Feedback", 
                "Correction",
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to Vocabulary')),
              );
            },
            icon: const Icon(Icons.bookmark_border),
            label: const Text('Save to Vocabulary'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16), 
        ],
      ),
    );
  }

  Widget _buildSection(String label, String text, {bool isError = false, bool isSuccess = false, bool isNative = false}) {
    Color? textColor;
    if (isError) textColor = Colors.red[700];
    if (isSuccess) textColor = Colors.green[700];
    if (isNative) textColor = Colors.purple[700];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.bold, 
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: textColor ?? Colors.black87,
            fontWeight: (isSuccess || isNative) ? FontWeight.w600 : FontWeight.normal,
            fontStyle: isNative ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}
