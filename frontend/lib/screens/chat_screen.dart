import 'package:flutter/material.dart';
import '../models/scene.dart';
import '../models/message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/feedback_sheet.dart';
import '../widgets/analysis_sheet.dart';
import '../widgets/hints_sheet.dart';
import '../services/api_service.dart';
import '../services/revenue_cat_service.dart';
import '../services/chat_history_service.dart';
import '../services/preferences_service.dart'; // Added
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
  List<Message> _messages = [];
  bool _isAnalyzing = false;
  String? _analyzingMessageId;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    // Unique key for the scene. Title + Role is usually unique enough for MVP.
    final sceneKey = "${widget.scene.title}_${widget.scene.aiRole}";
    final history = ChatHistoryService().getMessages(sceneKey);
    
    if (history.isEmpty) {
      // Check target language
      final prefs = PreferencesService();
      final targetLang = await prefs.getTargetLanguage();
      
      String initialContent = widget.scene.initialMessage;
      
      // If target language is not English, translate the initial message
      if (targetLang != 'English') {
        try {
          initialContent = await _apiService.translateText(
            widget.scene.initialMessage, 
            targetLang
          );
        } catch (e) {
          print("Translation failed, falling back to original: $e");
        }
      }

      // Add initial AI message if history is empty
      final initialMsg = Message(
        id: 'init',
        content: initialContent,
        isUser: false,
        timestamp: DateTime.now(),
      );
      history.add(initialMsg);
    }
    
    // Use the same list reference so updates propagate to service automatically
    if (mounted) {
      setState(() {
        _messages = history;
      });
    }
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
    
    // No need to call addMessage - _messages is the same list as in the service
    final sceneKey = "${widget.scene.title}_${widget.scene.aiRole}";

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
             // No need to call updateMessage - we're using the same list reference
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
        // No need to call addMessage - _messages is the same list as in the service
        
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clear Conversation',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Are you sure you want to clear this conversation and start over?',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              final sceneKey = "${widget.scene.title}_${widget.scene.aiRole}";
                              
                              // Clear from service
                              ChatHistoryService().clearHistory(sceneKey);
                              
                              // Reload to re-initialize (and translate) the initial message
                              _loadMessages();
                            },
                            child: const Text(
                              'Clear',
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
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
                      } else if (!msg.isUser) {
                        // AI message - show analysis
                        _handleAnalyze(msg);
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
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
              // Prepare history
              final history = _messages.map((m) => <String, String>{
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.content,
              }).toList();

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => HintsSheet(
                  sceneDescription: widget.scene.description,
                  history: history,
                  onHintSelected: (hint) {
                    _textController.text = hint;
                  },
                ),
              );
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

  void _handleAnalyze(Message message) async {
    // If analysis already exists, show it directly
    if (message.analysis != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => AnalysisSheet(
          message: message,
          analysis: message.analysis,
        ),
      );
      return;
    }

    // Show loading sheet
    setState(() {
      _isAnalyzing = true;
      _analyzingMessageId = message.id;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) => AnalysisSheet(
        message: message,
        isLoading: true,
      ),
    );

    try {
      final analysis = await _apiService.analyzeMessage(message.content);
      
      if (!mounted) return;

      // Update message with analysis
      final messageIndex = _messages.indexWhere((m) => m.id == message.id);
      if (messageIndex != -1) {
        final updatedMessage = Message(
          id: message.id,
          content: message.content,
          isUser: message.isUser,
          timestamp: message.timestamp,
          translation: message.translation,
          feedback: message.feedback,
          analysis: analysis,
        );
        setState(() {
          _messages[messageIndex] = updatedMessage;
          _isAnalyzing = false;
          _analyzingMessageId = null;
        });

        // Close loading sheet and show result
        Navigator.pop(context);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => AnalysisSheet(
            message: updatedMessage,
            analysis: analysis,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _analyzingMessageId = null;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to analyze: $e')),
      );
    }
  }
}
