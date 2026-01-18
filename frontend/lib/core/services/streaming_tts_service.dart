import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:frontend/core/data/api/api_service.dart';
import 'package:frontend/core/data/local/storage_key_service.dart';

/// Streaming TTS Service using flutter_soloud
///
/// This service enables true streaming audio playback where audio starts
/// playing as soon as the first chunks arrive, rather than waiting for
/// all data to download.
///
/// Key features:
/// - Real-time PCM streaming from GCP TTS API
/// - Low-latency playback using SoLoud engine
/// - Auto-buffering with pause/resume when network is slow
/// - Automatic caching of audio files for future playback
class StreamingTtsService {
  static StreamingTtsService? _instance;
  static StreamingTtsService get instance {
    _instance ??= StreamingTtsService._();
    return _instance!;
  }

  StreamingTtsService._();

  /// SoLoud instance
  SoLoud get _soloud => SoLoud.instance;

  /// Current audio source for streaming
  AudioSource? _currentSource;

  /// Current playback handle
  SoundHandle? _currentHandle;

  /// Indicates if a stream is currently playing
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  /// Indicates if we're currently loading/buffering
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Callback for state changes
  void Function(StreamingTtsState state)? onStateChanged;

  /// Callback when cache file is saved
  /// Returns the path to the cached WAV file
  void Function(String cachePath)? onCacheSaved;

  /// Initialize the SoLoud engine
  /// Should be called once at app startup
  Future<void> initialize() async {
    if (!_soloud.isInitialized) {
      if (kDebugMode) {
        debugPrint('🔊 [StreamingTTS] Initializing SoLoud engine...');
      }
      await _soloud.init();
      if (kDebugMode) {
        debugPrint('🔊 [StreamingTTS] SoLoud engine initialized');
      }
    }
  }

  /// Play TTS audio with true streaming and caching
  /// Audio starts playing as soon as the first chunks arrive
  /// After playback, the audio is cached as a WAV file
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
    // Stop any current playback
    await stop();

    _isLoading = true;
    _notifyState(StreamingTtsState.loading);

    final startTime = DateTime.now();
    if (kDebugMode) {
      debugPrint('🔊 [StreamingTTS] Starting streaming playback');
      debugPrint(
        '   Text: "${text.substring(0, text.length > 50 ? 50 : text.length)}..."',
      );
    }

    // Collect all PCM chunks for caching
    final List<Uint8List> pcmChunks = [];
    String? cachedFilePath;

