import 'package:shared_preferences/shared_preferences.dart';
import '../data/language_constants.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _ensureInit() async {
    if (_prefs == null) {
      await init();
    }
  }

  Future<String> getNativeLanguage() async {
    await _ensureInit();
    return _prefs?.getString(LanguageConstants.keyNativeLanguage) ??
        LanguageConstants.defaultNativeLanguage;
  }

  Future<void> setNativeLanguage(String language) async {
    await _ensureInit();
    await _prefs?.setString(LanguageConstants.keyNativeLanguage, language);
  }

  Future<String> getTargetLanguage() async {
    await _ensureInit();
    return _prefs?.getString(LanguageConstants.keyTargetLanguage) ??
        LanguageConstants.defaultTargetLanguage;
  }

  Future<void> setTargetLanguage(String language) async {
    await _ensureInit();
    await _prefs?.setString(LanguageConstants.keyTargetLanguage, language);
  }
}
