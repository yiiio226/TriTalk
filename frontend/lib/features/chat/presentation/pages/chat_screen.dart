import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:frontend/features/scenes/domain/models/scene.dart';
import 'package:frontend/features/chat/domain/models/message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/feedback_sheet.dart';
import '../../../study/presentation/widgets/analysis_sheet.dart';
import '../widgets/hints_sheet.dart';
import '../widgets/message_skeleton_loader.dart';
import '../../../../core/data/api/api_service.dart';
import '../../data/chat_history_service.dart';

import 'package:frontend/core/design/app_design_system.dart';
import '../../../profile/presentation/pages/favorites_screen.dart';
import 'package:frontend/core/widgets/top_toast.dart';
import '../../../scenes/presentation/widgets/scene_options_drawer.dart';
import 'package:frontend/core/widgets/styled_drawer.dart';

import '../../chat.dart'; // Import feature barrel file

class ChatScreen extends ConsumerStatefulWidget {
  final Scene scene;

  const ChatScreen({super.key, required this.scene});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  Timer? _autoScrollTimer; // Timer for continuous scrolling during animation

  // Voice input state
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _recordingTimer;

  // Animation controller for pulsing microphone
  late AnimationController _pulseController;

  // Audio playback state
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ValueNotifier for text input state (triggers rebuild when text changes)
  final ValueNotifier<bool> _hasTextNotifier = ValueNotifier(false);

  // Getter for notifier (read-only access)
  ChatPageNotifier get _notifier =>
      ref.read(chatPageNotifierProvider(widget.scene).notifier);

  // Getters for state access in methods outside build() - use ref.read for non-reactive access
  ChatPageState get _state => ref.read(chatPageNotifierProvider(widget.scene));
  List<Message> get _messages => _state.messages;
  bool get _isMultiSelectMode => _state.isMultiSelectMode;
  Set<String> get _selectedMessageIds => _state.selectedMessageIds;
  List<String>? get _cachedHints => _state.cachedHints;
  int get _currentRecordingDuration => _state.recordingDuration;
  bool get _isRecordingVoice => _state.isRecording;
  bool get _isOptimizing => _state.isOptimizing;
  int get _hintsMessageCount => _messages.length;

