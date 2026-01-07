import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import '../models/message.dart';
import '../services/api_service.dart';

class ShadowingSheet extends StatefulWidget {
  final String targetText;

  const ShadowingSheet({Key? key, required this.targetText}) : super(key: key);

  @override
  State<ShadowingSheet> createState() => _ShadowingSheetState();
}

class _ShadowingSheetState extends State<ShadowingSheet> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ApiService _apiService = ApiService();

  bool _isRecording = false;
  String? _audioPath;
  bool _isAnalyzing = false;
  ShadowResult? _result;
  String _errorMessage = '';

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/shadow_${DateTime.now().millisecondsSinceEpoch}.wav';

        // Use WAV format with PCM encoding for better transcription accuracy
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000, // 16kHz is optimal for speech recognition
            numChannels: 1, // Mono audio
          ),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _audioPath = null;
          _result = null;
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Could not start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });
      if (path != null) {
        _analyzeAudio(path);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error stopping recording: $e');
    }
  }

  Future<void> _analyzeAudio(String path) async {
    setState(() => _isAnalyzing = true);

    try {
      // TODO: In real implementation, transcribe audio first or send audio file.
      // For MVP simulation, we simulate text based on random success or strict match (not possible here without STT).
      // Since we don't have STT on device, we will mock the "user_audio_text" to be the same as target
      // but slightly modified to test the "score" logic, or just send targetText to get a perfect score for demo.
      // Let's send the targetText to simulate a "Good" attempt for now.
      // Real App needs: Whispher API or on-device speech-to-text.

      final mockUserText = widget.targetText;

      final result = await _apiService.analyzeShadow(
        widget.targetText,
        mockUserText,
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Analysis failed: $e';
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Shadowing Practice',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              widget.targetText,
              style: const TextStyle(fontSize: 18, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),

          if (_isAnalyzing)
            const CircularProgressIndicator()
          else if (_result != null)
            _buildResultView()
          else
            _buildRecordButton(),

          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red.shade100 : Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic,
              size: 40,
              color: _isRecording ? Colors.red : Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isRecording ? 'Release to Stop' : 'Hold to Record',
            style: TextStyle(
              color: _isRecording ? Colors.red : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  '${_result!.score}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(_result!.score),
                  ),
                ),
                Text('Score', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(width: 32),
            Column(
              children: [
                _buildMiniScore('Intonation', _result!.intonationScore),
                const SizedBox(height: 8),
                _buildMiniScore('Pronunciation', _result!.pronunciationScore),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.tips_and_updates, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _result!.feedback,
                  style: const TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () {
            setState(() {
              _result = null;
              _audioPath = null;
            });
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh),
              SizedBox(width: 8),
              Text('Try Again'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniScore(String label, int score) {
    return Row(
      children: [
        SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey.shade200,
            color: _getScoreColor(score),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}
