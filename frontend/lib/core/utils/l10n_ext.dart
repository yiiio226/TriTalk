import 'package:flutter/widgets.dart';
import 'package:frontend/l10n/app_localizations.dart';

/// BuildContext 扩展，简化多语言资源的调用
/// 使用方式: context.l10n.yourKey
extension LocalizedContext on BuildContext {
  /// 快速获取多语言资源: context.l10n.yourKey
  AppLocalizations get l10n => AppLocalizations.of(this);
}
