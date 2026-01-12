import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../features/study/data/vocab_service.dart';
import '../design/app_design_system.dart';
import 'top_toast.dart';
import 'styled_drawer.dart';

class AnalysisSheet extends StatefulWidget {
  final Message message;
  final MessageAnalysis? analysis;
  final bool isLoading;
  final String? sceneId;
  final Stream<MessageAnalysis>? analysisStream;
  final Function(MessageAnalysis)? onAnalysisComplete;

  const AnalysisSheet({
    super.key,
    required this.message,
    this.analysis,
    this.isLoading = false,
    this.sceneId,
    this.analysisStream,
    this.onAnalysisComplete,
  });

  @override
  State<AnalysisSheet> createState() => _AnalysisSheetState();
}

class _AnalysisSheetState extends State<AnalysisSheet> {
  // Track which items are saved
  final Set<String> _savedGrammarPoints = {};
  final Set<String> _savedVocabulary = {};
  final Set<String> _savedIdioms = {};

  // Local analysis state for streaming
  MessageAnalysis? _currentAnalysis;
  bool _isStreaming = false;
  StreamSubscription<MessageAnalysis>? _subscription;

  // Track original sentence expand/collapse state
  bool _isOriginalSentenceExpanded = false;

  @override
  void dispose() {
    _subscription?.cancel();
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final displayAnalysis = _currentAnalysis ?? widget.analysis;
    final isStillLoading = widget.isLoading || _isStreaming;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      child: StyledDrawer(
        padding: EdgeInsets.zero, // Padding handled inside children
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.purple.shade400,
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
                            color: Colors.grey[100],
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
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const style = TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
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
                                    color: Colors.grey,
                                  ),
                                ),
                                if (isOverflowing)
                                  Icon(
                                    _isOriginalSentenceExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: Colors.black54,
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
          // Nothing loaded yet, show full skeleton
          _buildSkeletonLoader(),
        ] else if (displayAnalysis != null) ...[
          // Summary
          if (displayAnalysis.overallSummary.isNotEmpty &&
              displayAnalysis.overallSummary != 'No summary available.') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.analysisPurpleLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Text(
                displayAnalysis.overallSummary,
                style: TextStyle(
                  color: Colors.purple[900],
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Sentence Structure
          if (displayAnalysis.sentenceStructure.isNotEmpty &&
              displayAnalysis.sentenceBreakdown.isNotEmpty) ...[
            const Text(
              'SENTENCE STRUCTURE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              displayAnalysis.sentenceStructure,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
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
                        color: AppColors.analysisBlueLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            segment.text,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            segment.tag,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Grammar Points
          if (displayAnalysis.grammarPoints.isNotEmpty) ...[
            const Text(
              'GRAMMAR POINTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            ...displayAnalysis.grammarPoints.map(
              (point) => _buildGrammarPoint(context, point),
            ),
            const SizedBox(height: 12),
          ] else if (_isStreaming) ...[
            const Text(
              'GRAMMAR POINTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            _buildSkeletonCard(),
            const SizedBox(height: 12),
            _buildSkeletonCard(),
            const SizedBox(height: 12),
          ],

          // Vocabulary
          if (displayAnalysis.vocabulary.isNotEmpty) ...[
            const Text(
              'VOCABULARY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            ...displayAnalysis.vocabulary.map(
              (vocab) => _buildVocabularyItem(context, vocab),
            ),
            const SizedBox(height: 12),
          ] else if (_isStreaming) ...[
            const Text(
              'VOCABULARY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            _buildSkeletonCard(),
            const SizedBox(height: 12),
            _buildSkeletonCard(),
            const SizedBox(height: 12),
          ],

          // Idioms
          if (displayAnalysis.idioms.isNotEmpty) ...[
            const Text(
              'IDIOMS & SLANG',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            ...displayAnalysis.idioms.map(
              (idiom) => _buildIdiomItem(context, idiom),
            ),
            const SizedBox(height: 12),
          ],

          if (_isStreaming) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Loading...",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Save button - only show when finished? Or always allow saving partial?
          // Better to show when at least something is there or finished.
          const SizedBox(height: 12),
          if (!_isStreaming)
            ElevatedButton(
              onPressed: () {
                VocabService().add(
                  widget.message.content,
                  "AI Message Analysis",
                  "Analyzed Sentence",
                  scenarioId: widget.sceneId, // Link to current conversation
                );
                Navigator.pop(context);
                showTopToast(context, "Saved to Vocabulary", isError: false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Save Sentence',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ] else ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Analysis not available'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Original sentence skeleton
        _buildSkeletonBox(height: 12, width: 120),
        const SizedBox(height: 8),
        _buildSkeletonBox(height: 20, width: double.infinity),
        const SizedBox(height: 20),

        // Summary skeleton
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildSkeletonBox(height: 16, width: double.infinity),
              const SizedBox(height: 8),
              _buildSkeletonBox(height: 16, width: double.infinity),
              const SizedBox(height: 8),
              _buildSkeletonBox(height: 16, width: 200),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Structure skeleton
        _buildSkeletonBox(height: 12, width: 150),
        const SizedBox(height: 8),
        _buildSkeletonBox(height: 18, width: double.infinity),
        const SizedBox(height: 20),

        // Grammar points skeleton
        _buildSkeletonBox(height: 12, width: 130),
        const SizedBox(height: 12),
        _buildSkeletonCard(),
        const SizedBox(height: 12),
        _buildSkeletonCard(),
        const SizedBox(height: 20),

        // Vocabulary skeleton
        _buildSkeletonBox(height: 12, width: 100),
        const SizedBox(height: 12),
        _buildSkeletonCard(),
        const SizedBox(height: 12),
        _buildSkeletonCard(),
      ],
    );
  }

  Widget _buildSkeletonBox({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeletonBox(height: 16, width: 150),
          const SizedBox(height: 8),
          _buildSkeletonBox(height: 14, width: double.infinity),
          const SizedBox(height: 6),
          _buildSkeletonBox(height: 14, width: 250),
        ],
      ),
    );
  }

  Widget _buildSection(String label, String text, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isHighlight ? Colors.blue[700] : Colors.black87,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildGrammarPoint(BuildContext context, GrammarPoint point) {
    final isSaved = _savedGrammarPoints.contains(point.structure);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!, width: 1),
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
                        color: Colors.green[900],
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
                      color: Colors.green[700],
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
            style: TextStyle(fontSize: 13, color: Colors.green[800]),
          ),
          if (point.example.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '例: ${point.example}',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.green[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVocabularyItem(BuildContext context, VocabularyItem vocab) {
    final isSaved = _savedVocabulary.contains(vocab.word);

    Color levelColor = Colors.blue;
    if (vocab.level == 'intermediate') {
      levelColor = Colors.orange;
    } else if (vocab.level == 'advanced') {
      levelColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                vocab.word,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              if (vocab.partOfSpeech != null &&
                  vocab.partOfSpeech!.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  vocab.partOfSpeech!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[600],
                  ),
                ),
              ],
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
                      color: Colors.blue,
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
            style: TextStyle(fontSize: 13, color: Colors.blue[800]),
          ),
          if (vocab.example.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '例: ${vocab.example}',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.blue[700],
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
        color: AppColors.analysisRedLight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.stars_rounded, size: 18, color: Colors.red[700]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  idiom.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
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
                      color: Colors.red[700],
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
              color: Colors.red[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            idiom.explanation,
            style: TextStyle(fontSize: 14, color: Colors.red[900], height: 1.4),
          ),
        ],
      ),
    );
  }
}
