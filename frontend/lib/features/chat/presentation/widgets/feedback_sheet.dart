import 'package:flutter/material.dart';
import 'package:frontend/features/chat/domain/models/message.dart';
import '../../../study/data/vocab_service.dart';
import 'package:frontend/core/widgets/styled_drawer.dart';
import 'package:frontend/core/widgets/top_toast.dart';

class FeedbackSheet extends StatefulWidget {
  final Message message;
  final String sceneId;

  const FeedbackSheet({
    super.key,
    required this.message,
    required this.sceneId,
  });

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  final Set<String> _savedItems = {};

  @override
  void initState() {
    super.initState();
    _initializeSavedStates();
  }

  void _initializeSavedStates() {
    final vocabService = VocabService();
    final feedback = widget.message.feedback;

    if (feedback != null) {
      if (feedback.nativeExpression.isNotEmpty &&
          vocabService.exists(
            feedback.nativeExpression,
            scenarioId: widget.sceneId,
          )) {
        _savedItems.add(feedback.nativeExpression);
      }

      if (feedback.exampleAnswer.isNotEmpty &&
          vocabService.exists(
            feedback.exampleAnswer,
            scenarioId: widget.sceneId,
          )) {
        _savedItems.add(feedback.exampleAnswer);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.feedback == null) return const SizedBox.shrink();

    final feedback = widget.message.feedback!;

    return StyledDrawer(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                Icon(
                  feedback.isPerfect ? Icons.star : Icons.auto_fix_high,
                  color: feedback.isPerfect ? Colors.amber : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  feedback.isPerfect ? 'Perfect!' : 'Feedback',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSection(
                    'Your Sentence',
                    widget.message.content,
                    isError: !feedback.isPerfect,
                  ),
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
                      isSaved: _savedItems.contains(feedback.nativeExpression),
                      onSave: () => _saveToVocab(
                        context,
                        feedback.nativeExpression,
                        "Analyzed Sentence",
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (feedback.exampleAnswer.isNotEmpty) ...[
                    _buildSection(
                      'Possible Answer',
                      feedback.exampleAnswer,
                      isNative: true,
                      context: context,
                      isSaved: _savedItems.contains(feedback.exampleAnswer),
                      onSave: () => _saveToVocab(
                        context,
                        feedback.exampleAnswer,
                        "Analyzed Sentence",
                      ),
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
                        const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.blue,
                        ),
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
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveToVocab(BuildContext context, String phrase, String tag) {
    if (!_savedItems.contains(phrase)) {
      VocabService().add(
        phrase,
        "Smart Feedback",
        tag,
        scenarioId: widget.sceneId,
      );
      setState(() {
        _savedItems.add(phrase);
      });
      showTopToast(context, 'Saved to Vocabulary', isError: false);
    }
  }

  Widget _buildSection(
    String label,
    String text, {
    bool isError = false,
    bool isSuccess = false,
    bool isNative = false,
    bool isSaved = false,
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
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 20,
                    color: isNative ? Colors.purple[700] : Colors.grey[600],
                  ),
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
            fontWeight: (isSuccess || isNative)
                ? FontWeight.w600
                : FontWeight.normal,
            fontStyle: isNative ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}