    try {
      // Ensure SoLoud is initialized
      await initialize();

      // Create a buffer stream for PCM audio
      // GCP TTS returns: 24kHz, 16-bit signed LE, mono
      _currentSource = _soloud.setBufferStream(
        sampleRate: 24000,
        channels: Channels.mono,
        format: BufferType.s16le,
        bufferingType: BufferingType.released, // Free memory after playing
        bufferingTimeNeeds: 0.3, // 300ms buffer before starting playback
        onBuffering: (isBuffering, handle, time) {
          if (kDebugMode) {
            debugPrint(
              '🔊 [StreamingTTS] Buffering: $isBuffering, time: ${time}s',
            );
          }
          if (isBuffering) {
            _notifyState(StreamingTtsState.buffering);
          } else {
            _notifyState(StreamingTtsState.playing);
          }
        },
      );

      if (kDebugMode) {
        debugPrint('🔊 [StreamingTTS] Buffer stream created');
      }

      // Start playback immediately (will auto-pause until enough data)
      _currentHandle = await _soloud.play(_currentSource!);
      _isPlaying = true;
      _isLoading = false;

      if (kDebugMode) {
        final playStartTime = DateTime.now();
        debugPrint(
          '🔊 [StreamingTTS] ▶️ Playback started at ${playStartTime.toIso8601String()}',
        );
        debugPrint(
          '   Time to first play: ${playStartTime.difference(startTime).inMilliseconds}ms',
        );
      }

      // Start receiving audio chunks from API
      final apiService = ApiService();
      int totalChunks = 0;
      int totalBytes = 0;
      bool firstChunkReceived = false;

      await for (final chunk in apiService.generateTTSStream(
        text,
        voiceName: voiceName,
        languageCode: languageCode,
      )) {
        // Check if we've been stopped
        if (!_isPlaying || _currentSource == null) {
          if (kDebugMode) {
            debugPrint('🔊 [StreamingTTS] Playback stopped, aborting stream');
          }
          break;
        }

        switch (chunk.type) {
          case TTSChunkType.audioChunk:
            if (chunk.audioBase64 != null) {
              // Decode base64 to PCM bytes
              final pcmBytes = Uint8List.fromList(
                base64Decode(chunk.audioBase64!),
              );
              totalChunks++;
              totalBytes += pcmBytes.length;

              // Store for caching
              pcmChunks.add(pcmBytes);

              if (!firstChunkReceived) {
                firstChunkReceived = true;
                final firstChunkTime = DateTime.now();
                if (kDebugMode) {
                  debugPrint('🔊 [StreamingTTS] First audio chunk received');
                  debugPrint(
                    '   Time since start: ${firstChunkTime.difference(startTime).inMilliseconds}ms',
                  );
                  debugPrint('   Chunk size: ${pcmBytes.length} bytes');
                }
                _notifyState(StreamingTtsState.playing);
              }

              // Add PCM data to the buffer stream for playback
              _soloud.addAudioDataStream(_currentSource!, pcmBytes);

              if (kDebugMode && totalChunks % 5 == 0) {
                debugPrint(
                  '🔊 [StreamingTTS] Chunks: $totalChunks, Total: $totalBytes bytes',
                );
              }
            }
            break;

          case TTSChunkType.info:
            // Duration info received
            if (kDebugMode) {
              debugPrint(
                '🔊 [StreamingTTS] Info received: duration=${chunk.durationMs}ms',
              );
            }
            break;

          case TTSChunkType.done:
            // Mark the stream as complete
            if (_currentSource != null) {
              _soloud.setDataIsEnded(_currentSource!);
            }

            final doneTime = DateTime.now();
            if (kDebugMode) {
              debugPrint('🔊 [StreamingTTS] ✅ All data received');
              debugPrint(
                '   Total time: ${doneTime.difference(startTime).inMilliseconds}ms',
              );
              debugPrint('   Total chunks: $totalChunks');
              debugPrint('   Total bytes: $totalBytes');
            }

            // Save to cache file
            if (pcmChunks.isNotEmpty) {
              cachedFilePath = await _saveToCacheFile(pcmChunks, messageId);
              if (cachedFilePath != null) {
                onCacheSaved?.call(cachedFilePath);
              }
            }
            break;

          case TTSChunkType.error:
            throw Exception(chunk.error ?? 'TTS generation failed');
        }
      }

      // Wait for playback to complete
      _listenForCompletion();

      return cachedFilePath;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔊 [StreamingTTS] Error: $e');
      }
      _isLoading = false;
      _isPlaying = false;
      _notifyState(StreamingTtsState.error);
      rethrow;
    }
  }

  /// Save collected PCM chunks to a WAV cache file
  Future<String?> _saveToCacheFile(
    List<Uint8List> pcmChunks,
    String? messageId,
  ) async {
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
        storageKey.getUserScopedPath(cacheDir.path, 'tts_cache'),
      );
      if (!await ttsCacheDir.exists()) {
        await ttsCacheDir.create(recursive: true);
      }

      // Generate filename
      final safeFileName =
          (messageId ?? DateTime.now().millisecondsSinceEpoch.toString())
              .replaceAll(RegExp(r'[^a-zA-Z0-9-_]'), '_');
      final audioFile = File('${ttsCacheDir.path}/$safeFileName.wav');
      await audioFile.writeAsBytes(wavData);

      if (kDebugMode) {
        debugPrint(
          '🔊 [StreamingTTS] 💾 Cached audio saved: ${audioFile.path}',
        );
        debugPrint('   Size: ${wavData.length} bytes');
      }

      return audioFile.path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔊 [StreamingTTS] Failed to save cache: $e');
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

  /// Play a cached audio file directly (for subsequent plays)
  Future<void> playCached(String audioPath) async {
    await stop();

    _isLoading = true;
    _notifyState(StreamingTtsState.loading);

    try {
      await initialize();

      final source = await _soloud.loadFile(audioPath);
      _currentHandle = await _soloud.play(source);
      _currentSource = source;
      _isPlaying = true;
      _isLoading = false;
      _notifyState(StreamingTtsState.playing);

      if (kDebugMode) {
        debugPrint('🔊 [StreamingTTS] Playing cached file: $audioPath');
      }

      _listenForCompletion();
    } catch (e) {
      _isLoading = false;
      _isPlaying = false;
      _notifyState(StreamingTtsState.error);
      rethrow;
    }
  }

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
        _notifyState(StreamingTtsState.completed);
        if (kDebugMode) {
          debugPrint('🔊 [StreamingTTS] Playback completed');
        }
      }
    });
  }

  /// Stop current playback
  Future<void> stop() async {
    if (_currentHandle != null) {
      await _soloud.stop(_currentHandle!);
    }

    if (_currentSource != null) {
      await _soloud.disposeSource(_currentSource!);
    }

    _currentHandle = null;
    _currentSource = null;
    _isPlaying = false;
    _isLoading = false;
    _notifyState(StreamingTtsState.stopped);

    if (kDebugMode) {
      debugPrint('🔊 [StreamingTTS] Stopped');
    }
  }

  /// Notify state change
  void _notifyState(StreamingTtsState state) {
    onStateChanged?.call(state);
  }

  /// Dispose the service
  Future<void> dispose() async {
    await stop();
    // Note: We don't deinit SoLoud as it may be used elsewhere
  }
}

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

  /// Playback was stopped by user
  stopped,

  /// An error occurred
  error,
}
