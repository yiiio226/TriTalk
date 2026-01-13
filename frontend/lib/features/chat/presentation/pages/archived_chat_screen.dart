import 'package:flutter/material.dart';
import 'package:frontend/features/chat/domain/models/message.dart';
import '../widgets/chat_bubble.dart';
import '../../data/chat_history_service.dart';
import 'package:frontend/core/design/app_design_system.dart';

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
        isLoading: false, // Ensure no loading state
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightSurface, // Status bar background
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              color: AppColors.lightSurface,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightBackground,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.lightTextPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bookmark.title,
                      style: TextStyle(
                        fontSize: 18,
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
            // Content
            Expanded(
              child: Container(
                color: AppColors.lightBackground,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 36, 16, 16), // 20 + 16 spacing
                  itemCount: displayMessages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final msg = displayMessages[index];
                  return Align(
                    alignment: msg.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: ChatBubble(key: ValueKey(msg.id), message: msg),
                  );
                },
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
