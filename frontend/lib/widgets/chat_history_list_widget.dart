import 'package:flutter/material.dart';
import '../services/chat_history_service.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/history_skeleton_loader.dart';
import '../features/chat/presentation/pages/archived_chat_screen.dart';

class ChatHistoryListWidget extends StatefulWidget {
  final String? sceneId;

  const ChatHistoryListWidget({super.key, this.sceneId});

  @override
  State<ChatHistoryListWidget> createState() => _ChatHistoryListWidgetState();
}

class _ChatHistoryListWidgetState extends State<ChatHistoryListWidget> {
  List<BookmarkedConversation> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    // Simulate network delay to show skeleton if needed, or just load
    // Using a small delay to ensure smoother transition if switching tabs
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    setState(() {
      _bookmarks = ChatHistoryService().getBookmarks();
      _isLoading = false;
    });
  }

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

  void _deleteBookmark(String id) {
    ChatHistoryService().removeBookmark(id);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Conversation deleted")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const HistorySkeletonLoader();
    }

    return ValueListenableBuilder<List<BookmarkedConversation>>(
      valueListenable: ChatHistoryService().bookmarksNotifier,
      builder: (context, bookmarks, _) {
        if (bookmarks.isEmpty) {
          return const EmptyStateWidget(
            message: 'No archived conversations',
            imagePath: 'assets/empty_state_lemon.png',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: bookmarks.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = bookmarks[index];
            return Dismissible(
              key: Key(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await _showDeleteConfirmDialog(context);
              },
              onDismissed: (direction) {
                _deleteBookmark(item.id);
              },
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  item.preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.date,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.grey,
                      ),
                      onPressed: () async {
                        final confirm = await _showDeleteConfirmDialog(context);
                        if (confirm == true) {
                          _deleteBookmark(item.id);
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArchivedChatScreen(bookmark: item),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
