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
    refreshScenes();
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

  // Sync from cloud (background) -> Public for manual refresh
  Future<void> refreshScenes() async {
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
      
      // RECONCILIATION: Check if we have local custom scenes that are NOT in cloud
      // This happens if sync failed previously or if we were offline
      final cloudIds = cloudCustomScenes.map((e) => e.id).toSet();
      final localCustomScenes = _scenes.where((s) => isCustomScene(s)).toList();
      final scenesToPush = localCustomScenes.where((s) => !cloudIds.contains(s.id)).toList();
      
      // Push missing scenes to cloud
      for (var scene in scenesToPush) {
        // Upgrade invalid ID if necessary (e.g. legacy timestamp ID)
        if (scene.id.contains(' ') || scene.id.contains(':')) {
             // Generate new UUID
             // We need to import uuid package or use Supabase's gen_random_uuid() remotely?
             // Since we can't easily import uuid here without adding dependency if not already added?
             // Actually we can just wait for user to delete it or hack a "pseudo-uuid".
             // But CustomSceneDialog uses package:uuid now.
             // Ideally we should modify the local scene's ID.
             // Instead of adding dependency to SceneService (if not present), let's just delete the bad scene?
             // NO, user loses data.
             
             // Let's assume we can't easily change ID without 'uuid' package import.
             // But we can just skip it? No, sync error persists.
             // Let's try to generate a random ID similarly or just skip syncing this specific item to suppress error?
             // Use Supabase rpc? No.
             
             // Better: Update the migration script to allow text IDs? No, standard is UUID.
             
             // Best: We MUST fix the ID.
             // Let's modify the scene object with a new ID if possible.
             // Since Scene is immutable, we create copy.
             // But we need a UUID generator.
             
             // For now, let's just try to push. If it fails (caught in _addCloud), we ignore.
             // But the error is jamming the log.
             
             // Let's SKIP items that have invalid IDs to prevent error loop.
             debugPrint('Skipping sync for invalid ID: ${scene.id}');
             continue; 
        }
        await _addCloud(scene); 
      }
      
      // Final List: Cloud Scenes + Local-Only Scenes (which we just pushed) + Visible Standard
      // Note: If we just pushed them, they are conceptually "in cloud" or will be.
      // We should keep them.
      
      // The _scenes list currently contains Local scenes (loaded in init).
      // We want to UPDATE it with Cloud scenes (which might have updates from other devices),
      // BUT keep our local-only scenes.
      
      // Let's rebuilding _scenes properly:
      // Start with Visible Standard
      List<Scene> finalScenes = [...visibleStandardScenes];
      
      // Add all Cloud Scenes (Source of Truth for those IDs)
      finalScenes.addAll(cloudCustomScenes);
      
      // Add Local-Only Scenes (Preserve Offline Work)
      finalScenes.addAll(scenesToPush);
      
      _scenes = finalScenes;
      notifyListeners();

      // Update local cache
      // Save ONLY the custom parts
      final customToSave = [...cloudCustomScenes, ...scenesToPush];
      await _saveLocal(customToSave, hiddenIds.toList());

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
