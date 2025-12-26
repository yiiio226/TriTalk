import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/vocab_service.dart';

class AnalysisSheet extends StatelessWidget {
  final Message message;
  final MessageAnalysis? analysis;
  final bool isLoading;

  const AnalysisSheet({
    Key? key,
    required this.message,
    this.analysis,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.9,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (fixed at top)
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Sentence Analysis',
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
            
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
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
        if (isLoading) ...[
          // Skeleton screen for loading state
          _buildSkeletonLoader(),
        ] else if (analysis != null) ...[
          // Original sentence
          _buildSection('Original Sentence', message.content, isHighlight: true),
          const SizedBox(height: 16),

          // Overall summary with Context & Tone merged
          if (analysis!.overallSummary.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Summary
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 20, color: Colors.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          analysis!.overallSummary,
                          style: TextStyle(color: Colors.purple[900]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Sentence structure
          if (analysis!.sentenceStructure.isNotEmpty) ...[
            _buildSection('Sentence Structure', analysis!.sentenceStructure),
            const SizedBox(height: 16),
          ],

          // Grammar points
          if (analysis!.grammarPoints.isNotEmpty) ...[
            const Text(
              'GRAMMAR POINTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ...analysis!.grammarPoints.map((point) => _buildGrammarPoint(point)),
            const SizedBox(height: 16),
          ],

          // Vocabulary
          if (analysis!.vocabulary.isNotEmpty) ...[
            const Text(
              'VOCABULARY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ...analysis!.vocabulary.map((vocab) => _buildVocabularyItem(vocab)),
            const SizedBox(height: 16),
          ],

          // L-02: Idioms & Slang
          if (analysis!.idioms.isNotEmpty) ...[
            const Text(
              'IDIOMS & SLANG',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ...analysis!.idioms.map((idiom) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.whatshot, size: 16, color: Colors.orange[800]),
                      const SizedBox(width: 6),
                      Text(
                        idiom.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    idiom.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    idiom.explanation,
                    style: TextStyle(fontSize: 13, color: Colors.orange[900]),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
          ],

          // Save button
          ElevatedButton.icon(
            onPressed: () {
              // Save the original sentence to vocabulary
              VocabService().add(
                message.content,
                "AI Message Analysis",
                "Analyzed Sentence",
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

  Widget _buildGrammarPoint(GrammarPoint point) {
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
          Text(
            point.structure,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
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

  Widget _buildVocabularyItem(VocabularyItem vocab) {
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
