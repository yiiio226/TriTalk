import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/features/scenes/domain/models/scene.dart';
import '../../../core/data/local/storage_key_service.dart';

/// SceneService - Pure Clone Model
///
/// All scenes are stored in `custom_scenarios` table.
/// Standard scenes are automatically cloned to user's custom_scenarios on registration.
/// Sorting is based on `updated_at DESC` - most recently updated scenes appear first.
class SceneService extends ChangeNotifier {
  static final SceneService _instance = SceneService._internal();
  factory SceneService() => _instance;
  SceneService._internal() {
    _init();
  }

  static const String _storageKeyBase = 'scenes_cache_v2';
  final _supabase = Supabase.instance.client;

  List<Scene> _scenes = [];
  List<Scene> get scenes => List.unmodifiable(_scenes);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> _init() async {
    await _loadFromLocal();
    refreshScenes();
  }

  /// Load scenes from local cache (for offline support)
  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = StorageKeyService();

      final String? jsonString = prefs.getString(
        storageKey.getUserScopedKey(_storageKeyBase),
      );

      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _scenes = decoded.map((e) => Scene.fromMap(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading local scenes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh scenes from Supabase (Single Source of Truth)
  /// Scenes are ordered by updated_at DESC (most recent first)
  Future<void> refreshScenes() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('🔍 [SceneService] No user ID, skipping refresh');
        return;
      }

      debugPrint('🔍 [SceneService] Starting refresh for user: $userId');
      debugPrint('🔍 [SceneService] Schema: ${_supabase.rest.schema}');

      final startTime = DateTime.now();

      // Query custom_scenarios with ORDER BY updated_at DESC
      debugPrint('🔍 [SceneService] Executing query...');
      final response = await _supabase
          .from('custom_scenarios')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false)
          .timeout(
            const Duration(seconds: 30),
          ); // Increased from 10s to handle slow networks

      final duration = DateTime.now().difference(startTime);
      debugPrint(
        '🔍 [SceneService] Query completed in ${duration.inMilliseconds}ms',
      );
      debugPrint('🔍 [SceneService] Response length: ${response.length}');

      _scenes = response.map<Scene>((e) {
        return Scene(
          id: e['id'],
          title: e['title'] ?? '',
          description: e['description'] ?? '',
          emoji: e['emoji'] ?? '🎭',
          aiRole: e['ai_role'] ?? '',
          userRole: e['user_role'] ?? '',
          initialMessage: e['initial_message'] ?? 'Start chatting!',
          category: e['category'] ?? 'Custom',
          difficulty: e['difficulty'] ?? 'Easy',
          goal: e['goal'] ?? '',
          iconPath: e['icon_path'] ?? '',
          color: e['color'] ?? 0xFFFFFFFF,
          targetLanguage: e['target_language'] ?? 'en-US',
        );
      }).toList();

      debugPrint(
        '🔍 [SceneService] ✅ Successfully loaded ${_scenes.length} scenes',
      );
      _isLoading = false;
      notifyListeners();

