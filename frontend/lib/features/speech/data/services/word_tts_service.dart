import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:frontend/core/env/env.dart';

/// Service for playing word pronunciation using a hybrid TTS strategy.
///
/// Strategy (per document):
/// ```
/// 用户点击单词
///     ↓
/// [1. 检查本地缓存] ───(有)──→ 直接播放 ✅
///     ↓ (无)
/// [2. 检查语言是否本地 TTS 支持]
///     ↓
///   ┌─(支持)────→ [3a] 本地 TTS 播放 ✅（零成本）
///   │
///   └─(不支持)──→ [3b] 请求云端 TTS → 播放 → 缓存
/// ```
///
/// Features:
/// - Local cache for repeated playback
/// - Local TTS for supported languages (zero cost)
/// - Cloud TTS via MiniMax API as fallback
/// - Debounce for rapid taps
class WordTtsService {
  static final WordTtsService _instance = WordTtsService._internal();
  factory WordTtsService() => _instance;
  WordTtsService._internal() {
    _initLocalTts();
  }

  // Audio player for cached/cloud audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Local TTS engine
  final FlutterTts _flutterTts = FlutterTts();
  bool _isLocalTtsInitialized = false;
  Set<String> _supportedLanguages = {};

  // Track currently playing word to prevent duplicate requests
  String? _currentlyPlayingWord;
  bool _isLoading = false;

  // Debounce: minimum interval between plays (ms)
  static const int _debounceMs = 300;
  DateTime? _lastPlayTime;

  /// Check if currently loading audio
  bool get isLoading => _isLoading;

  /// Check if currently playing
  bool get isPlaying => _currentlyPlayingWord != null;

  /// Get the currently playing word
  String? get currentlyPlayingWord => _currentlyPlayingWord;

  /// Initialize local TTS engine
  Future<void> _initLocalTts() async {
    try {
      // Get available languages
      final languages = await _flutterTts.getLanguages;
      if (languages != null) {
        _supportedLanguages = Set<String>.from(
          (languages as List).map((e) => e.toString().toLowerCase()),
        );
      }

      // Configure TTS settings
      await _flutterTts.setSpeechRate(0.45); // Slightly slower for clarity
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Set completion handler
      _flutterTts.setCompletionHandler(() {
        _currentlyPlayingWord = null;
      });

      _isLocalTtsInitialized = true;

      if (kDebugMode) {
        debugPrint(
            '🎤 Local TTS initialized. Supported languages: ${_supportedLanguages.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to initialize local TTS: $e');
      }
      _isLocalTtsInitialized = false;
    }
  }

  /// Check if a language is supported by local TTS
  Future<bool> isLocalTtsAvailable(String language) async {
    if (!_isLocalTtsInitialized) {
      await _initLocalTts();
    }

    // Normalize language code (e.g., "en-US" -> "en_us" or "en-us")
    final normalized = language.toLowerCase().replaceAll('-', '_');
    final shortCode = language.split('-').first.toLowerCase();

    // Check exact match or short code match
    return _supportedLanguages.contains(normalized) ||
        _supportedLanguages.contains(language.toLowerCase()) ||
        _supportedLanguages.any((lang) => lang.startsWith(shortCode));
  }

