import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';
import '../../data/vocab_service.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/core/widgets/empty_state_widget.dart';
import 'package:frontend/features/speech/speech.dart';
import 'favorites_skeleton_loader.dart';

class VocabListWidget extends StatelessWidget {
  final String? sceneId;
  final String targetLanguage; // Language code for TTS
  final WordTtsService _wordTtsService = WordTtsService();

  VocabListWidget({
    super.key,
    this.sceneId,
    this.targetLanguage = 'en-US', // Default for backward compatibility
  });

  Future<void> _playWordPronunciation(String word) async {
    // Clean the word (keep hyphens and apostrophes for proper pronunciation)
    // Remove only sentence-ending punctuation like . , ! ? ; :
    final cleanWord = word.replaceAll(RegExp(r'[.,!?;:"]'), '').trim();
    if (cleanWord.isEmpty) return;

    try {
      await _wordTtsService.speakWord(cleanWord, language: targetLanguage);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Word TTS error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: VocabService(),
      builder: (context, child) {
        final service = VocabService();
        if (service.isLoading && service.items.isEmpty) {
          return const FavoritesSkeletonLoader();
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

        return CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                await VocabService().refresh();
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final int itemIndex = index ~/ 2;
                    if (index.isEven) {
                      final item = items[itemIndex];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightDivider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          item.phrase,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.lightTextPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Play Button
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
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: AppColors.lightTextSecondary,
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
                                  color: AppColors.lightTextSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }
                    return const SizedBox(height: 16);
                  },
                  childCount: items.length * 2 - 1,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
