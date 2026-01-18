import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../study/data/vocab_service.dart';
import 'package:frontend/core/widgets/styled_drawer.dart';
import 'package:frontend/core/widgets/empty_state_widget.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/features/speech/speech.dart';

class FavoritesSheet extends StatelessWidget {
  final String scenarioId;
  final WordTtsService _wordTtsService = WordTtsService();

  FavoritesSheet({super.key, required this.scenarioId});

  Future<void> _playWordPronunciation(String word) async {
    final cleanWord = word.replaceAll(RegExp(r'[.,!?;:"]'), '').trim();
    if (cleanWord.isEmpty) return;

    try {
      await _wordTtsService.speakWord(cleanWord, language: 'en-US');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Word TTS error: $e');
      }
    }
  }

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
              const Icon(Icons.bookmark, color: AppColors.primary),
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
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.phrase,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _playWordPronunciation(item.phrase);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.volume_up_outlined,
                                  color: AppColors.lightTextSecondary,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
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
