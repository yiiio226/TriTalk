import 'package:flutter/material.dart';
import '../services/chat_history_service.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/history_skeleton_loader.dart';
import '../screens/archived_chat_screen.dart';

class ChatHistoryListWidget extends StatefulWidget {
  final String? sceneId;

  const ChatHistoryListWidget({Key? key, this.sceneId}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const HistorySkeletonLoader();
    }
    
    if (_bookmarks.isEmpty) {
      return const EmptyStateWidget(
        message: 'No archived conversations',
        imagePath: 'assets/empty_state_lemon.png',
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _bookmarks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _bookmarks[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(item.preview, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(item.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArchivedChatScreen(bookmark: item),
              ),
            ).then((_) => _loadBookmarks()); // Reload on return in case of changes if any
          },
        );
      },
    );
  }
}
