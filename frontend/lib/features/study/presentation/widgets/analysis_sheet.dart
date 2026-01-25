import 'dart:async';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/chat/domain/models/message.dart';
import '../../data/vocab_service.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/features/speech/speech.dart';
import 'package:frontend/core/widgets/top_toast.dart';
import 'package:frontend/core/widgets/styled_drawer.dart';
import 'package:frontend/core/utils/l10n_ext.dart';
import 'package:frontend/features/subscription/presentation/feature_gate.dart';
import 'package:frontend/features/subscription/domain/models/paid_feature.dart';

class AnalysisSheet extends StatefulWidget {
  final Message message;
  final MessageAnalysis? analysis;
  final bool isLoading;
  final String? sceneId;
  final Stream<MessageAnalysis>? analysisStream;
  final Function(MessageAnalysis)? onAnalysisComplete;
  final String targetLanguage; // Language code for TTS

  const AnalysisSheet({
    super.key,
    required this.message,
    this.analysis,
    this.isLoading = false,
    this.sceneId,
    this.analysisStream,
    this.onAnalysisComplete,
    this.targetLanguage = 'en-US', // Default for backward compatibility
  });

  @override
  State<AnalysisSheet> createState() => _AnalysisSheetState();
}

class _AnalysisSheetState extends State<AnalysisSheet> {
  // Track which items are saved
  final Set<String> _savedGrammarPoints = {};
  final Set<String> _savedVocabulary = {};
  final Set<String> _savedIdioms = {};

  final WordTtsService _wordTtsService = WordTtsService();

  // Local analysis state for streaming
  MessageAnalysis? _currentAnalysis;
  bool _isStreaming = false;
  StreamSubscription<MessageAnalysis>? _subscription;

  // Track expand/collapse states for all sections (default collapsed)
  bool _isOriginalSentenceExpanded = false;
  bool _isSummaryExpanded = true;
  bool _isSentenceStructureExpanded = false;
  bool _isGrammarPointsExpanded = false;
  bool _isVocabularyExpanded = false;
  bool _isIdiomsExpanded = false;

