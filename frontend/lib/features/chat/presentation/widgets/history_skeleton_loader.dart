import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HistorySkeletonLoader extends StatelessWidget {
  const HistorySkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        itemCount: 8, // Show a few skeleton items
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Subtitle placeholder area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title placeholder
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      // Subtitle placeholder
                      Container(
                        width: 200,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Date placeholder
                Container(
                  width: 40,
                  height: 12,
                  color: Colors.white,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
