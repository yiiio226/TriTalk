import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VocabItem {
  final String phrase;
  final String translation;
  final String tag;

  VocabItem({required this.phrase, required this.translation, required this.tag});

  Map<String, dynamic> toJson() => {
    'phrase': phrase,
    'translation': translation,
    'tag': tag,
  };

  factory VocabItem.fromJson(Map<String, dynamic> json) {
    return VocabItem(
      phrase: json['phrase'] ?? '',
      translation: json['translation'] ?? '',
      tag: json['tag'] ?? '',
    );
  }
}

class VocabService extends ChangeNotifier {
  static final VocabService _instance = VocabService._internal();
  factory VocabService() => _instance;
  VocabService._internal() {
    _loadItems();
  }

  static const String _storageKey = 'vocab_items_v2';
  List<VocabItem> _items = [];

  List<VocabItem> get items => List.unmodifiable(_items);

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _items = decoded.map((e) => VocabItem.fromJson(e)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading vocab: $e');
      }
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> add(String phrase, String translation, String tag) async {
    // Avoid duplicates based on phrase
    if (!_items.any((i) => i.phrase == phrase)) {
      // Add to top of list
      _items.insert(0, VocabItem(phrase: phrase, translation: translation, tag: tag));
      notifyListeners();
      await _saveItems();
    }
  }

  Future<void> remove(String phrase) async {
    _items.removeWhere((i) => i.phrase == phrase);
    notifyListeners();
    await _saveItems();
  }
}
