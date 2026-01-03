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

  const ChatBubble({
    Key? key, 
    required this.message, 
    this.onTap,
    this.sceneId,
    this.onMessageUpdate,
  }) : super(key: key);

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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return VoiceFeedbackSheet(
            feedback: widget.message.voiceFeedback!,
            scrollController: scrollController,
          );
        },
      ),
    );
  }



  Widget _buildVoiceBubbleContent(bool isUser) {
    // Score label for voice feedback
    String? scoreLabel;
    Color? scoreColor;
    
    if (widget.message.voiceFeedback != null) {
      final score = widget.message.voiceFeedback!.pronunciationScore;
      scoreLabel = '$score';
      
      if (score >= 80) {
        scoreColor = Colors.green;
      } else if (score >= 60) {
        scoreColor = Colors.orange;
      } else {
        scoreColor = Colors.red;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _playPauseVoice,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUser ? Colors.white.withOpacity(0.3) : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 24,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Waveform placeholder or duration
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPlaying 
                      ? '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}'
                      : widget.message.audioDuration != null 
                          ? '${widget.message.audioDuration! ~/ 60}:${(widget.message.audioDuration! % 60).toString().padLeft(2, '0')}'
                          : 'Voice Message',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            if (widget.message.voiceFeedback != null)
              GestureDetector(
                onTap: _showVoiceFeedback,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreColor?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scoreColor ?? Colors.grey),
                  ),
                  child: Row(
                    children: [
                      Text(
                        scoreLabel!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.mic_rounded, size: 14, color: scoreColor),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: bubbleDecoration,
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        selectable: true, // Allow text selection
                      ),
            if (hasFeedback) ...[
               const SizedBox(height: 6),
               Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(
                     isPerfect ? Icons.star_rounded : Icons.auto_fix_high_rounded, 
                     size: 16, 
                     color: isPerfect ? Colors.green[700] : Colors.orange
                   ),
                   if (isPerfect) ...[
                     const SizedBox(width: 4),
                     Text(
                       "Perfect!", 
                       style: TextStyle(
                         fontSize: 12, 
                         fontWeight: FontWeight.bold,
                         color: Colors.green[800]
                       )
                     ),
                   ]
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
        ),
      ),
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