  @override
  void dispose() {
    _subscription?.cancel();
    // Stop any word TTS playback when sheet is closed
    _wordTtsService.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentAnalysis = widget.analysis;
    _initializeSavedStates();

    if (widget.analysisStream != null) {
      _isStreaming = true;
      _subscription = widget.analysisStream!.listen(
        (data) {
          if (mounted) {
            setState(() {
              _currentAnalysis = data;
            });
          }
        },
        onError: (e) {
          if (kDebugMode) {
            debugPrint("Stream error: $e");
          }
          if (mounted) {
            setState(() => _isStreaming = false);
            showTopToast(context, 'Analysis interrupted', isError: true);
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isStreaming = false;
            });
            if (_currentAnalysis != null && widget.onAnalysisComplete != null) {
              widget.onAnalysisComplete!(_currentAnalysis!);
            }
          }
        },
      );
    }
  }

  void _initializeSavedStates() {
    final vocabService = VocabService();
    final analysisToUse = _currentAnalysis ?? widget.analysis;

    // Check which grammar points are already saved
    if (analysisToUse?.grammarPoints != null) {
      for (var point in analysisToUse!.grammarPoints) {
        if (vocabService.exists(point.structure, scenarioId: widget.sceneId)) {
          _savedGrammarPoints.add(point.structure);
        }
      }
    }

    // Check which vocabulary items are already saved
    if (analysisToUse?.vocabulary != null) {
      for (var vocab in analysisToUse!.vocabulary) {
        if (vocabService.exists(vocab.word, scenarioId: widget.sceneId)) {
          _savedVocabulary.add(vocab.word);
        }
      }
    }

    // Check which idioms are already saved
    if (analysisToUse?.idioms != null) {
      for (var idiom in analysisToUse!.idioms) {
        if (vocabService.exists(idiom.text, scenarioId: widget.sceneId)) {
          _savedIdioms.add(idiom.text);
        }
      }
    }
  }

  Future<void> _playWordPronunciation(String word) async {
    // Style 2: Await for word pronunciation quota check
    final granted = await FeatureGate().performWithFeatureCheck(
      context,
      feature: PaidFeature.wordPronunciation,
    );
    if (!granted) return;

    // Clean the word (keep hyphens and apostrophes for proper pronunciation)
    // Remove only sentence-ending punctuation like . , ! ? ; :
    final cleanWord = word.replaceAll(RegExp(r'[.,!?;:"]'), '').trim();
    if (cleanWord.isEmpty) return;

    try {
      await _wordTtsService.speakWord(
        cleanWord,
        language: widget.targetLanguage,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Word TTS error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final displayAnalysis = _currentAnalysis ?? widget.analysis;
    final isStillLoading = widget.isLoading || _isStreaming;

    return SizedBox(
      height: screenHeight * 0.90,
      child: StyledDrawer(
        padding: EdgeInsets.zero, // Padding handled inside children
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Drag Handle & Header
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
                          color: AppColors.lg100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.lg500,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Sentence Analysis',
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

            // Original Sentence - Fixed at top
            if (displayAnalysis != null || isStillLoading)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: GestureDetector(
                  onTap: () {
                    // Only toggle if necessary (calculate overflow again or store state)
                    // Since we need to know if it's expandable to decide if click does anything,
                    // we might need to hoist the TextPainter check or just allow toggle even if not truncated (but icon hidden).
                    // Better: The icon visibility logic is inside LayoutBuilder.
                    // Let's refactor to calculate expandability once or assume if icon is shown, it's clickable.
                    // Actually, the user requirement implies if the icon IS shown (condition met), then clicking container toggles.
                    setState(() {
                      _isOriginalSentenceExpanded =
                          !_isOriginalSentenceExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.ln50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.ln100),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const style = TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightTextPrimary,
                          height: 1.4,
                        );

                        final span = TextSpan(
                          text: widget.message.content,
                          style: style,
                        );
                        final tp = TextPainter(
                          text: span,
                          textDirection: Directionality.of(context),
                          textScaler: MediaQuery.of(context).textScaler,
                        );
                        tp.layout(maxWidth: constraints.maxWidth);
                        final isOverflowing =
                            tp.computeLineMetrics().length > 1;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'ORIGINAL SENTENCE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightTextSecondary,
                                  ),
                                ),
                                if (isOverflowing)
                                  Icon(
                                    _isOriginalSentenceExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.lightTextSecondary,
                                    size: 24,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.message.content,
                              maxLines: _isOriginalSentenceExpanded ? null : 1,
                              overflow: _isOriginalSentenceExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: style,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: _buildContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Prefer local stream state, fallback to passed props
    final displayAnalysis = _currentAnalysis ?? widget.analysis;
    final isStillLoading = widget.isLoading || _isStreaming;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (displayAnalysis == null && isStillLoading) ...[
          // First entry: Show Summary skeleton and other section titles with loading indicators
          // Summary with skeleton loading (expanded by default)
          _buildCollapsibleSection(
            title: context.l10n.study_summary,
            isExpanded: true,
            isLoading: true,
            onToggle: () {},
            content: Shimmer.fromColors(
              baseColor: AppColors.lightSkeletonBase,
              highlightColor: AppColors.lightSkeletonHighlight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonBox(height: 16, width: double.infinity),
                  const SizedBox(height: 8),
                  _buildSkeletonBox(height: 16, width: double.infinity),
                  const SizedBox(height: 8),
                  _buildSkeletonBox(height: 16, width: 200),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Other sections: Show title only with loading indicator
          _buildCollapsibleSection(
            title: context.l10n.study_sentenceStructure,
            isExpanded: false,
            isLoading: true,
            onToggle: () {},
            content: const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),

          _buildCollapsibleSection(
            title: context.l10n.study_grammarPoints,
            isExpanded: false,
            isLoading: true,
            onToggle: () {},
            content: const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),

          _buildCollapsibleSection(
            title: context.l10n.study_vocabulary,
            isExpanded: false,
            isLoading: true,
            onToggle: () {},
            content: const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),

          _buildCollapsibleSection(
            title: context.l10n.study_idiomsSlang,
            isExpanded: false,
            isLoading: true,
            onToggle: () {},
            content: const SizedBox.shrink(),
          ),
        ] else if (displayAnalysis != null) ...[
          // Summary (Collapsible)
          if (displayAnalysis.overallSummary.isNotEmpty &&
              displayAnalysis.overallSummary != 'No summary available.') ...[
            _buildCollapsibleSection(
              title: context.l10n.study_summary,
              isExpanded: _isSummaryExpanded,
              isLoading: false,
              onToggle: () =>
                  setState(() => _isSummaryExpanded = !_isSummaryExpanded),
              content: Text(
                displayAnalysis.overallSummary,
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Sentence Structure (Collapsible)
          if (displayAnalysis.sentenceStructure.isNotEmpty &&
              displayAnalysis.sentenceBreakdown.isNotEmpty) ...[
            _buildCollapsibleSection(
              title: context.l10n.study_sentenceStructure,
              isExpanded: _isSentenceStructureExpanded,
              isLoading: false,
              onToggle: () => setState(
                () => _isSentenceStructureExpanded =
                    !_isSentenceStructureExpanded,
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayAnalysis.sentenceStructure,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: displayAnalysis.sentenceBreakdown
                        .map(
                          (segment) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ln50,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.ln100),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  segment.text,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  segment.tag,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.lightTextSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ] else if (_isStreaming) ...[
            _buildCollapsibleSection(
              title: context.l10n.study_sentenceStructure,
              isExpanded: false,
              isLoading: true,
              onToggle: () {},
              content: const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
          ],

          // Grammar Points (Collapsible)
          if (displayAnalysis.grammarPoints.isNotEmpty) ...[
            _buildCollapsibleSection(
              title: context.l10n.study_grammarPoints,
              isExpanded: _isGrammarPointsExpanded,
              isLoading: false,
              onToggle: () => setState(
                () => _isGrammarPointsExpanded = !_isGrammarPointsExpanded,
              ),
              content: Column(
                children: displayAnalysis.grammarPoints
                    .map((point) => _buildGrammarPoint(context, point))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
          ] else if (_isStreaming) ...[
            _buildCollapsibleSection(
              title: context.l10n.study_grammarPoints,
              isExpanded: false,
              isLoading: true,
              onToggle: () {},
              content: const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
          ],

          // Vocabulary (Collapsible)
          if (displayAnalysis.vocabulary.isNotEmpty) ...[
            _buildCollapsibleSection(
              title: context.l10n.study_vocabulary,
              isExpanded: _isVocabularyExpanded,
              isLoading: false,
              onToggle: () => setState(
                () => _isVocabularyExpanded = !_isVocabularyExpanded,
              ),
              content: Column(
                children: displayAnalysis.vocabulary
                    .map((vocab) => _buildVocabularyItem(context, vocab))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
          ] else if (_isStreaming) ...[
            _buildCollapsibleSection(
              title: context.l10n.study_vocabulary,
              isExpanded: false,
              isLoading: true,
              onToggle: () {},
              content: const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
          ],

          // Idioms (Collapsible)
          if (displayAnalysis.idioms.isNotEmpty) ...[
            _buildCollapsibleSection(
              title: context.l10n.study_idiomsSlang,
              isExpanded: _isIdiomsExpanded,
              isLoading: false,
              onToggle: () =>
                  setState(() => _isIdiomsExpanded = !_isIdiomsExpanded),
              titleColor: AppColors.lightTextPrimary,
              content: Column(
                children: displayAnalysis.idioms
                    .map((idiom) => _buildIdiomItem(context, idiom))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
          ] else if (_isStreaming) ...[
            _buildCollapsibleSection(
              title: context.l10n.study_idiomsSlang,
              isExpanded: false,
              isLoading: true,
              onToggle: () {},
              content: const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
          ],
        ] else ...[
          Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(context.l10n.study_analysisNotAvailable),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSkeletonBox({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// Three dots loading indicator with sequential fade animation
  Widget _buildThreeDotsLoader() {
    return const _ThreeDotsLoadingAnimation();
  }

  /// Reusable collapsible section widget
  Widget _buildCollapsibleSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
    bool isLoading = false,
    Color? titleColor,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onToggle,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.ln50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.ln100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: titleColor ?? AppColors.lightTextSecondary,
                  ),
                ),
                // Show loading indicator when loading, otherwise show expand icon
                if (isLoading)
                  _buildThreeDotsLoader()
                else
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: titleColor ?? AppColors.lightTextPrimary,
                    size: 24,
                  ),
              ],
            ),
            if (isExpanded) ...[const SizedBox(height: 12), content],
          ],
        ),
      ),
    );
  }

  Widget _buildGrammarPoint(BuildContext context, GrammarPoint point) {
    final isSaved = _savedGrammarPoints.contains(point.structure);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.ln50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.ln100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    String displayTitle;
                    if (point.structure.isNotEmpty) {
                      displayTitle = point.structure;
                    } else {
                      // Extract a concise title from explanation
                      // Take first sentence or first 40 chars
                      final explanation = point.explanation;
                      final firstSentenceEnd = explanation.indexOf('。');
                      if (firstSentenceEnd != -1 && firstSentenceEnd < 50) {
                        displayTitle = explanation.substring(
                          0,
                          firstSentenceEnd,
                        );
                      } else if (explanation.length > 40) {
                        displayTitle = '${explanation.substring(0, 40)}...';
                      } else {
                        displayTitle = explanation;
                      }
                    }

                    return Text(
                      displayTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextPrimary,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Save Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    final titleToSave = point.structure.isNotEmpty
                        ? point.structure
                        : (point.explanation.length > 30
                              ? point.explanation.substring(0, 30)
                              : point.explanation);
                    final contentToSave = point.structure.isNotEmpty
                        ? "${point.explanation}\\n\\n例: ${point.example}"
                        : "例: ${point.example}";

                    if (!isSaved) {
                      VocabService().add(
                        titleToSave,
                        contentToSave,
                        "Grammar Point",
                        scenarioId: widget.sceneId,
                      );
                      setState(() {
                        _savedGrammarPoints.add(point.structure);
                      });
                      showTopToast(
                        context,
                        'Saved Grammar Point',
                        isError: false,
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.lightTextSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            point.explanation,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.lightTextPrimary,
            ),
          ),
          if (point.example.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '例: ${point.example}',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVocabularyItem(BuildContext context, VocabularyItem vocab) {
    final isSaved = _savedVocabulary.contains(vocab.word);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.ln50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.ln100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                vocab.word,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              if (vocab.partOfSpeech != null &&
                  vocab.partOfSpeech!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  vocab.partOfSpeech!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              // Play Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _playWordPronunciation(vocab.word);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.volume_up_outlined,
                      color: AppColors.lightTextSecondary,
                      size: 16,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Save Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (!isSaved) {
                      VocabService().add(
                        vocab.word,
                        vocab.definition,
                        "Analysis Vocabulary",
                        scenarioId:
                            widget.sceneId, // Link to current conversation
                      );
                      setState(() {
                        _savedVocabulary.add(vocab.word);
                      });
                      showTopToast(
                        context,
                        'Saved "${vocab.word}" to Vocabulary',
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.lightTextSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            vocab.definition,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.lightTextPrimary,
            ),
          ),
          if (vocab.example.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '例: ${vocab.example}',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIdiomItem(BuildContext context, IdiomItem idiom) {
    final isSaved = _savedIdioms.contains(idiom.text);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.ln50,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.ln100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  idiom.type.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ),
              // Save Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (!isSaved) {
                      VocabService().add(
                        idiom.text,
                        idiom.explanation,
                        "Idiom/Slang",
                        scenarioId: widget.sceneId,
                      );
                      setState(() {
                        _savedIdioms.add(idiom.text);
                      });
                      showTopToast(context, 'Saved Idiom', isError: false);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.lightTextSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            idiom.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            idiom.explanation,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.lightTextPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stateful widget for continuous three-dot loading animation
class _ThreeDotsLoadingAnimation extends StatefulWidget {
  const _ThreeDotsLoadingAnimation();

  @override
  State<_ThreeDotsLoadingAnimation> createState() =>
      _ThreeDotsLoadingAnimationState();
}

class _ThreeDotsLoadingAnimationState extends State<_ThreeDotsLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(); // Loop the animation continuously
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define three different colors for the dots
    final dotColors = [
      AppColors.ln400, // First dot - lighter gray
      AppColors.ln500, // Second dot - medium gray
      AppColors.ln700, // Third dot - darker gray
    ];

    return SizedBox(
      width: 24,
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Sequential animation - each dot fades in one after another
              final dotDelay = index * 0.33; // Each dot starts 33% later
              final adjustedValue = (_controller.value - dotDelay).clamp(
                0.0,
                1.0,
              );

              // Create fade in/out effect
              double opacity;
              if (adjustedValue < 0.5) {
                // Fade in
                opacity = adjustedValue * 2;
              } else {
                // Fade out
                opacity = (1.0 - adjustedValue) * 2;
              }

              return Opacity(
                opacity: opacity.clamp(0.2, 1.0),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: dotColors[index],
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
