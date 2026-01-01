import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/scene.dart';
import '../models/message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/feedback_sheet.dart';
import '../widgets/analysis_sheet.dart';
import '../widgets/hints_sheet.dart';
import '../widgets/favorites_sheet.dart'; // Added
import '../services/api_service.dart';
import '../services/revenue_cat_service.dart';
import '../services/chat_history_service.dart';
import '../services/preferences_service.dart';
import '../services/auth_service.dart'; // Added // Added
import 'unified_favorites_screen.dart'; // Added for scene-specific favorites
import '../widgets/top_toast.dart';
import '../widgets/scene_options_drawer.dart';
import '../widgets/styled_drawer.dart';
import 'paywall_screen.dart';

class ChatScreen extends StatefulWidget {
  final Scene scene;

  const ChatScreen({Key? key, required this.scene}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _uuid = const Uuid();
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
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
    
    // Listen to keyboard changes and scroll to bottom when keyboard appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_handleScroll);
    });
  }
  
  double _previousKeyboardHeight = 0;
  
  void _handleScroll() {
    // This will be called on every frame, but we only care about keyboard changes
    // The actual keyboard detection happens in didChangeDependencies
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Detect keyboard height changes
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    // If keyboard is appearing (height increased from 0 or small value)
    if (keyboardHeight > _previousKeyboardHeight && keyboardHeight > 100) {
      // Only scroll if user is already near the bottom (within 100 pixels)
      if (_scrollController.hasClients) {
        final position = _scrollController.position;
        final isNearBottom = position.maxScrollExtent - position.pixels < 100;
        
        if (isNearBottom) {
          // User is at bottom, scroll to keep latest messages visible
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && _scrollController.hasClients) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
        }
        // If not near bottom, don't scroll - user is viewing history
      }
    }
    
    _previousKeyboardHeight = keyboardHeight;
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
    final sceneKey = widget.scene.id;
    final history = await ChatHistoryService().getMessagesWithSync(sceneKey);
    
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

      // Handle name substitution for placeholders like [Client's Name...]
      try {
        String displayName = widget.scene.userRole;
        final genericRoles = ['User', 'Client', 'Student', 'Me', 'You', 'Guest'];
        
        // Helper to check if role is generic (case-insensitive)
        bool isGeneric(String role) => genericRoles.any((r) => r.toLowerCase() == role.toLowerCase());
        
        if (isGeneric(displayName)) {
             final authUser = AuthService().currentUser;
             if (authUser != null && authUser.name.isNotEmpty && authUser.name != 'User' && authUser.name != 'TriTalk Explorer') {
                 displayName = authUser.name;
             }
        }
        
        // Remove "User" or generic fallback if no name found, or keep role if it's "Client" and no auth name?
        // Requirement: "If no name, use user name." If user name not available, stick to role?
        // If authUser.name is empty/generic, we might still want to replace placeholder with "User" or just remove brackets.
        // Let's stick to using displayName which is now either the specific role or the auth name.
        
        // Replace regex [.*?(Name|Client|User).*?] with displayName
        // Matches things like [Client's Name], [Client's Name - optional], [Insert Name]
        initialContent = initialContent.replaceAll(
          RegExp(r'\[.*?(?:Name|Client|User).*?\]', caseSensitive: false), 
          displayName
        );
      } catch (e) {
        print("Error substituting name: $e");
      }
      
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
      
      if (mounted) {
        setState(() {
          _messages = [...history, initialMsg];
        });
        
        // Sync entire message list to cloud
        ChatHistoryService().syncMessages(sceneKey, _messages);
        
        _jumpToBottom(); // Jump to bottom after loading initial message
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
        _jumpToBottom(); // Initial jump
        // Additional delayed jump to ensure all messages are fully rendered
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _jumpToBottom();
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
  bool _isTimeoutError = false; // Track if error was due to timeout

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    // Reset error state on new attempt
    setState(() {
      _showErrorBanner = false;
      _isTimeoutError = false;
    });

    if (!RevenueCatService().canSendMessage()) {
      _showLimitDialog();
      return;
    }

    final newMessage = Message(
      id: _uuid.v4(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
      isFeedbackLoading: true, // Show loading indicator for feedback
    );

    final sceneKey = widget.scene.id;
    
    setState(() {
      _messages.add(newMessage);
      _isSending = true;
    });
    
    // Sync entire message list to cloud (don't await to not block UI)
    ChatHistoryService().syncMessages(sceneKey, _messages);
    
    RevenueCatService().incrementMessageCount();
    
    _textController.clear();
    _scrollToBottom();

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
      ).timeout(const Duration(seconds: 30));
      
      if (!mounted) return;

      // 1. Update user message with feedback (Turns it Yellow)
      final userMsgIndex = _messages.indexWhere((m) => m.id == newMessage.id);
      if (userMsgIndex != -1) {
        final updatedMessage = Message(
          id: newMessage.id,
          content: newMessage.content,
          isUser: true,
          timestamp: newMessage.timestamp,
          feedback: response.feedback,
          isFeedbackLoading: false,
        );
        
        setState(() {
          _messages[userMsgIndex] = updatedMessage;
          
          // 2. Add loading message for AI response NOW (after feedback)
          _messages.add(Message(
            id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
            content: '',
            isUser: false,
            timestamp: DateTime.now(),
            isLoading: true,
          ));
        });
        
        // Sync entire message list to cloud
        ChatHistoryService().syncMessages(sceneKey, _messages);
      }
      
      _scrollToBottom();
      
      // 3. Simulated "thinking" delay for AI (1.5 seconds)
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (!mounted) return;

      setState(() {
        _isSending = false;
        
        // Remove loading message
        _messages.removeWhere((m) => m.isLoading);
        
        final aiMessage = Message(
          id: _uuid.v4(),
          content: response.message,
          isUser: false,
          timestamp: DateTime.now(),
          translation: response.translation,
          isAnimated: true, // Enable typewriter effect
        );

        _messages.add(aiMessage);
      });
      
      // Sync entire message list to cloud
      ChatHistoryService().syncMessages(sceneKey, _messages);
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
    } on TimeoutException catch (_) {
      // Handle timeout specifically
      if (!mounted) return;
      setState(() {
        // Remove the failed message so user can retry
        _messages.removeWhere((m) => m.id == newMessage.id);
        
        // Remove loading message if it was added
        _messages.removeWhere((m) => m.isLoading);
        
        _isSending = false;
        _failedMessage = text;
        _showErrorBanner = true;
        _isTimeoutError = true;
      });
    } catch (e) {
      // Handle other errors
      if (!mounted) return;
      setState(() {
        // Remove the failed message so user can retry
        _messages.removeWhere((m) => m.id == newMessage.id);
        
        // Remove loading message if it was added
        _messages.removeWhere((m) => m.isLoading);
        
        _isSending = false;
        _failedMessage = text;
        _showErrorBanner = true;
        _isTimeoutError = false;
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
        leadingWidth: 64, // Added width for custom leading
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF1A1A1A),
                size: 24,
              ),
            ),
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    widget.scene.title,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<SyncStatus>(
                  valueListenable: ChatHistoryService().syncStatus,
                  builder: (context, status, child) {
                    switch (status) {
                      case SyncStatus.syncing:
                        return const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                        );
                      case SyncStatus.synced:
                        return const Icon(Icons.circle, color: Color(0xFF34C759), size: 12);
                      case SyncStatus.offline:
                        return Icon(Icons.circle_outlined, color: Colors.grey[400], size: 16);
                    }
                  },
                ),
                const SizedBox(width: 16),
              ],
            ),
            Text(
              'Talking to ${widget.scene.aiRole}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent, 
        foregroundColor: Colors.black,
        elevation: 0, 
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.white.withOpacity(0.5),
                  builder: (context) => SceneOptionsDrawer(
                    onClear: _showClearConfirmation,
                    onBookmark: _bookmarkConversation,
                    onDelete: _showDeleteConfirmation,
                    onShowFavorites: _showFavorites, // Added
                  ),
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xFF1A1A1A),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),

      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping empty space
          FocusScope.of(context).unfocus();
        },
        child: Column(
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
                      key: ValueKey(msg.id),
                      message: msg,
                      sceneId: widget.scene.id, // Pass sceneId
                      onTap: () {
                        if (msg.feedback != null) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            barrierColor: Colors.white.withOpacity(0.5),
                            builder: (context) => FeedbackSheet(
                              message: msg,
                              sceneId: widget.scene.id, // Pass sceneId
                            ),
                          );
                        } else if (!msg.isUser) {
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
      ),
    );
  }

  void _showFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnifiedFavoritesScreen(
          sceneId: widget.scene.id, // Pass the current sceneId for filtering
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    final isInitialLoadError = _initialLoadFailed;
    String errorText;
    
    if (isInitialLoadError) {
      errorText = 'Network error. Failed to load conversation.';
    } else if (_isTimeoutError) {
      errorText = 'Request timed out. Please check your connection.';
    } else {
      errorText = 'Failed to send message. Please try again.';
    }
        
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
              style: const TextStyle(color: Colors.red, fontSize: 14),
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
            icon: const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber),
            onPressed: () {
              final history = _messages.map((m) => <String, String>{
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.content,
              }).toList();

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                barrierColor: Colors.white.withOpacity(0.5),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        isDense: true,
                      ),
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  // AI Optimization Button inside input container
                  IconButton(
                    iconSize: 20,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 40),
                    padding: EdgeInsets.zero,
                    icon: _isOptimizing 
                        ? const SizedBox(
                            width: 16, 
                            height: 16, 
                            child: CircularProgressIndicator(strokeWidth: 2)
                          )
                        : Icon(
                            Icons.auto_fix_high, 
                            color: _textController.text.trim().isNotEmpty 
                                ? Colors.green 
                                : Colors.grey[400]
                          ),
                    tooltip: 'Optimize with AI',
                    onPressed: _textController.text.trim().isEmpty || _isOptimizing
                        ? null
                        : () async {
                            final text = _textController.text.trim();
                            setState(() => _isOptimizing = true);

                            try {
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
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _bookmarkConversation() {
    final sceneKey = widget.scene.id;
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
      barrierColor: Colors.white.withOpacity(0.5),
      builder: (context) => StyledDrawer(
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
                  onPressed: () async {
                    final sceneKey = widget.scene.id;
                    await ChatHistoryService().clearHistory(sceneKey);
                    if (mounted) {
                      _loadMessages();
                      showTopToast(context, 'Conversation cleared', isError: false);
                      Navigator.pop(context);
                    }
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
      barrierColor: Colors.white.withOpacity(0.5),
      builder: (context) => StyledDrawer(
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
                    final sceneKey = widget.scene.id;
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

  void _handleAnalyze(Message message) {
    // If analysis already exists, show it directly
    if (message.analysis != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.white.withOpacity(0.5),
        builder: (context) => AnalysisSheet(
          message: message,
          analysis: message.analysis,
          sceneId: widget.scene.id,
        ),
      );
      return;
    }

    // Create stream
    // Note: We don't await the stream here; we pass it to the sheet.
    final stream = _apiService.analyzeMessage(message.content);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // isDismissible: false, // Allow dismissal during streaming to cancel
      backgroundColor: Colors.transparent,
      barrierColor: Colors.white.withOpacity(0.5),
      builder: (context) => AnalysisSheet(
        message: message,
        isLoading: true,
        sceneId: widget.scene.id,
        analysisStream: stream,
        onAnalysisComplete: (finalAnalysis) {
           _updateMessageAnalysis(message.id, finalAnalysis);
        },
      ),
    );
  }

  void _updateMessageAnalysis(String messageId, MessageAnalysis analysis) {
      if (!mounted) return;

      // Update message with analysis
      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        final currentMessage = _messages[messageIndex];
        final updatedMessage = Message(
          id: currentMessage.id,
          content: currentMessage.content,
          isUser: currentMessage.isUser,
          timestamp: currentMessage.timestamp,
          translation: currentMessage.translation,
          feedback: currentMessage.feedback,
          analysis: analysis,
        );
        
        setState(() {
          _messages[messageIndex] = updatedMessage;
        });

        // Save analysis result to local and cloud storage
        final sceneKey = widget.scene.id;
        ChatHistoryService().syncMessages(sceneKey, _messages);
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

