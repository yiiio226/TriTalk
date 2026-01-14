import 'package:flutter/material.dart';
import '../../data/chat_history_service.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/core/widgets/empty_state_widget.dart';
import '../pages/archived_chat_screen.dart';

class ChatHistoryListWidget extends StatelessWidget {
  final String? sceneId;

  const ChatHistoryListWidget({super.key, this.sceneId});

  Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Delete Conversation?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Are you sure you want to delete this conversation?',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFFF3B30),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteBookmark(BuildContext context, String id) {
    ChatHistoryService().removeBookmark(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Conversation deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<BookmarkedConversation>>(
      valueListenable: ChatHistoryService().bookmarksNotifier,
      builder: (context, bookmarks, _) {
        if (bookmarks.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await ChatHistoryService().refreshBookmarks();
            },
            child: ListView(
              children: const [
                SizedBox(height: 200),
                EmptyStateWidget(
                  message: 'No archived conversations',
                  imagePath: 'assets/empty_state_lemon.png',
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ChatHistoryService().refreshBookmarks();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = bookmarks[index];
              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await _showDeleteConfirmDialog(context);
                },
                onDismissed: (direction) {
                  _deleteBookmark(context, item.id);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightDivider),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ArchivedChatScreen(bookmark: item),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.date,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: AppColors.lightTextSecondary,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () async {
                                  final confirm =
                                      await _showDeleteConfirmDialog(context);
                                  if (confirm == true && context.mounted) {
                                    _deleteBookmark(context, item.id);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.preview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.lightTextSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
