import 'package:flutter/material.dart';
import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onTap;

  const ChatBubble({Key? key, required this.message, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser ? Colors.blue[100] : Colors.white;
    final radius = BorderRadius.circular(16);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: isUser
              ? radius.copyWith(bottomRight: Radius.zero)
              : radius.copyWith(bottomLeft: Radius.zero),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: const TextStyle(fontSize: 16),
            ),
            if (message.feedback != null) ...[
               const SizedBox(height: 4),
               const Icon(Icons.auto_fix_high, size: 16, color: Colors.orange),
            ]
          ],
        ),
      ),
    );
  }
}
