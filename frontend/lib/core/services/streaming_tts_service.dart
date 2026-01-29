import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:frontend/core/data/api/api_service.dart';
import 'package:frontend/core/data/local/storage_key_service.dart';
import 'package:frontend/core/cache/cache_constants.dart';

// ============================================================================
// Configuration Constants
// ============================================================================

/// Configuration for TTS download tasks
class _TtsDownloadConfig {
  /// Maximum number of concurrent download tasks
  static const int maxConcurrentDownloads = 3;

  /// Timeout for a single download task
  static const Duration downloadTimeout = Duration(seconds: 60);

  /// Maximum buffer size for a single audio (~5 min @24kHz 16-bit mono ≈ 14MB)
  static const int maxBufferSizeBytes = 15 * 1024 * 1024; // 15MB

  /// Minimum data size to save as partial cache (1 second @24kHz 16-bit mono)
  static const int minPartialSaveBytes = 48000;
}

// ============================================================================
// Exceptions
// ============================================================================

/// TTS service related exceptions
class TtsException implements Exception {
  final String message;
  TtsException(this.message);

  @override
  String toString() => 'TtsException: $message';
}

/// API level errors (e.g., quota exceeded, authentication)
class TtsApiException extends TtsException {
  final int? statusCode;
  TtsApiException(super.message, {this.statusCode});

  @override
  String toString() => 'TtsApiException: $message (status: $statusCode)';
}

// ============================================================================
// Download Task Info
// ============================================================================

/// Represents an active download task
class _DownloadTask {
  final String messageId;
  final String text;
  final Completer<String?> completer;
  final DateTime startedAt;

  _DownloadTask({
    required this.messageId,
    required this.text,
    required this.completer,
  }) : startedAt = DateTime.now();

  Future<String?> get future => completer.future;
}

// ============================================================================
// Streaming TTS Service
// ============================================================================

/// Streaming TTS Service using flutter_soloud
///
/// This service enables true streaming audio playback where audio starts
/// playing as soon as the first chunks arrive, rather than waiting for
/// all data to download.
///
/// ## Key Features (v2.0 - Download/Playback Decoupled)
///
/// - Real-time PCM streaming from GCP TTS API
/// - Low-latency playback using SoLoud engine
/// - **Download continues even after user stops playback**
/// - **Background caching for repeated plays**
/// - Concurrent download management with limits
/// - Timeout and error handling
class StreamingTtsService {
  static StreamingTtsService? _instance;
  static StreamingTtsService get instance {
    _instance ??= StreamingTtsService._();
    return _instance!;
  }

  StreamingTtsService._();

  // --------------------------------------------------------------------------
  // Audio Engine References
  // --------------------------------------------------------------------------

  /// SoLoud instance (for streaming playback)
  SoLoud get _soloud => SoLoud.instance;

  /// AudioPlayer instance (for cached file playback - more reliable on iOS)
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Track if we're using AudioPlayer for current playback
  bool _usingAudioPlayer = false;

  /// Current audio source for streaming
  AudioSource? _currentSource;

  /// Current playback handle
  SoundHandle? _currentHandle;

  // --------------------------------------------------------------------------
  // State Management (NEW in v2.0)
  // --------------------------------------------------------------------------

  /// Registry of active download tasks (key: messageId)
  final Map<String, _DownloadTask> _activeDownloads = {};

  /// Currently playing message ID (null if not playing or using cached file)
  String? _currentPlayingMessageId;

  /// Flag indicating if user explicitly stopped playback
  /// When true, we still continue downloading but don't feed audio to player
  bool _isPlayerStopped = false;

  // --------------------------------------------------------------------------
  // Public State
  // --------------------------------------------------------------------------

  /// Indicates if audio is currently playing
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  /// Indicates if we're currently loading/buffering
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Number of active background downloads
  int get activeDownloadCount => _activeDownloads.length;

  // --------------------------------------------------------------------------
  // Callbacks
  // --------------------------------------------------------------------------

  /// Callback for state changes
  void Function(StreamingTtsState state)? onStateChanged;

  /// Callback when cache file is saved
  /// Returns the path to the cached WAV file
  void Function(String cachePath)? onCacheSaved;

  /// Callback for download errors (useful for background download error reporting)
  void Function(String messageId, String error)? onDownloadError;

  // --------------------------------------------------------------------------
  // Initialization
  // --------------------------------------------------------------------------

  /// Initialize the SoLoud engine
  /// Should be called once at app startup
  Future<void> initialize() async {
    if (!_soloud.isInitialized) {
      await _soloud.init();
    }
  }

