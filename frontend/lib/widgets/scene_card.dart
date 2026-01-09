import 'package:flutter/material.dart';
import '../models/scene.dart';
import '../design/app_design_system.dart';

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
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AppRadius.xl),
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
                        style: AppTypography.subtitle2.copyWith(
                          color: AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      if (showRole) ...[
                        const SizedBox(height: 2), // Tighter spacing
                        Text(
                          'With: ${scene.aiRole}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondaryLight,
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
