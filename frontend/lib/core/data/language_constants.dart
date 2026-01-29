import 'package:flutter/widgets.dart';
import 'package:frontend/core/utils/l10n_ext.dart';

class LanguageOption {
  final String code; // ISO Code: 'en-US', 'zh-CN'
  final String label; // Display Name: 'English (US)', 'Chinese'
  final String flag; // Emoji flag if needed, or keeping it simple for now

  const LanguageOption({
    required this.code,
    required this.label,
    this.flag = '',
  });
}

class LanguageConstants {
  static const String keyNativeLanguage = 'native_language';
  static const String keyTargetLanguage = 'target_language';

  // Default Codes
  static const String defaultNativeLanguageCode = 'zh-CN';
  static const String defaultTargetLanguageCode = 'en-US';

  // Support List with strictly defined ISO codes
  // This allows us to support variants like en-US vs en-GB later easily
  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(code: 'en-US', label: 'English (US)', flag: '🇺🇸'),
    LanguageOption(code: 'en-GB', label: 'English (UK)', flag: '🇬🇧'),
    LanguageOption(code: 'zh-CN', label: 'Chinese (Simplified)', flag: '🇨🇳'),
    LanguageOption(code: 'ja-JP', label: 'Japanese', flag: '🇯🇵'),
    LanguageOption(code: 'ko-KR', label: 'Korean', flag: '🇰🇷'),
    LanguageOption(code: 'es-ES', label: 'Spanish (Spain)', flag: '🇪🇸'),
    LanguageOption(code: 'es-MX', label: 'Spanish (Mexico)', flag: '🇲🇽'),
    LanguageOption(code: 'fr-FR', label: 'French', flag: '🇫🇷'),
    LanguageOption(code: 'de-DE', label: 'German', flag: '🇩🇪'),
  ];

  /// Helper to get label dynamically from code
  static String getLabel(String? code) {
    if (code == null || code.isEmpty) return 'Select Language';
    try {
      return supportedLanguages
          .firstWhere((element) => element.code == code)
          .label;
    } catch (e) {
      // Fallback for unknown codes or old data compatibility
      if (code == 'English') return 'English (US)';
      if (code.contains('Chinese')) return 'Chinese (Simplified)';
      return code;
    }
  }

  /// Get localized label using context
  static String getLocalizedLabel(BuildContext context, String? code) {
    if (code == null || code.isEmpty) return 'Select Language';
    switch (code) {
      case 'en-US':
        return context.l10n.lang_en_US;
      case 'en-GB':
        return context.l10n.lang_en_GB;
      case 'zh-CN':
        return context.l10n.lang_zh_CN;
      case 'ja-JP':
        return context.l10n.lang_ja_JP;
      case 'ko-KR':
        return context.l10n.lang_ko_KR;
      case 'es-ES':
        return context.l10n.lang_es_ES;
      case 'es-MX':
        return context.l10n.lang_es_MX;
      case 'fr-FR':
        return context.l10n.lang_fr_FR;
      case 'de-DE':
        return context.l10n.lang_de_DE;
      default:
        return getLabel(code);
    }
  }

  /// Helper to get ISO code from legacy name (Safe migration in app runtime)
  static String getIsoCode(String? name) {
    if (name == null) return defaultTargetLanguageCode;
    // Check if it's already a code
    if (supportedLanguages.any((l) => l.code == name)) return name;

    // Convert legacy names
    switch (name) {
      case 'English':
        return 'en-US';
      case 'Chinese (Simplified)':
        return 'zh-CN';
      case 'Japanese':
        return 'ja-JP';
      case 'Korean':
        return 'ko-KR';
      case 'Spanish':
        return 'es-ES';
      case 'French':
        return 'fr-FR';
      case 'German':
        return 'de-DE';
      default:
        return defaultTargetLanguageCode;
    }
  }
}
