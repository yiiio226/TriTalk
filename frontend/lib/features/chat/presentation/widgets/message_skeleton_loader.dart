import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:frontend/core/design/app_design_system.dart';

class MessageSkeletonLoader extends StatelessWidget {
  const MessageSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightSkeletonBase, // Much lighter base
      highlightColor:
          AppColors.lightSkeletonHighlight, // Much lighter highlight
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: 6,
        itemBuilder: (context, index) {
          final isUser = index % 2 != 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 240),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // Use opacity to make the bubble background fainter than the text blocks
                  color: AppColors.lightSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppRadius.lg),
                    topRight: const Radius.circular(AppRadius.lg),
                    bottomLeft: isUser
                        ? const Radius.circular(AppRadius.lg)
                        : Radius.zero,
                    bottomRight: isUser
                        ? Radius.zero
                        : const Radius.circular(AppRadius.lg),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text Block 1
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Text Block 2 (shorter)
                    Container(
                      width: 120, // Fixed shorter width for second line
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
