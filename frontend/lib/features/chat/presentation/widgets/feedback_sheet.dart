import 'package:flutter/material.dart';
import 'package:frontend/features/chat/domain/models/message.dart';
import '../../../study/data/vocab_service.dart';
import '../../../study/data/shadowing_history_service.dart';
import 'package:frontend/core/widgets/styled_drawer.dart';
import 'package:frontend/core/widgets/top_toast.dart';
import '../../../study/presentation/widgets/shadowing_sheet.dart';
import 'package:frontend/core/design/app_design_system.dart';

class FeedbackSheet extends StatefulWidget {
  final Message message;
  final String sceneId;
  final String targetLanguage; // Language for assessment

  const FeedbackSheet({
    super.key,
    required this.message,
    required this.sceneId,
    this.targetLanguage = 'en-US', // Default for backward compatibility
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
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.ln200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: feedback.isPerfect
                            ? AppColors.lg100
                            : AppColors.ly100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        feedback.isPerfect ? Icons.star : Icons.auto_fix_high,
                        color: feedback.isPerfect
                            ? AppColors.lg500
                            : AppColors.ly500,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      feedback.isPerfect ? 'Perfect!' : 'Feedback',
                      style: const TextStyle(
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
                          color: AppColors.ln50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
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
                  // YOUR SENTENCE section with error highlighting
                  if (!feedback.isPerfect) ...[
                    _buildErrorHighlightSection(
                      'Your Sentence',
                      widget.message.content,
                      feedback.correctedText,
                    ),
                  ] else ...[
                    _buildSection(
                      'Your Sentence',
                      widget.message.content,
                      isError: false,
                    ),
                  ],
                  const SizedBox(height: 8),

                  if (feedback.isPerfect) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lg100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '语法正确！表达很棒！',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.lg800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (!feedback.isPerfect) const SizedBox(height: 8),

                  if (!feedback.isPerfect) ...[
                    _buildDiffSection(
                      'Corrected',
                      widget.message.content,
                      feedback.correctedText,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lg100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        feedback.explanation,
                        style: TextStyle(color: AppColors.lg800),
                      ),
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
                        reason: feedback.nativeExpressionReason,
                      ),
                      onShadowing: () => _openShadowingSheet(
                        context,
                        feedback.nativeExpression,
                        'native_expression',
                      ),
                      showShadowing: true,
                    ),
                    if (feedback.nativeExpressionReason != null &&
                        feedback.nativeExpressionReason!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lg100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          feedback.nativeExpressionReason!,
                          style: TextStyle(color: AppColors.lg800),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],

                  if (feedback.exampleAnswer.isNotEmpty) ...[
                    _buildSection(
                      'Reference Answer',
                      feedback.exampleAnswer,
                      isNative: true,
                      context: context,
                      isSaved: _savedItems.contains(feedback.exampleAnswer),
                      onSave: () => _saveToVocab(
                        context,
                        feedback.exampleAnswer,
                        "Analyzed Sentence",
                        reason: feedback.exampleAnswerReason,
                      ),
                      onShadowing: () => _openShadowingSheet(
                        context,
                        feedback.exampleAnswer,
                        'reference_answer',
                      ),
                      showShadowing: true,
                    ),
                    if (feedback.exampleAnswerReason != null &&
                        feedback.exampleAnswerReason!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lg100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          feedback.exampleAnswerReason!,
                          style: TextStyle(color: AppColors.lg800),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveToVocab(
    BuildContext context,
    String phrase,
    String tag, {
    String? reason,
  }) {
    if (!_savedItems.contains(phrase)) {
      VocabService().add(
        phrase,
        "Smart Feedback",
        tag,
        scenarioId: widget.sceneId,
        reason: reason,
      );
      setState(() {
        _savedItems.add(phrase);
      });
      showTopToast(context, 'Saved to Vocabulary', isError: false);
    } else {
      VocabService().remove(phrase);
      setState(() {
        _savedItems.remove(phrase);
      });
      showTopToast(context, 'Removed from Vocabulary', isError: false);
    }
  }

  void _openShadowingSheet(
    BuildContext context,
    String targetText,
    String sourceType,
  ) {
    // Open sheet immediately with loading state
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.white.withValues(alpha: 0.5),
      builder: (context) => ShadowingSheet(
        targetText: targetText,
        messageId: widget.message.id,
        sourceType: sourceType,
        sourceId: widget.message.id,
        sceneKey: widget.sceneId,
        targetLanguage: widget.targetLanguage, // Pass language
        isLoadingInitialData: true,
        onLoadInitialData: () async {
          // This callback will be called by ShadowingSheet to load cloud data
          try {
            final latestPractice = await ShadowingHistoryService()
                .getLatestPractice(sourceType, widget.message.id);

            if (latestPractice != null) {
              // Convert ShadowingPractice to VoiceFeedback format
              final cloudFeedback = VoiceFeedback(
                pronunciationScore: latestPractice.pronunciationScore,
                correctedText: latestPractice.targetText,
                nativeExpression: '',
                feedback: latestPractice.feedbackText ?? '',
                azureAccuracyScore: latestPractice.accuracyScore,
                azureFluencyScore: latestPractice.fluencyScore,
                azureCompletenessScore: latestPractice.completenessScore,
                azureProsodyScore: latestPractice.prosodyScore,
                azureWordFeedback: latestPractice.wordFeedback,
              );

              return (feedback: cloudFeedback);
            }
          } catch (e) {
            debugPrint('⚠️ Failed to fetch cloud shadowing data: $e');
          }

          return null;
        },
      ),
    );
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
    VoidCallback? onShadowing,
    bool showShadowing = false,
  }) {
    Color? textColor;
    if (isError) textColor = AppColors.lr500;
    if (isSuccess) textColor = AppColors.lg800;
    if (isNative) textColor = AppColors.lightTextPrimary;

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
                color: AppColors.lightTextSecondary,
              ),
            ),
            Row(
              children: [
                if (showShadowing && onShadowing != null) ...[
                  _buildActionButton(
                    icon: Icons.mic_rounded,
                    onTap: onShadowing,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                if (onSave != null)
                  _buildActionButton(
                    icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                    onTap: onSave,
                    color: isSaved
                        ? AppColors.lightSuccess
                        : AppColors.lightTextPrimary,
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: textColor ?? AppColors.lightTextPrimary,
            fontWeight: (isSuccess || isNative)
                ? FontWeight.w500
                : FontWeight.w500,
            fontStyle: isNative ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8), // Padding for hit target
        color: Colors.transparent, // Ensure hit test works
        child: Icon(
          icon,
          size: 20, // Slightly larger icon since it stands alone
          color: color,
        ),
      ),
    );
  }

  Widget _buildErrorHighlightSection(
    String label,
    String originalText,
    String correctedText,
  ) {
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
        _buildErrorHighlightText(originalText, correctedText),
      ],
    );
  }

