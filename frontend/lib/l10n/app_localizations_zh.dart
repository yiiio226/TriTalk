// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get common_tritalkError => 'TriTalk - 错误';

  @override
  String get home_cancel => '取消';

  @override
  String get scenes_favorites => '收藏';

  @override
  String get scenes_clearConversation => '清除对话';

  @override
  String get scenes_bookmarkConversation => '收藏对话';

  @override
  String get study_savedToNotebook => '已保存到笔记本！';

  @override
  String get study_summary => '总结';

  @override
  String get study_sentenceStructure => '句子结构';

  @override
  String get study_grammarPoints => '语法要点';

  @override
  String get study_vocabulary => '词汇';

  @override
  String get study_idiomsSlang => '习语与俚语';

  @override
  String get study_analysisNotAvailable => '暂无分析';

  @override
  String get chat_delete => '删除';

  @override
  String get chat_typeAMessage => '输入消息...';

  @override
  String get chat_optimizeWithAi => 'AI 优化';

  @override
  String get chat_conversationDeleted => '对话已删除';

  @override
  String get chat_analyzingPronunciation => '正在分析发音...';

  @override
  String get chat_retry => '重试';

  @override
  String get subscription_welcomeToPro => '欢迎成为 Pro会员！';

  @override
  String get subscription_purchasesRestored => '购买已恢复';

  @override
  String get profile_nativeLanguage => '母语';

  @override
  String get profile_learningLanguage => '学习语言';

  @override
  String get profile_vocabularySentencesChatHistory => '词汇、句子、聊天记录';

  @override
  String get profile_upgradeToPro => '升级到 Pro';

  @override
  String get profile_getUnlimitedChatsAnd => '获取无限对话和高级反馈';

  @override
  String get profile_logOut => '退出登录';

  @override
  String get onboarding_sessionExpiredPleaseLog => '会话已过期，请重新登录。';

  @override
  String get tritalk => 'TriTalk';

  @override
  String get profile_appLanguage => '应用语言';

  @override
  String get profile_selectAppLanguage => '选择应用语言';

  @override
  String get profile_languageSettings => '语言设置';

  @override
  String get common_systemDefault => '跟随系统';

  @override
  String home_chooseScenario(String language) {
    return '选择场景来练习您的$language';
  }
}
