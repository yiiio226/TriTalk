import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/vocab_service.dart';
import 'styled_drawer.dart';
import 'top_toast.dart';

class FeedbackSheet extends StatelessWidget {
  final Message message;
  final String sceneId; // Added sceneId

  const FeedbackSheet({
    Key? key, 
    required this.message, 
    required this.sceneId
  }) : super(key: key);

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
            _buildSection(
              'Corrected', 
              feedback.correctedText, 
              isSuccess: true,
              context: context,
            ),
            const SizedBox(height: 16),
          ],
          
          if (feedback.nativeExpression.isNotEmpty) ...[
             _buildSection(
               'Native Expression', 
               feedback.nativeExpression, 
               isNative: true,
               context: context,
               onSave: () => _saveToVocab(context, feedback.nativeExpression, "Analyzed Sentence"),
             ),
             const SizedBox(height: 16),
          ],

          if (feedback.exampleAnswer.isNotEmpty) ...[
             _buildSection(
               'Possible Answer', 
               feedback.exampleAnswer, 
               isNative: true,
               context: context,
               onSave: () => _saveToVocab(context, feedback.exampleAnswer, "Analyzed Sentence"),
             ),
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
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                // Save mostly interesting things, like the native expression or corrected text
                final textToSave = feedback.nativeExpression.isNotEmpty 
                    ? feedback.nativeExpression 
                    : feedback.correctedText;
                    
                _saveToVocab(context, textToSave, "Analyzed Sentence");
              },
              icon: const Icon(Icons.bookmark_border),
              label: const Text(
                'Save to Vocabulary', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16), 
        ],
      ),
    );
  }

  void _saveToVocab(BuildContext context, String phrase, String tag) {
    VocabService().add(
      phrase,
      "Smart Feedback", 
      tag,
      scenarioId: sceneId,
    );
     showTopToast(context, 'Saved to Vocabulary', isError: false);
  }

  Widget _buildSection(
    String label, 
    String text, {
    bool isError = false, 
    bool isSuccess = false, 
    bool isNative = false,
    BuildContext? context,
    VoidCallback? onSave,
  }) {
    Color? textColor;
    if (isError) textColor = Colors.red[700];
    if (isSuccess) textColor = Colors.green[700];
    if (isNative) textColor = Colors.purple[700];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: Colors.grey[600],
              ),
            ),
            if (onSave != null)
              GestureDetector(
                onTap: onSave,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                  child: Icon(Icons.bookmark_add_outlined, size: 20, color: Colors.grey[600]),
                ),
              ),
          ],
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
