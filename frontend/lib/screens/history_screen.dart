import 'package:flutter/material.dart';
import '../services/chat_history_service.dart';
import '../widgets/chat_bubble.dart'; 
import '../widgets/empty_state_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<BookmarkedConversation> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    setState(() {
      _bookmarks = ChatHistoryService().getBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Chat History',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Content
            Expanded(
              child: _bookmarks.isEmpty
                  ? const EmptyStateWidget(
                      message: 'No archived conversations',
                      imagePath: 'assets/empty_state_lemon.png',
                    )
                  : ListView.separated(
                      itemCount: _bookmarks.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _bookmarks[index];
                        return ListTile(
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item.preview, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Text(item.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArchivedChatScreen(bookmark: item),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArchivedChatScreen extends StatelessWidget {
  final BookmarkedConversation bookmark;

  const ArchivedChatScreen({Key? key, required this.bookmark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bookmark.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Content
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bookmark.messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final msg = bookmark.messages[index];
                  return Align(
                    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: ChatBubble(
                      key: ValueKey(msg.id),
                      message: msg,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
