// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'TriTalk';

  @override
  String get home_greeting => '嗨！准备好练习了吗？';

  @override
  String get home_dailyGoal => '每日目标';

  @override
  String get home_recentScenarios => '最近场景';

  @override
  String get home_exploreScenarios => '探索场景';

  @override
  String get home_startChat => '开始对话';

  @override
  String get home_cancel => '取消';

  @override
  String get chat_typeAMessage => '输入消息...';

  @override
  String get chat_pressToSpeak => '按住 说话';

  @override
  String get chat_releaseToSend => '松开 发送';

  @override
  String get chat_optimizeWithAi => 'AI 润色';

  @override
  String get chat_retry => '重试';

  @override
  String get chat_delete => '删除';

  @override
  String get profile_languageSettings => '语言设置';

  @override
  String get profile_appLanguage => '应用语言';

  @override
  String get profile_nativeLanguage => '母语';

  @override
  String get profile_learningLanguage => '学习语言';

  @override
  String get profile_upgradeToPro => '升级到 Pro';

  @override
  String get profile_logOut => '退出登录';

  @override
  String get profile_preferences => 'Preferences';

  @override
  String get profile_notifications => 'Notifications';

  @override
  String get profile_statsChats => '已对话次数';

  @override
  String get profile_statsMins => '学习时长';

  @override
  String get profile_vocabularySentencesChatHistory => '生词本，句子，聊天记录';

  @override
  String get common_loading => '加载中...';

  @override
  String get common_error => '错误';

  @override
  String get common_success => '成功';

  @override
  String get common_save => '保存';

  @override
  String get common_confirm => '确认';

  @override
  String subscription_currentTier(Object tier) {
    return '当前方案：$tier';
  }

  @override
  String get subscription_restore => '恢复购买';

  @override
  String get subscription_unlockPotential => '解锁全部潜力';

  @override
  String get subscription_description => '获得无限对话、高级语法分析，以及所有高级场景的使用权限。';

  @override
  String get subscription_recommended => '热门';

  @override
  String get subscription_monthlyPlan => '月度方案';

  @override
  String get subscription_yearlyPlan => '年度方案';

  @override
  String get subscription_purchaseSuccess => '订阅已激活！欢迎！';

  @override
  String get subscription_purchaseFailed => '购买失败，请重试。';

  @override
  String get subscription_noPurchasesToRestore => '未找到之前的购买记录。';

  @override
  String get subscription_restoreFailed => '恢复购买失败，请重试。';

  @override
  String get subscription_noProductsAvailable => '暂无可用商品。';

  @override
  String get subscription_featureUnlimitedMessages => '无限消息';

  @override
  String get subscription_featureAdvancedFeedback => '高级语法反馈';

  @override
  String get subscription_featureAllPlusFeatures => '包含所有 Plus 功能';

  @override
  String get subscription_featurePremiumScenarios => '高级场景';

  @override
  String get subscription_featurePrioritySupport => '优先支持';

  @override
  String get chat_listen => '听读';

  @override
  String get chat_stop => '停止';

  @override
  String get chat_perfect => '完美';

  @override
  String get chat_feedback => '反馈';

  @override
  String get chat_analyzing => '分析中...';

  @override
  String get chat_analyze => '分析';

  @override
  String get chat_hide_text => '隐藏';

  @override
  String get chat_text => '文本';

  @override
  String get chat_voiceToTextLabel => '文';

  @override
  String get chat_shadow => '跟读';

  @override
  String get chat_translate => '翻译';

  @override
  String get chat_save => '保存';

  @override
  String get scenes_favorites => '收藏';

  @override
  String get scenes_clearConversation => '清空对话';

  @override
  String get scenes_bookmarkConversation => '收藏对话';

  @override
  String get analysis_title => '句子分析';

  @override
  String get analysis_originalSentence => '原句';

  @override
  String analysis_savedToVocab(Object word) {
    return '已保存 \"$word\" 到生词本';
  }

  @override
  String get analysis_savedIdiom => '已保存习语';

  @override
  String get shadowing_title => '跟读练习';

  @override
  String get shadowing_holdToRecord => '按住录音';

  @override
  String get shadowing_recordAgain => '重新录音';

  @override
  String get shadowing_complete => '完成';

  @override
  String get shadowing_notRated => '未评分';

  @override
  String get shadowing_myScore => '我的评分';

  @override
  String get saveNote_title => '快速保存';

  @override
  String get saveNote_instruction => '点击单词选择特定词汇，或保存整句。';

  @override
  String get saveNote_saveSentence => '保存整句';

  @override
  String saveNote_saveSelected(Object count) {
    return '保存已选 ($count)';
  }

  @override
  String get chat_suggestions => '建议';

  @override
  String chat_suggestionsFailed(Object error) {
    return '加载建议失败：$error';
  }

  @override
  String get chat_deleteConversation => '删除对话';

  @override
  String get chat_deleteConversationContent => '确定要删除此对话吗？这也将从主屏幕移除它。';

  @override
  String get home_createScenario => '创建场景';

  @override
  String get home_createScenarioDescription => '描述您想练习的情境，AI 将为您创建角色扮演场景。';

  @override
  String get home_createScenarioHint => '例如：我需要退还某种有缺陷的产品，但店员很刁难...';

  @override
  String get home_generateScenario => '生成场景';

  @override
  String get profile_selectNative => '选择母语';

  @override
  String get profile_selectLearning => '选择学习语言';

  @override
  String get profile_tools => '工具';

  @override
  String get tab_vocabulary => '词汇';

  @override
  String get tab_sentence => '句子';

  @override
  String get tab_grammar => '语法';

  @override
  String get tab_chat => '对话';

  @override
  String get study_noSavedSentences => '暂无已保存的分析句子';

  @override
  String get profile_selectAppLanguage => '选择应用语言';

  @override
  String get profile_systemDefault => '系统默认';

  @override
  String home_chooseScenario(String language) {
    return '选择一个场景开始练习 $language';
  }

  @override
  String get onboarding_sessionExpiredPleaseLog => '会话已过期，请重新登录。';

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
  String get study_savedToNotebook => '已保存到生词本';

  @override
  String get chat_conversationDeleted => '对话已删除';

  @override
  String get analysis_savedGrammarPoint => '已保存语法点';

  @override
  String get lang_en_US => '英语 (美国)';

  @override
  String get lang_en_GB => '英语 (英国)';

  @override
  String get lang_zh_CN => '简体中文';

  @override
  String get lang_ja_JP => '日语';

  @override
  String get lang_ko_KR => '韩语';

  @override
  String get lang_es_ES => '西班牙语 (西班牙)';

  @override
  String get lang_es_MX => '西班牙语 (墨西哥)';

  @override
  String get lang_fr_FR => '法语';

  @override
  String get lang_de_DE => '德语';

  @override
  String chat_messagesDeleted(num count) {
    return '已删除 $count 条消息';
  }

  @override
  String get home_sceneDeleted => '场景已删除';

  @override
  String study_example(String text) {
    return '例：$text';
  }

  @override
  String get home_savedToFavorites => '已保存到收藏';

  @override
  String get home_clearConversation => '清空对话';

  @override
  String get home_clearConversationContent => '确定要清空此对话并重新开始吗？';

  @override
  String get home_conversationCleared => '对话已清空';

  @override
  String get home_clear => '清空';

  @override
  String get home_noMessagesToBookmark => '没有可收藏的消息';

  @override
  String get feedback_greatStatus => '语调很棒！听起来很自然。';

  @override
  String get feedback_greatTipQuestion => '你的疑问语调非常到位！继续保持。';

  @override
  String get feedback_greatTipDefault => '你的语调与母语者完美匹配。';

  @override
  String get feedback_goodStatus => '不错的开始，尝试表达更多情感。';

  @override
  String get feedback_goodTipQuestion => '💡 提示：在问句结尾处提高音调。';

  @override
  String get feedback_goodTipExclamation => '💡 提示：在关键词上增加更多能量和强调。';

  @override
  String get feedback_goodTipDefault => '💡 提示：变化你的音调，避免单调。';

  @override
  String get feedback_flatStatus => '太平了，模仿语调的起伏。';

  @override
  String get feedback_flatTipQuestion => '💡 提示：问句结尾应该上扬 ↗️。尝试夸张一点练习。';

  @override
  String get feedback_flatTipExclamation => '💡 提示：表现出兴奋！用更高的音调强调重要的词。';

  @override
  String get feedback_flatTipDefault => '💡 提示：你的声音听起来像机器人。模仿母语者的节奏和旋律。';

  @override
  String get common_retry => '重试';

  @override
  String get common_azureAi => 'Azure AI';

  @override
  String get scenes_configureSession => '配置您的练习会话';

  @override
  String get study_pitchContour => '音调曲线';

  @override
  String get study_tapCurve => '点击曲线';

  @override
  String get study_pronunciation => '发音';

  @override
  String get study_tapWords => '点击单词';

  @override
  String get chat_deleteMessagesConfirm => '确定要删除选中的消息吗？此操作无法撤销。';

  @override
  String get chat_textModeIcon => '文';

  @override
  String get feedback_grammarCorrect => '语法正确！表达很棒！';

  @override
  String get feedback_pronunciationLabel => '发音：';

  @override
  String get feedback_sentenceLabel => '句子：';

  @override
  String get feedback_intonationLabel => '🌊 语调：';

  @override
  String get onboarding_tellUsAboutYourself => '介绍一下你自己';

  @override
  String get onboarding_nativeLanguageQuestion => '你的母语是什么？';

  @override
  String get onboarding_learningLanguageQuestion => '你想学习什么？';

  @override
  String get deleteAccount => '删除账号';

  @override
  String get deleteAccountConfirmationTitle => '确认删除账号？';

  @override
  String get deleteAccountConfirmationContent => '此操作不可撤销。您的所有数据将被永久删除且无法恢复。';

  @override
  String get deleteAccountSubscriptionWarning => '删除账号不会取消您的订阅。请在设备设置中管理订阅。';

  @override
  String get deleteAccountTypeConfirm => '输入 DELETE 以确认';

  @override
  String get deleteAccountTypeHint => 'DELETE';

  @override
  String get deleteAction => '删除';

  @override
  String get cancelAction => '取消';

  @override
  String get deleteAccountLoading => '正在删除账号...';

  @override
  String get deleteAccountFailed => '删除账号失败';

  @override
  String get profile_dangerZone => '危险操作';
}
