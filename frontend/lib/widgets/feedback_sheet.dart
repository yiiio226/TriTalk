import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/vocab_service.dart';

class FeedbackSheet extends StatelessWidget {
  final Message message;

  const FeedbackSheet({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.feedback == null) return const SizedBox.shrink();
    
    final feedback = message.feedback!;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_fix_high, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Feedback',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSection('Your Sentence', message.content, isError: true),
          const SizedBox(height: 16),
          _buildSection('Optimized', feedback.optimizedText, isSuccess: true),
          const SizedBox(height: 16),
          
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
                    feedback.reason,
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              VocabService().add(
                feedback.optimizedText,
                "Optimized Expression", // Placeholder translation or definition
                "Feedback",
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
          const SizedBox(height: 16), // SafeArea padding basically
        ],
      ),
    );
  }

  Widget _buildSection(String label, String text, {bool isError = false, bool isSuccess = false}) {
    Color? textColor;
    if (isError) textColor = Colors.red[700];
    if (isSuccess) textColor = Colors.green[700];

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
            color: textColor,
            fontWeight: isSuccess ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
