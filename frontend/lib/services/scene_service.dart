import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/scene.dart';
import '../data/mock_scenes.dart';

class SceneService extends ChangeNotifier {
  static final SceneService _instance = SceneService._internal();
  factory SceneService() => _instance;
  SceneService._internal() {
    _init();
  }

  static const String _storageKey = 'custom_scenes_v1';
  final _supabase = Supabase.instance.client;
  
  // Start with mock scenes, custom scenes will be appended
  List<Scene> _scenes = List.from(mockScenes);
  List<Scene> get scenes => List.unmodifiable(_scenes);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> _init() async {
    await _loadFromLocal();
    _syncFromCloud();
  }

  // Load custom scenes from local storage and append to mock scenes
  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Load Custom Scenes
      final String? jsonString = prefs.getString(_storageKey);
      List<Scene> customScenes = [];
      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        customScenes = decoded.map((e) => Scene.fromMap(e)).toList();
      }
      
      // 2. Load Hidden Standard IDs
      final String? hiddenJson = prefs.getString('hidden_standard_scenes');
      Set<String> hiddenIds = {};
      if (hiddenJson != null) {
         final List<dynamic> decodedHidden = jsonDecode(hiddenJson);
         hiddenIds = decodedHidden.cast<String>().toSet();
      }

      // 3. Merge: (Standard - Hidden) + Custom
      final visibleStandardScenes = mockScenes.where((s) => !hiddenIds.contains(s.id)).toList();
      _scenes = [...visibleStandardScenes, ...customScenes];
      
    } catch (e) {
      debugPrint('Error loading local scenes: $e');
    } finally {
       _isLoading = false; 
      notifyListeners();
    }
  }

  // Sync from cloud (background)
  Future<void> _syncFromCloud() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // 1. Fetch Custom Scenes
      final customResponse = await _supabase
          .from('custom_scenarios')
          .select()
          .eq('user_id', userId)
          .timeout(const Duration(seconds: 5));

      List<Scene> cloudCustomScenes = [];
      if (customResponse != null && customResponse is List) {
        cloudCustomScenes = customResponse.map((e) {
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
              iconPath: e['icon_path'] ?? 'assets/images/user_avatar_male.png',
              color: e['color'] ?? 0xFF000000,
            );
        }).toList();
      }

      // 2. Fetch Hidden Standard Scenes
      final hiddenResponse = await _supabase
          .from('user_hidden_scenes')
          .select('scene_id')
          .eq('user_id', userId)
          .timeout(const Duration(seconds: 5));
      
      Set<String> hiddenIds = {};
      if (hiddenResponse != null && hiddenResponse is List) {
        hiddenIds = hiddenResponse.map((e) => e['scene_id'] as String).toSet();
      }

      // 3. Merge: (Standard - Hidden) + Custom
      final visibleStandardScenes = mockScenes.where((s) => !hiddenIds.contains(s.id)).toList();
      
      _scenes = [...visibleStandardScenes, ...cloudCustomScenes];
      notifyListeners();

      // Update local cache
      await _saveLocal(cloudCustomScenes, hiddenIds.toList());

    } catch (e) {
      debugPrint('Error fetching cloud scenes (non-critical): $e');
    }
  }

  // Save custom scenes AND hidden IDs locally
  Future<void> _saveLocal(List<Scene> customScenes, List<String> hiddenIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save Custom Scenes
      final String customJson = jsonEncode(customScenes.map((e) => e.toMap()).toList());
      await prefs.setString(_storageKey, customJson);

      // Save Hidden IDs
      final String hiddenJson = jsonEncode(hiddenIds);
      await prefs.setString('hidden_standard_scenes', hiddenJson);
    } catch (e) {
      debugPrint('Error saving local scenes: $e');
    }
  }
  
  Future<void> addScene(Scene scene) async {
    _scenes.add(scene);
    notifyListeners();
    
    // Update Local & Cloud
    final mockIds = mockScenes.map((e) => e.id).toSet();
    final customScenes = _scenes.where((s) => !mockIds.contains(s.id)).toList();
    final hiddenIds = mockScenes.where((s) => !_scenes.any((current) => current.id == s.id)).map((s) => s.id).toList();

    await _saveLocal(customScenes, hiddenIds);
    _addCloud(scene);
  }

  Future<void> _addCloud(Scene scene) async {
     try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('custom_scenarios').upsert(
        {
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
          'updated_at': DateTime.now().toIso8601String(),
        }
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error syncing scene to cloud: $e');
    }
  }
  
  // Helper to check if a scene is custom
  bool isCustomScene(Scene scene) {
     if (mockScenes.any((s) => s.id == scene.id)) return false;
     return true;
  }
  
  Future<void> deleteScene(String sceneId) async {
    // 1. Remove from in-memory list
    _scenes.removeWhere((s) => s.id == sceneId);
    notifyListeners();
    
    // 2. Identify lists
    final mockIds = mockScenes.map((e) => e.id).toSet();
    final isCustom = !mockIds.contains(sceneId);
    
    final customScenes = _scenes.where((s) => !mockIds.contains(s.id)).toList();
    // Hidden IDs are those in mockScenes but NOT in _scenes
    final hiddenIds = mockScenes.where((s) => !_scenes.any((current) => current.id == s.id)).map((s) => s.id).toList();

    // 3. Save Local
    await _saveLocal(customScenes, hiddenIds);
    
    // 4. Sync Cloud
    if (isCustom) {
      _deleteCloudCustom(sceneId);
    } else {
      _hideCloudStandard(sceneId);
    }
  }

  Future<void> _deleteCloudCustom(String sceneId) async {
     try {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) return;
        
        await _supabase.from('custom_scenarios')
            .delete()
            .eq('user_id', userId)
            .eq('id', sceneId)
            .timeout(const Duration(seconds: 5));
     } catch (e) {
        debugPrint('Error deleting scene from cloud: $e');
     }
  }

  Future<void> _hideCloudStandard(String sceneId) async {
     try {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) return;
        
        await _supabase.from('user_hidden_scenes')
            .insert({'user_id': userId, 'scene_id': sceneId})
            .timeout(const Duration(seconds: 5));
     } catch (e) {
        debugPrint('Error hiding standard scene: $e');
     }
  }
}
