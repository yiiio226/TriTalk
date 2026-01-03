import 'package:flutter/material.dart';
import '../models/message.dart';

class VoiceFeedbackSheet extends StatefulWidget {
  final VoiceFeedback feedback;
  final ScrollController? scrollController;

  const VoiceFeedbackSheet({
    super.key,
    required this.feedback,
    this.scrollController,
  });

  @override
  State<VoiceFeedbackSheet> createState() => _VoiceFeedbackSheetState();
}

class _VoiceFeedbackSheetState extends State<VoiceFeedbackSheet> {
  // Mock bookmark states for demo. In a real app, these would come from backend/provider
  // The user requirement mentions bookmarking "Native Expression" and "Corrected" items
  bool _isCorrectedSaved = false;
  bool _isNativeSaved = false;

  @override
  Widget build(BuildContext context) {
    // Determine score color
    Color scoreColor;
    if (widget.feedback.pronunciationScore >= 80) {
      scoreColor = Colors.green;
    } else if (widget.feedback.pronunciationScore >= 60) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          const Text(
            'Pronunciation Feedback',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Score Circle
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: widget.feedback.pronunciationScore / 100,
                        strokeWidth: 8,
                        color: scoreColor,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    Text(
                      '${widget.feedback.pronunciationScore}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getScoreLabel(widget.feedback.pronunciationScore),
                  style: TextStyle(
                    fontSize: 16,
                    color: scoreColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Sections based on feedback data
          
          // Suggestion / Correction
          if (widget.feedback.correctedText.isNotEmpty)
            _buildSection(
              title: 'Suggestion',
              content: widget.feedback.correctedText,
              icon: Icons.check_circle_outline,
              iconColor: Colors.blue,
              isSaved: _isCorrectedSaved,
              onSave: () {
                setState(() {
                  _isCorrectedSaved = !_isCorrectedSaved;
                });
                _showSaveToast(_isCorrectedSaved, 'Suggestion');
              },
            ),
            
          // Native Expression
          if (widget.feedback.nativeExpression.isNotEmpty)
            _buildSection(
              title: 'Native Expression',
              content: widget.feedback.nativeExpression,
              icon: Icons.auto_awesome_outlined,
              iconColor: Colors.purple,
              isSaved: _isNativeSaved,
              onSave: () {
                setState(() {
                  _isNativeSaved = !_isNativeSaved;
                });
                _showSaveToast(_isNativeSaved, 'Native Expression');
              },
            ),
            
          // Detailed Feedback
          if (widget.feedback.feedback.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Icon(Icons.tips_and_updates_outlined, size: 20, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      Text(
                        'AI Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.feedback.feedback,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return 'Excellent!';
    if (score >= 80) return 'Great Job!';
    if (score >= 60) return 'Good Effort';
    return 'Keep Practicing';
  }

  void _showSaveToast(bool saved, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved ? 'Saved $type to Quick Save' : 'Removed $type from Quick Save'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 16,
          right: 16,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    required bool isSaved,
    required VoidCallback onSave,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: iconColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? Colors.amber : Colors.grey[400],
                  size: 20,
                ),
                onPressed: onSave,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: isSaved ? 'Remove from saved' : 'Save to review later',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }
}
