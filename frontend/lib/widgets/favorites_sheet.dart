import 'package:flutter/material.dart';
import '../features/study/data/vocab_service.dart';
import 'styled_drawer.dart';
import 'empty_state_widget.dart';

class FavoritesSheet extends StatelessWidget {
  final String scenarioId;

  const FavoritesSheet({super.key, required this.scenarioId});

  @override
  Widget build(BuildContext context) {
    return StyledDrawer(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'Favorites',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedBuilder(
              animation: VocabService(),
              builder: (context, child) {
                final service = VocabService();
                final items = service.getItemsForScenario(scenarioId);

                if (items.isEmpty) {
                  return const Center(
                    child: EmptyStateWidget(
                      message: 'No favorites yet for this scenario',
                      imagePath: 'assets/empty_state_pear.png',
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item.phrase,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.translation.isNotEmpty &&
                              item.translation != "Smart Feedback")
                            Text(item.translation),
                          Text(
                            item.tag,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          service.remove(item.phrase);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
