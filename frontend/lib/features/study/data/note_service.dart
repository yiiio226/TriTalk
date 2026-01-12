import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/data/local/storage_key_service.dart';

class NoteService {
  static const String _keySentencesBase = 'saved_sentences';
  static const String _keyVocabularyBase = 'saved_vocabulary';

  Future<void> saveSentence(String sentence) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = StorageKeyService();
    final key = storageKey.getUserScopedKey(_keySentencesBase);
    List<String> sentences = prefs.getStringList(key) ?? [];

    if (!sentences.contains(sentence)) {
      sentences.add(sentence);
      await prefs.setStringList(key, sentences);
    }
  }

  Future<void> saveVocabulary(String word, {String? context}) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = StorageKeyService();
    final key = storageKey.getUserScopedKey(_keyVocabularyBase);
    List<String> rawList = prefs.getStringList(key) ?? [];

    final newItem = jsonEncode({
      'word': word,
      'context': context ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    });

    rawList.add(newItem);
    await prefs.setStringList(key, rawList);
  }

  Future<List<String>> getSentences() async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = StorageKeyService();
    return prefs.getStringList(
          storageKey.getUserScopedKey(_keySentencesBase),
        ) ??
        [];
  }
}
