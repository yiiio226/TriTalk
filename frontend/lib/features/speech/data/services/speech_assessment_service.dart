import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:frontend/core/data/api/api_service.dart';
import '../../domain/models/pronunciation_result.dart';

/// 发音评估服务
/// Speech Assessment Service for Azure AI Speech Pronunciation Assessment
///
/// This service uses raw HTTP calls (not Swagger-generated client) as recommended
/// for multipart/form-data endpoints involving file uploads. This provides:
/// - Full control over binary file encoding
/// - Better error debugging
/// - More reliable multipart request handling
class SpeechAssessmentService {
  static final SpeechAssessmentService _instance =
      SpeechAssessmentService._internal();
  factory SpeechAssessmentService() => _instance;
  SpeechAssessmentService._internal();

  /// 获取 API base URL (复用 ApiService 的环境配置)
  String get _baseUrl => ApiService.baseUrl;

  /// 构建请求头 (带认证)
  Map<String, String> _headers() {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';

    if (token.isEmpty && kDebugMode) {
      debugPrint('⚠️ Warning: No Auth Token available for speech assessment');
    }

    return {'Authorization': 'Bearer $token'};
  }

  /// 评估用户发音 (从文件)
  ///
  /// [audioFile] - 录音文件 (推荐 WAV 格式, 16kHz, Mono)
  /// [referenceText] - 用户应该朗读的参考文本
  /// [language] - 语言代码 (默认: en-US)
  /// [enableProsody] - 是否启用语调评估
  ///
  /// Returns [PronunciationResult] with detailed phoneme-level feedback
  Future<PronunciationResult> assessPronunciation({
    required File audioFile,
    required String referenceText,
    String language = 'en-US',
    bool enableProsody = true,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/speech/assess');

      // 构建 multipart 请求
      final request = http.MultipartRequest('POST', uri);

      // 添加认证头
      request.headers.addAll(_headers());

      // 添加表单字段
      request.fields['reference_text'] = referenceText;
      request.fields['language'] = language;
      request.fields['enable_prosody'] = enableProsody.toString();

      // 添加音频文件 (WAV format with PCM encoding, required by Azure)
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
          filename: 'audio.wav',
          contentType: MediaType('audio', 'wav'),
        ),
      );

      if (kDebugMode) {
        debugPrint(
          '\n\n\n🎤🎤🎤🎤🎤 SpeechAssessment: Sending request to $uri',
        );
        debugPrint(
          '   Reference text: "${referenceText.substring(0, referenceText.length.clamp(0, 50))}..."',
        );
        debugPrint('   Language: $language, Prosody: $enableProsody');
      }

      // 发送请求
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = PronunciationResult.fromJson(data);

        if (kDebugMode) {
          debugPrint('✅ SpeechAssessment: Success');
          debugPrint('   Pronunciation Score: ${result.pronunciationScore}');
          debugPrint('   Accuracy Score: ${result.accuracyScore}');
          debugPrint('   Words analyzed: ${result.wordFeedback.length}');
        }

        return result;
      } else {
        // Log detailed error information
        if (kDebugMode) {
          debugPrint('❌ SpeechAssessment: HTTP Error');
          debugPrint('   Status Code: ${response.statusCode}');
          debugPrint('   Response Headers: ${response.headers}');
          debugPrint('   Response Body: ${response.body}');
        }

        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage =
            errorData['error'] ??
            'Failed to assess pronunciation: ${response.statusCode}';

        throw SpeechAssessmentException(
          '$errorMessage (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is SpeechAssessmentException) rethrow;

      if (kDebugMode) {
        debugPrint('❌ SpeechAssessment exception: $e');
        debugPrint('   Exception type: ${e.runtimeType}');
      }
      throw SpeechAssessmentException('Error assessing pronunciation: $e');
    }
  }

  /// 评估用户发音 (从字节数据)
  ///
  /// 用于录音后直接评估，避免临时文件
  ///
  /// [audioBytes] - 音频字节数据 (推荐 PCM 16kHz Mono)
  /// [referenceText] - 用户应该朗读的参考文本
  /// [language] - 语言代码 (默认: en-US)
  /// [enableProsody] - 是否启用语调评估
  Future<PronunciationResult> assessPronunciationFromBytes({
    required List<int> audioBytes,
    required String referenceText,
    String language = 'en-US',
    bool enableProsody = true,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/speech/assess');

      final request = http.MultipartRequest('POST', uri);

      // 添加认证头
      request.headers.addAll(_headers());

      // 添加表单字段
      request.fields['reference_text'] = referenceText;
      request.fields['language'] = language;
      request.fields['enable_prosody'] = enableProsody.toString();

      // 从字节创建文件 (WAV format with PCM encoding, required by Azure)
      request.files.add(
        http.MultipartFile.fromBytes(
          'audio',
          audioBytes,
          filename: 'audio.wav',
          contentType: MediaType('audio', 'wav'),
        ),
      );

      if (kDebugMode) {
        debugPrint(
          '\n\n\n\n 🎤🎤🎤 SpeechAssessment: Sending ${audioBytes.length} bytes',
        );
        debugPrint(
          '   Reference text: "${referenceText.substring(0, referenceText.length.clamp(0, 50))}..."',
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return PronunciationResult.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw SpeechAssessmentException(
          errorData['error'] ??
              'Failed to assess pronunciation: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is SpeechAssessmentException) rethrow;

      if (kDebugMode) {
        debugPrint('❌ SpeechAssessment error: $e');
      }
      throw SpeechAssessmentException('Error assessing pronunciation: $e');
    }
  }

  /// 评估用户发音 (从音频路径字符串)
  ///
  /// 便捷方法，接受路径字符串而非 File 对象
  Future<PronunciationResult> assessPronunciationFromPath({
    required String audioPath,
    required String referenceText,
    String language = 'en-US',
    bool enableProsody = true,
  }) async {
    return assessPronunciation(
      audioFile: File(audioPath),
      referenceText: referenceText,
      language: language,
      enableProsody: enableProsody,
    );
  }
}

/// 发音评估异常
class SpeechAssessmentException implements Exception {
  final String message;

  SpeechAssessmentException(this.message);

  @override
  String toString() => 'SpeechAssessmentException: $message';
}
