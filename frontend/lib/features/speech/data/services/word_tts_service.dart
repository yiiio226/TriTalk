import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:frontend/core/env/env.dart';

/// Service for playing word pronunciation using cloud TTS.
///
/// Features:
/// - Cloud TTS via MiniMax API
/// - Disk caching for repeated playback
/// - Debounce for rapid taps
class WordTtsService {
  static final WordTtsService _instance = WordTtsService._internal();
  factory WordTtsService() => _instance;
  WordTtsService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

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

  /// Play pronunciation for a word.
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

      // Try cache first
      final cachedPath = await _getCachedAudioPath(word, language);
      if (cachedPath != null) {
        if (kDebugMode) {
          debugPrint('🎵 WordTTS: Playing from cache: $word');
        }
        await _playAudio(cachedPath);
        return true;
      }

      // Fetch from API
      if (kDebugMode) {
        debugPrint('🌐 WordTTS: Fetching from API: $word');
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
        await _playAudio(savedPath);
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

  /// Stop current playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentlyPlayingWord = null;
    _isLoading = false;
  }

  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
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

  /// Fetch word audio from API
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
  Future<void> _playAudio(String filePath) async {
    _isLoading = false;

    // Setup completion listener
    _audioPlayer.onPlayerComplete.listen((_) {
      _currentlyPlayingWord = null;
    });

    await _audioPlayer.play(UrlSource(Uri.file(filePath).toString()));
  }
}