      // Update local cache
      await _saveLocal();
    } catch (e) {
      debugPrint('🔍 [SceneService] ❌ Error fetching scenes from cloud: $e');
      debugPrint('🔍 [SceneService] Error type: ${e.runtimeType}');
      if (e is TimeoutException) {
        debugPrint('🔍 [SceneService] ⏱️ Query timed out after 10 seconds');
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save scenes to local cache
  Future<void> _saveLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = StorageKeyService();

      final String jsonString = jsonEncode(
        _scenes.map((e) => e.toMap()).toList(),
      );
      await prefs.setString(
        storageKey.getUserScopedKey(_storageKeyBase),
        jsonString,
      );
    } catch (e) {
      debugPrint('Error saving local scenes: $e');
    }
  }

  /// Add a new scene (user-created)
  Future<void> addScene(Scene scene) async {
    // Insert at top of list (optimistic UI)
    _scenes.insert(0, scene);
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('custom_scenarios')
          .insert({
            'id': scene.id,
            'user_id': userId,
            'title': scene.title,
            'description': scene.description,
            'ai_role': scene.aiRole,
            'user_role': scene.userRole,
            'initial_message': scene.initialMessage,
            'emoji': scene.emoji,
            'category': scene.category,
            'difficulty': scene.difficulty,
            'goal': scene.goal,
            'color': scene.color,
            'icon_path': scene.iconPath,
            'target_language': scene.targetLanguage,
            'source_type': 'custom', // User-created scene
          })
          .timeout(const Duration(seconds: 5));

      await _saveLocal();
    } catch (e) {
      debugPrint('Error adding scene to cloud: $e');
      // Rollback optimistic update
      _scenes.removeWhere((s) => s.id == scene.id);
      notifyListeners();
    }
  }

  /// Delete a scene
  Future<void> deleteScene(String sceneId) async {
    // Store for rollback
    final sceneIndex = _scenes.indexWhere((s) => s.id == sceneId);
    final deletedScene = sceneIndex >= 0 ? _scenes[sceneIndex] : null;

    // Optimistic UI update
    _scenes.removeWhere((s) => s.id == sceneId);
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('custom_scenarios')
          .delete()
          .eq('user_id', userId)
          .eq('id', sceneId)
          .timeout(const Duration(seconds: 5));

      await _saveLocal();
    } catch (e) {
      debugPrint('Error deleting scene from cloud: $e');
      // Rollback optimistic update
      if (deletedScene != null && sceneIndex >= 0) {
        _scenes.insert(sceneIndex, deletedScene);
        notifyListeners();
      }
    }
  }

  /// Move scene to top (update updated_at to bring it to the top of the list)
  Future<void> moveSceneToTop(String sceneId) async {
    final sceneIndex = _scenes.indexWhere((s) => s.id == sceneId);
    if (sceneIndex == -1 || sceneIndex == 0) return;

    // Optimistic UI update
    final scene = _scenes.removeAt(sceneIndex);
    _scenes.insert(0, scene);
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Update updated_at to bring scene to top (ORDER BY updated_at DESC)
      await _supabase
          .from('custom_scenarios')
          .update({'updated_at': DateTime.now().toUtc().toIso8601String()})
          .eq('user_id', userId)
          .eq('id', sceneId)
          .timeout(const Duration(seconds: 5));

      await _saveLocal();
    } catch (e) {
      debugPrint('Error moving scene to top: $e');
      // Refresh from cloud to get correct order
      await refreshScenes();
    }
  }

  /// Reorder scenes - dragging a scene will move it to the top
  ///
  /// In the new architecture, any reorder action updates `updated_at` to NOW,
  /// which moves the scene to the top of the list (ORDER BY updated_at DESC).
  /// This creates a "most recently interacted" sorting behavior.
  Future<void> reorderScenes(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= _scenes.length) return;

    final scene = _scenes[oldIndex];

    // Delegate to moveSceneToTop - any drag action moves scene to top
    await moveSceneToTop(scene.id);
  }

  /// Update a scene
  Future<void> updateScene(Scene scene) async {
    // Find and update in local list
    final index = _scenes.indexWhere((s) => s.id == scene.id);
    if (index == -1) return;

    final oldScene = _scenes[index];
    _scenes[index] = scene;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('custom_scenarios')
          .update({
            'title': scene.title,
            'description': scene.description,
            'ai_role': scene.aiRole,
            'user_role': scene.userRole,
            'initial_message': scene.initialMessage,
            'emoji': scene.emoji,
            'category': scene.category,
            'difficulty': scene.difficulty,
            'goal': scene.goal,
            'color': scene.color,
            'icon_path': scene.iconPath,
            'target_language': scene.targetLanguage,
            // updated_at is auto-updated by DB trigger
          })
          .eq('user_id', userId)
          .eq('id', scene.id)
          .timeout(const Duration(seconds: 5));

      await _saveLocal();
    } catch (e) {
      debugPrint('Error updating scene: $e');
      // Rollback
      _scenes[index] = oldScene;
      notifyListeners();
    }
  }

  /// Get a scene by ID
  Scene? getSceneById(String sceneId) {
    try {
      return _scenes.firstWhere((s) => s.id == sceneId);
    } catch (_) {
      return null;
    }
  }
}
