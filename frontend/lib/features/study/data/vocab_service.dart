import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../../../core/data/local/storage_key_service.dart';

class VocabItem {
  final String phrase;
  final String translation;
  final String tag;
  final String? scenarioId; // Added scenario link
  final DateTime createdAt; // Added for sorting

  VocabItem({
    required this.phrase,
    required this.translation,
    required this.tag,
    this.scenarioId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'phrase': phrase,
    'translation': translation,
    'tag': tag,
    'scenario_id': scenarioId,
    'created_at': createdAt.toIso8601String(),
  };

  factory VocabItem.fromJson(Map<String, dynamic> json) {
    return VocabItem(
      phrase: json['phrase'] ?? '',
      translation: json['translation'] ?? '',
      tag: json['tag'] ?? '',
      scenarioId: json['scenario_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class VocabService extends ChangeNotifier {
  static final VocabService _instance = VocabService._internal();
  factory VocabService() => _instance;
  VocabService._internal() {
    _loadItems();
  }

  static const String _storageKeyBase = 'vocab_items_v2';
  final _supabase = Supabase.instance.client;
  List<VocabItem> _items = [];
  List<VocabItem> get items => List.unmodifiable(_items);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> _loadItems() async {
    // 1. Load from local storage (Fast)
    final prefs = await SharedPreferences.getInstance();
    final storageKey = StorageKeyService();
    final String? jsonString = prefs.getString(
      storageKey.getUserScopedKey(_storageKeyBase),
    );
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _items = decoded.map((e) => VocabItem.fromJson(e)).toList();
        // Ensure sorted by newest first
        _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading local vocab: $e');
      }
    }

    // 2. Sync from Cloud (Background)
    await _syncFromCloud();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _syncFromCloud() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('vocabulary')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false) // Sort by newest first
          .timeout(const Duration(seconds: 5));

      final cloudItems = response.map((e) {
        return VocabItem(
          phrase: e['word'] ?? '',
          translation: e['translation'] ?? '',
          tag: e['tag'] ?? '',
          scenarioId: e['scenario_id'],
          createdAt: e['created_at'] != null
              ? DateTime.parse(e['created_at'])
              : null,
        );
      }).toList();

      // Simple merge strategy: Cloud wins.
      _items = cloudItems.cast<VocabItem>();
      notifyListeners();

      // Update local cache
      await _saveLocal();
    } catch (e) {
      debugPrint('Error fetching cloud vocab (non-critical): $e');
    }
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = StorageKeyService();
    final String jsonString = jsonEncode(
      _items.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(
      storageKey.getUserScopedKey(_storageKeyBase),
      jsonString,
    );
  }

  // No longer needed as we sync per item operation
  // Future<void> _syncToCloud() async {}

  Future<void> add(
    String phrase,
    String translation,
    String tag, {
    String? scenarioId,
  }) async {
    // Avoid duplicates based on phrase AND scenarioId
    // If scenarioId is provided, we check if there's already an item with this phrase AND this scenarioId.
    // If scenarioId is null, we check if there's an item with this phrase and null scenarioId.
    bool exists = _items.any(
      (i) => i.phrase == phrase && i.scenarioId == scenarioId,
    );

    if (!exists) {
      final newItem = VocabItem(
        phrase: phrase,
        translation: translation,
        tag: tag,
        scenarioId: scenarioId,
      );
      // Add to top of list
      _items.insert(0, newItem);
      notifyListeners();

      // Save local immediately
      await _saveLocal();

      // Sync to cloud in background
      _addCloud(newItem);
    }
  }

  Future<void> _addCloud(VocabItem item) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('vocabulary')
          .insert({
            'user_id': userId,
            'word': item.phrase,
            'translation': item.translation,
            'tag': item.tag,
            'scenario_id': item.scenarioId,
          })
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error adding vocab to cloud: $e');
    }
  }

  Future<void> remove(String phrase) async {
    _items.removeWhere((i) => i.phrase == phrase);
    notifyListeners();

    // Save local immediately
    await _saveLocal();

    // Sync to cloud in background
    _removeCloud(phrase);
  }

  Future<void> _removeCloud(String phrase) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('vocabulary')
          .delete()
          .eq('user_id', userId)
          .eq('word', phrase)
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error removing vocab from cloud: $e');
    }
  }

  List<VocabItem> getItemsForScenario(String scenarioId) {
    return _items.where((item) => item.scenarioId == scenarioId).toList();
  }

  bool exists(String phrase, {String? scenarioId}) {
    return _items.any((i) => i.phrase == phrase && i.scenarioId == scenarioId);
  }
}
