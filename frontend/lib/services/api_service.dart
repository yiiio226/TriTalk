import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import 'preferences_service.dart';

// 环境枚举
enum Environment {
  localDev,    // 本地开发环境 (Wrangler dev server)
  production,  // 生产环境 (已部署的 Cloudflare Workers)
}

class ApiService {
  // ==================== 环境配置 ====================
  // 自动环境切换:
  // - 开发时: flutter run (默认使用 localDev)
  // - 生产时: flutter run --dart-define=USE_PROD=true
  //          flutter build apk --dart-define=USE_PROD=true
  static const Environment currentEnvironment = 
      bool.fromEnvironment('USE_PROD', defaultValue: false)
          ? Environment.production
          : Environment.localDev;
  // =================================================
  
  // 本地开发 URL (Cloudflare Workers 开发服务器)
  static const String _localDevUrl = 'http://192.168.1.8:8787';
  
  // 生产环境 URL (已部署的 Cloudflare Workers)
  static const String _productionUrl = 'https://tritalk-backend.tristart226.workers.dev';
  
  // 根据当前环境自动选择 URL
  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.localDev:
        print('🔧 API Environment: LOCAL DEV ($currentEnvironment) -> $_localDevUrl');
        return _localDevUrl;
      case Environment.production:
        print('🚀 API Environment: PRODUCTION ($currentEnvironment) -> $_productionUrl');
        return _productionUrl;
    }
  } 

  Future<ChatResponse> sendMessage(String text, String sceneContext) async {
    try {
      final prefs = PreferencesService();
      final nativeLang = await prefs.getNativeLanguage();
      final targetLang = await prefs.getTargetLanguage();

      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          'history': [], // TODO: Pass actual history
          'scene_context': sceneContext,
          'native_language': nativeLang,
          'target_language': targetLang,
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

  Future<HintResponse> getHints(String sceneContext, List<Map<String, String>> history) async {
    try {
      final prefs = PreferencesService();
      final nativeLang = await prefs.getNativeLanguage();
      final targetLang = await prefs.getTargetLanguage();

      final response = await http.post(
        Uri.parse('$baseUrl/chat/hint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': '', // Not needed for hint request strictly but used in model
          'history': history,
          'scene_context': sceneContext,
          'native_language': nativeLang,
          'target_language': targetLang,
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
  
  Future<SceneGenerationResponse> generateScene(String description, String tone) async {
    try {
      // Scene generation might mostly depend on target language for the content,
      // but we pass it anyway if the backend uses it.
      // Currently backend doesn't explicitly look for it in generate_scene but it's good practice.
      
      final response = await http.post(
        Uri.parse('$baseUrl/scene/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'description': description,
          'tone': tone,
        }),
      );

      if (response.statusCode == 200) {
        return SceneGenerationResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to generate scene: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating scene: $e');
    }
  }

  Future<MessageAnalysis> analyzeMessage(String message) async {
    try {
      final prefs = PreferencesService();
      final nativeLang = await prefs.getNativeLanguage();

      final response = await http.post(
        Uri.parse('$baseUrl/chat/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'native_language': nativeLang,
        }),
      );

      if (response.statusCode == 200) {
        return MessageAnalysis.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to analyze message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing message: $e');
    }
  }

  Future<String> polishScenario(String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scene/polish'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['polished_text'];
      } else {
        throw Exception('Failed to polish scenario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error polishing scenario: $e');
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

class SceneGenerationResponse {
  final String title;
  final String aiRole;
  final String userRole;
  final String goal;
  final String description;
  final String initialMessage;
  final String emoji;

  SceneGenerationResponse({
    required this.title,
    required this.aiRole,
    required this.userRole,
    required this.goal,
    required this.description,
    required this.initialMessage,
    required this.emoji,
  });

  factory SceneGenerationResponse.fromJson(Map<String, dynamic> json) {
    return SceneGenerationResponse(
      title: json['title'],
      aiRole: json['ai_role'],
      userRole: json['user_role'],
      goal: json['goal'],
      description: json['description'],
      initialMessage: json['initial_message'],
      emoji: json['emoji'],
    );
  }
}
