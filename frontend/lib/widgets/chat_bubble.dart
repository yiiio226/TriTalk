import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/message.dart';
import '../widgets/shadowing_sheet.dart';
import '../widgets/save_note_sheet.dart';

class ChatBubble extends StatefulWidget {
  final Message message;
  final VoidCallback? onTap;

  const ChatBubble({Key? key, required this.message, this.onTap}) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with SingleTickerProviderStateMixin {
  bool _showTranslation = false;
  
  // Typewriter state
  String _displayedText = "";
  Timer? _typewriterTimer;
  int _currentIndex = 0;
  bool _isAnimationComplete = false; // Track if typewriter animation is done
  
  // Loading state
  late AnimationController _loadingController;
  
  @override
  void initState() {
    super.initState();
    
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
  
  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _loadingController.dispose();
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
                : SelectableText(
                    _displayedText,
                    style: const TextStyle(fontSize: 16, height: 1.4),
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
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.purple[700]),
                          const SizedBox(width: 4),
                          Text(
                            "Analyze",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple[700]),
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
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mic_none_rounded, size: 14, color: Colors.blue[700]),
                          const SizedBox(width: 4),
                          Text(
                            "Shadow",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue[700]),
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
                        builder: (context) => SaveNoteSheet(originalSentence: message.content),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bookmark_border_rounded, size: 14, color: Colors.green[700]),
                          const SizedBox(width: 4),
                          Text(
                            "Save",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
            ],
            if (_showTranslation && message.translation != null) ...[
               const SizedBox(height: 8),
               const Divider(height: 1),
               const SizedBox(height: 8),
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
