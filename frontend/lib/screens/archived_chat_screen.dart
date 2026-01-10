import 'package:flutter/material.dart';
import '../models/message.dart';
import '../widgets/chat_bubble.dart';
import '../services/chat_history_service.dart';
import '../design/app_design_system.dart';

class ArchivedChatScreen extends StatelessWidget {
  final BookmarkedConversation bookmark;

  const ArchivedChatScreen({super.key, required this.bookmark});

  @override
  Widget build(BuildContext context) {
    // Reset animation flags for all messages to prevent re-animation
    final displayMessages = bookmark.messages.map((msg) {
      return Message(
        id: msg.id,
        content: msg.content,
        isUser: msg.isUser,
        timestamp: msg.timestamp,
        translation: msg.translation,
        feedback: msg.feedback,
        analysis: msg.analysis,
        isAnimated: false, // Disable animation for archived messages
        isLoading: false,  // Ensure no loading state
      );
    }).toList();

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
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextPrimary,
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
                itemCount: displayMessages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final msg = displayMessages[index];
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
