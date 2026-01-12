import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/scenes/domain/models/scene.dart';
import '../chat.dart';

/// Provider for the ChatPageNotifier.
///
/// Uses .family to create a unique notifier for each Scene.
/// Uses .autoDispose to clean up state when the screen is closed.
final chatPageNotifierProvider = StateNotifierProvider.autoDispose
    .family<ChatPageNotifier, ChatPageState, Scene>((ref, scene) {
      final repository = ref.watch(chatRepositoryProvider);
      return ChatPageNotifier(repository: repository, scene: scene);
    });