  // Error state getters
  bool get _showErrorBanner => _state.showErrorBanner || _state.error != null;
  bool get _initialLoadFailed => _messages.isEmpty && _state.error != null;
  bool get _isTimeoutError => _state.error?.contains('timed out') ?? false;

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

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2800), // Slower wave
      vsync: this,
    );

    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifier.loadMessages();
      
      // Listen for when messages are loaded and scroll to bottom
      ref.listenManual(
        chatPageNotifierProvider(widget.scene),
        (previous, next) {
          // Scroll to bottom when messages are first loaded or when new messages arrive
          if (next.messages.isNotEmpty && !next.isLoading) {
            // Check if this is the initial load (previous was loading or had no messages)
            final isInitialLoad = previous == null || 
                                  previous.isLoading || 
                                  previous.messages.isEmpty;
            
            if (isInitialLoad) {
              // Scroll to bottom after messages are rendered
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(
                    _scrollController.position.maxScrollExtent,
                  );
                }
              });
            }
          }
        },
      );
    });

    // Listen to text changes via ValueNotifier (no setState needed)
    _textController.addListener(() {
      _hasTextNotifier.value = _textController.text.trim().isNotEmpty;
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
    _hasTextNotifier.dispose();
    super.dispose();
  }

  void _startVoiceRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

    // Use WAV format with PCM encoding - required by Azure Speech API
    // Azure Pronunciation Assessment only supports: WAV (PCM) or OGG (Opus)
    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000, // 16kHz optimal for speech recognition
        numChannels: 1, // Mono audio
      ),
      path: path,
    );

    _notifier.setRecording(true);
    _startRecordingTimer();

    // Start waveform animation
    _pulseController.repeat();
  }

  void _startRecordingTimer() {
    _notifier.updateRecordingDuration(0);
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final state = ref.read(chatPageNotifierProvider(widget.scene));
      _notifier.updateRecordingDuration(state.recordingDuration + 1);
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _notifier.updateRecordingDuration(0);
  }

  /// Enhanced voice recording stop with options from main branch
  /// - convertToText: Transcribe audio to text and put in text field
  /// - sendDirectly: Send as voice message directly
  Future<void> _stopVoiceRecordingWithOptions({
    bool convertToText = false,
    bool sendDirectly = false,
  }) async {
    // Capture duration BEFORE stopping timer (which resets it to 0)
    final capturedDuration = _currentRecordingDuration;
    
    _stopRecordingTimer();

    // Stop pulsing animation
    _pulseController.stop();
    _pulseController.reset();

    try {
      final path = await _audioRecorder.stop();
      _notifier.setRecording(false);

      if (path == null) {
        return;
      }

      if (sendDirectly) {
        _notifier.sendVoiceMessage(path, capturedDuration);
        _scrollToBottom();
      } else if (convertToText) {
        await _transcribeAudio(path);
      }
    } catch (e) {
      if (mounted) {
        showTopToast(context, '录音失败: $e', isError: true);
        _notifier.setRecording(false);
      }
    }
  }

  /// Transcribe audio to text and populate the text input field
  /// Note: This stays in the widget because it interacts with _textController
  Future<void> _transcribeAudio(String audioPath) async {
    _notifier.setTranscribing(true);

    try {
      // Check if the audio file exists and has content
      final file = File(audioPath);
      if (!await file.exists()) {
        throw Exception('Audio file does not exist at path: $audioPath');
      }

      final fileSize = await file.length();

      // iOS Simulator doesn't have real microphone - file will be empty or very small
      if (fileSize < 1000) {
        if (mounted) {
          _notifier.setTranscribing(false);
          showTopToast(
            context,
            'Recording too short or empty (${fileSize}B). Try on a real device.',
            isError: true,
          );
        }
        return;
      }

      final transcription = await _apiService.transcribeAudio(audioPath);

      if (mounted &&
          (transcription.rawText.isNotEmpty || transcription.text.isNotEmpty)) {
        setState(() {
          _textController.text = transcription.rawText.isNotEmpty
              ? transcription.rawText
              : transcription.text;
        });
        _notifier.setTranscribing(false);
        showTopToast(context, 'Voice transcribed & optimized', isError: false);
      } else {
        if (mounted) {
          _notifier.setTranscribing(false);
          showTopToast(context, 'Could not recognize speech', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _notifier.setTranscribing(false);
        showTopToast(context, 'Speech-to-text failed: $e', isError: true);
      }
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    _notifier.sendMessage(text);
    _scrollToBottom();
  }

  void _retryLastMessage() {
    final failedMsg = _messages.cast<Message?>().firstWhere(
      (m) => m?.hasPendingError == true,
      orElse: () => null,
    );

    if (failedMsg != null) {
      _notifier.retryMessage(failedMsg);
    }
  }

  // _resendMessage removed/replaced by notifier logic

  // Multi-select mode methods
  void _enterMultiSelectMode(String messageId) {
    _notifier.toggleMultiSelectMode(messageId);
  }

  void _toggleMessageSelection(String messageId) {
    _notifier.toggleMultiSelectMode(messageId);
  }

  void _exitMultiSelectMode() {
    _notifier.exitMultiSelectMode();
  }

  Future<void> _deleteSelectedMessages() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除消息'),
        content: Text('确定要删除选中的 ${_selectedMessageIds.length} 条消息吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _notifier.deleteSelectedMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the state for reactive updates - this triggers rebuilds when state changes
    // We call ref.watch to subscribe to state changes even though we use getters for access
    ref.watch(chatPageNotifierProvider(widget.scene));

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
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.lightTextPrimary,
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
                  barrierColor: Colors.white.withValues(alpha: 0.5),
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
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.lightTextPrimary,
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
              child: (_messages.isEmpty && _state.isLoading)
                  ? const MessageSkeletonLoader()
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      itemCount: _messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return GestureDetector(
                          behavior: HitTestBehavior
                              .opaque, // Make entire area tappable
                          onTap: _isMultiSelectMode
                              ? () => _toggleMessageSelection(msg.id)
                              : null,
                          onLongPress: () => _enterMultiSelectMode(msg.id),
                          child: Align(
                            alignment: msg.isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: ChatBubble(
                              key: ValueKey(msg.id),
                              message: msg,
                              sceneId: widget.scene.id, // Pass sceneId
                              isMultiSelectMode: _isMultiSelectMode,
                              onLongPress:
                                  null, // Handled by outer GestureDetector
                              onSelectionToggle:
                                  null, // Handled by outer GestureDetector
                              onMessageUpdate: (updatedMessage) {
                                // Update message in list and sync to cloud
                                final msgIndex = _messages.indexWhere(
                                  (m) => m.id == updatedMessage.id,
                                );
                                if (msgIndex != -1) {
                                  // Use _notifier to update state
                                  _notifier.updateMessage(updatedMessage);
                                  // Sync to cloud
                                  ChatHistoryService().syncMessages(
                                    widget.scene.id,
                                    _messages,
                                  );
                                }
                              },
                              onTap: () {
                                if (!msg.isUser && !_isMultiSelectMode) {
                                  _handleAnalyze(msg);
                                }
                              },
                              onShowFeedback: () {
                                if (msg.isUser) {
                                  _handleUserMessageAnalysis(msg);
                                } else {
                                  _showFeedbackSheet(msg);
                                }
                              },
                              onContentChanged: () {
                                // Auto-scroll when AI message content changes during typewriter animation
                                // Only scroll if we're near the bottom (within 200 pixels)
                                if (_scrollController.hasClients) {
                                  final position = _scrollController.position;
                                  final isNearBottom =
                                      position.maxScrollExtent -
                                          position.pixels <
                                          200;

                                  if (isNearBottom) {
                                    // Schedule scroll after the current frame
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (_scrollController.hasClients) {
                                        _scrollController.animateTo(
                                          _scrollController
                                              .position.maxScrollExtent,
                                          duration: const Duration(
                                              milliseconds: 100),
                                          curve: Curves.easeOut,
                                        );
                                      }
                                    });
                                  }
                                }
                              },
                            ),
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
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: _isRecordingVoice
          ? _buildRecordingMode()
          : ValueListenableBuilder<bool>(
              valueListenable: _hasTextNotifier,
              builder: (context, hasText, child) {
                return _buildTextInputMode();
              },
            ),
    );
  }

  // Recording Mode: Waveform | Text Button | Send Button
  Widget _buildRecordingMode() {
    return Row(
      children: [
        // Waveform visualization
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(children: [Expanded(child: _buildWaveform())]),
          ),
        ),
        const SizedBox(width: 8),
        // Text button (转文本)
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[100],
          ),
          child: IconButton(
            icon: const Text(
              '文',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
            ),
            onPressed: () =>
                _stopVoiceRecordingWithOptions(convertToText: true),
          ),
        ),
        const SizedBox(width: 8),
        // Send button (直接发送语音)
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_upward_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => _stopVoiceRecordingWithOptions(sendDirectly: true),
          ),
        ),
      ],
    );
  }

  // Waveform animation widget
  Widget _buildWaveform() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(30, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            // Uniform height, animate color instead
            // Use smaller multiplier for wider wave (contiguous blocks)
            final offset = (index * 0.05) % 1.0;
            final animValue = (_pulseController.value + offset) % 1.0;
            // Use a threshold that creates a "filling" effect or large block moving
            final isDark = animValue < 0.5; // Simple moving block

            return Container(
              width: 2, // Thinner bars
              height: 14, // Uniform height, reduced
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }

  // Text Input Mode with inline voice recording
  Widget _buildTextInputMode() {
    final hasText = _textController.text.trim().isNotEmpty;

    return Row(
      key: const ValueKey('textMode'),
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Lightbulb button
        IconButton(
          icon: const Icon(
            Icons.lightbulb_outline_rounded,
            color: Colors.amber,
          ),
          onPressed: _showHintsSheet,
        ),
        // Text input field
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.transparent, width: 0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.transparent,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                // AI Optimization Button (only show when has text)
                if (hasText)
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
                        : const Icon(Icons.auto_fix_high, color: Colors.green),
                    tooltip: 'Optimize with AI',
                    onPressed: _isOptimizing ? null : _optimizeMessage,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Voice or Send button
        _buildVoiceOrSendButton(hasText),
      ],
    );
  }

  Widget _buildVoiceOrSendButton(bool hasText) {
    if (hasText) {
      // Send button when text is present
      return Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_upward_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: _sendMessage,
        ),
      );
    } else {
      // Microphone button when no text
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[100],
        ),
        child: IconButton(
          icon: Icon(
            Icons.mic_rounded,
            color: AppColors.lightTextPrimary,
            size: 20,
          ),
          onPressed: _startVoiceRecording,
        ),
      );
    }
  }

  // Helper method to show hints sheet
  void _showHintsSheet() {
    final history = _messages
        .map(
          (m) => <String, String>{
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.content,
          },
        )
        .toList();

    final currentMessageCount = _messages.length;
    final isCacheValid =
        _cachedHints != null && _hintsMessageCount == currentMessageCount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.white.withValues(alpha: 0.5),
      builder: (context) => HintsSheet(
        sceneDescription:
            'AI Role: ${widget.scene.aiRole}, User Role: ${widget.scene.userRole}. ${widget.scene.description}',
        history: history,
        cachedHints: isCacheValid ? _cachedHints : null,
        onHintsCached: (hints) {
          _notifier.cacheHints(hints, currentMessageCount);
        },
        onHintSelected: (hint) {
          _textController.text = hint;
        },
      ),
    );
  }

  // Helper method to optimize message
  Future<void> _optimizeMessage() async {
    final text = _textController.text.trim();
    _notifier.setOptimizing(true);

    try {
      final history = _messages
          .where((m) => !m.isLoading && m.content.isNotEmpty)
          .map(
            (m) => <String, String>{
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.content,
            },
          )
          .toList();

      final optimizedText = await _apiService.optimizeMessage(
        text,
        'AI Role: ${widget.scene.aiRole}, User Role: ${widget.scene.userRole}. ${widget.scene.description}',
        history,
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
        _notifier.setOptimizing(false);
      }
    }
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
      barrierColor: Colors.white.withValues(alpha: 0.5),
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
                      _notifier.loadMessages(); // Use notifier to reload
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
      barrierColor: Colors.white.withValues(alpha: 0.5),
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

  void _retryInitialLoad() {
    _notifier.loadMessages();
  }

  Future<void> _handleUserMessageAnalysis(Message message) async {
    if (!message.isUser) return;

    // If feedback already exists, show it directly
    if (message.feedback != null) {
      _showFeedbackSheet(message);
      return;
    }

    // For voice messages, open the feedback sheet directly
    // The VoiceFeedbackSheet will handle Azure assessment
    if (message.isVoiceMessage) {
      _showFeedbackSheet(message);
      return;
    }

    // For text messages, analyze first then show sheet
    try {
      await _notifier.analyzeMessage(message);

      // Get updated message from state to pass to sheet
      final updatedMsg = _messages.firstWhere((m) => m.id == message.id);

      if (!mounted) return;
      // Automatically open feedback sheet
      _showFeedbackSheet(updatedMsg);
    } catch (e) {
      if (mounted) {
        showTopToast(context, 'Failed to analyze message: $e', isError: true);
      }
    }
  }

  void _handleAnalyze(Message message) {
    // If analysis already exists, show it directly
    if (message.analysis != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.white.withValues(alpha: 0.5),
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
      barrierColor: Colors.white.withValues(alpha: 0.5),
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
      barrierColor: Colors.white.withValues(alpha: 0.5),
      builder: (context) =>
          FeedbackSheet(message: message, sceneId: widget.scene.id),
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
        hints: currentMessage.hints, // Preserve hints
      );

      _notifier.updateMessage(updatedMessage);
    }
  }
}
