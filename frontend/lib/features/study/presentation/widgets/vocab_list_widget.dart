import 'package:flutter/material.dart';
import '../../data/vocab_service.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/core/widgets/empty_state_widget.dart';
import 'vocab_skeleton_loader.dart';

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
                color: AppColors.lightBackground,
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
                          item.phrase,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightTextPrimary,
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
          },
        );
      },
    );
  }
}
