import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../data/vocab_service.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/core/widgets/empty_state_widget.dart';
import 'favorites_skeleton_loader.dart';

class SavedSentenceListWidget extends StatelessWidget {
  final String? sceneId;

  const SavedSentenceListWidget({super.key, this.sceneId});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: VocabService(),
      builder: (context, child) {
        final service = VocabService();
        if (service.isLoading && service.items.isEmpty) {
          return const FavoritesSkeletonLoader();
        }

        final items = service.items
            .where(
              (item) =>
                  item.tag == 'Analyzed Sentence' &&
                  (sceneId == null || item.scenarioId == sceneId),
            )
            .toList();

        if (items.isEmpty) {
          return const Center(
            child: EmptyStateWidget(
              message: 'No analyzed sentences saved yet',
              imagePath: 'assets/empty_state_pear.png',
            ),
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
                              children: [
                                Expanded(
                                  child: Text(
                                    item.phrase, // The sentence
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.lightTextPrimary,
                                      height: 1.4,
                                    ),
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
                            if (item.translation.isNotEmpty &&
                                item.translation != 'Analyzed Sentence') ...[
                              const SizedBox(height: 8),
                              Text(
                                item.translation, // "AI Message Analysis" or manual
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.lightTextSecondary,
                                  fontStyle: FontStyle.italic,
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
