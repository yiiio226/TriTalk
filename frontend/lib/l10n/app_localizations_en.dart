// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TriTalk';

  @override
  String get home_greeting => 'Hi! Ready to practice?';

  @override
  String get home_dailyGoal => 'Daily Goal';

  @override
  String get home_recentScenarios => 'Recent Scenarios';

  @override
  String get home_exploreScenarios => 'Explore Scenarios';

  @override
  String get home_startChat => 'Start Chat';

  @override
  String get home_cancel => 'Cancel';

  @override
  String get chat_typeAMessage => 'Type a message...';

  @override
  String get chat_pressToSpeak => 'Press to speak';

  @override
  String get chat_releaseToSend => 'Release to send';

  @override
  String get chat_optimizeWithAi => 'Optimize with AI';

  @override
  String get chat_retry => 'Retry';

  @override
  String get chat_delete => 'Delete';

  @override
  String get profile_languageSettings => 'Language Settings';

  @override
  String get profile_appLanguage => 'App Language';

  @override
  String get profile_nativeLanguage => 'Native Language';

  @override
  String get profile_learningLanguage => 'Learning Language';

  @override
  String get profile_upgradeToPro => 'Upgrade to Pro';

  @override
  String get profile_logOut => 'Log Out';

  @override
  String get profile_vocabularySentencesChatHistory =>
      'Vocabulary, Sentences, Chat History';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Success';

  @override
  String get common_save => 'Save';

  @override
  String get common_confirm => 'Confirm';

  @override
  String subscription_currentTier(Object tier) {
    return 'Current Plan: $tier';
  }

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

  @override
  String get chat_listen => 'Listen';

  @override
  String get chat_stop => 'Stop';

  @override
  String get chat_perfect => 'Perfect';

  @override
  String get chat_feedback => 'Feedback';

  @override
  String get chat_analyzing => 'Analyzing...';

  @override
  String get chat_analyze => 'Analyze';

  @override
  String get chat_hide_text => 'Hide Text';

  @override
  String get chat_text => 'Text';

  @override
  String get chat_voiceToTextLabel => 'Text';

  @override
  String get chat_shadow => 'Shadow';

  @override
  String get chat_translate => 'Translate';

  @override
  String get chat_save => 'Save';

  @override
  String get scenes_favorites => 'Favorites';

  @override
  String get scenes_clearConversation => 'Clear Conversation';

  @override
  String get scenes_bookmarkConversation => 'Bookmark Conversation';

  @override
  String get analysis_title => 'Sentence Analysis';

  @override
  String get analysis_originalSentence => 'ORIGINAL SENTENCE';

  @override
  String analysis_savedToVocab(Object word) {
    return 'Saved \"$word\" to Vocabulary';
  }

  @override
  String get analysis_savedIdiom => 'Saved Idiom';

  @override
  String get shadowing_title => 'Shadowing Practice';

  @override
  String get shadowing_holdToRecord => 'Hold to Record';

  @override
  String get shadowing_recordAgain => 'Record Again';

  @override
  String get shadowing_complete => 'Complete';

  @override
  String get shadowing_notRated => 'Not Rated';

  @override
  String get shadowing_myScore => 'My Score';

  @override
  String get saveNote_title => 'Quick Save';

  @override
  String get saveNote_instruction =>
      'Tap words to select specific vocabulary, or save the entire sentence.';

  @override
  String get saveNote_saveSentence => 'Save Entire Sentence';

  @override
  String saveNote_saveSelected(Object count) {
    return 'Save Selected ($count)';
  }

  @override
  String get chat_suggestions => 'Suggestions';

  @override
  String chat_suggestionsFailed(Object error) {
    return 'Failed to load suggestions: $error';
  }

  @override
  String get chat_deleteConversation => 'Delete Conversation';

  @override
  String get chat_deleteConversationContent =>
      'Are you sure you want to delete this conversation? This will also remove it from your home screen.';

  @override
  String get home_createScenario => 'Create Scenario';

  @override
  String get home_createScenarioDescription =>
      'Describe a situation you want to practice. AI will create a roleplay scenario for you.';

  @override
  String get home_createScenarioHint =>
      'Example: I need to return a defective product, but the store clerk is being difficult...';

  @override
  String get home_generateScenario => 'Generate Scenario';

  @override
  String get profile_selectNative => 'Select Native Language';

  @override
  String get profile_selectLearning => 'Select Learning Language';

  @override
  String get profile_tools => 'Tools';

  @override
  String get tab_vocabulary => 'Vocabulary';

  @override
  String get tab_sentence => 'Sentence';

  @override
  String get tab_grammar => 'Grammar';

  @override
  String get tab_chat => 'Chat';

  @override
  String get study_noSavedSentences => 'No analyzed sentences saved yet';

  @override
  String get profile_selectAppLanguage => 'Select App Language';

  @override
  String get profile_systemDefault => 'System Default';

  @override
  String home_chooseScenario(String language) {
    return 'Choose a scenario to practice $language';
  }

  @override
  String get onboarding_sessionExpiredPleaseLog =>
      'Session expired. Please log in again.';

  @override
  String get study_summary => 'Summary';

  @override
  String get study_sentenceStructure => 'Sentence Structure';

  @override
  String get study_grammarPoints => 'Grammar Points';

  @override
  String get study_vocabulary => 'Vocabulary';

  @override
  String get study_idiomsSlang => 'Idioms & Slang';

  @override
  String get study_analysisNotAvailable => 'Analysis not available';

  @override
  String get study_savedToNotebook => 'Saved to Notebook';

  @override
  String get chat_conversationDeleted => 'Conversation deleted';

  @override
  String get analysis_savedGrammarPoint => 'Saved Grammar Point';

  @override
  String get lang_en_US => 'English (US)';

  @override
  String get lang_en_GB => 'English (UK)';

  @override
  String get lang_zh_CN => 'Chinese (Simplified)';

  @override
  String get lang_ja_JP => 'Japanese';

  @override
  String get lang_ko_KR => 'Korean';

  @override
  String get lang_es_ES => 'Spanish (Spain)';

  @override
  String get lang_es_MX => 'Spanish (Mexico)';

  @override
  String get lang_fr_FR => 'French';

  @override
  String get lang_de_DE => 'German';

  @override
  String chat_messagesDeleted(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deleted $count messages',
      one: 'Deleted 1 message',
    );
    return '$_temp0';
  }

  @override
  String get home_sceneDeleted => 'Scene deleted';

  @override
  String study_example(String text) {
    return 'Example: $text';
  }

  @override
  String get home_savedToFavorites => 'Saved to Favorites';

  @override
  String get home_clearConversation => 'Clear Conversation';

  @override
  String get home_clearConversationContent =>
      'Are you sure you want to clear this conversation and start over?';

  @override
  String get home_conversationCleared => 'Conversation cleared';

  @override
  String get home_clear => 'Clear';

  @override
  String get home_noMessagesToBookmark => 'No messages to bookmark';

  @override
  String get feedback_greatStatus => 'Great intonation! You sound natural.';

  @override
  String get feedback_greatTipQuestion =>
      'Your question intonation is spot-on! Keep it up.';

  @override
  String get feedback_greatTipDefault =>
      'Your tone matches the native speaker perfectly.';

  @override
  String get feedback_goodStatus => 'Good start. Try to express more emotion.';

  @override
  String get feedback_goodTipQuestion =>
      '💡 Tip: Raise your pitch more at the end of the question.';

  @override
  String get feedback_goodTipExclamation =>
      '💡 Tip: Add more energy and emphasis on key words.';

  @override
  String get feedback_goodTipDefault =>
      '💡 Tip: Vary your pitch to sound less monotone.';

  @override
  String get feedback_flatStatus => 'Too flat. Mimic the ups and downs.';

  @override
  String get feedback_flatTipQuestion =>
      '💡 Tip: Questions should rise at the end ↗️. Practice with exaggerated pitch.';

  @override
  String get feedback_flatTipExclamation =>
      '💡 Tip: Show excitement! Emphasize important words with higher pitch.';

  @override
  String get feedback_flatTipDefault =>
      '💡 Tip: Your voice sounds robotic. Copy the rhythm and melody of the native speaker.';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_azureAi => 'Azure AI';

  @override
  String get scenes_configureSession => 'Configure your practice session';

  @override
  String get study_pitchContour => 'Pitch Contour';

  @override
  String get study_tapCurve => 'Tap curve';

  @override
  String get study_pronunciation => 'Pronunciation';

  @override
  String get study_tapWords => 'Tap words';

  @override
  String get chat_deleteMessagesConfirm =>
      'Are you sure you want to delete selected messages? This action cannot be undone.';

  @override
  String get chat_textModeIcon => 'Text';

  @override
  String get feedback_grammarCorrect => 'Grammar is correct! Great expression!';

  @override
  String get feedback_pronunciationLabel => 'Pronunciation:';

  @override
  String get feedback_sentenceLabel => 'Sentence:';

  @override
  String get feedback_intonationLabel => '🌊 Intonation:';

  @override
  String get onboarding_tellUsAboutYourself => 'Tell us about yourself';

  @override
  String get onboarding_nativeLanguageQuestion =>
      'What is your native language?';

  @override
  String get onboarding_learningLanguageQuestion =>
      'What do you want to learn?';
}
