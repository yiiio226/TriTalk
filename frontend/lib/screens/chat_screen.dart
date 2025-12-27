import 'dart:async';
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
import '../widgets/top_toast.dart';
import '../widgets/scene_options_drawer.dart';
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
  Timer? _autoScrollTimer; // Timer for continuous scrolling during animation

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

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }
  @override
  void initState() {
    super.initState();
    _loadMessages();
    _textController.addListener(() {
      setState(() {}); // Rebuild to update optimization button state
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _initialLoadFailed = false; // Added for initial load error tracking

  Future<void> _loadMessages() async {
    // Unique key for the scene. Title + Role is usually unique enough for MVP.
    final sceneKey = "${widget.scene.title}_${widget.scene.aiRole}";
    final history = ChatHistoryService().getMessages(sceneKey);
    
    bool isNewConversation = history.isEmpty;
    
    if (isNewConversation) {
      // Add a loading placeholder immediately
      final loadingId = 'init_loading';
      final loadingMsg = Message(
        id: loadingId,
        content: '',
        isUser: false,
        timestamp: DateTime.now(),
        isLoading: true,
      );
      
      if (mounted) {
        setState(() {
          _messages = [loadingMsg]; // Initialize with loading message
          _initialLoadFailed = false;
          _showErrorBanner = false;
        });
      }

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
          print("Translation failed: $e");
          if (mounted) {
            setState(() {
              _messages = []; // Clear loading message
              _initialLoadFailed = true;
              _showErrorBanner = true;
              _failedMessage = "Initial Load Failed"; // Marker
            });
          }
          return; // Exit on error
        }
      }

      // Replace loading message with actual initial AI message
      final initialMsg = Message(
        id: 'init_${DateTime.now().millisecondsSinceEpoch}', // Unique ID to force re-render
        content: initialContent,
        isUser: false, 
        timestamp: DateTime.now(),
        isAnimated: true, // Enable typewriter effect for initial message
      );
      
      history.add(initialMsg);
      
      if (mounted) {
        setState(() {
          _messages = history;
        });
        _scrollToBottom(); // Scroll to bottom after loading initial message
      }
    } else {
      // Reset animation flags for existing messages to prevent re-animation
      for (int i = 0; i < history.length; i++) {
        final msg = history[i];
        if (msg.isAnimated || msg.isLoading) {
          history[i] = Message(
            id: msg.id,
            content: msg.content,
            isUser: msg.isUser,
            timestamp: msg.timestamp,
            translation: msg.translation,
            feedback: msg.feedback,
            analysis: msg.analysis,
            isAnimated: false,
            isLoading: false,
          );
        }
      }
      if (mounted) {
        setState(() {
          _messages = history;
        });
        _scrollToBottom(); // Initial scroll
        // Additional delayed scroll to ensure all messages are fully rendered
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _scrollToBottom();
        });
      }
    }
  }

  void _retryInitialLoad() {
      _loadMessages();
  }

  final ApiService _apiService = ApiService();
  bool _isSending = false;
  bool _isOptimizing = false; // Added for AI optimization loading state
  // Error handling state
  String? _failedMessage;
  bool _showErrorBanner = false;

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    // Reset error state on new attempt
    setState(() {
      _showErrorBanner = false;
    });

    if (!RevenueCatService().canSendMessage()) {
      _showLimitDialog();
      return;
    }

    final newMessage = Message(
      id: DateTime.now().toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
      isFeedbackLoading: true, // Show loading indicator for feedback
    );

    setState(() {
      _messages.add(newMessage);
      _isSending = true;
      
      // Add temporary loading message
      _messages.add(Message(
        id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
        content: '',
        isUser: false,
        timestamp: DateTime.now(),
        isLoading: true,
      ));
    });
    
    // No need to call addMessage - _messages is the same list as in the service
    final sceneKey = "${widget.scene.title}_${widget.scene.aiRole}";

    RevenueCatService().incrementMessageCount();
    
    _textController.clear();
    _scrollToBottom();
    // Additional delayed scroll to ensure loading message is visible
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _scrollToBottom();
    });

    try {
      // Build conversation history (exclude loading messages and current message)
      final history = _messages
          .where((m) => !m.isLoading && m.content.isNotEmpty)
          .map((m) => <String, String>{
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.content,
          })
          .toList();

      final response = await _apiService.sendMessage(
        text, 
        'AI Role: ${widget.scene.aiRole}, User Role: ${widget.scene.userRole}. ${widget.scene.description}',
        history
      );
      
      if (!mounted) return;

      setState(() {
        _isSending = false;
        
        // Remove loading message
        _messages.removeWhere((m) => m.isLoading);
        
        // Update user message with feedback and remove loading state
        final userMsgIndex = _messages.indexWhere((m) => m.id == newMessage.id);
        if (userMsgIndex != -1) {
          _messages[userMsgIndex] = Message(
            id: newMessage.id,
            content: newMessage.content,
            isUser: true,
            timestamp: newMessage.timestamp,
            feedback: response.feedback,
            isFeedbackLoading: false, // Turn off loading indicator
          );
        }
        
        final aiMessage = Message(
          id: DateTime.now().toString(),
          content: response.message,
          isUser: false,
          timestamp: DateTime.now(),
          translation: response.translation,
          isAnimated: true, // Enable typewriter effect
        );

        _messages.add(aiMessage);
        // No need to call addMessage - _messages is the same list as in the service
      });
      _scrollToBottom();
      // Start continuous auto-scroll during typewriter animation
      _startAutoScroll();
      // Stop auto-scroll after animation should be complete (estimate based on content length)
      final animationDuration = (response.message.length * 30).clamp(1000, 5000);
      Future.delayed(Duration(milliseconds: animationDuration), () {
        if (mounted) {
          _stopAutoScroll();
          _scrollToBottom(); // Final scroll to ensure everything is visible
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        // Remove the failed message so user can retry
        _messages.removeWhere((m) => m.id == newMessage.id);
        
        // Remove loading message
        _messages.removeWhere((m) => m.isLoading);
        
        _isSending = false;
        _failedMessage = text;
        _showErrorBanner = true;
      });
    }
  }

  void _retryLastMessage() {
    if (_failedMessage != null) {
      _textController.text = _failedMessage!;
      _sendMessage();
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
        surfaceTintColor: Colors.transparent, // Prevent color change on scroll
        foregroundColor: Colors.black, // Icons and text color
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => SceneOptionsDrawer(
                  onClear: _showClearConfirmation,
                  onBookmark: _bookmarkConversation,
                  onDelete: _showDeleteConfirmation,
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
                    key: ValueKey(msg.id), // Force rebuild when ID changes
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
          if (_showErrorBanner) _buildErrorBanner(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    final isInitialLoadError = _initialLoadFailed;
    final errorText = isInitialLoadError 
        ? 'Network error. Failed to load conversation.'
        : 'Failed to send message';
        
    return Container(
      width: double.infinity,
      color: Colors.red.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
           Expanded(
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: isInitialLoadError ? _retryInitialLoad : _retryLastMessage,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
            ),
            child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
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
                  sceneDescription: 'AI Role: ${widget.scene.aiRole}, User Role: ${widget.scene.userRole}. ${widget.scene.description}',
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
          // AI Optimization Button
          IconButton(
            icon: _isOptimizing 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                : Icon(
                    Icons.auto_fix_high, 
                    color: _textController.text.trim().isNotEmpty 
                        ? Colors.green 
                        : Colors.grey
                  ),
            tooltip: 'Optimize with AI',
            onPressed: _textController.text.trim().isEmpty || _isOptimizing
                ? null
                : () async {
                    final text = _textController.text.trim();
                    setState(() => _isOptimizing = true);

                    try {
                      // Prepare context
                      final history = _messages
                          .where((m) => !m.isLoading && m.content.isNotEmpty)
                          .map((m) => <String, String>{
                            'role': m.isUser ? 'user' : 'assistant',
                            'content': m.content,
                          })
                          .toList();

                      final optimizedText = await _apiService.optimizeMessage(
                        text, 
                        'AI Role: ${widget.scene.aiRole}, User Role: ${widget.scene.userRole}. ${widget.scene.description}',
                        history
                      );

                      if (mounted) {
                        _textController.text = optimizedText;
                        // Optional: Show a small toast/snackbar that it was optimized?
                        showTopToast(context, "Message optimized!", isError: false);
                      }
                    } catch (e) {
                      if (mounted) {
                         showTopToast(context, "Optimization failed: $e", isError: true);
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isOptimizing = false);
                      }
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.black),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _bookmarkConversation() {
    final sceneKey = "${widget.scene.title}_${widget.scene.aiRole}";
    final nonEmptyMessages = _messages.where((m) => m.content.isNotEmpty && !m.isLoading).toList();
    
    if (nonEmptyMessages.isEmpty) {
      showTopToast(context, "No messages to bookmark", isError: true);
      return;
    }

    final lastMessage = nonEmptyMessages.last.content;
    final preview = lastMessage.length > 50 ? '${lastMessage.substring(0, 50)}...' : lastMessage;
    
    // Format date: "Today", "Yesterday", or "MM-dd"
    final now = DateTime.now();
    final dateStr = "${now.month}/${now.day}"; // Simple format for now

    ChatHistoryService().addBookmark(
      widget.scene.title, 
      preview, 
      dateStr, 
      sceneKey, 
      nonEmptyMessages
    );

    showTopToast(context, "Conversation bookmarked!", isError: false);
  }

  void _showClearConfirmation() {
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
                    ChatHistoryService().clearHistory(sceneKey);
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
  }

  void _showDeleteConfirmation() {
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
              'Delete Conversation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to delete this conversation? This will also remove it from your home screen.',
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
                    ChatHistoryService().clearHistory(sceneKey);
                    // Return 'delete' signal to previous screen
                    Navigator.pop(context, 'delete');
                  },
                  child: const Text(
                    'Delete',
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
      
      showTopToast(
        context, 
        _getFriendlyErrorMessage(e),
        isError: true,
      );
    }
  }

  String _getFriendlyErrorMessage(Object error) {
    final errorStr = error.toString();
    if (errorStr.contains('SocketException') || 
        errorStr.contains('Connection refused') ||
        errorStr.contains('Network is unreachable')) {
      return 'Network error. Please check your connection.';
    }
    if (errorStr.contains('500')) {
      return 'Server error. Please try again later.';
    }
    if (errorStr.contains('404')) {
      return 'Service not available.';
    }
    // Strip "Exception: " prefix if present for cleaner display
    if (errorStr.startsWith('Exception: ')) {
      return errorStr.substring(11);
    }
    return 'An error occurred: $errorStr';
  }
  }