  Widget _buildErrorHighlightText(String original, String corrected) {
    final errorSpans = _computeErrorHighlight(original, corrected);

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        children: errorSpans,
      ),
    );
  }

  List<TextSpan> _computeErrorHighlight(String original, String corrected) {
    final List<TextSpan> spans = [];

    // Simple word-based diff to identify errors
    final originalWords = original.split(' ');
    final correctedWords = corrected.split(' ');

    int i = 0, j = 0;

    while (i < originalWords.length) {
      if (j < correctedWords.length && originalWords[i] == correctedWords[j]) {
        // Word is correct - show in black
        spans.add(
          TextSpan(
            text: '${originalWords[i]} ',
            style: const TextStyle(color: Colors.black87),
          ),
        );
        i++;
        j++;
      } else {
        // Word is incorrect - show in red
        spans.add(
          TextSpan(
            text: '${originalWords[i]} ',
            style: TextStyle(
              color: AppColors.lr500,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
        i++;

        // Skip ahead in corrected text to find next match
        bool foundMatch = false;
        for (int k = j; k < correctedWords.length && k < j + 3; k++) {
          if (i < originalWords.length &&
              originalWords[i] == correctedWords[k]) {
            j = k;
            foundMatch = true;
            break;
          }
        }
        if (!foundMatch && j < correctedWords.length) {
          j++;
        }
      }
    }

    return spans;
  }

  Widget _buildDiffSection(
    String label,
    String originalText,
    String correctedText,
  ) {
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
        _buildDiffText(originalText, correctedText),
      ],
    );
  }

  Widget _buildDiffText(String original, String corrected) {
    final diffSpans = _computeDiff(original, corrected);

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        children: diffSpans,
      ),
    );
  }

  List<TextSpan> _computeDiff(String original, String corrected) {
    final List<TextSpan> spans = [];

    // Simple word-based diff algorithm
    final originalWords = original.split(' ');
    final correctedWords = corrected.split(' ');

    int i = 0, j = 0;

    while (i < originalWords.length || j < correctedWords.length) {
      if (i < originalWords.length && j < correctedWords.length) {
        if (originalWords[i] == correctedWords[j]) {
          // Words match - show in normal style
          spans.add(
            TextSpan(
              text: '${originalWords[i]} ',
              style: const TextStyle(color: Colors.black87),
            ),
          );
          i++;
          j++;
        } else {
          // Words differ - check if it's a replacement or insertion/deletion
          bool foundMatch = false;

          // Look ahead in corrected text for the original word
          for (int k = j + 1; k < correctedWords.length && k < j + 3; k++) {
            if (originalWords[i] == correctedWords[k]) {
              // Found the word later - means insertion happened
              for (int m = j; m < k; m++) {
                spans.add(
                  TextSpan(
                    text: '${correctedWords[m]} ',
                    style: const TextStyle(
                      color: AppColors.lg500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              j = k;
              foundMatch = true;
              break;
            }
          }

          if (!foundMatch) {
            // Look ahead in original text for the corrected word
            bool foundInOriginal = false;
            for (int k = i + 1; k < originalWords.length && k < i + 3; k++) {
              if (originalWords[k] == correctedWords[j]) {
                // Found the word later in original - means deletion happened
                for (int m = i; m < k; m++) {
                  spans.add(
                    TextSpan(
                      text: '${originalWords[m]} ',
                      style: const TextStyle(
                        color: AppColors.lr500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  );
                }
                i = k;
                foundInOriginal = true;
                break;
              }
            }

            if (!foundInOriginal) {
              // Simple replacement - show deletion then addition
              spans.add(
                TextSpan(
                  text: '${originalWords[i]} ',
                  style: const TextStyle(
                    color: AppColors.lr500,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              );
              spans.add(
                TextSpan(
                  text: '${correctedWords[j]} ',
                  style: const TextStyle(
                    color: AppColors.lg500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
              i++;
              j++;
            }
          }
        }
      } else if (i < originalWords.length) {
        // Remaining words in original - deletions
        spans.add(
          TextSpan(
            text: '${originalWords[i]} ',
            style: const TextStyle(
              color: AppColors.lr500,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        );
        i++;
      } else {
        // Remaining words in corrected - additions
        spans.add(
          TextSpan(
            text: '${correctedWords[j]} ',
            style: const TextStyle(
              color: AppColors.lg500,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        j++;
      }
    }

    return spans;
  }
}
