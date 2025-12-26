import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NoteService {
  static const String _keySentences = 'saved_sentences';
  static const String _keyVocabulary = 'saved_vocabulary';

  Future<void> saveSentence(String sentence) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sentences = prefs.getStringList(_keySentences) ?? [];
    
    if (!sentences.contains(sentence)) {
      sentences.add(sentence);
      await prefs.setStringList(_keySentences, sentences);
    }
  }

  Future<void> saveVocabulary(String word, {String? context}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> rawList = prefs.getStringList(_keyVocabulary) ?? [];
    
    final newItem = jsonEncode({
      'word': word,
      'context': context ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    });

    rawList.add(newItem);
    await prefs.setStringList(_keyVocabulary, rawList);
  }

  Future<List<String>> getSentences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySentences) ?? [];
  }
}