  /// Play pronunciation for a word using hybrid strategy.
  /// Returns true if playback started successfully.
  Future<bool> speakWord(String word, {String language = 'en-US'}) async {
    // Debounce rapid taps
    final now = DateTime.now();
    if (_lastPlayTime != null &&
        now.difference(_lastPlayTime!).inMilliseconds < _debounceMs) {
      if (kDebugMode) {
        debugPrint('🔇 WordTTS: Debounced (too fast)');
      }
      return false;
    }
    _lastPlayTime = now;

    // If same word is already playing, stop it
    if (_currentlyPlayingWord == word) {
      await stop();
      return false;
    }

    // If another word is playing, stop it first
    if (_currentlyPlayingWord != null) {
      await stop();
    }

    try {
      _isLoading = true;
      _currentlyPlayingWord = word;

      // ========== Step 1: Check local cache ==========
      final cachedPath = await _getCachedAudioPath(word, language);
      if (cachedPath != null) {
        if (kDebugMode) {
          debugPrint('🎵 WordTTS: Playing from cache: $word');
        }
        await _playAudioFile(cachedPath);
        return true;
      }

      // ========== Step 2: Check if local TTS supports this language ==========
      final localTtsSupported = await isLocalTtsAvailable(language);

      if (localTtsSupported) {
        // ========== Step 3a: Use local TTS (zero cost) ==========
        if (kDebugMode) {
          debugPrint('🎤 WordTTS: Using local TTS for: $word ($language)');
        }
        await _playWithLocalTts(word, language);
        return true;
      }

      // ========== Step 3b: Use cloud TTS ==========
      if (kDebugMode) {
        debugPrint('🌐 WordTTS: Fetching from cloud API: $word');
      }

      final audioBase64 = await _fetchWordAudio(word, language);
      if (audioBase64 == null) {
        _isLoading = false;
        _currentlyPlayingWord = null;
        return false;
      }

      // Save to cache
      final savedPath = await _saveToCache(word, language, audioBase64);
      if (savedPath != null) {
        await _playAudioFile(savedPath);
        return true;
      }

      // Fallback: play directly from base64
      final bytes = base64Decode(audioBase64);
      await _audioPlayer.play(BytesSource(bytes));
      _isLoading = false;
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ WordTTS Error: $e');
      }
      _isLoading = false;
      _currentlyPlayingWord = null;
      return false;
    }
  }

  /// Play word using local TTS engine
  Future<void> _playWithLocalTts(String word, String language) async {
    _isLoading = false;

    // Set language
    await _flutterTts.setLanguage(language);

    // Normalize word for TTS
    // Single uppercase letters like "I" get spelled out as "Capital I"
    // Convert to lowercase to speak naturally
    String textToSpeak = word;
    if (word.length == 1 && word == word.toUpperCase()) {
      textToSpeak = word.toLowerCase();
    }

    // Speak the word
    await _flutterTts.speak(textToSpeak);
  }

  /// Stop current playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    await _flutterTts.stop();
    _currentlyPlayingWord = null;
    _isLoading = false;
  }

  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
  }

  /// Clear all cached audio files
  Future<void> clearCache({String? language}) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final cacheBaseDir = Directory('${docsDir.path}/word_tts_cache');

      if (language != null) {
        // Clear specific language cache
        final langDir = Directory('${cacheBaseDir.path}/$language');
        if (await langDir.exists()) {
          await langDir.delete(recursive: true);
        }
      } else {
        // Clear all cache
        if (await cacheBaseDir.exists()) {
          await cacheBaseDir.delete(recursive: true);
        }
      }

      if (kDebugMode) {
        debugPrint(
            '🗑️ WordTTS: Cache cleared ${language != null ? "for $language" : "(all)"}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Cache clear error: $e');
      }
    }
  }

  // ==================== Private Methods ====================

  /// Get base URL for API
  String get _baseUrl {
    const useProd = bool.fromEnvironment('USE_PROD', defaultValue: false);
    return useProd ? Env.prodBackendUrl : Env.localBackendUrl;
  }

  /// Get auth headers
  Map<String, String> _headers() {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Generate cache key for a word (MD5 hash, lowercase)
  String _getCacheKey(String word) {
    final normalized = word.toLowerCase().trim();
    final bytes = utf8.encode(normalized);
    final hash = md5.convert(bytes).toString();
    return hash.substring(0, 16); // First 16 chars is enough
  }

  /// Get cache directory for a language
  Future<Directory> _getCacheDir(String language) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${docsDir.path}/word_tts_cache/$language');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Check if audio is cached and return path
  Future<String?> _getCachedAudioPath(String word, String language) async {
    try {
      final cacheDir = await _getCacheDir(language);
      final cacheKey = _getCacheKey(word);

      // Look for any audio file with this key
      await for (final entity in cacheDir.list()) {
        if (entity is File) {
          final fileName = entity.path.split('/').last;
          final nameWithoutExt = fileName.split('.').first;
          if (nameWithoutExt == cacheKey) {
            return entity.path;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Cache lookup error: $e');
      }
    }
    return null;
  }

  /// Fetch word audio from cloud API
  Future<String?> _fetchWordAudio(String word, String language) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/tts/word'),
        headers: _headers(),
        body: jsonEncode({
          'word': word,
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['audio_base64'] as String?;
      } else {
        if (kDebugMode) {
          debugPrint('TTS API error: ${response.statusCode} ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TTS API request failed: $e');
      }
      return null;
    }
  }

  /// Save audio to cache
  Future<String?> _saveToCache(
    String word,
    String language,
    String audioBase64,
  ) async {
    try {
      final cacheDir = await _getCacheDir(language);
      final cacheKey = _getCacheKey(word);
      final filePath = '${cacheDir.path}/$cacheKey.mp3';

      final file = File(filePath);
      final bytes = base64Decode(audioBase64);
      await file.writeAsBytes(bytes);

      if (kDebugMode) {
        debugPrint('💾 WordTTS: Cached $word -> $cacheKey.mp3');
      }

      return filePath;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Cache save error: $e');
      }
      return null;
    }
  }

  /// Play audio from file path
  Future<void> _playAudioFile(String filePath) async {
    _isLoading = false;

    // Setup completion listener
    _audioPlayer.onPlayerComplete.listen((_) {
      _currentlyPlayingWord = null;
    });

    await _audioPlayer.play(UrlSource(Uri.file(filePath).toString()));
  }
}
