import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  // Use 127.0.0.1 for iOS Simulator, 10.0.2.2 for Android Emulator
  // For Physical device, use your machine's local IP
  static const String baseUrl = 'http://127.0.0.1:8000'; 

  Future<ChatResponse> sendMessage(String text, String sceneContext) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          'history': [], // TODO: Pass actual history
          'scene_context': sceneContext,
        }),
      );

      if (response.statusCode == 200) {
        return ChatResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load chat response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<HintResponse> getHints(String sceneContext) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/hint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': '', // Not needed for hint request strictly but used in model
          'history': [],
          'scene_context': sceneContext,
        }),
      );

      if (response.statusCode == 200) {
        return HintResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load hints: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting hints: $e');
    }
  }
}

class ChatResponse {
  final String message;
  final String? translation;
  final ReviewFeedback? feedback;

  ChatResponse({required this.message, this.translation, this.feedback});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      message: json['message'],
      translation: json['translation'],
      feedback: json['review_feedback'] != null
          ? ReviewFeedback.fromJson(json['review_feedback'])
          : null,
    );
  }
}

class HintResponse {
  final List<String> hints;
  HintResponse({required this.hints});
  factory HintResponse.fromJson(Map<String, dynamic> json) {
    return HintResponse(hints: List<String>.from(json['hints']));
  }
}
