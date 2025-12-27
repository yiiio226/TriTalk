import 'package:flutter/material.dart';
import 'styled_drawer.dart';

class SceneOptionsDrawer extends StatelessWidget {
  final VoidCallback? onClear;
  final VoidCallback? onDelete;
  final VoidCallback? onBookmark;

  const SceneOptionsDrawer({
    Key? key,
    this.onClear,
    this.onDelete,
    this.onBookmark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StyledDrawer(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          if (onClear != null || onBookmark != null) const Divider(),
          if (onDelete != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Conversation', style: TextStyle(color: Colors.red)),
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
