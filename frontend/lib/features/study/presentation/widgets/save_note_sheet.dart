import 'package:flutter/material.dart';
import '../../data/vocab_service.dart';
import 'package:frontend/core/widgets/styled_drawer.dart';
import 'package:frontend/core/utils/l10n_ext.dart';

class SaveNoteSheet extends StatefulWidget {
  final String originalSentence;
  final String? sceneId; // Add sceneId to link to conversation

  const SaveNoteSheet({
    super.key,
    required this.originalSentence,
    this.sceneId,
  });

  @override
  State<SaveNoteSheet> createState() => _SaveNoteSheetState();
}

class _SaveNoteSheetState extends State<SaveNoteSheet> {
  // VocabService is a singleton, accessed directly
  late List<String> _words;
  final Set<int> _selectedWordIndices = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Split by space but keep punctuation attached to words for simplicity in this V1
    _words = widget.originalSentence.split(' ');
  }

  Future<void> _saveSelection() async {
    setState(() => _isSaving = true);

    try {
      if (_selectedWordIndices.isEmpty) {
        // Save whole sentence with sceneId
        await VocabService().add(
          widget.originalSentence,
          "Saved Sentence",
          "Analyzed Sentence", // Tag for Sentence Tab
          scenarioId: widget.sceneId, // Link to current conversation
        );
      } else {
        // Save selected words with sceneId
        final indices = _selectedWordIndices.toList()..sort();
        final selectedText = indices.map((i) => _words[i]).join(' ');

        await VocabService().add(
          selectedText,
          widget
              .originalSentence, // Use original sentence as context/translation
          "Vocabulary", // Tag
          scenarioId: widget.sceneId, // Link to current conversation
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.study_savedToNotebook)),
        );
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StyledDrawer(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed Header
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.saveNote_title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                const SizedBox(height: 8),
                Text(
                  context.l10n.saveNote_instruction,
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_words.length, (index) {
                  final isSelected = _selectedWordIndices.contains(index);
                  // Check if word is already saved (strip punctuation for better matching if needed, but simple check first)
                  // Note: naive check. Ideally we strip punctuation.
                  final word = _words[index].replaceAll(RegExp(r'[^\w\s]'), '');
                  final isSaved = VocabService().exists(
                    word,
                    scenarioId: widget.sceneId,
                  );

                  return GestureDetector(
                    onTap: isSaved
                        ? null
                        : () {
                            setState(() {
                              if (isSelected) {
                                _selectedWordIndices.remove(index);
                              } else {
                                _selectedWordIndices.add(index);
                              }
                            });
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.black
                            : (isSaved
                                  ? Colors.deepPurple.shade50
                                  : Colors.white),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isSaved
                                    ? Colors.deepPurple.shade200
                                    : Colors.grey.shade300),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        _words[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isSaved ? Colors.deepPurple : Colors.black87),
                          fontWeight: isSelected || isSaved
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Fixed Footer
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                ), // Height controlled by minimumSize
                minimumSize: const Size(double.infinity, 56),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _selectedWordIndices.isEmpty
                          ? context.l10n.saveNote_saveSentence
                          : context.l10n.saveNote_saveSelected(
                              _selectedWordIndices.length,
                            ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
