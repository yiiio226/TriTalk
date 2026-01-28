// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_tritalkError => 'TriTalk - Error';

  @override
  String get home_cancel => 'Cancel';

  @override
  String get scenes_favorites => 'Favorites';

  @override
  String get scenes_clearConversation => 'Clear Conversation';

  @override
  String get scenes_bookmarkConversation => 'Bookmark Conversation';

  @override
  String get study_savedToNotebook => 'Saved to Notebook!';

  @override
  String get study_summary => 'SUMMARY';

  @override
  String get study_sentenceStructure => 'SENTENCE STRUCTURE';

  @override
  String get study_grammarPoints => 'GRAMMAR POINTS';

  @override
  String get study_vocabulary => 'VOCABULARY';

  @override
  String get study_idiomsSlang => 'IDIOMS & SLANG';

  @override
  String get study_analysisNotAvailable => 'Analysis not available';

  @override
  String get chat_delete => 'Delete';

  @override
  String get chat_typeAMessage => 'Type a message...';

  @override
  String get chat_optimizeWithAi => 'Optimize with AI';

  @override
  String get chat_conversationDeleted => 'Conversation deleted';

  @override
  String get chat_analyzingPronunciation => 'Analyzing pronunciation...';

  @override
  String get chat_retry => 'Retry';

  @override
  String get subscription_welcomeToPro => 'Welcome to Pro!';

  @override
  String get subscription_purchasesRestored => 'Purchases Restored';

  @override
  String get profile_nativeLanguage => 'Native Language';

  @override
  String get profile_learningLanguage => 'Learning Language';

  @override
  String get profile_vocabularySentencesChatHistory =>
      'Vocabulary, Sentences, Grammar, Chat History';

  @override
  String get profile_upgradeToPro => 'Upgrade to Pro';

  @override
  String get profile_getUnlimitedChatsAnd =>
      'Get unlimited chats and advanced feedback';

  @override
  String get profile_logOut => 'Log Out';

  @override
  String get onboarding_sessionExpiredPleaseLog =>
      'Session expired. Please log in again.';

  @override
  String get tritalk => 'TriTalk';

  @override
  String get profile_appLanguage => 'App Language';

  @override
  String get profile_selectAppLanguage => 'Select App Language';

  @override
  String get profile_languageSettings => 'Language Settings';

  @override
  String get common_systemDefault => 'System Default';

  @override
  String home_chooseScenario(String language) {
    return 'Choose a scenario to practice your $language';
  }

  @override
  String get subscription_upgrade => 'Upgrade';

  @override
  String get subscription_choosePlan => 'Choose a Plan';

  @override
  String get subscription_restore => 'Restore Purchases';

  @override
  String get subscription_unlockPotential => 'Unlock Full Potential';

  @override
  String get subscription_description =>
      'Get unlimited conversations, advanced grammar analysis, and access to all premium scenarios.';

  @override
  String get subscription_recommended => 'POPULAR';

  @override
  String get subscription_monthlyPlan => 'Monthly';

  @override
  String get subscription_yearlyPlan => 'Yearly';

  @override
  String get subscription_purchaseSuccess => 'Subscription activated! Welcome!';

  @override
  String get subscription_purchaseFailed =>
      'Purchase failed. Please try again.';

  @override
  String get subscription_noPurchasesToRestore =>
      'No previous purchases found.';

  @override
  String get subscription_restoreFailed =>
      'Failed to restore purchases. Please try again.';

  @override
  String get subscription_noProductsAvailable => 'No products available.';

  @override
  String get subscription_featureUnlimitedMessages => 'Unlimited messages';

  @override
  String get subscription_featureAdvancedFeedback =>
      'Advanced grammar feedback';

  @override
  String get subscription_featureAllPlusFeatures =>
      'All Plus features included';

  @override
  String get subscription_featurePremiumScenarios => 'Premium scenarios';

  @override
  String get subscription_featurePrioritySupport => 'Priority support';
}
