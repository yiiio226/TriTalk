import 'package:flutter/material.dart';
import '../services/vocab_service.dart';
import '../widgets/empty_state_widget.dart';

class GrammarPatternsScreen extends StatelessWidget {
  const GrammarPatternsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sentence Patterns',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: VocabService(),
        builder: (context, child) {
          final items = VocabService().items
              .where((item) => item.tag == 'Grammar Point')
              .toList();

          if (items.isEmpty) {
            return const Center(
              child: EmptyStateWidget(
                message: 'No sentence patterns saved yet',
                imagePath: 'assets/empty_state_pear.png', // Reusing the pear image
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50], // Consistent with AnalysisSheet
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.phrase, // Structure
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark, color: Colors.green),
                          onPressed: () {
                            VocabService().remove(item.phrase);
                          },
                        ),
                      ],
                    ),
                    if (item.translation.isNotEmpty) ...[
                       const SizedBox(height: 8),
                       Text(
                         item.translation, // Explanation + Example
                         style: TextStyle(
                           fontSize: 14,
                           color: Colors.green[800],
                           height: 1.5,
                         ),
                       ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
