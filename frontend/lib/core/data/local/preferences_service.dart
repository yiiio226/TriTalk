import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/data/language_constants.dart';
import 'storage_key_service.dart';

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
    final storageKey = StorageKeyService();
    return _prefs?.getString(
          storageKey.getUserScopedKey(LanguageConstants.keyNativeLanguage),
        ) ??
        LanguageConstants.defaultNativeLanguage;
  }

  Future<void> setNativeLanguage(String language) async {
    await _ensureInit();
    final storageKey = StorageKeyService();
    await _prefs?.setString(
      storageKey.getUserScopedKey(LanguageConstants.keyNativeLanguage),
      language,
    );
  }

  Future<String> getTargetLanguage() async {
    await _ensureInit();
    final storageKey = StorageKeyService();
    return _prefs?.getString(
          storageKey.getUserScopedKey(LanguageConstants.keyTargetLanguage),
        ) ??
        LanguageConstants.defaultTargetLanguage;
  }

  Future<void> setTargetLanguage(String language) async {
    await _ensureInit();
    final storageKey = StorageKeyService();
    await _prefs?.setString(
      storageKey.getUserScopedKey(LanguageConstants.keyTargetLanguage),
      language,
    );
  }
}