  // --------------------------------------------------------------------------
  // Public API: Play Streaming
  // --------------------------------------------------------------------------

  /// Play TTS audio with true streaming and background caching
  ///
  /// This method implements the decoupled download/playback architecture:
  /// 1. If cached file exists → play directly
  /// 2. If download already in progress → wait for it, then play cached
  /// 3. Otherwise → start new download with real-time playback
  ///
  /// [text] - The text to convert to speech
  /// [messageId] - Message ID for cache file naming
  /// [voiceName] - Optional voice name (e.g., "Kore", "Charon")
  /// [languageCode] - Optional language code (e.g., "en-US")
  ///
  /// Returns the path to the cached WAV file after completion
  Future<String?> playStreaming(
    String text, {
    String? messageId,
    String? voiceName,
    String? languageCode,
  }) async {
    final effectiveMessageId =
        messageId ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Validate input
    if (text.trim().isEmpty) {
      throw TtsException('Text cannot be empty');
    }

    // Stop any current playback (but not downloads!)
    await _stopPlaybackOnly();

    _isLoading = true;
    _notifyState(StreamingTtsState.loading);

    try {
      // Strategy 1: Check if cache file already exists
      final cachedPath = await _getCacheFilePath(effectiveMessageId);
      if (cachedPath != null && await File(cachedPath).exists()) {
        if (kDebugMode) {
          debugPrint(
            '🎧 [TTS] Cache hit for $effectiveMessageId, playing cached file',
          );
        }
        _isLoading = false;
        await playCached(cachedPath);
        return cachedPath;
      }

      // Strategy 2: Check if download already in progress
      if (_activeDownloads.containsKey(effectiveMessageId)) {
        if (kDebugMode) {
          debugPrint(
            '🎧 [TTS] Download in progress for $effectiveMessageId, waiting...',
          );
        }
        _notifyState(StreamingTtsState.waitingForDownload);

        // Wait for existing download to complete
        final path = await _activeDownloads[effectiveMessageId]!.future;
        _isLoading = false;

        if (path != null && await File(path).exists()) {
          await playCached(path);
          return path;
        } else {
          throw TtsException('Download completed but file not found');
        }
      }

      // Strategy 3: Check concurrent limit
      if (_activeDownloads.length >=
          _TtsDownloadConfig.maxConcurrentDownloads) {
        if (kDebugMode) {
          debugPrint(
            '🎧 [TTS] Concurrent limit reached, waiting for a slot...',
          );
        }
        // Wait for the oldest download to complete
        final oldestTask = _activeDownloads.values.reduce(
          (a, b) => a.startedAt.isBefore(b.startedAt) ? a : b,
        );
        await oldestTask.future;
      }

      // Strategy 4: Start new download with real-time playback
      if (kDebugMode) {
        debugPrint(
          '🎧 [TTS] Starting new streaming download for $effectiveMessageId',
        );
      }

      return await _startStreamingDownload(
        text: text,
        messageId: effectiveMessageId,
        voiceName: voiceName,
        languageCode: languageCode,
        playWhileDownloading: true,
      );
    } catch (e) {
      _isLoading = false;
      _isPlaying = false;
      _notifyState(StreamingTtsState.error);
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // Core: Streaming Download with Real-time Playback
  // --------------------------------------------------------------------------

  /// Start a streaming download task
  ///
  /// [playWhileDownloading] - If true, feeds audio to player in real-time
  Future<String?> _startStreamingDownload({
    required String text,
    required String messageId,
    String? voiceName,
    String? languageCode,
    required bool playWhileDownloading,
  }) async {
    // Create download task
    final completer = Completer<String?>();
    final task = _DownloadTask(
      messageId: messageId,
      text: text,
      completer: completer,
    );
    _activeDownloads[messageId] = task;

    // Set current playing message
    if (playWhileDownloading) {
      _currentPlayingMessageId = messageId;
      _isPlayerStopped = false;
    }

    // Execute download in background
    _executeDownload(
      task: task,
      voiceName: voiceName,
      languageCode: languageCode,
    );

    // For playWhileDownloading, we return when download completes
    // (but playback may continue in background)
    return completer.future;
  }

  /// Execute the actual download and feed audio to player
  Future<void> _executeDownload({
    required _DownloadTask task,
    String? voiceName,
    String? languageCode,
  }) async {
    final List<Uint8List> buffer = [];
    int totalBytes = 0;
    String? cachedFilePath;
    bool sourceInitialized = false;

    try {
      // Ensure SoLoud is initialized
      await initialize();

      // Create buffer stream for real-time playback (if this message is being played)
      if (_currentPlayingMessageId == task.messageId && !_isPlayerStopped) {
        _currentSource = _soloud.setBufferStream(
          sampleRate: 24000,
          channels: Channels.mono,
          format: BufferType.s16le,
          bufferingType: BufferingType.released,
          bufferingTimeNeeds: 0.3,
          onBuffering: (isBuffering, handle, time) {
            if (_currentPlayingMessageId == task.messageId) {
              if (isBuffering) {
                _notifyState(StreamingTtsState.buffering);
              } else {
                _notifyState(StreamingTtsState.playing);
              }
            }
          },
        );
        _currentHandle = await _soloud.play(_currentSource!);
        _isPlaying = true;
        _isLoading = false;
        sourceInitialized = true;
      }

      // Start API stream with timeout
      final apiService = ApiService();
      bool firstChunkReceived = false;

      await for (final chunk
          in apiService
              .generateTTSStream(
                task.text,
                voiceName: voiceName,
                languageCode: languageCode,
              )
              .timeout(_TtsDownloadConfig.downloadTimeout)) {
        switch (chunk.type) {
          case TTSChunkType.audioChunk:
            if (chunk.audioBase64 != null) {
              final pcmBytes = Uint8List.fromList(
                base64Decode(chunk.audioBase64!),
              );

              // Check buffer size limit
              if (totalBytes + pcmBytes.length >
                  _TtsDownloadConfig.maxBufferSizeBytes) {
                if (kDebugMode) {
                  debugPrint(
                    '🎧 [TTS] Buffer limit reached for ${task.messageId}',
                  );
                }
                // Save what we have and stop
                break;
              }

              buffer.add(pcmBytes);
              totalBytes += pcmBytes.length;

              if (!firstChunkReceived) {
                firstChunkReceived = true;
                if (_currentPlayingMessageId == task.messageId) {
                  _notifyState(StreamingTtsState.playing);
                }
              }

              // Feed to player if this message is currently being played
              if (_currentPlayingMessageId == task.messageId &&
                  !_isPlayerStopped &&
                  _currentSource != null) {
                _soloud.addAudioDataStream(_currentSource!, pcmBytes);
              }
            }
            break;

          case TTSChunkType.info:
            // Duration info received - could log if needed
            break;

          case TTSChunkType.done:
            // Mark stream as complete for player
            if (_currentPlayingMessageId == task.messageId &&
                _currentSource != null) {
              _soloud.setDataIsEnded(_currentSource!);
            }

            // Save to cache file
            if (buffer.isNotEmpty) {
              cachedFilePath = await _saveToCacheFile(buffer, task.messageId);
              if (cachedFilePath != null) {
                onCacheSaved?.call(cachedFilePath);
                if (kDebugMode) {
                  debugPrint(
                    '🎧 [TTS] Cache saved for ${task.messageId}: $cachedFilePath',
                  );
                }
              }
            }
            break;

          case TTSChunkType.error:
            throw TtsApiException(
              chunk.error ?? 'TTS generation failed',
              statusCode: 500,
            );
        }
      }

      // Listen for playback completion if we're playing this message
      if (_currentPlayingMessageId == task.messageId && sourceInitialized) {
        _listenForCompletion();
      }

      // Complete the task
      task.completer.complete(cachedFilePath);
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('🎧 [TTS] Download timeout for ${task.messageId}');
      }

      // Save partial data if enough
      if (buffer.isNotEmpty &&
          totalBytes > _TtsDownloadConfig.minPartialSaveBytes) {
        cachedFilePath = await _saveToCacheFile(
          buffer,
          task.messageId,
          partial: true,
        );
        if (kDebugMode) {
          debugPrint(
            '🎧 [TTS] Saved partial cache for ${task.messageId}: $cachedFilePath',
          );
        }
      }

      task.completer.complete(cachedFilePath);
      onDownloadError?.call(task.messageId, 'Download timeout');
    } on TtsApiException catch (e) {
      if (kDebugMode) {
        debugPrint('🎧 [TTS] API error for ${task.messageId}: $e');
      }
      task.completer.completeError(e);
      onDownloadError?.call(task.messageId, e.message);
      _notifyState(StreamingTtsState.error);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🎧 [TTS] Unexpected error for ${task.messageId}: $e');
      }
      task.completer.completeError(e);
      onDownloadError?.call(task.messageId, e.toString());
      _notifyState(StreamingTtsState.error);
    } finally {
      // Always clean up the download registry
      _activeDownloads.remove(task.messageId);

      // Notify background download state if player was stopped
      if (_isPlayerStopped && _activeDownloads.isEmpty) {
        _notifyState(StreamingTtsState.idle);
      } else if (_isPlayerStopped && _activeDownloads.isNotEmpty) {
        _notifyState(StreamingTtsState.backgroundDownloading);
      }
    }
  }

