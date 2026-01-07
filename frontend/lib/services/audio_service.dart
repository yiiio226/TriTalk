import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

/// AudioService - Handles TTS audio playback with local caching
///
/// This service implements the client-first caching strategy:
/// 1. Check local cache for existing audio
/// 2. If cached, play from local file
/// 3. If not cached, request from backend, cache, then play
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Track current playing state
  String? _currentlyPlayingMessageId;
  bool _isPlaying = false;

  // Cache directory path
  String? _cacheDirPath;

  /// Get the cache directory path
  Future<String> get _cacheDir async {
    if (_cacheDirPath != null) return _cacheDirPath!;

    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/audio_cache');

    // Create directory if it doesn't exist
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    _cacheDirPath = cacheDir.path;
    return _cacheDirPath!;
  }

  /// Get the local cache file path for a message
  Future<String> _getCacheFilePath(String messageId) async {
    final dir = await _cacheDir;
    return '$dir/$messageId.mp3';
  }

  /// Check if audio is cached locally
  Future<bool> isAudioCached(String messageId) async {
    final filePath = await _getCacheFilePath(messageId);
    return File(filePath).exists();
  }

  /// Get player state
  bool get isPlaying => _isPlaying;
  String? get currentlyPlayingMessageId => _currentlyPlayingMessageId;

  /// Play audio for a message
  /// Returns true if playback started successfully
  Future<bool> playAudio({
    required String messageId,
    required String audioUrl,
  }) async {
    try {
      // If currently playing the same message, toggle pause/play
      if (_currentlyPlayingMessageId == messageId && _isPlaying) {
        await pause();
        return true;
      }

      // Stop any current playback
      await stop();

      // Check local cache first
      final cacheFilePath = await _getCacheFilePath(messageId);
      final cacheFile = File(cacheFilePath);

      if (await cacheFile.exists()) {
        // Play from local cache
        await _player.setFilePath(cacheFilePath);
      } else {
        // Download and cache, then play
        await _downloadAndCache(audioUrl, cacheFilePath);
        await _player.setFilePath(cacheFilePath);
      }

      _currentlyPlayingMessageId = messageId;
      _isPlaying = true;

      // Listen for playback completion
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _currentlyPlayingMessageId = null;
        }
      });

      await _player.play();
      return true;
    } catch (e) {
      print('AudioService: Error playing audio: $e');
      _isPlaying = false;
      _currentlyPlayingMessageId = null;
      return false;
    }
  }

  /// Download audio from URL and save to local cache
  Future<void> _downloadAndCache(String url, String filePath) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Failed to download audio: ${response.statusCode}');
      }
    } catch (e) {
      print('AudioService: Error downloading audio: $e');
      rethrow;
    }
  }

  /// Pause current playback
  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  /// Resume playback
  Future<void> resume() async {
    await _player.play();
    _isPlaying = true;
  }

  /// Stop playback and reset
  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _currentlyPlayingMessageId = null;
  }

  /// Clear all cached audio files
  Future<void> clearCache() async {
    try {
      final dir = Directory(await _cacheDir);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create();
      }
      _cacheDirPath = null; // Reset so it gets recreated
    } catch (e) {
      print('AudioService: Error clearing cache: $e');
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    try {
      final dir = Directory(await _cacheDir);
      if (!await dir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in dir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Dispose the audio player
  void dispose() {
    _player.dispose();
  }
}
