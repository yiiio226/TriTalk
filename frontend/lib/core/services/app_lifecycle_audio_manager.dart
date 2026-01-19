import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/services/streaming_tts_service.dart';
import 'package:frontend/features/speech/data/services/word_tts_service.dart';

/// Service that handles app lifecycle events to properly manage audio resources.
///
/// This service:
/// - Stops all audio playback when the app goes to background
/// - Stops all audio playback when the app is terminated
/// - Resumes playback state (if applicable) when app returns to foreground
///
/// Usage:
/// Initialize this service once in your app's main widget that has access
/// to the widget tree. Typically in a StatefulWidget that wraps your main app.
class AppLifecycleAudioManager with WidgetsBindingObserver {
  static AppLifecycleAudioManager? _instance;
  static AppLifecycleAudioManager get instance {
    _instance ??= AppLifecycleAudioManager._();
    return _instance!;
  }

  AppLifecycleAudioManager._();

  bool _isInitialized = false;

  /// Initialize the lifecycle manager.
  /// Call this once during app initialization.
  void initialize() {
    if (_isInitialized) return;

    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;

    if (kDebugMode) {
      debugPrint('🔊 AppLifecycleAudioManager: Initialized');
    }
  }

  /// Dispose the lifecycle manager.
  /// Call this when the app is being destroyed.
  void dispose() {
    if (!_isInitialized) return;

    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;

    if (kDebugMode) {
      debugPrint('🔊 AppLifecycleAudioManager: Disposed');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kDebugMode) {
      debugPrint('🔊 AppLifecycleAudioManager: State changed to $state');
    }

    switch (state) {
      case AppLifecycleState.paused:
        // App is going to background - stop all audio
        _stopAllAudio();
        break;
      case AppLifecycleState.detached:
        // App is being terminated - stop and cleanup
        _stopAllAudio();
        break;
      case AppLifecycleState.inactive:
        // App is inactive (e.g., incoming call) - optionally pause
        // For now, we also stop audio to be safe
        _stopAllAudio();
        break;
      case AppLifecycleState.resumed:
        // App is back to foreground - nothing to do by default
        // Audio can be resumed by user action
        break;
      case AppLifecycleState.hidden:
        // App is hidden (iOS specific in some cases)
        _stopAllAudio();
        break;
    }
  }

  /// Stop all audio playback across the app
  Future<void> _stopAllAudio() async {
    if (kDebugMode) {
      debugPrint('🔊 AppLifecycleAudioManager: Stopping all audio...');
    }

    try {
      // Stop StreamingTtsService (main TTS for chat bubbles and shadowing)
      final streamingTts = StreamingTtsService.instance;
      if (streamingTts.isPlaying) {
        await streamingTts.stop();
      }

      // Stop WordTtsService (word pronunciation in various sheets)
      final wordTts = WordTtsService();
      await wordTts.stop();

      if (kDebugMode) {
        debugPrint('🔊 AppLifecycleAudioManager: All audio stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔊 AppLifecycleAudioManager: Error stopping audio: $e');
      }
    }
  }

  /// Manually stop all audio (can be called from anywhere in the app)
  Future<void> stopAllAudio() async {
    await _stopAllAudio();
  }
}
