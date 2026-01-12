import 'package:flutter/material.dart';
import '../features/study/data/vocab_service.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/vocab_skeleton_loader.dart';

class VocabListWidget extends StatelessWidget {
  final String? sceneId;

  const VocabListWidget({super.key, this.sceneId});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: VocabService(),
      builder: (context, child) {
        final service = VocabService();
        if (service.isLoading && service.items.isEmpty) {
          return const VocabSkeletonLoader();
        }

        // Filter out Grammar Points AND Analyzed Sentences
        // AND match sceneId if provided
        final items = service.items
            .where(
              (i) =>
                  i.tag != 'Grammar Point' &&
                  i.tag != 'Analyzed Sentence' &&
                  (sceneId == null || i.scenarioId == sceneId),
            )
            .toList();

        if (items.isEmpty) {
          return const EmptyStateWidget(
            message: 'No vocabulary saved yet',
            imagePath: 'assets/empty_state_pear.png',
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
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.phrase,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.blue[300],
                        ),
                        onPressed: () {
                          VocabService().remove(item.phrase);
                        },
                      ),
                    ],
                  ),
                  if (item.translation.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.translation,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
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
