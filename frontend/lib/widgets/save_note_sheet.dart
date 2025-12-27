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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const Text(
                'Quick Save',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
          const Text(
            'Tap words to select specific vocabulary, or save the entire sentence.',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    boxShadow: isSelected 
                        ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] 
                        : null,
                  ),
                  child: Text(
                    _words[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
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
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 0), // Height controlled by minimumSize
              minimumSize: const Size(double.infinity, 56),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 24, width: 24, 
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)
                  )
                : Text(
                    _selectedWordIndices.isEmpty 
                        ? 'Save Whole Sentence' 
                        : 'Save Selected Vocabulary',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
