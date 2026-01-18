import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/features/chat/domain/models/message.dart';
import '../local/preferences_service.dart';
import 'package:frontend/core/env/env.dart';

// 环境枚举
enum Environment {
  localDev, // 本地开发环境 (Wrangler dev server)
  production, // 生产环境 (已部署的 Cloudflare Workers)
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
      if (kDebugMode) {
        debugPrint('⚠️ Warning: No Auth Token available for API call');
      }
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
        if (kDebugMode) {
          debugPrint(
            '🔧 API Environment: LOCAL DEV ($currentEnvironment) -> $_localDevUrl',
          );
        }
        return _localDevUrl;
      case Environment.production:
        if (kDebugMode) {
          debugPrint(
            '🚀 API Environment: PRODUCTION ($currentEnvironment) -> $_productionUrl',
          );
        }
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
        if (kDebugMode) {
          debugPrint('❌ [sendMessage] Status: ${response.statusCode}');
          debugPrint('❌ [sendMessage] Body: ${response.body}');
        }
        throw Exception(
          'Failed to load chat response: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [sendMessage] Exception: $e');
      }
      throw Exception('Error sending message: $e');
    }
  }

  Future<HintResponse> getHints(
    String sceneContext,
    List<Map<String, String>> history,
  ) async {
    try {
      final prefs = PreferencesService();
      final nativeLang = await prefs.getNativeLanguage();
      final targetLang = await prefs.getTargetLanguage();

      final response = await http.post(
        Uri.parse('$baseUrl/chat/hint'),
        headers: _headers(),
        body: jsonEncode({
          'message':
              '', // Not needed for hint request strictly but used in model
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

  Future<SceneGenerationResponse> generateScene(
    String description,
    String tone,
  ) async {
    try {
      // Scene generation might mostly depend on target language for the content,
      // but we pass it anyway if the backend uses it.
      // Currently backend doesn't explicitly look for it in generate_scene but it's good practice.

      final response = await http.post(
        Uri.parse('$baseUrl/scene/generate'),
        headers: _headers(),
        body: jsonEncode({'description': description, 'tone': tone}),
      );

      if (response.statusCode == 200) {
        return SceneGenerationResponse.fromJson(jsonDecode(response.body));
      } else {
        if (kDebugMode) {
          debugPrint('❌ [generateScene] Status: ${response.statusCode}');
          debugPrint('❌ [generateScene] Body: ${response.body}');
        }
        throw Exception(
          'Failed to generate scene: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [generateScene] Exception: $e');
      }
      throw Exception('Error generating scene: $e');
    }
  }

  Future<String> translateText(String text, String targetLanguage) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/common/translate'),
        headers: _headers(),
        body: jsonEncode({'text': text, 'target_language': targetLanguage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translation'];
      } else {
        if (kDebugMode) {
          debugPrint('❌ [translateText] Status: ${response.statusCode}');
          debugPrint('❌ [translateText] Body: ${response.body}');
        }
        throw Exception(
          'Failed to translate text: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [translateText] Exception: $e');
      }
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
        throw Exception(
          'Failed to analyze message: ${streamedResponse.statusCode}',
        );
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
            if (json is Map<String, dynamic> &&
                json.containsKey('type') &&
                json.containsKey('data')) {
              final type = json['type'];
              final data = json['data'];

              switch (type) {
                case 'summary':
                  currentAnalysis = currentAnalysis.copyWith(
                    overallSummary: data as String,
                  );
                  break;
                case 'structure':
                  if (data is Map<String, dynamic>) {
                    currentAnalysis = currentAnalysis.copyWith(
                      sentenceStructure: data['structure'] ?? '',
                      sentenceBreakdown:
                          (data['breakdown'] as List?)
                              ?.map((e) => StructureSegment.fromJson(e))
                              .toList() ??
                          [],
                    );
                  }
                  break;
                case 'grammar':
                  if (data is List) {
                    currentAnalysis = currentAnalysis.copyWith(
                      grammarPoints: data
                          .map((e) => GrammarPoint.fromJson(e))
                          .toList(),
                    );
                  }
                  break;
                case 'vocabulary':
                  if (data is List) {
                    currentAnalysis = currentAnalysis.copyWith(
                      vocabulary: data
                          .map((e) => VocabularyItem.fromJson(e))
                          .toList(),
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
                  currentAnalysis = currentAnalysis.copyWith(
                    pragmaticAnalysis: data as String,
                  );
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
            if (kDebugMode) {
              debugPrint('Error parsing chunk: $e');
            }
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
        body: jsonEncode({'description': description}),
      );

      if (kDebugMode) {
        debugPrint(
          '📝 [polishScenario] Response status: ${response.statusCode}',
        );
        if (response.statusCode != 200) {
          debugPrint(
            '📝 [polishScenario] Response headers: ${response.headers}',
          );
          debugPrint('📝 [polishScenario] Response body: ${response.body}');
        }
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['polished_text'];
      } else {
        if (kDebugMode) {
          debugPrint('❌ [polishScenario] Error: ${response.statusCode}');
          debugPrint('❌ [polishScenario] Body: ${response.body}');
        }
        throw Exception(
          'Failed to polish scenario: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [polishScenario] Exception: $e');
      }
      throw Exception('Error polishing scenario: $e');
    }
  }

  Future<ShadowResult> analyzeShadow(
    String targetText,
    String userAudioText,
  ) async {
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
    List<Map<String, String>> history,
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

  Future<TranscriptionResponse> transcribeAudio(String audioPath) async {
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
      request.files.add(await http.MultipartFile.fromPath('audio', audioPath));

      // Add target language as field
      request.fields['target_language'] = targetLang;

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return TranscriptionResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to transcribe audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error transcribing audio: $e');
    }
  }

  /// Sends a voice message and streams the AI's response.
  ///
  /// This method uses a streaming protocol to deliver a low-latency conversational experience.
  ///
  /// **Stream Protocol Flow:**
  /// 1. **Phase 1: Token Streaming (Event Type: [VoiceStreamEventType.token])**
  ///    - The AI begins replying immediately with pure text tokens.
  ///    - These should be displayed in the AI's chat bubble as they arrive.
  ///
  /// 2. **Phase 2: Metadata (Event Type: [VoiceStreamEventType.metadata])**
  ///    - Once the reply is finished, a special separator `[[METADATA]]` triggers a metadata event.
  ///    - The [metadata] field will contain a [VoiceMessageResponse] object with:
  ///      - `transcript`: The raw text transcription of what the user said (generated by the Multimodal LLM).
  ///      - `translation`: The translation of the AI's reply (Phase 1 content) into the native language.
  ///      - `voiceFeedback`: Pronunciation and grammar feedback on the user's audio.
  ///      - `reviewFeedback`: General language coaching feedback.
  ///
  /// **Usage:**
  /// Listening to this stream allows the UI to populate the AI Message immediately while asynchronously
  /// filling in the User Message's transcript once the audio processing is complete.
  Stream<VoiceStreamEvent> sendVoiceMessage(
    String audioPath,
    String sceneContext,
    List<Map<String, String>> history,
  ) async* {
    final prefs = PreferencesService();
    final nativeLang = await prefs.getNativeLanguage();
    final targetLang = await prefs.getTargetLanguage();

    // Create multipart request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/chat/send-voice'),
    );

    request.headers.addAll(_headers());
    request.files.add(await http.MultipartFile.fromPath('audio', audioPath));
    request.fields['scene_context'] = sceneContext;
    request.fields['history'] = jsonEncode(history);
    request.fields['native_language'] = nativeLang;
    request.fields['target_language'] = targetLang;

    final client = http.Client();
    try {
      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode != 200) {
        throw Exception(
          'Failed to send voice message: ${streamedResponse.statusCode}',
        );
      }

      String buffer = '';

      await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
        buffer += chunk;

        // Process complete lines (NDJSON format)
        while (buffer.contains('\n')) {
          final index = buffer.indexOf('\n');
          final line = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 1);

          if (line.isEmpty) continue;

          try {
            final json = jsonDecode(line);

            if (json is Map<String, dynamic>) {
              final type = json['type'];

              if (type == 'token') {
                // Stream AI reply tokens
                final content = json['content'];
                if (content != null && content.isNotEmpty) {
                  yield VoiceStreamEvent(
                    type: VoiceStreamEventType.token,
                    content: content,
                  );
                }
              } else if (type == 'metadata') {
                // Parse metadata event
                final data = json['data'];
                if (data != null) {
                  final analysis = data['analysis'];

                  // Only create feedback objects if analysis exists
                  VoiceFeedback? voiceFeedback;
                  ReviewFeedback? reviewFeedback;

                  if (analysis != null) {
                    voiceFeedback = VoiceFeedback(
                      pronunciationScore: 0,
                      correctedText: analysis['corrected_text'] ?? '',
                      nativeExpression: analysis['native_expression'] ?? '',
                      feedback: analysis['explanation'] ?? '',
                      sentenceBreakdown: [],
                      errorFocus: null,
                    );

                    reviewFeedback = ReviewFeedback(
                      isPerfect: analysis['is_perfect'] ?? false,
                      correctedText: analysis['corrected_text'] ?? '',
                      nativeExpression: analysis['native_expression'] ?? '',
                      explanation: analysis['explanation'] ?? '',
                      exampleAnswer: analysis['example_answer'] ?? '',
                    );
                  }

                  final response = VoiceMessageResponse(
                    message: '',
                    translation: data['translation'],
                    voiceFeedback:
                        voiceFeedback ??
                        VoiceFeedback(
                          pronunciationScore: 0,
                          correctedText: '',
                          nativeExpression: '',
                          feedback: '',
                          sentenceBreakdown: [],
                          errorFocus: null,
                        ),
                    reviewFeedback: reviewFeedback,
                    transcript: data['transcript'],
                  );

                  yield VoiceStreamEvent(
                    type: VoiceStreamEventType.metadata,
                    metadata: response,
                  );
                }
              } else if (type == 'done') {
                // Stream complete
                break;
              } else if (type == 'error') {
                throw Exception(json['error'] ?? 'Voice message failed');
              }
            }
          } on FormatException {
            // Skip non-JSON lines
            if (kDebugMode) debugPrint("Skipping non-JSON line: $line");
          }
        }
      }

      yield VoiceStreamEvent(type: VoiceStreamEventType.done);
    } catch (e) {
      throw Exception('Error sending voice message: $e');
    } finally {
      client.close();
    }
  }

  // ... (deleteMessages remains same)

  Future<void> deleteMessages(String sceneKey, List<String> messageIds) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/chat/messages'),
        headers: _headers(),
        body: jsonEncode({'scene_key': sceneKey, 'message_ids': messageIds}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting messages: $e');
    }
  }

  /// Generate text-to-speech audio from text using GCP Vertex AI streaming API
  /// Returns a Stream of TTSStreamChunk that yields audio data as it arrives
  ///
  /// NOTE: GCP TTS returns raw PCM audio (24kHz, 16-bit, mono).
  /// The final 'done' chunk includes WAV header for proper playback.
  /// Streaming TTS API with diagnostic logging.
  /// Logs timing information to help diagnose streaming latency.
  Stream<TTSStreamChunk> generateTTSStream(
    String text, {
    String? messageId,
    String? voiceName,
    String? languageCode,
  }) async* {
    final request = http.Request(
      'POST',
      Uri.parse('$baseUrl/tts/gcp/generate'),
    );
    request.headers.addAll(_headers());
    request.body = jsonEncode({
      'text': text,
      if (voiceName != null) 'voice_name': voiceName,
      if (languageCode != null) 'language_code': languageCode,
    });

    final client = http.Client();

    // 🔊 TTS Streaming Diagnostics
    final requestStartTime = DateTime.now();
    DateTime? firstByteTime;
    DateTime? firstAudioChunkTime;
    int totalAudioChunks = 0;
    int totalBytesReceived = 0;

    if (kDebugMode) {
      debugPrint(
        '🔊 [TTS Stream] REQUEST STARTED at ${requestStartTime.toIso8601String()}',
      );
      debugPrint(
        '   Text length: ${text.length} chars, preview: "${text.substring(0, text.length > 50 ? 50 : text.length)}..."',
      );
    }

    try {
      final streamedResponse = await client.send(request);

      // Log when we first got response headers (connection established)
      final connectionTime = DateTime.now();
      if (kDebugMode) {
        debugPrint(
          '🔊 [TTS Stream] CONNECTION ESTABLISHED at ${connectionTime.toIso8601String()}',
        );
        debugPrint(
          '   Latency to first response: ${connectionTime.difference(requestStartTime).inMilliseconds}ms',
        );
        debugPrint('   Status code: ${streamedResponse.statusCode}');
      }

      if (streamedResponse.statusCode != 200) {
        throw Exception(
          'Failed to generate TTS: ${streamedResponse.statusCode}',
        );
      }

      // Buffer for incomplete lines
      String buffer = '';
      final List<String> audioChunksBase64 = [];
      int? durationMs;
      Map<String, dynamic>? audioFormat;

      await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
        // Track first byte timing
        if (firstByteTime == null) {
          firstByteTime = DateTime.now();
          if (kDebugMode) {
            debugPrint(
              '🔊 [TTS Stream] FIRST BYTE RECEIVED at ${firstByteTime.toIso8601String()}',
            );
            debugPrint(
              '   Time since request: ${firstByteTime.difference(requestStartTime).inMilliseconds}ms',
            );
          }
        }

        buffer += chunk;

        while (buffer.contains('\n')) {
          final index = buffer.indexOf('\n');
          final line = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 1);

          if (line.isEmpty) continue;

          try {
            final json = jsonDecode(line);
            if (json is Map<String, dynamic>) {
              final type = json['type'];

              switch (type) {
                case 'audio_chunk':
                  final audioBase64 = json['audio_base64'] as String?;
                  // Store audio format info (PCM specs from GCP)
                  if (json['audio_format'] != null) {
                    audioFormat = json['audio_format'] as Map<String, dynamic>;
                  }
                  if (audioBase64 != null) {
                    // Track first audio chunk timing
                    if (firstAudioChunkTime == null) {
                      firstAudioChunkTime = DateTime.now();
                      if (kDebugMode) {
                        debugPrint(
                          '🔊 [TTS Stream] FIRST AUDIO CHUNK at ${firstAudioChunkTime.toIso8601String()}',
                        );
                        debugPrint(
                          '   Time since request: ${firstAudioChunkTime.difference(requestStartTime).inMilliseconds}ms',
                        );
                        debugPrint(
                          '   ⚠️ NOTE: Audio playback should START NOW for true streaming!',
                        );
                      }
                    }

                    totalAudioChunks++;
                    final chunkBytes = base64Decode(audioBase64).length;
                    totalBytesReceived += chunkBytes;

                    if (kDebugMode) {
                      debugPrint(
                        '🔊 [TTS Stream] Audio chunk #$totalAudioChunks received: $chunkBytes bytes (total: $totalBytesReceived bytes)',
                      );
                    }

                    audioChunksBase64.add(audioBase64);
                    yield TTSStreamChunk(
                      type: TTSChunkType.audioChunk,
                      audioBase64: audioBase64,
                      chunkIndex: json['chunk_index'] as int? ?? 0,
                      allChunksBase64: List.from(audioChunksBase64),
                      audioFormat: audioFormat,
                    );
                  }
                  break;
                case 'info':
                  durationMs = json['duration_ms'] as int?;
                  yield TTSStreamChunk(
                    type: TTSChunkType.info,
                    durationMs: durationMs,
                    audioFormat: audioFormat,
                  );
                  break;
                case 'done':
                  final doneTime = DateTime.now();

                  if (kDebugMode) {
                    debugPrint(
                      '🔊 [TTS Stream] ALL DATA RECEIVED at ${doneTime.toIso8601String()}',
                    );
                    debugPrint(
                      '   Total time: ${doneTime.difference(requestStartTime).inMilliseconds}ms',
                    );
                    debugPrint('   Total chunks: $totalAudioChunks');
                    debugPrint('   Total audio bytes: $totalBytesReceived');
                    if (firstAudioChunkTime != null) {
                      debugPrint(
                        '   ⏱️ Streaming window (first chunk to done): ${doneTime.difference(firstAudioChunkTime).inMilliseconds}ms',
                      );
                      debugPrint(
                        '   ⚠️ If playback starts AFTER this point, streaming is NOT being utilized!',
                      );
                    }
                  }

                  // Combine all PCM chunks and add WAV header
                  String? finalAudioBase64;
                  if (audioChunksBase64.isNotEmpty) {
                    finalAudioBase64 = _combinePcmChunksWithWavHeader(
                      audioChunksBase64,
                    );
                  }
                  yield TTSStreamChunk(
                    type: TTSChunkType.done,
                    allChunksBase64: List.from(audioChunksBase64),
                    audioBase64: finalAudioBase64,
                    durationMs: durationMs,
                    audioFormat: audioFormat,
                  );
                  break;
                case 'error':
                  throw Exception(json['error'] ?? 'TTS generation failed');
              }
            }
          } catch (e) {
            if (e is Exception) rethrow;
            if (kDebugMode) {
              debugPrint('Error parsing TTS chunk: $e');
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error generating TTS: $e');
    } finally {
      client.close();
    }
  }

  /// Combine PCM audio chunks and add WAV header for playback
  /// GCP TTS returns raw 16-bit PCM at 24kHz mono
  String _combinePcmChunksWithWavHeader(List<String> chunksBase64) {
    // Decode all base64 chunks and combine
    final List<int> pcmBytes = [];
    for (final chunk in chunksBase64) {
      pcmBytes.addAll(base64Decode(chunk));
    }

    // Create WAV header (44 bytes)
    const int sampleRate = 24000;
    const int bitsPerSample = 16;
    const int numChannels = 1;
    final int dataSize = pcmBytes.length;
    final int byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    const int blockAlign = numChannels * bitsPerSample ~/ 8;

    final wavHeader = <int>[
      // RIFF header
      0x52, 0x49, 0x46, 0x46, // "RIFF"
      ...(_intToBytes(36 + dataSize, 4)), // File size - 8
      0x57, 0x41, 0x56, 0x45, // "WAVE"
      // fmt subchunk
      0x66, 0x6D, 0x74, 0x20, // "fmt "
      0x10, 0x00, 0x00, 0x00, // Subchunk1Size (16 for PCM)
      0x01, 0x00, // AudioFormat (1 for PCM)
      ...(_intToBytes(numChannels, 2)), // NumChannels
      ...(_intToBytes(sampleRate, 4)), // SampleRate
      ...(_intToBytes(byteRate, 4)), // ByteRate
      ...(_intToBytes(blockAlign, 2)), // BlockAlign
      ...(_intToBytes(bitsPerSample, 2)), // BitsPerSample
      // data subchunk
      0x64, 0x61, 0x74, 0x61, // "data"
      ...(_intToBytes(dataSize, 4)), // Subchunk2Size
    ];

    // Combine header and PCM data
    final wavData = [...wavHeader, ...pcmBytes];

    // Encode to base64
    return base64Encode(Uint8List.fromList(wavData));
  }

  /// Convert integer to little-endian bytes
  List<int> _intToBytes(int value, int numBytes) {
    final bytes = <int>[];
    for (int i = 0; i < numBytes; i++) {
      bytes.add((value >> (8 * i)) & 0xFF);
    }
    return bytes;
  }

  /// Generate text-to-speech audio from text (non-streaming fallback)
  /// Returns TTSResponse with base64-encoded WAV audio data
  Future<TTSResponse> generateTTS(
    String text, {
    String? voiceName,
    String? languageCode,
  }) async {
    try {
      // Use streaming API and get the final WAV audio
      String? finalAudioBase64;
      int? durationMs;

      await for (final chunk in generateTTSStream(
        text,
        voiceName: voiceName,
        languageCode: languageCode,
      )) {
        // The 'done' chunk contains the complete WAV with header
        if (chunk.type == TTSChunkType.done && chunk.audioBase64 != null) {
          finalAudioBase64 = chunk.audioBase64;
        }
        if (chunk.durationMs != null) {
          durationMs = chunk.durationMs;
        }
      }

      if (finalAudioBase64 == null) {
        return TTSResponse(error: 'No audio received');
      }

      return TTSResponse(audioBase64: finalAudioBase64, durationMs: durationMs);
    } catch (e) {
      return TTSResponse(error: e.toString());
    }
  }

  /// Dispose resources
  void dispose() {
    // Currently ApiService is stateless (clients are created per request),
    // so there are no permanent resources to dispose.
    // This method is kept for consistency and future state management.
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
  final String? transcript;

  VoiceMessageResponse({
    required this.message,
    this.translation,
    required this.voiceFeedback,
    this.reviewFeedback,
    this.transcript,
  });

  factory VoiceMessageResponse.fromJson(Map<String, dynamic> json) {
    return VoiceMessageResponse(
      message: json['message'],
      translation: json['translation'],
      voiceFeedback: VoiceFeedback.fromJson(json['voice_feedback']),
      reviewFeedback: json['review_feedback'] != null
          ? ReviewFeedback.fromJson(json['review_feedback'])
          : null,
      transcript: json['transcript'],
    );
  }
}

/// Response from TTS API containing audio data
class TTSResponse {
  final String? audioUrl;
  final String? audioBase64;
  final int? durationMs;
  final String? error;

  TTSResponse({this.audioUrl, this.audioBase64, this.durationMs, this.error});

  factory TTSResponse.fromJson(Map<String, dynamic> json) {
    return TTSResponse(
      audioUrl: json['audio_url'],
      audioBase64: json['audio_base64'],
      durationMs: json['duration_ms'],
      error: json['error'],
    );
  }

  bool get hasAudio => audioBase64 != null || audioUrl != null;
}

/// Type of TTS stream chunk
enum TTSChunkType { audioChunk, info, done, error }

/// A chunk of streaming TTS audio data
/// NOTE: GCP TTS returns PCM audio; WAV header is added in the 'done' chunk
class TTSStreamChunk {
  final TTSChunkType type;
  final String? audioBase64;
  final int? chunkIndex;
  final int? durationMs;
  final List<String>? allChunksBase64;
  final String? error;

  /// Audio format info from GCP (PCM specs: sample_rate, bits_per_sample, etc.)
  final Map<String, dynamic>? audioFormat;

  TTSStreamChunk({
    required this.type,
    this.audioBase64,
    this.chunkIndex,
    this.durationMs,
    this.allChunksBase64,
    this.error,
    this.audioFormat,
  });

  /// Combine all collected chunks into a single base64 string (raw PCM, no WAV header)
  String? get combinedAudioBase64 =>
      allChunksBase64?.isNotEmpty == true ? allChunksBase64!.join('') : null;
}

enum VoiceStreamEventType { token, metadata, done }

class VoiceStreamEvent {
  final VoiceStreamEventType type;
  final String? content;
  final VoiceMessageResponse? metadata;

  VoiceStreamEvent({required this.type, this.content, this.metadata});
}

class TranscriptionResponse {
  final String text; // Optimized text
  final String rawText; // Original raw transcription

  TranscriptionResponse({required this.text, required this.rawText});

  factory TranscriptionResponse.fromJson(Map<String, dynamic> json) {
    return TranscriptionResponse(
      text: json['text'] ?? '',
      rawText: json['raw_text'] ?? '',
    );
  }
}
