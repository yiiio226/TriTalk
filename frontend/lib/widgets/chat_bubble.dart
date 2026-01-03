import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import '../models/message.dart';
import '../widgets/shadowing_sheet.dart';
import '../widgets/save_note_sheet.dart';
import '../widgets/voice_feedback_sheet.dart'; // New import
import '../services/api_service.dart';
import '../services/preferences_service.dart';

class ChatBubble extends StatefulWidget {
  final Message message;
  final VoidCallback? onTap;
  final String? sceneId; // Add sceneId to pass to SaveNoteSheet
  final Function(Message)? onMessageUpdate; // Callback to update message with translation
  final VoidCallback? onShowFeedback;
  final bool isMultiSelectMode; // Whether multi-select mode is active
  final VoidCallback? onLongPress; // Callback to enter multi-select mode
  final VoidCallback? onSelectionToggle; // Callback to toggle selection

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
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with SingleTickerProviderStateMixin {
  bool _showTranslation = false;
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
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize translation from message if it exists
    if (widget.message.translation != null) {
      _translatedText = widget.message.translation;
    }
    
    // Setup loading controller
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    
    // Setup typewriter if needed
    if (widget.message.isAnimated && !widget.message.isLoading) {
      _isAnimationComplete = false; // Animation will start
      _startTypewriter();
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
            _duration = newDuration;
          });
        }
      });

      _audioPlayer.onPositionChanged.listen((newPosition) {
        if (mounted) {
          setState(() {
            _position = newPosition;
          });
        }
      });
      
      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _position = Duration.zero;
          });
        }
      });
    }
  }
  
  @override
  void didUpdateWidget(ChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle text changes or animation toggle
    if (widget.message.content != oldWidget.message.content) {
      if (widget.message.isAnimated) {
        _currentIndex = 0;
        _displayedText = "";
        _isAnimationComplete = false; // Animation will restart
        _startTypewriter();
      } else {
        _displayedText = widget.message.content;
        _isAnimationComplete = true;
      }
    }
  }
  
  void _startTypewriter() {
    _typewriterTimer?.cancel();
    
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_currentIndex < widget.message.content.length) {
        if (mounted) {
          setState(() {
            _currentIndex++;
            _displayedText = widget.message.content.substring(0, _currentIndex);
          });
        }
      } else {
        timer.cancel();
        // Animation complete, update state to show action buttons
        if (mounted) {
          setState(() {
            _isAnimationComplete = true;
          });
        }
      }
    });
  }

  Future<void> _playPauseVoice() async {
    if (widget.message.audioPath == null) return;
    
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(widget.message.audioPath!));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to play audio: $e')),
        );
      }
    }
  }
  
  void _showVoiceFeedback() {
    if (widget.message.voiceFeedback == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.white.withOpacity(0.5),
      builder: (context) => VoiceFeedbackSheet(
        feedback: widget.message.voiceFeedback!,
      ),
    );
  }



  Widget _buildVoiceBubbleContent(bool isUser) {
    // Duration formatting: e.g. 3"
    final duration = widget.message.audioDuration ?? 0;
    final durationText = '${duration}"';

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
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            _isPlaying
                ? const Icon(Icons.pause_rounded, size: 20, color: Colors.black87)
                : RotatedBox(
                    quarterTurns: 1,
                    child: Icon(Icons.wifi_rounded, size: 20, color: Colors.black87),
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
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    
    final hasFeedback = message.feedback != null;
    final isPerfect = message.feedback?.isPerfect ?? false;
    final isMagicWand = hasFeedback && !isPerfect;

    // Color logic: User messages are white until feedback received (yellow). AI messages are white.
    final Color color = isUser 
        ? (hasFeedback ? const Color(0xFFFFF3CD) : Colors.white)
        : Colors.white;

    // Increased radius
    final radius = BorderRadius.circular(20);

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
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.green.shade200, width: 1),
      );
    } else if (isMagicWand) {
      bubbleDecoration = bubbleDecoration.copyWith(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)], 
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

    // In multi-select mode, ignore all internal gestures and let parent handle it
    final child = Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: bubbleDecoration.copyWith(
            border: message.isSelected
                ? Border.all(color: Colors.black, width: 1)
                : bubbleDecoration.border,
          ),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: AbsorbPointer(
          absorbing: widget.isMultiSelectMode, // Block all internal gestures in multi-select mode
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            widget.message.isLoading
                ? _buildLoadingIndicator()
                : widget.message.isVoiceMessage
                    ? _buildVoiceBubbleContent(isUser)
                    : MarkdownBody(
                        data: _displayedText,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(fontSize: 16, height: 1.4),
                          strong: const TextStyle(fontWeight: FontWeight.bold),
                          em: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        selectable: !widget.isMultiSelectMode, // Disable selection in multi-select mode
                      ),
            if (hasFeedback) ...[
                const SizedBox(height: 6),
               Wrap(
                 spacing: 8,
                 runSpacing: 8,
                 children: [
                   // Grammar/Perfect Button
                   GestureDetector(
                     onTap: () => widget.onShowFeedback?.call(),
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.5),
                         borderRadius: BorderRadius.circular(16),
                       ),
                       child: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Icon(
                             isPerfect ? Icons.star_rounded : Icons.auto_fix_high_rounded,
                             size: 14,
                             color: isPerfect ? Colors.green[800] : Colors.orange[900], // Match bg family
                           ),
                           const SizedBox(width: 4),
                           Text(
                             isPerfect ? "Perfect" : "Fix",
                             style: TextStyle(
                               fontSize: 11, 
                               fontWeight: FontWeight.bold, 
                               color: isPerfect ? Colors.green[800] : Colors.orange[900] // Match bg family
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),

                   // Pronunciation Score (if exists)
                   if (widget.message.isVoiceMessage && widget.message.voiceFeedback != null)
                     GestureDetector(
                       onTap: _showVoiceFeedback,
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.5),
                           borderRadius: BorderRadius.circular(16),
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Icon(
                               Icons.mic_none_rounded,
                               size: 14,
                               color: widget.message.voiceFeedback!.pronunciationScore >= 80 
                                   ? Colors.green[800] 
                                   : Colors.orange[900],
                             ),
                             const SizedBox(width: 4),
                             Text(
                               '${widget.message.voiceFeedback!.pronunciationScore}',
                               style: TextStyle(
                                 fontSize: 11,
                                 fontWeight: FontWeight.bold,
                                 color: widget.message.voiceFeedback!.pronunciationScore >= 80 
                                     ? Colors.green[800] 
                                     : Colors.orange[900],
                               ),
                             ),
                           ],
                         ),
                       ),
                     ),
                 ],
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
            // Analysis icon for AI messages (only show when animation is complete)
            if (!isUser && !widget.message.isLoading && _isAnimationComplete) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Grammar Analysis
                  GestureDetector(
                    onTap: () => widget.onTap?.call(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.black),
                          const SizedBox(width: 4),
                          const Text(
                            "Analyze",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Play
                  GestureDetector(
                    onTap: _playTextToSpeech,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.volume_up_rounded, size: 14, color: Colors.black),
                          const SizedBox(width: 4),
                          const Text(
                            "Listen",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Shadowing
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => ShadowingSheet(targetText: message.content),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.mic_none_rounded, size: 14, color: Colors.black),
                          const SizedBox(width: 4),
                          const Text(
                            "Shadow",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Translate
                  GestureDetector(
                    onTap: _handleTranslate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isTranslating)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          else
                            const Icon(Icons.translate_rounded, size: 14, color: Colors.black),
                          const SizedBox(width: 4),
                          const Text(
                            "Translate",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
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
                         barrierColor: Colors.white.withOpacity(0.5),
                        builder: (context) => SaveNoteSheet(
                          originalSentence: message.content,
                          sceneId: widget.sceneId, // Pass sceneId
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bookmark_border_rounded, size: 14, color: Colors.black),
                          const SizedBox(width: 4),
                          const Text(
                            "Save",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
            ],
            if (_showTranslation && _translatedText != null) ...[
               const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                SelectableText(
                  _translatedText!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
             ]
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
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.check,
              size: 14,
              color: Colors.white,
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
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _playTextToSpeech() {
    // Placeholder for TTS functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text-to-speech functionality coming soon!')),
    );
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
                  -4 * sin(0.5 + 0.5 * DateTime.now().millisecondsSinceEpoch / 200 + index)
                ), // Bouncing effect
                child: Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.black,
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
              scale: 0.5 + 0.5 * sin(DateTime.now().millisecondsSinceEpoch / 200 + index),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black,
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
