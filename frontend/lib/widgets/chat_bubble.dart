import 'package:flutter/material.dart';
import '../models/message.dart';

class ChatBubble extends StatefulWidget {
  final Message message;
  final VoidCallback? onTap;

  const ChatBubble({Key? key, required this.message, this.onTap}) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser ? Colors.blue[100] : Colors.white;
    final radius = BorderRadius.circular(16);

    return GestureDetector(
      onTap: () {
        if (!isUser && message.translation != null) {
          setState(() {
            _showTranslation = !_showTranslation;
          });
        }
        widget.onTap?.call();
      },
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
            ],
            if (_showTranslation && message.translation != null) ...[
               const SizedBox(height: 6),
               const Divider(height: 12),
               Text(
                 message.translation!,
                 style: TextStyle(fontSize: 14, color: Colors.grey[700]),
               ),
            ]
          ],
        ),
      ),
    );
  }
}
