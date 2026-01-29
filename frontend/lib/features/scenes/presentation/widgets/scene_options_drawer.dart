import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/styled_drawer.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/core/utils/l10n_ext.dart';

class SceneOptionsDrawer extends StatelessWidget {
  final VoidCallback? onClear;
  final VoidCallback? onDelete;
  final VoidCallback? onBookmark; // This is "Bookmark Conversation"
  final VoidCallback? onShowFavorites; // New: Show Favorites List

  const SceneOptionsDrawer({
    super.key,
    this.onClear,
    this.onDelete,
    this.onBookmark,
    this.onShowFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return StyledDrawer(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onShowFavorites != null)
            ListTile(
              leading: const Icon(Icons.star_outline, color: AppColors.primary),
              title: Text(context.l10n.scenes_favorites),
              onTap: () {
                Navigator.pop(context);
                onShowFavorites!();
              },
            ),
          if (onClear != null)
            ListTile(
              leading: const Icon(Icons.refresh, color: AppColors.primary),
              title: Text(context.l10n.scenes_clearConversation),
              onTap: () {
                Navigator.pop(context);
                onClear!();
              },
            ),
          if (onBookmark != null)
            ListTile(
              leading: const Icon(
                Icons.bookmark_border,
                color: AppColors.primary,
              ),
              title: Text(context.l10n.scenes_bookmarkConversation),
              onTap: () {
                Navigator.pop(context);
                onBookmark!();
              },
            ),
          if (onClear != null || onBookmark != null || onShowFavorites != null)
            const Divider(),
          if (onDelete != null)
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.lightError,
              ),
              title: Text(
                context.l10n.chat_deleteConversation,
                style: const TextStyle(color: AppColors.lightError),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete!();
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
