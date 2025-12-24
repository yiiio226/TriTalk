import 'package:flutter/material.dart';
import '../models/scene.dart';

class SceneCard extends StatelessWidget {
  final Scene scene;
  final VoidCallback onTap;

  const SceneCard({Key? key, required this.scene, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                scene.iconPath.isNotEmpty
                    ? Image.asset(
                        scene.iconPath,
                        width: 48,
                        height: 48,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to emoji if asset fails to load
                          return _buildEmojiFallback(scene.emoji);
                        },
                      )
                    : _buildEmojiFallback(scene.emoji),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(scene.difficulty).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    scene.difficulty,
                    style: TextStyle(
                      color: _getDifficultyColor(scene.difficulty),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              scene.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Role: ${scene.aiRole}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            Text(
              'Goal: ${scene.goal}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50); // Green
      case 'medium':
        return const Color(0xFFFFC107); // Amber/Yellow
      case 'hard':
        return const Color(0xFFE91E63); // Pink/Red
      default:
        return Colors.blue;
    }
  }

  Widget _buildEmojiFallback(String emoji) {
    return Text(
      emoji,
      style: const TextStyle(fontSize: 40),
    );
  }
}
