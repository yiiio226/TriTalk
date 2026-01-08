import 'package:flutter/material.dart';
import '../models/scene.dart';

class SceneCard extends StatelessWidget {
  final Scene scene;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool showRole;

  const SceneCard({
    super.key,
    required this.scene,
    required this.onTap,
    this.onLongPress,
    this.showRole = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(scene.color).withOpacity(0.6), // Use scene color
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: showRole ? 2 : 3, // Smaller image area in list view
                child: Center(
                  child: scene.iconPath.isNotEmpty
                      ? Image.asset(
                          scene.iconPath,
                          width: showRole ? 60 : 80, // Smaller icon in list view
                          height: showRole ? 60 : 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildEmojiFallback(scene.emoji);
                          },
                        )
                      : _buildEmojiFallback(scene.emoji),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        scene.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          height: 1.2,
                        ),
                      ),
                      if (showRole) ...[
                        const SizedBox(height: 2), // Tighter spacing
                        Text(
                          'With: ${scene.aiRole}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiFallback(String emoji) {
    return Text(
      emoji,
      style: const TextStyle(fontSize: 60),
    );
  }
}
