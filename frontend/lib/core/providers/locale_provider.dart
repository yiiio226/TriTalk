import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../initializer/app_initializer.dart';

/// Key used to store the user's app language preference in SharedPreferences
const String _appLocaleKey = 'app_locale';

/// 支持的 App 显示语言列表
/// 与 i18n ARB 文件中的语言对应
class AppLanguageOption {
  final String code; // 例如 'en', 'zh'
  final String label; // 显示名称
  final String flag; // Emoji 国旗

  const AppLanguageOption({
    required this.code,
    required this.label,
    required this.flag,
  });
}

/// App 显示语言选项
class AppLanguages {
  static const List<AppLanguageOption> supportedLanguages = [
    AppLanguageOption(code: 'system', label: 'System Default', flag: '🌐'),
    AppLanguageOption(code: 'en', label: 'English', flag: '🇺🇸'),
    AppLanguageOption(code: 'zh', label: '中文', flag: '🇨🇳'),
    AppLanguageOption(code: 'ja', label: '日本語', flag: '🇯🇵'),
    AppLanguageOption(code: 'ko', label: '한국어', flag: '🇰🇷'),
    AppLanguageOption(code: 'es', label: 'Español', flag: '🇪🇸'),
    AppLanguageOption(code: 'fr', label: 'Français', flag: '🇫🇷'),
    AppLanguageOption(code: 'de', label: 'Deutsch', flag: '🇩🇪'),
  ];

  /// 根据语言代码获取显示标签
  static String getLabel(String code) {
    return supportedLanguages
        .firstWhere(
          (lang) => lang.code == code,
          orElse: () => supportedLanguages.first,
        )
        .label;
  }

  /// 根据语言代码获取国旗
  static String getFlag(String code) {
    return supportedLanguages
        .firstWhere(
          (lang) => lang.code == code,
          orElse: () => supportedLanguages.first,
        )
        .flag;
  }

  /// 判断是否为有效的语言代码
  static bool isValidCode(String code) {
    return supportedLanguages.any((lang) => lang.code == code);
  }
}

/// Locale state managed by Riverpod
/// Supports system default or user-selected language
class LocaleState {
  /// 用户选择的语言代码
  /// 'system' 表示跟随系统语言
  /// 'en', 'zh' 等表示具体语言
  final String selectedCode;

  const LocaleState({this.selectedCode = 'system'});

  /// 获取实际的 Locale 对象
  /// 如果是 'system'，返回 null 表示跟随系统
  Locale? get locale {
    if (selectedCode == 'system' || !AppLanguages.isValidCode(selectedCode)) {
      return null;
    }
    return Locale(selectedCode);
  }

  /// 是否跟随系统语言
  bool get isFollowingSystem => selectedCode == 'system';

  LocaleState copyWith({String? selectedCode}) {
    return LocaleState(selectedCode: selectedCode ?? this.selectedCode);
  }
}

/// Riverpod provider for app locale management
final localeProvider = StateNotifierProvider<LocaleNotifier, LocaleState>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

/// Notifier that handles locale state changes and persistence
class LocaleNotifier extends StateNotifier<LocaleState> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(const LocaleState()) {
    _loadSavedLocale();
  }

  /// 从 SharedPreferences 加载保存的语言设置
  void _loadSavedLocale() {
    final savedCode = _prefs.getString(_appLocaleKey);
    if (savedCode != null && AppLanguages.isValidCode(savedCode)) {
      state = LocaleState(selectedCode: savedCode);
    } else {
      // 默认跟随系统
      state = const LocaleState(selectedCode: 'system');
    }
  }

  /// 设置应用语言
  Future<void> setLocale(String code) async {
    if (!AppLanguages.isValidCode(code)) {
      return;
    }

    // 保存到 SharedPreferences
    await _prefs.setString(_appLocaleKey, code);

    // 更新状态
    state = LocaleState(selectedCode: code);
  }

  /// 重置为跟随系统语言
  Future<void> resetToSystem() async {
    await _prefs.remove(_appLocaleKey);
    state = const LocaleState(selectedCode: 'system');
  }
}

/// 便捷方法：获取当前有效的 Locale 用于 MaterialApp
extension LocaleStateExtension on LocaleState {
  /// 获取显示标签
  String get displayLabel => AppLanguages.getLabel(selectedCode);

  /// 获取国旗 emoji
  String get displayFlag => AppLanguages.getFlag(selectedCode);
}
