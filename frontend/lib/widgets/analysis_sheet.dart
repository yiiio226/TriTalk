import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/vocab_service.dart';
import 'top_toast.dart';
import 'styled_drawer.dart';

class AnalysisSheet extends StatefulWidget {
  final Message message;
  final MessageAnalysis? analysis;
  final bool isLoading;
  final String? sceneId; // Added sceneId

  const AnalysisSheet({
    Key? key,
    required this.message,
    this.analysis,
    this.isLoading = false,
    this.sceneId,
  }) : super(key: key);

  @override
  State<AnalysisSheet> createState() => _AnalysisSheetState();
}

class _AnalysisSheetState extends State<AnalysisSheet> {
  // Track which items are saved
  final Set<String> _savedGrammarPoints = {};
  final Set<String> _savedVocabulary = {};

  @override
  void initState() {
    super.initState();
    _initializeSavedStates();
  }

  void _initializeSavedStates() {
    final vocabService = VocabService();
    
    // Check which grammar points are already saved
    if (widget.analysis?.grammarPoints != null) {
      for (var point in widget.analysis!.grammarPoints) {
        if (vocabService.exists(point.structure, scenarioId: widget.sceneId)) {
          _savedGrammarPoints.add(point.structure);
        }
      }
    }
    
    // Check which vocabulary items are already saved
    if (widget.analysis?.vocabulary != null) {
      for (var vocab in widget.analysis!.vocabulary) {
        if (vocabService.exists(vocab.word, scenarioId: widget.sceneId)) {
          _savedVocabulary.add(vocab.word);
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.85,
      ),
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
                        child: Icon(Icons.auto_awesome_rounded, color: Colors.purple.shade400, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Sentence Analysis',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.isLoading) ...[
          _buildSkeletonLoader(),
        ] else if (widget.analysis != null) ...[
          // Original Sentence
          const Text(
            'ORIGINAL SENTENCE',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            widget.message.content,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Summary
          if (widget.analysis!.overallSummary.isNotEmpty && 
              widget.analysis!.overallSummary != 'No summary available.') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5), // Purple 50 equivalent
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 22, color: Colors.purple[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.analysis!.overallSummary,
                      style: TextStyle(color: Colors.purple[900], fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Sentence Structure
          if (widget.analysis!.sentenceStructure.isNotEmpty && 
              widget.analysis!.sentenceBreakdown.isNotEmpty) ...[
            const Text(
              'SENTENCE STRUCTURE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              widget.analysis!.sentenceStructure,
              style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: widget.analysis!.sentenceBreakdown.map((segment) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD), // Blue 50
                  borderRadius: BorderRadius.circular(12),
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
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Grammar Points
          if (widget.analysis!.grammarPoints.isNotEmpty) ...[
            const Text(
              'GRAMMAR POINTS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ...widget.analysis!.grammarPoints.map((point) => _buildGrammarPoint(context, point)),
            const SizedBox(height: 12),
          ],

          // Vocabulary
          if (widget.analysis!.vocabulary.isNotEmpty) ...[
            const Text(
              'VOCABULARY',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ...widget.analysis!.vocabulary.map((vocab) => _buildVocabularyItem(context, vocab)),
            const SizedBox(height: 12),
          ],

          // Idioms
          if (widget.analysis!.idioms.isNotEmpty) ...[
            const Text(
              'IDIOMS & SLANG',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 12),
            ...widget.analysis!.idioms.map((idiom) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE), // Red 50
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stars_rounded, size: 18, color: Colors.red[700]),
                      const SizedBox(width: 6),
                      Text(
                        idiom.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[800],
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
            )),
            const SizedBox(height: 12),
          ],

          // Save button
          const SizedBox(height: 12),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            child: const Text('Save Sentence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                child: Text(
                  point.structure,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Save Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    final contentToSave = "${point.explanation}\\n\\n例: ${point.example}";
                    
                    if (!isSaved) {
                      VocabService().add(
                        point.structure,
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
              if (vocab.level != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: levelColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    vocab.level!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: levelColor,
                    ),
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
                        scenarioId: widget.sceneId, // Link to current conversation
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
}
