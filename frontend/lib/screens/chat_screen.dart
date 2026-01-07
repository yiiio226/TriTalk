import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/scene.dart';
import '../models/message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/feedback_sheet.dart';
import '../widgets/analysis_sheet.dart';
import '../widgets/hints_sheet.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart'; // Added for TTS
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

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
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
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
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
    
    // Initialize pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2800), // Slower wave
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
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
              _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent,
              );
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
    _recordingTimer?.cancel();
    _pulseController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _audioService.stop(); // Stop any playing audio
    super.dispose();
  }

  // Voice input methods
  Future<void> _startVoiceRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/voice_input_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(const RecordConfig(), path: path);
        
        setState(() {
          _isRecordingVoice = true;
        });
        
        // Start pulsing animation
        _pulseController.repeat();
        
        // Start timer for potential future use
        _currentRecordingDuration = 0;
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _currentRecordingDuration++;
          });
        });
      } else {
        // Request permission
        final status = await Permission.microphone.request();
        if (status.isGranted) {
          _startVoiceRecording();
        } else {
          if (mounted) {
            showTopToast(context, '需要麦克风权限才能录音', isError: true);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showTopToast(context, '无法开始录音: $e', isError: true);
        setState(() {
          _isRecordingVoice = false;
        });
      }
    }
  }

  Future<void> _stopVoiceRecording({bool convertToText = false, bool sendDirectly = false}) async {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    
    // Stop pulsing animation
    _pulseController.stop();
    _pulseController.reset();
    
    try {
      final path = await _audioRecorder.stop();
      
      setState(() {
        _isRecordingVoice = false;
      });
      
      if (path == null) {
        return;
      }
      
      if (sendDirectly) {
        await _sendVoiceMessage(path, _currentRecordingDuration);
      } else if (convertToText) {
        // Transcribe the audio to text
        await _transcribeAudio(path);
      }
    } catch (e) {
      if (mounted) {
        showTopToast(context, '录音失败: $e', isError: true);
        setState(() {
          _isRecordingVoice = false;
        });
      }
    }
  }

  Future<void> _transcribeAudio(String audioPath) async {
    try {
      final transcribedText = await _apiService.transcribeAudio(audioPath);
      
      if (mounted && transcribedText.isNotEmpty) {
        setState(() {
          _textController.text = transcribedText;
        });
      } else {
        if (mounted) {
          showTopToast(context, '无法识别语音内容', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        showTopToast(context, '语音转文字失败: $e', isError: true);
      }
    }
  }

  Future<void> _sendVoiceMessage(String audioPath, int duration) async {
    // Generate IDs
    final userMessageId = _uuid.v4();
    final aiMessageId = _uuid.v4();
    
    // Add user voice message immediately (optimistic UI)
    final userMessage = Message(
      id: userMessageId,
      content: '', // Voice connection doesn't necessarily have text content immediately
      isUser: true,
      timestamp: DateTime.now(),
      audioPath: audioPath,
      audioDuration: duration,
      isFeedbackLoading: true,
    );
    
    setState(() {
      _messages.add(userMessage);
      _isRecordingVoice = false;
    });

    // Save initial state (user message + loading)
    ChatHistoryService().syncMessages(widget.scene.id, _messages);
    
    _scrollToBottom();
    
    try {
      // Prepare history
      final history = _messages
          .where((m) => !m.isLoading && m.id != userMessageId && m.content.isNotEmpty)
          .map((m) => <String, String>{
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.content,
          })
          .toList();
          
      // Ensure we have correct role info
      final sceneContext = 'AI Role: ${widget.scene.aiRole}, User Role: ${widget.scene.userRole}. ${widget.scene.description}';
      
      // Call API
      final response = await _apiService.sendVoiceMessage(
        audioPath, 
        sceneContext, 
        history
      );
      
      // Update UI with response
      setState(() {
        // Update user message with feedback if available (and maybe transcribed text if provided)
        final index = _messages.indexWhere((m) => m.id == userMessageId);
        if (index != -1) {
          _messages[index] = Message(
            id: userMessage.id,
            content: '', // Keep empty or use transcribed text if API returns it in future
            isUser: true,
            timestamp: userMessage.timestamp,
            audioPath: audioPath,
            audioDuration: userMessage.audioDuration, // Keep placeholder or update
            voiceFeedback: response.voiceFeedback,
            feedback: response.reviewFeedback,
            isFeedbackLoading: false,
          );
        }
        
        // Add real AI message
        final aiMessage = Message(
          id: aiMessageId,
          content: response.message,
          isUser: false,
          timestamp: DateTime.now(),
          translation: response.translation,
          isAnimated: true,
        );
        _messages.add(aiMessage);
      });

      // Save final state (AI response + feedback)
      ChatHistoryService().syncMessages(widget.scene.id, _messages);
      
      _scrollToBottom();
      
    } catch (e) {
      if (mounted) {
        showTopToast(context, 'Failed to send voice message: $e', isError: true);
        setState(() {
           // Optionally mark user message as failed
           final index = _messages.indexWhere((m) => m.id == userMessageId);
           if (index != -1) {
             _messages[index] = Message(
               id: userMessage.id,
               content: userMessage.content,
               isUser: true,
               timestamp: userMessage.timestamp,
               audioPath: userMessage.audioPath,
               audioDuration: userMessage.audioDuration,
               isFeedbackLoading: false, // Stop loading
               // Error state could be handled here
             );
           }
        });
      }
    }
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
        final genericRoles = [
          'User',
          'Client',
          'Student',
          'Me',
          'You',
          'Guest',
        ];

        // Helper to check if role is generic (case-insensitive)
        bool isGeneric(String role) =>
            genericRoles.any((r) => r.toLowerCase() == role.toLowerCase());

        if (isGeneric(displayName)) {
          final authUser = AuthService().currentUser;
          if (authUser != null &&
              authUser.name.isNotEmpty &&
              authUser.name != 'User' &&
              authUser.name != 'TriTalk Explorer') {
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
          displayName,
        );
      } catch (e) {
        print("Error substituting name: $e");
      }

      // If target language is not English, translate the initial message
      if (targetLang != 'English') {
        try {
          initialContent = await _apiService.translateText(
            widget.scene.initialMessage,
            targetLang,
          );
        } catch (e) {
          print("Translation failed: $e");
          if (mounted) {
            setState(() {
              _messages = []; // Clear loading message
              _initialLoadFailed = true;
              _showErrorBanner = true;
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
      // Check for pending error messages and restore error banner
      bool hasFailedMessage = false;
      for (int i = 0; i < history.length; i++) {
        final msg = history[i];
        if (msg.hasPendingError) {
          hasFailedMessage = true;
        }
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
            hints: msg.hints,
            hasPendingError: msg.hasPendingError,
          );
        }
      }
      if (mounted) {
        setState(() {
          _messages = history;
          
          // Restore error banner if there's a failed message
          if (hasFailedMessage) {
            _showErrorBanner = true;
          }
          
          // Restore hints from the last message if available
          if (_messages.isNotEmpty && _messages.last.hints != null) {
            _cachedHints = _messages.last.hints;
            _hintsMessageCount = _messages.length;
          }
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
      // Invalidate hints cache when conversation changes
      _cachedHints = null;
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
          .map(
            (m) => <String, String>{
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.content,
            },
          )
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
          _messages.add(
            Message(
              id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
              content: '',
              isUser: false,
              timestamp: DateTime.now(),
              isLoading: true,
            ),
          );
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
      final animationDuration = (response.message.length * 30).clamp(
        1000,
        5000,
      );
      Future.delayed(Duration(milliseconds: animationDuration), () {
        if (mounted) {
          _stopAutoScroll();
          _scrollToBottom(); // Final scroll to ensure everything is visible
        }
      });
    } on TimeoutException catch (_) {
      // Handle timeout specifically
      if (!mounted) return;

      // Find and update the user message to stop loading
      final userMsgIndex = _messages.indexWhere((m) => m.id == newMessage.id);
      if (userMsgIndex != -1) {
        final updatedMessage = Message(
          id: newMessage.id,
          content: newMessage.content,
          isUser: true,
          timestamp: newMessage.timestamp,
          isFeedbackLoading: false, // Stop loading indicator
        );
        
        setState(() {
          _messages[userMsgIndex] = updatedMessage;
          
          // Remove any loading AI messages
          _messages.removeWhere((m) => m.isLoading);

          _isSending = false;
          _showErrorBanner = true;
          _isTimeoutError = true;
        });
        
        // Sync updated state to cloud
        ChatHistoryService().syncMessages(sceneKey, _messages);
      }
    } catch (e) {
      // Handle other errors
      if (!mounted) return;

      // Find and update the user message to stop loading
      final userMsgIndex = _messages.indexWhere((m) => m.id == newMessage.id);
      if (userMsgIndex != -1) {
        final updatedMessage = Message(
          id: newMessage.id,
          content: newMessage.content,
          isUser: true,
          timestamp: newMessage.timestamp,
          isFeedbackLoading: false, // Stop loading indicator
        );
        
        setState(() {
          _messages[userMsgIndex] = updatedMessage;
          
          // Remove any loading AI messages
          _messages.removeWhere((m) => m.isLoading);

          _isSending = false;
          _showErrorBanner = true;
          _isTimeoutError = false;
        });
        
        // Sync updated state to cloud
        ChatHistoryService().syncMessages(sceneKey, _messages);
      }
    }
  }

  void _retryLastMessage() {
    // Find the message with hasPendingError
    final failedMsgIndex = _messages.indexWhere((m) => m.hasPendingError);
    if (failedMsgIndex == -1) return;
    
    final failedMsg = _messages[failedMsgIndex];
    final sceneKey = widget.scene.id;
    
    // Reset error state on UI
    setState(() {
      _showErrorBanner = false;
      _isTimeoutError = false;
      _isSending = true;
      
      // Update message to show loading state
      _messages[failedMsgIndex] = Message(
        id: failedMsg.id,
        content: failedMsg.content,
        isUser: true,
        timestamp: failedMsg.timestamp,
        isFeedbackLoading: true,
        hasPendingError: false, // Clear error state
      );
    });
    
    // Resend the message
    _resendMessage(failedMsg, failedMsgIndex, sceneKey);
  }
  
  Future<void> _resendMessage(Message originalMsg, int msgIndex, String sceneKey) async {
    try {
      final history = _messages
          .where((m) => !m.isLoading && m.content.isNotEmpty)
          .map((m) => <String, String>{
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.content,
          })
          .toList();

      final response = await _apiService.sendMessage(
        originalMsg.content, 
        'AI Role: ${widget.scene.aiRole}, User Role: ${widget.scene.userRole}. ${widget.scene.description}',
        history
      ).timeout(const Duration(seconds: 10));
      
      if (!mounted) return;

      // Update user message with feedback
      final updatedMessage = Message(
        id: originalMsg.id,
        content: originalMsg.content,
        isUser: true,
        timestamp: originalMsg.timestamp,
        feedback: response.feedback,
        isFeedbackLoading: false,
        hasPendingError: false,
      );
      
      setState(() {
        _messages[msgIndex] = updatedMessage;
        
        // Add loading message for AI response
        _messages.add(Message(
          id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
          content: '',
          isUser: false,
          timestamp: DateTime.now(),
          isLoading: true,
        ));
      });
      
      ChatHistoryService().syncMessages(sceneKey, _messages);
      _scrollToBottom();
      
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (!mounted) return;

      setState(() {
        _isSending = false;
        _messages.removeWhere((m) => m.isLoading);
        
        final aiMessage = Message(
          id: _uuid.v4(),
          content: response.message,
          isUser: false,
          timestamp: DateTime.now(),
          translation: response.translation,
          isAnimated: true,
        );

        _messages.add(aiMessage);
      });
      
      ChatHistoryService().syncMessages(sceneKey, _messages);
      _scrollToBottom();
      _startAutoScroll();
      final animationDuration = (response.message.length * 30).clamp(1000, 5000);
      Future.delayed(Duration(milliseconds: animationDuration), () {
        if (mounted) {
          _stopAutoScroll();
          _scrollToBottom();
        }
      });
    } on TimeoutException catch (_) {
      if (!mounted) return;
      
      final failedMessage = Message(
        id: originalMsg.id,
        content: originalMsg.content,
        isUser: true,
        timestamp: originalMsg.timestamp,
        isFeedbackLoading: false,
        hasPendingError: true,
      );
      
      setState(() {
        _messages[msgIndex] = failedMessage;
        _messages.removeWhere((m) => m.isLoading);
        _isSending = false;
        _showErrorBanner = true;
        _isTimeoutError = true;
      });
      
      ChatHistoryService().syncMessages(sceneKey, _messages);
    } catch (e) {
      if (!mounted) return;
      
      final failedMessage = Message(
        id: originalMsg.id,
        content: originalMsg.content,
        isUser: true,
        timestamp: originalMsg.timestamp,
        isFeedbackLoading: false,
        hasPendingError: true,
      );
      
      setState(() {
        _messages[msgIndex] = failedMessage;
        _messages.removeWhere((m) => m.isLoading);
        _isSending = false;
        _showErrorBanner = true;
        _isTimeoutError = false;
      });
      
      ChatHistoryService().syncMessages(sceneKey, _messages);
    }
  }
  
  // Multi-select mode methods
  void _enterMultiSelectMode(String messageId) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedMessageIds.clear();
      _selectedMessageIds.add(messageId);
      
      // Update message selection state
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = Message(
          id: _messages[index].id,
          content: _messages[index].content,
          isUser: _messages[index].isUser,
          timestamp: _messages[index].timestamp,
          translation: _messages[index].translation,
          feedback: _messages[index].feedback,
          analysis: _messages[index].analysis,
          isLoading: _messages[index].isLoading,
          isAnimated: _messages[index].isAnimated,
          isFeedbackLoading: _messages[index].isFeedbackLoading,
          hints: _messages[index].hints,
          hasPendingError: _messages[index].hasPendingError,
          isSelected: true,
          audioPath: _messages[index].audioPath,
          audioDuration: _messages[index].audioDuration,
          voiceFeedback: _messages[index].voiceFeedback,
        );
      }
    });
  }
  
  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      
      // Clear all selections
      for (int i = 0; i < _messages.length; i++) {
        if (_messages[i].isSelected) {
          _messages[i] = Message(
            id: _messages[i].id,
            content: _messages[i].content,
            isUser: _messages[i].isUser,
            timestamp: _messages[i].timestamp,
            translation: _messages[i].translation,
            feedback: _messages[i].feedback,
            analysis: _messages[i].analysis,
            isLoading: _messages[i].isLoading,
            isAnimated: _messages[i].isAnimated,
            isFeedbackLoading: _messages[i].isFeedbackLoading,
            hints: _messages[i].hints,
            hasPendingError: _messages[i].hasPendingError,
            isSelected: false,
            audioPath: _messages[i].audioPath,
            audioDuration: _messages[i].audioDuration,
            voiceFeedback: _messages[i].voiceFeedback,
          );
        }
      }
      
      _selectedMessageIds.clear();
    });
  }
  
  void _toggleMessageSelection(String messageId) {
    setState(() {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index == -1) return;
      
      final isCurrentlySelected = _selectedMessageIds.contains(messageId);
      
      if (isCurrentlySelected) {
        _selectedMessageIds.remove(messageId);
      } else {
        _selectedMessageIds.add(messageId);
      }
      
      // Update message selection state
      _messages[index] = Message(
        id: _messages[index].id,
        content: _messages[index].content,
        isUser: _messages[index].isUser,
        timestamp: _messages[index].timestamp,
        translation: _messages[index].translation,
        feedback: _messages[index].feedback,
        analysis: _messages[index].analysis,
        isLoading: _messages[index].isLoading,
        isAnimated: _messages[index].isAnimated,
        isFeedbackLoading: _messages[index].isFeedbackLoading,
        hints: _messages[index].hints,
        hasPendingError: _messages[index].hasPendingError,
        isSelected: !isCurrentlySelected,
        audioPath: _messages[index].audioPath,
        audioDuration: _messages[index].audioDuration,
        voiceFeedback: _messages[index].voiceFeedback,
      );
      
      // Exit multi-select mode if no messages are selected
      if (_selectedMessageIds.isEmpty) {
        _exitMultiSelectMode();
      }
    });
  }
  
  Future<void> _deleteSelectedMessages() async {
    if (_selectedMessageIds.isEmpty) return;
    
    // Show confirmation dialog
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.white.withOpacity(0.5),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Delete ${_selectedMessageIds.length} message${_selectedMessageIds.length > 1 ? 's' : ''}?',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    
    if (confirmed != true) return;
    
    // Delete messages
    final messageIdsToDelete = List<String>.from(_selectedMessageIds);
    final sceneKey = widget.scene.id;
    
    setState(() {
      // Remove messages from local list
      _messages.removeWhere((m) => messageIdsToDelete.contains(m.id));
      _exitMultiSelectMode();
    });
    
    // Delete from cloud
    try {
      await ChatHistoryService().deleteMessages(sceneKey, messageIdsToDelete);
      if (mounted) {
        showTopToast(context, 'Deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete messages: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 64, // Added width for custom leading
        leading: Center(
          child: GestureDetector(
            onTap: () {
              if (_isMultiSelectMode) {
                _exitMultiSelectMode();
              } else {
                Navigator.pop(context);
              }
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey,
                            ),
                          ),
                        );
                      case SyncStatus.synced:
                        return const Icon(
                          Icons.circle,
                          color: Color(0xFF34C759),
                          size: 12,
                        );
                      case SyncStatus.offline:
                        return Icon(
                          Icons.circle_outlined,
                          color: Colors.grey[400],
                          size: 16,
                        );
                    }
                  },
                ),
                const SizedBox(width: 16),
              ],
            ),
            Text(
              'Talking to ${widget.scene.aiRole}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
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
            if (_isMultiSelectMode) _buildMultiSelectActionBar(),
            if (!_isMultiSelectMode) _buildInputArea(),
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

  /// Handle TTS speaker button tap
  Future<void> _handleSpeaker(Message message) async {
    // If currently playing this message, stop
    if (_currentlyPlayingMessageId == message.id) {
      await _audioService.stop();
      if (mounted) {
        setState(() {
          _currentlyPlayingMessageId = null;
        });
      }
      return;
    }

    // Stop any other playing audio
    await _audioService.stop();

    // Update state to show loading/playing
    if (mounted) {
      setState(() {
        _currentlyPlayingMessageId = message.id;
      });
    }

    try {
      // Check if audio is already cached locally
      final isCached = await _audioService.isAudioCached(message.id);

      String audioUrl;

      if (isCached) {
        // Use empty URL since we have local cache
        audioUrl = '';
      } else {
        // Request TTS from backend
        final ttsResponse = await _apiService.generateTTS(
          messageId: message.id,
          text: message.content,
        );
        audioUrl = ttsResponse.audioUrl;
      }

      // Play the audio
      final success = await _audioService.playAudio(
        messageId: message.id,
        audioUrl: audioUrl,
      );

      if (!success && mounted) {
        showTopToast(context, 'Failed to play audio', isError: true);
        setState(() {
          _currentlyPlayingMessageId = null;
        });
      }

      // Listen for playback completion to update state
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _audioService.currentlyPlayingMessageId != message.id) {
          setState(() {
            _currentlyPlayingMessageId = null;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        showTopToast(context, 'TTS error: $e', isError: true);
        setState(() {
          _currentlyPlayingMessageId = null;
        });
      }
    }
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
            onPressed: isInitialLoadError
                ? _retryInitialLoad
                : _retryLastMessage,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectActionBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Selected count
            Expanded(
              child: Text(
                '${_selectedMessageIds.length} selected',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Delete button
            ElevatedButton.icon(
              onPressed: _deleteSelectedMessages,
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Cancel button
            OutlinedButton(
              onPressed: _exitMultiSelectMode,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
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
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                    icon: _isOptimizing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
    final nonEmptyMessages = _messages
        .where((m) => m.content.isNotEmpty && !m.isLoading)
        .toList();

    if (nonEmptyMessages.isEmpty) {
      showTopToast(context, "No messages to bookmark", isError: true);
      return;
    }

    final lastMessage = nonEmptyMessages.last.content;
    final preview = lastMessage.length > 50
        ? '${lastMessage.substring(0, 50)}...'
        : lastMessage;

    // Format date: "Today", "Yesterday", or "MM-dd"
    final now = DateTime.now();
    final dateStr = "${now.month}/${now.day}"; // Simple format for now

    ChatHistoryService().addBookmark(
      widget.scene.title,
      preview,
      dateStr,
      sceneKey,
      nonEmptyMessages,
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () async {
                    final sceneKey = widget.scene.id;
                    await ChatHistoryService().clearHistory(sceneKey);
                    if (mounted) {
                      _loadMessages();
                      showTopToast(
                        context,
                        'Conversation cleared',
                        isError: false,
                      );
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
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

  void _showFeedbackSheet(Message message) {
     if (message.feedback == null) return;
     
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.white.withOpacity(0.5),
        builder: (context) => FeedbackSheet(
          message: message,
          sceneId: widget.scene.id,
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
