import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';
import 'preferences_service.dart';
import '../env.dart';

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
  
  // Helper to create headers with Auth Token
  static Map<String, String> _headers() {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';
    
    // Debug print to check if token exists
    if (token.isEmpty) {
      print('⚠️ Warning: No Auth Token available for API call');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // 本地开发 URL (Cloudflare Workers 开发服务器)
  static const String _localDevUrl = Env.localBackendUrl;
  
  // 生产环境 URL (已部署的 Cloudflare Workers)
  static const String _productionUrl = Env.prodBackendUrl;
  
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

  Future<ChatResponse> sendMessage(
    String text, 
    String sceneContext,
    List<Map<String, String>> history,
  ) async {
    try {
      final prefs = PreferencesService();
      final nativeLang = await prefs.getNativeLanguage();
      final targetLang = await prefs.getTargetLanguage();

      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: _headers(),
        body: jsonEncode({
          'message': text,
          'history': history,
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
        headers: _headers(),
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
        headers: _headers(),
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

  Future<String> translateText(String text, String targetLanguage) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/common/translate'),
        headers: _headers(),
        body: jsonEncode({
          'text': text,
          'target_language': targetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translation'];
      } else {
        throw Exception('Failed to translate text: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error translating text: $e');
    }
  }

  Stream<MessageAnalysis> analyzeMessage(String message) async* {
    final prefs = PreferencesService();
    final nativeLang = await prefs.getNativeLanguage();

    final request = http.Request('POST', Uri.parse('$baseUrl/chat/analyze'));
    request.headers.addAll(_headers());
    request.body = jsonEncode({
      'message': message,
      'native_language': nativeLang,
    });

    final client = http.Client();
    try {
      final streamedResponse = await client.send(request);
      
      if (streamedResponse.statusCode != 200) {
        throw Exception('Failed to analyze message: ${streamedResponse.statusCode}');
      }

      // Initial empty analysis state
      var currentAnalysis = MessageAnalysis(
        grammarPoints: [],
        vocabulary: [],
        sentenceStructure: '',
        sentenceBreakdown: [],
        overallSummary: '',
        pragmaticAnalysis: null,
        emotionTags: [],
        idioms: [],
      );

      // Buffer for incomplete lines
      String buffer = '';

      await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
        buffer += chunk;
        
        while (buffer.contains('\n')) {
          final index = buffer.indexOf('\n');
          final line = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 1);

          if (line.isEmpty) continue;

          try {
            final json = jsonDecode(line);
            if (json is Map<String, dynamic> && json.containsKey('type') && json.containsKey('data')) {
              final type = json['type'];
              final data = json['data'];

              switch (type) {
                case 'summary':
                  currentAnalysis = currentAnalysis.copyWith(overallSummary: data as String);
                  break;
                case 'structure':
                  if (data is Map<String, dynamic>) {
                    currentAnalysis = currentAnalysis.copyWith(
                      sentenceStructure: data['structure'] ?? '',
                      sentenceBreakdown: (data['breakdown'] as List?)
                          ?.map((e) => StructureSegment.fromJson(e))
                          .toList() ?? []
                    );
                  }
                  break;
                case 'grammar':
                  if (data is List) {
                     currentAnalysis = currentAnalysis.copyWith(
                      grammarPoints: data.map((e) => GrammarPoint.fromJson(e)).toList(),
                    );
                  }
                  break;
                case 'vocabulary':
                   if (data is List) {
                    currentAnalysis = currentAnalysis.copyWith(
                      vocabulary: data.map((e) => VocabularyItem.fromJson(e)).toList(),
                    );
                  }
                  break;
                case 'idioms':
                   if (data is List) {
                    currentAnalysis = currentAnalysis.copyWith(
                      idioms: data.map((e) => IdiomItem.fromJson(e)).toList(),
                    );
                  }
                  break;
                case 'pragmatic':
                  currentAnalysis = currentAnalysis.copyWith(pragmaticAnalysis: data as String);
                  break;
                case 'emotion':
                   if (data is List) {
                    currentAnalysis = currentAnalysis.copyWith(
                      emotionTags: List<String>.from(data),
                    );
                  }
                  break;
              }
              yield currentAnalysis;
            }
          } catch (e) {
            print('Error parsing chunk: $e');
            // Continue despite error
          }
        }
      }
    } catch (e) {
      throw Exception('Error analyzing message: $e');
    } finally {
      client.close();
    }
  }

  Future<String> polishScenario(String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scene/polish'),
        headers: _headers(),
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

  Future<ShadowResult> analyzeShadow(String targetText, String userAudioText) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/shadow'),
        headers: _headers(),
        body: jsonEncode({
          'target_text': targetText,
          'user_audio_text': userAudioText,
        }),
      );

      if (response.statusCode == 200) {
        return ShadowResult.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to analyze shadow: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing shadow: $e');
    }
  }

  Future<String> optimizeMessage(
    String draft, 
    String sceneContext, 
    List<Map<String, String>> history
  ) async {
    try {
      final prefs = PreferencesService();
      final targetLang = await prefs.getTargetLanguage();

      final response = await http.post(
        Uri.parse('$baseUrl/chat/optimize'),
        headers: _headers(),
        body: jsonEncode({
          'message': draft,
          'scene_context': sceneContext,
          'history': history,
          'target_language': targetLang,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['optimized_text'];
      } else {
        throw Exception('Failed to optimize message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error optimizing message: $e');
    }
  }

  Future<String> transcribeAudio(String audioPath) async {
    try {
      final prefs = PreferencesService();
      final targetLang = await prefs.getTargetLanguage();

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/chat/transcribe'),
      );

      // Add headers
      final headers = _headers();
      request.headers.addAll(headers);

      // Add audio file
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioPath,
      ));

      // Add target language as field
      request.fields['target_language'] = targetLang;

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] ?? '';
      } else {
        throw Exception('Failed to transcribe audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error transcribing audio: $e');
    }
  }

  Future<VoiceMessageResponse> sendVoiceMessage(
    String audioPath,
    String sceneContext,
    List<Map<String, String>> history,
  ) async {
    try {
      final prefs = PreferencesService();
      final nativeLang = await prefs.getNativeLanguage();
      final targetLang = await prefs.getTargetLanguage();

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/chat/send-voice'),
      );

      // Add headers
      final headers = _headers();
      request.headers.addAll(headers);

      // Add audio file
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioPath,
      ));

      // Add other fields
      request.fields['scene_context'] = sceneContext;
      request.fields['history'] = jsonEncode(history);
      request.fields['native_language'] = nativeLang;
      request.fields['target_language'] = targetLang;

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return VoiceMessageResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to send voice message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending voice message: $e');
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

class VoiceMessageResponse {
  final String message;
  final String? translation;
  final VoiceFeedback voiceFeedback;
  final ReviewFeedback? reviewFeedback;

  VoiceMessageResponse({
    required this.message,
    this.translation,
    required this.voiceFeedback,
    this.reviewFeedback,
  });

  factory VoiceMessageResponse.fromJson(Map<String, dynamic> json) {
    return VoiceMessageResponse(
      message: json['message'],
      translation: json['translation'],
      voiceFeedback: VoiceFeedback.fromJson(json['voice_feedback']),
      reviewFeedback: json['review_feedback'] != null
          ? ReviewFeedback.fromJson(json['review_feedback'])
          : null,
    );
  }
}

