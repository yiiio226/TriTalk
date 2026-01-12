import 'package:flutter/material.dart';
import '../../../../core/widgets/styled_drawer.dart';

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
              leading: const Icon(Icons.star_outline, color: Colors.amber),
              title: const Text('Favorites'),
              onTap: () {
                Navigator.pop(context);
                onShowFavorites!();
              },
            ),
          if (onClear != null)
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.black),
              title: const Text('Clear Conversation'),
              onTap: () {
                Navigator.pop(context);
                onClear!();
              },
            ),
          if (onBookmark != null)
            ListTile(
              leading: const Icon(Icons.bookmark_border, color: Colors.black),
              title: const Text('Bookmark Conversation'),
              onTap: () {
                Navigator.pop(context);
                onBookmark!();
              },
            ),
          if (onClear != null || onBookmark != null || onShowFavorites != null)
            const Divider(),
          if (onDelete != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete Conversation',
                style: TextStyle(color: Colors.red),
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