  // --------------------------------------------------------------------------
  // Cache Management
  // --------------------------------------------------------------------------

  /// Get the expected cache file path for a message
  Future<String?> _getCacheFilePath(String messageId) async {
    try {
      final cacheDir = await getApplicationDocumentsDirectory();
      final storageKey = StorageKeyService();
      final ttsCacheDir = Directory(
        storageKey.getUserScopedPath(cacheDir.path, CacheConstants.ttsCacheDir),
      );

      final safeFileName = messageId.replaceAll(RegExp(r'[^a-zA-Z0-9-_]'), '_');
      return '${ttsCacheDir.path}/$safeFileName.wav';
    } catch (e) {
      return null;
    }
  }

  /// Save collected PCM chunks to a WAV cache file
  Future<String?> _saveToCacheFile(
    List<Uint8List> pcmChunks,
    String messageId, {
    bool partial = false,
  }) async {
    try {
      // Combine all chunks
      int totalLength = pcmChunks.fold(0, (sum, chunk) => sum + chunk.length);
      final pcmData = Uint8List(totalLength);
      int offset = 0;
      for (final chunk in pcmChunks) {
        pcmData.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }

      // Create WAV header
      final wavData = _createWavFile(pcmData);

      // Get cache directory
      final cacheDir = await getApplicationDocumentsDirectory();
      final storageKey = StorageKeyService();
      final ttsCacheDir = Directory(
        storageKey.getUserScopedPath(cacheDir.path, CacheConstants.ttsCacheDir),
      );
      if (!await ttsCacheDir.exists()) {
        await ttsCacheDir.create(recursive: true);
      }

      // Generate filename (add _partial suffix if incomplete)
      final safeFileName = messageId.replaceAll(RegExp(r'[^a-zA-Z0-9-_]'), '_');
      final suffix = partial ? '_partial' : '';
      final audioFile = File('${ttsCacheDir.path}/$safeFileName$suffix.wav');
      await audioFile.writeAsBytes(wavData);

      return audioFile.path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🎧 [TTS] Failed to save cache: $e');
      }
      return null;
    }
  }

  /// Create WAV file from raw PCM data
  /// GCP TTS: 24kHz, 16-bit, mono
  Uint8List _createWavFile(Uint8List pcmData) {
    const sampleRate = 24000;
    const bitsPerSample = 16;
    const numChannels = 1;
    const byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    const blockAlign = numChannels * bitsPerSample ~/ 8;

    final wavData = Uint8List(44 + pcmData.length);
    final byteData = ByteData.view(wavData.buffer);

    // RIFF header
    wavData[0] = 0x52; // 'R'
    wavData[1] = 0x49; // 'I'
    wavData[2] = 0x46; // 'F'
    wavData[3] = 0x46; // 'F'
    byteData.setUint32(4, 36 + pcmData.length, Endian.little); // File size - 8
    wavData[8] = 0x57; // 'W'
    wavData[9] = 0x41; // 'A'
    wavData[10] = 0x56; // 'V'
    wavData[11] = 0x45; // 'E'

    // fmt subchunk
    wavData[12] = 0x66; // 'f'
    wavData[13] = 0x6D; // 'm'
    wavData[14] = 0x74; // 't'
    wavData[15] = 0x20; // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little); // AudioFormat (1 for PCM)
    byteData.setUint16(22, numChannels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, blockAlign, Endian.little);
    byteData.setUint16(34, bitsPerSample, Endian.little);

    // data subchunk
    wavData[36] = 0x64; // 'd'
    wavData[37] = 0x61; // 'a'
    wavData[38] = 0x74; // 't'
    wavData[39] = 0x61; // 'a'
    byteData.setUint32(40, pcmData.length, Endian.little);

    // Copy PCM data
    wavData.setRange(44, 44 + pcmData.length, pcmData);

    return wavData;
  }

  // --------------------------------------------------------------------------
  // Cached Playback
  // --------------------------------------------------------------------------

  /// Play a cached audio file directly (for subsequent plays)
  /// Uses AudioPlayer for better iOS compatibility
  Future<void> playCached(String audioPath) async {
    // Stop and clean up any previous playback
    await _stopPlaybackOnly();

    _isLoading = true;
    _usingAudioPlayer = true;
    _notifyState(StreamingTtsState.loading);

    try {
      // Setup completion listener
      _audioPlayer.onPlayerComplete.listen((_) {
        if (_usingAudioPlayer) {
          _isPlaying = false;
          _usingAudioPlayer = false;
          _notifyState(StreamingTtsState.completed);
        }
      });

      // Play using AudioPlayer (more reliable on iOS)
      await _audioPlayer.play(DeviceFileSource(audioPath));

      _isPlaying = true;
      _isLoading = false;
      _notifyState(StreamingTtsState.playing);
    } catch (e) {
      _isLoading = false;
      _isPlaying = false;
      _usingAudioPlayer = false;
      _notifyState(StreamingTtsState.error);
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // Playback Completion Detection
  // --------------------------------------------------------------------------

  /// Listen for playback completion
  void _listenForCompletion() {
    if (_currentHandle == null) return;

    // Poll for completion
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isPlaying || _currentHandle == null) {
        timer.cancel();
        return;
      }

      final isValid = _soloud.getIsValidVoiceHandle(_currentHandle!);
      if (!isValid) {
        // Playback completed
        timer.cancel();
        _isPlaying = false;
        _currentHandle = null;
        _currentSource = null;
        _currentPlayingMessageId = null;
        _notifyState(StreamingTtsState.completed);
      }
    });
  }

  // --------------------------------------------------------------------------
  // Stop Controls
  // --------------------------------------------------------------------------

  /// Stop playback only (downloads continue in background)
  ///
  /// This is the key change in v2.0: stopping playback does NOT cancel downloads
  Future<void> _stopPlaybackOnly() async {
    try {
      // Stop AudioPlayer if it was being used
      if (_usingAudioPlayer) {
        await _audioPlayer.stop();
        _usingAudioPlayer = false;
      }

      // Stop SoLoud if it was being used
      if (_currentHandle != null) {
        await _soloud.stop(_currentHandle!);
      }

      if (_currentSource != null) {
        await _soloud.disposeSource(_currentSource!);
      }
    } catch (e) {
      // Ignore errors during cleanup
    }

    _currentHandle = null;
    _currentSource = null;
    _isPlaying = false;
    _isLoading = false;
    _isPlayerStopped = true;
    // Note: _currentPlayingMessageId is NOT cleared here to allow download to continue
  }

  /// Stop current playback (public API)
  ///
  /// Downloads continue in background. Use [dispose] to cancel everything.
  Future<void> stop() async {
    await _stopPlaybackOnly();

    // Clear the current playing message ID
    _currentPlayingMessageId = null;

    // Notify appropriate state
    if (_activeDownloads.isNotEmpty) {
      _notifyState(StreamingTtsState.backgroundDownloading);
    } else {
      _notifyState(StreamingTtsState.stopped);
    }
  }

  /// Cancel all downloads and stop playback
  Future<void> cancelAll() async {
    await _stopPlaybackOnly();

    // Cancel all pending downloads
    for (final task in _activeDownloads.values) {
      if (!task.completer.isCompleted) {
        task.completer.complete(null);
      }
    }
    _activeDownloads.clear();

    _currentPlayingMessageId = null;
    _notifyState(StreamingTtsState.stopped);
  }

  // --------------------------------------------------------------------------
  // State Notification
  // --------------------------------------------------------------------------

  /// Notify state change
  void _notifyState(StreamingTtsState state) {
    onStateChanged?.call(state);
  }

  // --------------------------------------------------------------------------
  // Disposal
  // --------------------------------------------------------------------------

  /// Dispose the service
  Future<void> dispose() async {
    await cancelAll();
    // Note: We don't deinit SoLoud as it may be used elsewhere
  }
}

// ============================================================================
// State Enum
// ============================================================================

/// State of the streaming TTS playback
enum StreamingTtsState {
  /// Initial state, not playing
  idle,

  /// Loading/initializing
  loading,

  /// Buffering audio data
  buffering,

  /// Actively playing audio
  playing,

  /// Playback completed successfully
  completed,

  /// Playback was stopped by user (downloads may continue)
  stopped,

  /// Background download in progress (user has stopped playback)
  backgroundDownloading,

  /// Waiting for an in-progress download to complete before playing
  waitingForDownload,

  /// An error occurred
  error,
}
