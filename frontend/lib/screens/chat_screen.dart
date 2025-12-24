import 'package:flutter/material.dart';
import '../models/scene.dart';
import '../models/message.dart';
import '../models/scene.dart';
import '../models/message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/feedback_sheet.dart';
import '../services/api_service.dart';
import '../services/revenue_cat_service.dart';
import '../services/chat_history_service.dart';
import 'paywall_screen.dart';

class ChatScreen extends StatefulWidget {
  final Scene scene;

  const ChatScreen({Key? key, required this.scene}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    // Unique key for the scene. Title + Role is usually unique enough for MVP.
    final sceneKey = "${widget.scene.title}_${widget.scene.aiRole}";
    final history = ChatHistoryService().getMessages(sceneKey);
    
    if (history.isEmpty) {
      // Add initial AI message if history is empty
      final initialMsg = Message(
        id: 'init',
        content: widget.scene.initialMessage,
        isUser: false,
        timestamp: DateTime.now(),
      );
      history.add(initialMsg);
       // Ensure service has it (getMessages returns reference, so add works, but good to be explicit)
    }
    
    // We use the same list reference so updates propagate to service automatically
    setState(() {
      _messages.addAll(history);
    });
  }

  final ApiService _apiService = ApiService();
  bool _isSending = false;

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    if (!RevenueCatService().canSendMessage()) {
      _showLimitDialog();
      return;
    }

    final newMessage = Message(
      id: DateTime.now().toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage);
      _isSending = true;
    });
    
    // Persist (since _messages is a COPY in this implementation? No, addAll copies elements.
    // So distinct list. We must sync back to service or use service list directly.)
    // Better: Helper to add to both.
    final sceneKey = "${widget.scene.title}_${widget.scene.aiRole}";
    ChatHistoryService().addMessage(sceneKey, newMessage);

    RevenueCatService().incrementMessageCount();
    
    _textController.clear();
    _scrollToBottom();

    try {
      final response = await _apiService.sendMessage(text, widget.scene.description);
      
      if (!mounted) return;

      setState(() {
        // Update the last user message with feedback if any
        if (response.feedback != null) {
           final lastUserMsgIndex = _messages.lastIndexWhere((m) => m.isUser);
           if (lastUserMsgIndex != -1) {
             final oldMsg = _messages[lastUserMsgIndex];
             final updatedMsg = Message(
               id: oldMsg.id,
               content: oldMsg.content,
               isUser: true,
               timestamp: oldMsg.timestamp,
               feedback: response.feedback,
             );
             _messages[lastUserMsgIndex] = updatedMsg;
             
             // Update history persistence
             // For MVP, we can just reload or update directly. 
             // Since we use separate list instances, we must update the service list too.
             // Simplest: The service returns a reference. We should use that reference directly instead of copying.
             // But ListView wants a list.
             // Let's manually update service for now because finding index in service list is tricky without ID map.
             // Actually, simplest is to use the SAME LIST INSTANCE.
           }
        }
        
        final aiMessage = Message(
          id: DateTime.now().toString(),
          content: response.message,
          isUser: false,
          timestamp: DateTime.now(),
          translation: response.translation,
        );

        _messages.add(aiMessage);
        ChatHistoryService().addMessage(sceneKey, aiMessage);
        
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() {
        _isSending = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.scene.title, style: const TextStyle(fontSize: 16)),
            Text(
              'Talking to ${widget.scene.aiRole}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Icons and text color
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: ChatBubble(
                    message: msg,
                    onTap: () {
                      if (msg.feedback != null) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => FeedbackSheet(message: msg),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 40),
      // ... same decoration ...
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () async {
              // Prepare history
              final history = _messages.map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.content,
              }).toList();

              // Show loading or hints
              try {
                final hints = await _apiService.getHints(widget.scene.description, history);
                if (!mounted) return;
                
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Suggestions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...hints.hints.map((hint) => ListTile(
                            title: Text(hint),
                            onTap: () {
                              _textController.text = hint;
                              Navigator.pop(context);
                            },
                          )).toList(),
                        ],
                      ),
                    );
                  },
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get hints: $e')));
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              minLines: 1,
              maxLines: 4,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Limit Reached'),
        content: const Text(
          'You have reached your daily limit of 10 free messages. Upgrade to Pro for unlimited access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaywallScreen()),
              );
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}
