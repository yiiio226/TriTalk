import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'package:path_provider/path_provider.dart';
import 'package:frontend/features/chat/domain/models/message.dart';
import '../../../study/presentation/widgets/shadowing_sheet.dart';
import '../../../study/presentation/widgets/save_note_sheet.dart';
import 'package:frontend/core/data/api/api_service.dart';
import '../../../../core/data/local/preferences_service.dart';
import '../../../../core/services/streaming_tts_service.dart';
import '../../../../features/study/data/shadowing_history_service.dart';
import '../../../../core/widgets/top_toast.dart';

class ChatBubble extends StatefulWidget {
  final Message message;
  final VoidCallback? onTap;
  final String? sceneId; // Add sceneId to pass to SaveNoteSheet
  final Function(Message)?
  onMessageUpdate; // Callback to update message with translation
  final VoidCallback? onShowFeedback;
  final bool isMultiSelectMode; // Whether multi-select mode is active
  final VoidCallback? onLongPress; // Callback to enter multi-select mode
  final VoidCallback? onSelectionToggle; // Callback to toggle selection
  final VoidCallback?
  onContentChanged; // Callback when content changes (for auto-scroll)

  const ChatBubble({
    super.key,
    required this.message,
    this.onTap,
    this.sceneId,
    this.onMessageUpdate,
    this.onShowFeedback,
    this.isMultiSelectMode = false,
    this.onLongPress,
    this.onSelectionToggle,
    this.onContentChanged,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  // Track which messages have STARTED their typewriter animation
  // This prevents the animation from restarting if the user scrolls away and back
  static final Set<String> _startedAnimations = {};

  bool _showTranslation = false;
  bool _showTranscript = false; // Added for voice transcript toggle
  bool _isTranscriptLoading = false; // Loading state for transcript
  bool _isTranslating = false;
  String? _translatedText;

  // Typewriter state
  String _displayedText = "";
  Timer? _typewriterTimer;
  int _currentIndex = 0;
  bool _isAnimationComplete = false; // Track if typewriter animation is done

  // Loading state
  late AnimationController _loadingController;

  // Audio Playback
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  // TTS state
  bool _isTTSLoading = false;
  bool _isTTSPlaying = false;
  String? _ttsAudioPath; // Cached TTS audio file path
  StreamSubscription<void>?
  _ttsCompleteSubscription; // Single TTS completion listener

  // Shadow loading state
  bool _isShadowLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize translation from message if it exists
    if (widget.message.translation != null) {
      _translatedText = widget.message.translation;
    }

    // Initialize TTS audio path from message if it exists
    if (widget.message.ttsAudioPath != null) {
      _ttsAudioPath = widget.message.ttsAudioPath;
    }

    // Setup loading controller
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    // Setup typewriter if needed
    if (widget.message.isAnimated && !widget.message.isLoading) {
      // Check if this message has already STARTED animating
      if (_startedAnimations.contains(widget.message.id)) {
        // Already started (even if not finished), show full text immediately to avoid restart
        _displayedText = widget.message.content;
        _isAnimationComplete = true;
      } else {
        // First time, start animation and mark as started
        _isAnimationComplete = false;
        _startedAnimations.add(widget.message.id);
        _startTypewriter();
      }
    } else {
      _displayedText = widget.message.content;
      _isAnimationComplete = true; // No animation, so it's "complete"
    }

    // Setup audio player listeners if it's a voice message
    if (widget.message.isVoiceMessage) {
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });

      _audioPlayer.onDurationChanged.listen((newDuration) {
        if (mounted) {
          setState(() {
            // _duration = newDuration; // removed unused
          });
        }
      });

      _audioPlayer.onPositionChanged.listen((newPosition) {
        if (mounted) {
          setState(() {
            // _position = newPosition; // removed unused
          });
        }
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            // _position = Duration.zero; // removed unused
          });
        }
      });
    }

    // Setup TTS completion listener once (to avoid accumulation)
    _ttsCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isTTSPlaying = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(ChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle text changes or animation toggle
    if (widget.message.content != oldWidget.message.content) {
      // Only restart animation if this message hasn't started animating yet
      // This prevents restart when scrolling during streaming
      if (!_startedAnimations.contains(widget.message.id)) {
        if (widget.message.isAnimated) {
          _currentIndex = 0;
          _displayedText = "";
          _isAnimationComplete = false;
          _startedAnimations.add(widget.message.id);
          _startTypewriter();
        } else {
          _displayedText = widget.message.content;
          _isAnimationComplete = true;
        }
      } else {
        // Animation already started, just update to show full content
        // This handles the case where content is being streamed
        _displayedText = widget.message.content;
        if (_typewriterTimer == null || !_typewriterTimer!.isActive) {
          _isAnimationComplete = true;
        }
      }
    }
  }

  void _startTypewriter() {
    _typewriterTimer?.cancel();

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 30), (
      timer,
    ) {
      if (_currentIndex < widget.message.content.length) {
        if (mounted) {
          setState(() {
            _currentIndex++;
            _displayedText = widget.message.content.substring(0, _currentIndex);
          });
          // Notify parent that content changed (for auto-scroll)
          widget.onContentChanged?.call();
        }
      } else {
        timer.cancel();
        // Animation complete, update state to show action buttons
        if (mounted) {
          setState(() {
            _isAnimationComplete = true;
            // No need to add to set here, we added it at start
          });
        }
      }
    });
  }

  Future<String> _resolveAudioPath(String originalPath) async {
    final file = File(originalPath);
    if (await file.exists()) {
      return originalPath;
    }

    // iOS Sandbox handling: Path might contain old Container UUID
    // Try to find the file in current Documents or Cache directory by filename
    try {
      final filename = originalPath.split('/').last;

      // Check Documents
      final docsDir = await getApplicationDocumentsDirectory();
      final docsFile = File('${docsDir.path}/$filename');
      if (await docsFile.exists()) {
        return docsFile.path;
      }

      // Check Cache
      final cacheDir = await getTemporaryDirectory();
      final cacheFile = File('${cacheDir.path}/$filename');
      if (await cacheFile.exists()) {
        return cacheFile.path;
      }

      // Check specialized paths if needed (e.g. tts_cache)
      // This handles the specific case of TTS files stored in user-scoped tts_cache
      // and recorded files stored in root of Documents
    } catch (e) {
      debugPrint('Error resolving audio path: $e');
    }

    return originalPath;
  }

  Future<void> _playPauseVoice() async {
    if (widget.message.audioPath == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        final resolvedPath = await _resolveAudioPath(widget.message.audioPath!);
        // Use UrlSource with file URI for robust playback on iOS/macOS
        await _audioPlayer.play(UrlSource(Uri.file(resolvedPath).toString()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to play audio: $e')));
      }
    }
  }

  Widget _buildVoiceBubbleContent(bool isUser) {
    // Duration formatting: e.g. 3"
    final duration = widget.message.audioDuration ?? 0;
    final durationText = '$duration"';

    return GestureDetector(
      onTap: _playPauseVoice,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent, // Expand tap area
        padding: const EdgeInsets.symmetric(vertical: 4),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              durationText,
              style: const TextStyle(
                fontSize: 14, // Reduced from 16
                fontWeight: FontWeight.w500,
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(width: 4),
            _isPlaying
                ? const Icon(
                    Icons.pause_rounded,
                    size: 16,
                    color: AppColors.lightTextPrimary,
                  )
                : RotatedBox(
                    quarterTurns: 1,
                    child: Icon(
                      Icons.wifi_rounded,
                      size: 16,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _loadingController.dispose();
    _ttsCompleteSubscription?.cancel(); // Cancel TTS completion listener
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isUser = message.isUser;
    // final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start; // unused

    final hasFeedback = message.feedback != null;
    final isPerfect = message.feedback?.isPerfect ?? false;
    final isMagicWand = hasFeedback && !isPerfect;

    // Color logic: User messages are white until feedback received (yellow). AI messages are white.
    final Color color = isUser
        ? (hasFeedback ? const Color(0xFFFFF3CD) : AppColors.lightSurface)
        : AppColors.lightSurface;

    // Increased radius
    final radius = BorderRadius.circular(AppRadius.lg);

    BoxDecoration bubbleDecoration = BoxDecoration(
      color: color,
      borderRadius: isUser
          ? radius.copyWith(bottomRight: Radius.zero)
          : radius.copyWith(bottomLeft: Radius.zero),
      boxShadow: AppShadows.xs,
    );

    // Only apply feedback styling to user messages
    if (isUser && isPerfect) {
      bubbleDecoration = bubbleDecoration.copyWith(
        gradient: LinearGradient(
          colors: [AppColors.lg100, AppColors.lg200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.lg200, width: 1),
      );
    } else if (isUser && isMagicWand) {
      bubbleDecoration = bubbleDecoration.copyWith(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.ly200, width: 1),
      );
    } else if (isUser && hasFeedback) {
      bubbleDecoration = bubbleDecoration.copyWith(
        border: Border.all(color: AppColors.lo100, width: 1),
      );
    }

    // In multi-select mode, ignore all internal gestures and let parent handle it
    final child = Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: bubbleDecoration.copyWith(
            border: message.isSelected
                ? Border.all(color: AppColors.lightTextPrimary, width: 1)
                : bubbleDecoration.border,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: AbsorbPointer(
            absorbing: widget
                .isMultiSelectMode, // Block all internal gestures in multi-select mode
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widget.message.isLoading
                      ? _buildLoadingIndicator()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.message.isVoiceMessage)
                              _buildVoiceBubbleContent(isUser),
                            if (widget.message.content.isNotEmpty &&
                                !widget.message.isVoiceMessage) ...[
                              if (widget.message.isVoiceMessage)
                                const SizedBox(height: 8),
                              MarkdownBody(
                                data: _displayedText,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(
                                    fontSize: 16,
                                    height: 1.4,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                  strong: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                  em: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                                selectable: !widget.isMultiSelectMode,
                              ),
                            ],
                          ],
                        ),
                  // Only show feedback for user messages
                  if (isUser && hasFeedback) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Grammar/Perfect Button
                          GestureDetector(
                            onTap: () => widget.onShowFeedback?.call(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightSurface.withValues(
                                  alpha: 0.3,
                                ), // Increased transparency
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPerfect
                                        ? Icons.star_rounded
                                        : Icons.auto_fix_high_rounded,
                                    size: 14,
                                    color: isPerfect
                                        ? AppColors.lightSuccess
                                        : AppColors.lightWarning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isPerfect ? "Perfect" : "Feedback",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isPerfect
                                          ? AppColors.lightSuccess
                                          : AppColors.lightWarning,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Text button for voice messages (same row as Perfect/Fix)
                          if (widget.message.isVoiceMessage) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                if (_showTranscript) {
                                  // Just hide if already showing
                                  setState(() {
                                    _showTranscript = false;
                                  });
                                } else {
                                  // Check if transcript is already loaded
                                  if (widget.message.content.isEmpty) {
                                    // Show loading and wait for transcript
                                    setState(() {
                                      _isTranscriptLoading = true;
                                    });

                                    // Poll for transcript updates (check every 100ms for up to 30 seconds)
                                    int attempts = 0;
                                    const maxAttempts = 300; // 30 seconds
                                    while (attempts < maxAttempts &&
                                        widget.message.content.isEmpty) {
                                      await Future.delayed(
                                        const Duration(milliseconds: 100),
                                      );
                                      attempts++;
                                      if (!mounted) return;
                                    }

                                    if (mounted) {
                                      setState(() {
                                        _isTranscriptLoading = false;
                                        // Only show transcript if content is now available
                                        if (widget.message.content.isNotEmpty) {
                                          _showTranscript = true;
                                        }
                                      });
                                    }
                                  } else {
                                    // Transcript already loaded, show immediately
                                    setState(() {
                                      _showTranscript = true;
                                    });
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.lightSurface.withValues(
                                    alpha: 0.3,
                                  ), // Match Perfect/Fix button background
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_isTranscriptLoading)
                                      const SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.lightTextPrimary,
                                              ),
                                        ),
                                      )
                                    else
                                      Icon(
                                        _showTranscript
                                            ? Icons.subtitles_off_rounded
                                            : Icons.subtitles_rounded,
                                        size: 14,
                                        color: AppColors.lightTextPrimary,
                                      ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _showTranscript ? "Hide Text" : "Text",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (widget.message.isFeedbackLoading) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 12,
                          child: _buildSmallLoader(),
                        ),
                      ],
                    ),
                  ],
                  // Analyze button for user messages (only show when no feedback exists)
                  if (isUser &&
                      !widget.message.isLoading &&
                      !hasFeedback &&
                      !widget.message.isFeedbackLoading) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Analyze button
                          GestureDetector(
                            onTap: () => widget.onShowFeedback?.call(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: widget.message.isAnalyzing
                                    ? AppColors.ln200
                                    : AppColors.ln100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.message.isAnalyzing)
                                    const SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.lightTextPrimary,
                                            ),
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 14,
                                      color: AppColors.lightTextPrimary,
                                    ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.message.isAnalyzing
                                        ? "Analyzing..."
                                        : "Analyze",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Text button for voice messages (same row as Analyze)
                          if (widget.message.isVoiceMessage) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                if (_showTranscript) {
                                  // Just hide if already showing
                                  setState(() {
                                    _showTranscript = false;
                                  });
                                } else {
                                  // Check if transcript is already loaded
                                  if (widget.message.content.isEmpty) {
                                    // Show loading and wait for transcript
                                    setState(() {
                                      _isTranscriptLoading = true;
                                    });

                                    // Poll for transcript updates (check every 100ms for up to 30 seconds)
                                    int attempts = 0;
                                    const maxAttempts = 300; // 30 seconds
                                    while (attempts < maxAttempts &&
                                        widget.message.content.isEmpty) {
                                      await Future.delayed(
                                        const Duration(milliseconds: 100),
                                      );
                                      attempts++;
                                      if (!mounted) return;
                                    }

                                    if (mounted) {
                                      setState(() {
                                        _isTranscriptLoading = false;
                                        // Only show transcript if content is now available
                                        if (widget.message.content.isNotEmpty) {
                                          _showTranscript = true;
                                        }
                                      });
                                    }
                                  } else {
                                    // Transcript already loaded, show immediately
                                    setState(() {
                                      _showTranscript = true;
                                    });
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.ln100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_isTranscriptLoading)
                                      const SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.lightTextPrimary,
                                              ),
                                        ),
                                      )
                                    else
                                      Icon(
                                        _showTranscript
                                            ? Icons.subtitles_off_rounded
                                            : Icons.subtitles_rounded,
                                        size: 14,
                                        color: AppColors.lightTextPrimary,
                                      ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _showTranscript ? "Hide Text" : "Text",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  // Analysis icon for AI messages (only show when animation is complete)
                  if (!isUser &&
                      !widget.message.isLoading &&
                      _isAnimationComplete) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Grammar Analysis
                        GestureDetector(
                          onTap: () => widget.onTap?.call(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ln100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 14,
                                  color: AppColors.lightTextPrimary,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "Analyze",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Listen / TTS Play
                        GestureDetector(
                          onTap: _playTextToSpeech,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _isTTSPlaying
                                  ? AppColors.lb100
                                  : AppColors.ln100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isTTSLoading)
                                  const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  )
                                else if (_isTTSPlaying)
                                  const Icon(
                                    Icons.stop_rounded,
                                    size: 14,
                                    color: AppColors.lightInfo,
                                  )
                                else
                                  const Icon(
                                    Icons.volume_up_rounded,
                                    size: 14,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                const SizedBox(width: 4),
                                Text(
                                  _isTTSPlaying ? "Stop" : "Listen",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _isTTSPlaying
                                        ? AppColors.lightInfo
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Shadowing
                        GestureDetector(
                          onTap: _handleShadowClick,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _isShadowLoading
                                  ? AppColors.ln200
                                  : AppColors.ln100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isShadowLoading)
                                  const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.mic_none_rounded,
                                    size: 14,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                const SizedBox(width: 4),
                                Text(
                                  _isShadowLoading ? "Shadow" : "Shadow",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Translate
                        GestureDetector(
                          onTap: _handleTranslate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ln100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isTranslating)
                                  const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.translate_rounded,
                                    size: 14,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                const SizedBox(width: 4),
                                const Text(
                                  "Translate",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Save
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              barrierColor: AppColors.lightSurface.withValues(
                                alpha: 0.5,
                              ),
                              builder: (context) => SaveNoteSheet(
                                originalSentence: message.content,
                                sceneId: widget.sceneId, // Pass sceneId
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ln100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.bookmark_border_rounded,
                                  size: 14,
                                  color: AppColors.lightTextPrimary,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "Save",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                  ],
                  if (widget.message.isVoiceMessage && _showTranscript) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    MarkdownBody(
                      data: widget.message.content.isEmpty
                          ? "..."
                          : widget.message.content,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 14, height: 1.4),
                        strong: const TextStyle(fontWeight: FontWeight.bold),
                        em: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      selectable: !widget.isMultiSelectMode,
                    ),
                  ],
                  if (_showTranslation && _translatedText != null) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    SelectableText(
                      _translatedText!,
                      style: TextStyle(fontSize: 14, color: AppColors.ln700),
                    ),
                  ],
                ],
              ), // Close Column
            ), // Close IntrinsicWidth
          ), // Close AbsorbPointer
        ), // Close Container
        // Selection indicator
        if (message.isSelected)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.lightTextPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightSurface, width: 2),
              ),
              child: const Icon(
                Icons.check,
                size: 14,
                color: AppColors.lightSurface,
              ),
            ),
          ),
      ], // Close Stack children
    ); // Close Stack

    // In multi-select mode, return child directly without gesture handling
    if (widget.isMultiSelectMode) {
      return child;
    }

    // In normal mode, wrap with GestureDetector for translation toggle
    return GestureDetector(
      onTap: () {
        if (!isUser && message.translation != null) {
          setState(() {
            _showTranslation = !_showTranslation;
          });
        }
        widget.onTap?.call();
      },
      onLongPress: widget.onLongPress,
      child: child,
    );
  }

  Future<void> _handleTranslate() async {
    // Toggle translation visibility if already translated
    if (_translatedText != null) {
      setState(() {
        _showTranslation = !_showTranslation;
      });
      return;
    }

    // Fetch translation
    setState(() {
      _isTranslating = true;
    });

    // Continue with the actual translation logic
    await _continueHandleTranslate();
  }

  /// Handle Shadow button click: fetch cloud data and open ShadowingSheet
  Future<void> _handleShadowClick() async {
    final message = widget.message;

    setState(() {
      _isShadowLoading = true;
    });

    VoiceFeedback? cloudFeedback;

    try {
      // Fetch latest practice data from cloud using new API
      final latestPractice = await ShadowingHistoryService().getLatestPractice(
        'ai_message', // source_type for chat bubble
        message.id, // source_id (message_id)
      );

      if (latestPractice != null) {
        // Convert ShadowingPractice to VoiceFeedback format
        cloudFeedback = VoiceFeedback(
          pronunciationScore: latestPractice.pronunciationScore,
          correctedText: latestPractice.targetText,
          nativeExpression: '',
          feedback: latestPractice.feedbackText ?? '',
          azureAccuracyScore: latestPractice.accuracyScore,
          azureFluencyScore: latestPractice.fluencyScore,
          azureCompletenessScore: latestPractice.completenessScore,
          azureProsodyScore: latestPractice.prosodyScore,
          azureWordFeedback: latestPractice.wordFeedback,
        );

        if (kDebugMode) {
          debugPrint(
            '📊 Loaded cloud shadowing data: score=${latestPractice.pronunciationScore}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to fetch cloud shadowing data: $e');
      }
      // Show error toast but continue to open sheet
      if (mounted) {
        showTopToast(
          context,
          'Failed to load previous practice data',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isShadowLoading = false;
        });
      }
    }

    // Open ShadowingSheet with cloud data (or null if fetch failed)
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: AppColors.lightSurface.withValues(alpha: 0.5),
        builder: (context) => ShadowingSheet(
          targetText: message.content,
          messageId: message.id,
          sourceType: 'ai_message',
          sourceId: message.id,
          sceneKey: widget.sceneId,
          initialFeedback: cloudFeedback ?? message.shadowingFeedback,
          initialTtsAudioPath: message.ttsAudioPath ?? _ttsAudioPath,
          onFeedbackUpdate: (feedback, audioPath) {
            widget.onMessageUpdate?.call(
              message.copyWith(
                shadowingFeedback: feedback,
                shadowingAudioPath: audioPath,
              ),
            );
          },
          onTtsUpdate: (ttsPath) {
            widget.onMessageUpdate?.call(
              message.copyWith(ttsAudioPath: ttsPath),
            );
            setState(() {
              _ttsAudioPath = ttsPath;
            });
          },
        ),
      );
    }
  }

  Future<void> _continueHandleTranslate() async {
    try {
      final prefs = PreferencesService();
      final nativeLang = await prefs.getNativeLanguage();
      final apiService = ApiService();

      final translation = await apiService.translateText(
        widget.message.content,
        nativeLang,
      );

      if (mounted) {
        setState(() {
          _translatedText = translation;
          _showTranslation = true;
          _isTranslating = false;
        });

        // Save translation to message object
        if (widget.onMessageUpdate != null) {
          final updatedMessage = Message(
            id: widget.message.id,
            content: widget.message.content,
            isUser: widget.message.isUser,
            timestamp: widget.message.timestamp,
            translation: translation, // Save the translation
            feedback: widget.message.feedback,
            analysis: widget.message.analysis,
          );
          widget.onMessageUpdate!(updatedMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation failed: $e'),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    }
  }

  /// Play text-to-speech for the message content using true streaming
  /// First play: streams audio with low latency, then caches for future use
  /// Subsequent plays: uses cached audio file for instant playback
  Future<void> _playTextToSpeech() async {
    final streamingTts = StreamingTtsService.instance;

    // Debug log: cache hit/miss info
    if (kDebugMode) {
      final cacheKey = widget.message.id;
      final cachedPath = _ttsAudioPath;
      final fileExists = cachedPath != null
          ? await File(cachedPath).exists()
          : false;
      final cacheStatus = (cachedPath != null && fileExists)
          ? "✅ CACHE HIT"
          : "❌ CACHE MISS";
      debugPrint('🎧 [TTS Cache] Key: $cacheKey | $cacheStatus');
    }

    // If already playing, stop it
    if (_isTTSPlaying || streamingTts.isPlaying) {
      await streamingTts.stop();
      setState(() {
        _isTTSPlaying = false;
        _isTTSLoading = false;
      });
      return;
    }

    // Check if we have a cached audio file
    if (_ttsAudioPath != null && await File(_ttsAudioPath!).exists()) {
      if (kDebugMode) {
        debugPrint('🔊 [TTS] Using cached audio: $_ttsAudioPath');
      }

      // Setup state listener for cached playback
      _setupStateListener(streamingTts);

      try {
        setState(() => _isTTSLoading = true);
        await streamingTts.playCached(_ttsAudioPath!);
      } catch (e) {
        if (mounted) {
          setState(() {
            _isTTSLoading = false;
            _isTTSPlaying = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to play audio: $e'),
              backgroundColor: AppColors.lightError,
            ),
          );
        }
      }
      return;
    }

    // Show loading state
    setState(() {
      _isTTSLoading = true;
    });

    // Setup state change listener
    _setupStateListener(streamingTts);

    // Setup cache callback
    streamingTts.onCacheSaved = (cachePath) {
      if (mounted) {
        setState(() {
          _ttsAudioPath = cachePath;
        });
        // Persist to Message object so it survives page navigation
        widget.onMessageUpdate?.call(
          widget.message.copyWith(ttsAudioPath: cachePath),
        );
        if (kDebugMode) {
          debugPrint('🔊 [TTS] Cache saved: $cachePath');
          debugPrint('🔊 [TTS] Persisted to Message object');
        }
      }
    };

    try {
      // Start streaming playback with caching
      await streamingTts.playStreaming(
        widget.message.content,
        messageId: widget.message.id,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTTSLoading = false;
          _isTTSPlaying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate speech: $e'),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    }
  }

  /// Setup state change listener for StreamingTtsService
  void _setupStateListener(StreamingTtsService streamingTts) {
    streamingTts.onStateChanged = (state) {
      if (!mounted) return;

      switch (state) {
        case StreamingTtsState.loading:
        case StreamingTtsState.buffering:
          setState(() {
            _isTTSLoading = true;
            _isTTSPlaying = false;
          });
          break;
        case StreamingTtsState.playing:
          setState(() {
            _isTTSLoading = false;
            _isTTSPlaying = true;
          });
          break;
        case StreamingTtsState.completed:
        case StreamingTtsState.stopped:
          setState(() {
            _isTTSLoading = false;
            _isTTSPlaying = false;
          });
          break;
        case StreamingTtsState.error:
          setState(() {
            _isTTSLoading = false;
            _isTTSPlaying = false;
          });
          break;
        case StreamingTtsState.idle:
          break;
      }
    };
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 40,
      height: 20,
      child: AnimatedBuilder(
        animation: _loadingController,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Transform.translate(
                offset: Offset(
                  0,
                  -4 *
                      sin(
                        0.5 +
                            0.5 * DateTime.now().millisecondsSinceEpoch / 200 +
                            index,
                      ),
                ), // Bouncing effect
                child: Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.lightTextPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildSmallLoader() {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            return Transform.scale(
              scale:
                  0.5 +
                  0.5 *
                      sin(DateTime.now().millisecondsSinceEpoch / 200 + index),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightTextPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
