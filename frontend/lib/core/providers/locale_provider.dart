import 'package:flutter/material.dart';

/// 全局语言设置的状态管理
/// 支持跟随系统语言或用户手动选择
class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  /// 获取当前语言设置
  /// 返回 null 表示跟随系统语言
  Locale? get locale => _locale;

  /// 设置应用语言
  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners(); // 触发全屏刷新
  }

  /// 清除语言设置，跟随系统语言
  void clearLocale() {
    _locale = null;
    notifyListeners();
  }
}
