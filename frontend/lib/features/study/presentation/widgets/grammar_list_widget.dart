import 'package:flutter/material.dart';
import '../../data/vocab_service.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/core/widgets/empty_state_widget.dart';

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
                          item.phrase, // Structure
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
