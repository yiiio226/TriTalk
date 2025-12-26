import 'package:flutter/material.dart';
import '../services/vocab_service.dart';

class SaveNoteSheet extends StatefulWidget {
  final String originalSentence;

  const SaveNoteSheet({Key? key, required this.originalSentence}) : super(key: key);

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
        // Save whole sentence
        await VocabService().add(
          widget.originalSentence,
          "Saved Sentence", 
          "Golden Sentence", // Tag
        );
      } else {
        // Save selected words
        final indices = _selectedWordIndices.toList()..sort();
        final selectedText = indices.map((i) => _words[i]).join(' ');
        
        await VocabService().add(
          selectedText,
          widget.originalSentence, // Use original sentence as context/translation
          "Vocabulary", // Tag
        );
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to Notebook!')),
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Save to Note',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap words to select specific vocabulary, or save the entire sentence.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_words.length, (index) {
              final isSelected = _selectedWordIndices.contains(index);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedWordIndices.remove(index);
                    } else {
                      _selectedWordIndices.add(index);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    _words[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveSelection,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20, width: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  )
                : Text(
                    _selectedWordIndices.isEmpty 
                        ? 'Save Whole Sentence' 
                        : 'Save Selected Vocabulary',
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
