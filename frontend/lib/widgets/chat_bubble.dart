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

    final isPerfect = message.feedback?.isPerfect ?? false;
    final hasFeedback = message.feedback != null;

    BoxDecoration bubbleDecoration = BoxDecoration(
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
    );

    if (isPerfect) {
      bubbleDecoration = bubbleDecoration.copyWith(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)], // Golden/Cream gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.amber.shade200, width: 1),
      );
    } else if (hasFeedback) {
      bubbleDecoration = bubbleDecoration.copyWith(
        border: Border.all(color: Colors.orange.shade100, width: 1),
      );
    }

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
        decoration: bubbleDecoration,
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              message.content,
              style: const TextStyle(fontSize: 16),
            ),
            if (hasFeedback) ...[
               const SizedBox(height: 4),
               Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(
                     isPerfect ? Icons.star : Icons.auto_fix_high, 
                     size: 14, 
                     color: isPerfect ? Colors.amber[700] : Colors.orange
                   ),
                   if (isPerfect) ...[
                     const SizedBox(width: 4),
                     Text(
                       "Perfect!", 
                       style: TextStyle(
                         fontSize: 10, 
                         fontWeight: FontWeight.bold,
                         color: Colors.amber[800]
                       )
                     ),
                   ]
                 ],
               ),
            ],
            // Analysis icon for AI messages
            if (!isUser) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: Colors.purple[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Analyze",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                ],
              ),
            ],
            if (_showTranslation && message.translation != null) ...[
               const SizedBox(height: 6),
               const Divider(height: 12),
               SelectableText(
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
