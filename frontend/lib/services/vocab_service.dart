import 'package:flutter/material.dart';

class VocabItem {
  final String phrase;
  final String translation;
  final String tag;

  VocabItem({required this.phrase, required this.translation, required this.tag});
}

class VocabService extends ChangeNotifier {
  static final VocabService _instance = VocabService._internal();
  factory VocabService() => _instance;
  VocabService._internal();

  final List<VocabItem> _items = [];

  List<VocabItem> get items => List.unmodifiable(_items);

  void add(String phrase, String translation, String tag) {
    if (!_items.any((i) => i.phrase == phrase)) {
      _items.add(VocabItem(phrase: phrase, translation: translation, tag: tag));
      notifyListeners();
    }
  }

  void remove(String phrase) {
    _items.removeWhere((i) => i.phrase == phrase);
    notifyListeners();
  }
}
