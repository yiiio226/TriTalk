import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/services/streaming_tts_service.dart';

/// Mixin that provides TTS (Text-to-Speech) playback functionality
/// with streaming support and caching.
///
/// This mixin encapsulates the common TTS playback logic used across
/// multiple widgets (e.g., ChatBubble, ShadowingSheet) to avoid code duplication.
///
/// **Important**: Since this mixin can be used with different State types
/// (State, ConsumerState, etc.), it doesn't extend State directly.
/// The consuming class must provide `mounted` and `setState` access.
///
/// ## Usage
///
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with TtsPlaybackMixin {
///   @override
///   void dispose() {
///     disposeTtsPlayback(); // Clean up resources
///     super.dispose();
///   }
///
///   void _onPlayPressed() {
///     playTts(
///       text: 'Hello world',
///       cacheKey: 'unique_key',
///       cachedPath: _savedPath,
///       onStateChange: (loading, playing) => setState(() {
///         _isLoading = loading;
///         _isPlaying = playing;
///       }),
///       onCacheSaved: (path) => setState(() => _savedPath = path),
///       onError: (error) => showError(error),
///     );
///   }
/// }
/// ```
mixin TtsPlaybackMixin {
  /// Play text-to-speech with streaming support and caching.
  ///
  /// [text] - The text content to speak
  /// [cacheKey] - Unique identifier for caching (e.g., message ID)
  /// [cachedPath] - Path to previously cached audio file (if any)
  /// [onStateChange] - Callback when loading/playing state changes (required for UI updates)
  /// [onCacheSaved] - Callback when audio is cached after first play
  /// [onError] - Callback when an error occurs
  /// [beforePlay] - Optional callback executed before playback starts (e.g., stop other audio)
  /// [isMounted] - Function that returns whether the widget is still mounted
  Future<void> playTts({
    required String text,
    required String cacheKey,
    String? cachedPath,
    required void Function(bool loading, bool playing) onStateChange,
    required bool Function() isMounted,
    void Function(String path)? onCacheSaved,
    void Function(String error)? onError,
    Future<void> Function()? beforePlay,
  }) async {
    final streamingTts = StreamingTtsService.instance;

    // Debug logging: cache hit/miss info
    if (kDebugMode) {
      final fileExists = cachedPath != null
          ? await File(cachedPath).exists()
          : false;
      final cacheStatus = (cachedPath != null && fileExists)
          ? "✅ CACHE HIT"
          : "❌ CACHE MISS";
      debugPrint('🎧 [TTS Cache] Key: $cacheKey | $cacheStatus');
    }

    // If already playing, stop it (toggle behavior)
    if (streamingTts.isPlaying) {
      await streamingTts.stop();
      if (isMounted()) {
        onStateChange(false, false);
      }
      return;
    }

    // Execute pre-play hook (e.g., stop recording playback)
    await beforePlay?.call();

    // Setup state change listener
    _setupTtsStateListener(
      streamingTts,
      onStateChange: onStateChange,
      isMounted: isMounted,
    );

    // Try cached playback first
    if (cachedPath != null && await File(cachedPath).exists()) {
      if (kDebugMode) {
        debugPrint('🔊 [TTS] Using cached audio: $cachedPath');
      }

      try {
        if (isMounted()) {
          onStateChange(true, false);
        }
        await streamingTts.playCached(cachedPath);
      } catch (e) {
        if (isMounted()) {
          onStateChange(false, false);
        }
        onError?.call('Failed to play audio: $e');
      }
      return;
    }

    // No cache - stream from API
    if (isMounted()) {
      onStateChange(true, false);
    }

    // Setup cache callback
    if (onCacheSaved != null) {
      streamingTts.onCacheSaved = (cachePath) {
        if (isMounted()) {
          onCacheSaved(cachePath);
          if (kDebugMode) {
            debugPrint('🔊 [TTS] Cache saved: $cachePath');
          }
        }
      };
    }

    try {
      // Start streaming playback with caching
      await streamingTts.playStreaming(text, messageId: cacheKey);
    } catch (e) {
      if (isMounted()) {
        onStateChange(false, false);
      }
      onError?.call('Failed to generate speech: $e');
    }
  }

  /// Stop any currently playing TTS audio
  Future<void> stopTts({
    void Function(bool loading, bool playing)? onStateChange,
    bool Function()? isMounted,
  }) async {
    final streamingTts = StreamingTtsService.instance;
    await streamingTts.stop();
    if (isMounted?.call() ?? true) {
      onStateChange?.call(false, false);
    }
  }

  /// Clean up TTS resources. Call this in the widget's dispose() method.
  void disposeTtsPlayback() {
    // Clear callback references to prevent memory leaks
    StreamingTtsService.instance.onStateChanged = null;
    StreamingTtsService.instance.onCacheSaved = null;
  }

  // ============================================================
  // Internal Helpers
  // ============================================================

  /// Setup state change listener for StreamingTtsService
  ///
  /// Handles all states including new v2.0 states:
  /// - [waitingForDownload]: Shown as loading (waiting for in-progress download)
  /// - [backgroundDownloading]: User perspective is stopped (download continues silently)
  void _setupTtsStateListener(
    StreamingTtsService streamingTts, {
    required void Function(bool loading, bool playing) onStateChange,
    required bool Function() isMounted,
  }) {
    streamingTts.onStateChanged = (state) {
      if (!isMounted()) return;

      switch (state) {
        case StreamingTtsState.loading:
        case StreamingTtsState.buffering:
        case StreamingTtsState
            .waitingForDownload: // NEW: waiting for in-progress download
          onStateChange(true, false);
          break;
        case StreamingTtsState.playing:
          onStateChange(false, true);
          break;
        case StreamingTtsState.completed:
        case StreamingTtsState.stopped:
        case StreamingTtsState
            .backgroundDownloading: // NEW: user stopped, download continues
          onStateChange(false, false);
          break;
        case StreamingTtsState.error:
          onStateChange(false, false);
          break;
        case StreamingTtsState.idle:
          // No state change needed
          break;
      }
    };
  }
}
