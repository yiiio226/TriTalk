import 'package:flutter/material.dart';
import '../features/study/data/vocab_service.dart';
import '../widgets/empty_state_widget.dart';

class GrammarListWidget extends StatelessWidget {
  final String? sceneId;

  const GrammarListWidget({super.key, this.sceneId});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: VocabService(),
      builder: (context, child) {
        final items = VocabService().items
            .where(
              (item) =>
                  item.tag == 'Grammar Point' &&
                  (sceneId == null || item.scenarioId == sceneId),
            )
            .toList();

        if (items.isEmpty) {
          return const Center(
            child: EmptyStateWidget(
              message: 'No sentence patterns saved yet',
              imagePath: 'assets/empty_state_pear.png',
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
                color: Colors.green[50],
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
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.green[300],
                        ), // Subtle delete icon
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
    );
  }
}
