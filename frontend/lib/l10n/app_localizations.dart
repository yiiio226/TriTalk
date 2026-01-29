import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'TriTalk'**
  String get appTitle;

  /// Greeting shown on the home screen
  ///
  /// In en, this message translates to:
  /// **'Hi! Ready to practice?'**
  String get home_greeting;

  /// Label for the daily goal section
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get home_dailyGoal;

  /// Section title for recent conversation scenarios
  ///
  /// In en, this message translates to:
  /// **'Recent Scenarios'**
  String get home_recentScenarios;

  /// Section title to explore new scenarios
  ///
  /// In en, this message translates to:
  /// **'Explore Scenarios'**
  String get home_exploreScenarios;

  /// Button text to start a new chat
  ///
  /// In en, this message translates to:
  /// **'Start Chat'**
  String get home_startChat;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get home_cancel;

  /// Hint text for the message input field
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chat_typeAMessage;

  /// Instruction for voice input
  ///
  /// In en, this message translates to:
  /// **'Press to speak'**
  String get chat_pressToSpeak;

  /// Instruction for voice input
  ///
  /// In en, this message translates to:
  /// **'Release to send'**
  String get chat_releaseToSend;

  /// Button tooltip for AI text optimization
  ///
  /// In en, this message translates to:
  /// **'Optimize with AI'**
  String get chat_optimizeWithAi;

  /// Button text to retry a failed action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get chat_retry;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chat_delete;

  /// Section header for language settings in profile
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get profile_languageSettings;

  /// Label for app interface language setting
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get profile_appLanguage;

  /// Label for user's native language setting
  ///
  /// In en, this message translates to:
  /// **'Native Language'**
  String get profile_nativeLanguage;

  /// Label for user's target learning language setting
  ///
  /// In en, this message translates to:
  /// **'Learning Language'**
  String get profile_learningLanguage;

  /// Button text to upgrade subscription
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get profile_upgradeToPro;

  /// Button text to log out
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profile_logOut;

  /// Subtitle for Favorites, listing categories
  ///
  /// In en, this message translates to:
  /// **'Vocabulary, Sentences, Chat History'**
  String get profile_vocabularySentencesChatHistory;

  /// Generic loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// Generic success title
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// Generic save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// Generic confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// Label showing current subscription tier
  ///
  /// In en, this message translates to:
  /// **'Current Plan: {tier}'**
  String subscription_currentTier(Object tier);

  /// Button text to restore previous purchases
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get subscription_restore;

  /// Headline on paywall screen
  ///
  /// In en, this message translates to:
  /// **'Unlock Full Potential'**
  String get subscription_unlockPotential;

  /// Description text on paywall explaining premium benefits
  ///
  /// In en, this message translates to:
  /// **'Get unlimited conversations, advanced grammar analysis, and access to all premium scenarios.'**
  String get subscription_description;

  /// Badge text for recommended subscription tier
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get subscription_recommended;

  /// Label for monthly subscription plan
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get subscription_monthlyPlan;

  /// Label for yearly subscription plan
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get subscription_yearlyPlan;

  /// Success message after completing a purchase
  ///
  /// In en, this message translates to:
  /// **'Subscription activated! Welcome!'**
  String get subscription_purchaseSuccess;

  /// Error message when purchase fails
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get subscription_purchaseFailed;

  /// Message when restore finds no previous purchases
  ///
  /// In en, this message translates to:
  /// **'No previous purchases found.'**
  String get subscription_noPurchasesToRestore;

  /// Error message when restore fails
  ///
  /// In en, this message translates to:
  /// **'Failed to restore purchases. Please try again.'**
  String get subscription_restoreFailed;

  /// Message when no subscription products are available
  ///
  /// In en, this message translates to:
  /// **'No products available.'**
  String get subscription_noProductsAvailable;

  /// Feature description for unlimited messaging
  ///
  /// In en, this message translates to:
  /// **'Unlimited messages'**
  String get subscription_featureUnlimitedMessages;

  /// Feature description for advanced feedback
  ///
  /// In en, this message translates to:
  /// **'Advanced grammar feedback'**
  String get subscription_featureAdvancedFeedback;

  /// Feature description indicating all Plus features
  ///
  /// In en, this message translates to:
  /// **'All Plus features included'**
  String get subscription_featureAllPlusFeatures;

  /// Feature description for premium scenarios
  ///
  /// In en, this message translates to:
  /// **'Premium scenarios'**
  String get subscription_featurePremiumScenarios;

  /// Feature description for priority support
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get subscription_featurePrioritySupport;

  /// Button to listen to TTS audio
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get chat_listen;

  /// Button to stop TTS audio
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get chat_stop;

  /// Button label for perfect pronunciation
  ///
  /// In en, this message translates to:
  /// **'Perfect'**
  String get chat_perfect;

  /// Button label for feedback
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get chat_feedback;

  /// Status text while analyzing
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get chat_analyzing;

  /// Button label to start analysis
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get chat_analyze;

  /// Button label to hide text
  ///
  /// In en, this message translates to:
  /// **'Hide Text'**
  String get chat_hide_text;

  /// Button label to show text
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get chat_text;

  /// Button label for shadowing practice
  ///
  /// In en, this message translates to:
  /// **'Shadow'**
  String get chat_shadow;

  /// Button to translate text
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get chat_translate;

  /// Button to save content
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get chat_save;

  /// Title for favorites screen
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get scenes_favorites;

  /// Option to clear conversation
  ///
  /// In en, this message translates to:
  /// **'Clear Conversation'**
  String get scenes_clearConversation;

  /// Option to bookmark conversation
  ///
  /// In en, this message translates to:
  /// **'Bookmark Conversation'**
  String get scenes_bookmarkConversation;

  /// Title for analysis sheet
  ///
  /// In en, this message translates to:
  /// **'Sentence Analysis'**
  String get analysis_title;

  /// Label for original sentence in analysis
  ///
  /// In en, this message translates to:
  /// **'ORIGINAL SENTENCE'**
  String get analysis_originalSentence;

  /// Toast message when word is saved
  ///
  /// In en, this message translates to:
  /// **'Saved \"{word}\" to Vocabulary'**
  String analysis_savedToVocab(Object word);

  /// Toast message when idiom is saved
  ///
  /// In en, this message translates to:
  /// **'Saved Idiom'**
  String get analysis_savedIdiom;

  /// Title for shadowing practice sheet
  ///
  /// In en, this message translates to:
  /// **'Shadowing Practice'**
  String get shadowing_title;

  /// Instruction to hold button to record
  ///
  /// In en, this message translates to:
  /// **'Hold to Record'**
  String get shadowing_holdToRecord;

  /// Instruction to record again
  ///
  /// In en, this message translates to:
  /// **'Record Again'**
  String get shadowing_recordAgain;

  /// Status label for complete
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get shadowing_complete;

  /// Status label for not rated
  ///
  /// In en, this message translates to:
  /// **'Not Rated'**
  String get shadowing_notRated;

  /// Label for user's score
  ///
  /// In en, this message translates to:
  /// **'My Score'**
  String get shadowing_myScore;

  /// Title for quick save sheet
  ///
  /// In en, this message translates to:
  /// **'Quick Save'**
  String get saveNote_title;

  /// Instruction for saving notes
  ///
  /// In en, this message translates to:
  /// **'Tap words to select specific vocabulary, or save the entire sentence.'**
  String get saveNote_instruction;

  /// Button to save entire sentence
  ///
  /// In en, this message translates to:
  /// **'Save Entire Sentence'**
  String get saveNote_saveSentence;

  /// Button to save selected words
  ///
  /// In en, this message translates to:
  /// **'Save Selected ({count})'**
  String saveNote_saveSelected(Object count);

  /// Title for suggestions sheet
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get chat_suggestions;

  /// Error message for failed suggestions
  ///
  /// In en, this message translates to:
  /// **'Failed to load suggestions: {error}'**
  String chat_suggestionsFailed(Object error);

  /// Title for delete conversation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Conversation'**
  String get chat_deleteConversation;

  /// Content for delete conversation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this conversation? This will also remove it from your home screen.'**
  String get chat_deleteConversationContent;

  /// Title for create scenario dialog
  ///
  /// In en, this message translates to:
  /// **'Create Scenario'**
  String get home_createScenario;

  /// Description for create scenario dialog
  ///
  /// In en, this message translates to:
  /// **'Describe a situation you want to practice. AI will create a roleplay scenario for you.'**
  String get home_createScenarioDescription;

  /// Hint text for scenario description
  ///
  /// In en, this message translates to:
  /// **'Example: I need to return a defective product, but the store clerk is being difficult...'**
  String get home_createScenarioHint;

  /// Button to generate scenario
  ///
  /// In en, this message translates to:
  /// **'Generate Scenario'**
  String get home_generateScenario;

  /// Title for selecting native language
  ///
  /// In en, this message translates to:
  /// **'Select Native Language'**
  String get profile_selectNative;

  /// Title for selecting learning language
  ///
  /// In en, this message translates to:
  /// **'Select Learning Language'**
  String get profile_selectLearning;

  /// Section header for tools
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get profile_tools;

  /// Tab label for vocabulary
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get tab_vocabulary;

  /// Tab label for sentence
  ///
  /// In en, this message translates to:
  /// **'Sentence'**
  String get tab_sentence;

  /// Tab label for grammar
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get tab_grammar;

  /// Tab label for chat
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get tab_chat;

  /// Empty state message for saved sentences
  ///
  /// In en, this message translates to:
  /// **'No analyzed sentences saved yet'**
  String get study_noSavedSentences;

  /// Title for the app language selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select App Language'**
  String get profile_selectAppLanguage;

  /// Label for system default language option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get profile_systemDefault;

  /// Subtitle on home screen prompting to choose a scenario
  ///
  /// In en, this message translates to:
  /// **'Choose a scenario to practice {language}'**
  String home_chooseScenario(String language);

  /// Error message when session expires
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get onboarding_sessionExpiredPleaseLog;

  /// Header for summary section
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get study_summary;

  /// Header for sentence structure section
  ///
  /// In en, this message translates to:
  /// **'Sentence Structure'**
  String get study_sentenceStructure;

  /// Header for grammar points section
  ///
  /// In en, this message translates to:
  /// **'Grammar Points'**
  String get study_grammarPoints;

  /// Header for vocabulary section
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get study_vocabulary;

  /// Header for idioms and slang section
  ///
  /// In en, this message translates to:
  /// **'Idioms & Slang'**
  String get study_idiomsSlang;

  /// Message when analysis is not available
  ///
  /// In en, this message translates to:
  /// **'Analysis not available'**
  String get study_analysisNotAvailable;

  /// Success message when content is saved
  ///
  /// In en, this message translates to:
  /// **'Saved to Notebook'**
  String get study_savedToNotebook;

  /// Message when conversation is deleted
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get chat_conversationDeleted;

  /// Toast message when grammar point is saved
  ///
  /// In en, this message translates to:
  /// **'Saved Grammar Point'**
  String get analysis_savedGrammarPoint;

  /// Language name for English (US)
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get lang_en_US;

  /// Language name for English (UK)
  ///
  /// In en, this message translates to:
  /// **'English (UK)'**
  String get lang_en_GB;

  /// Language name for Chinese (Simplified)
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get lang_zh_CN;

  /// Language name for Japanese
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get lang_ja_JP;

  /// Language name for Korean
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get lang_ko_KR;

  /// Language name for Spanish (Spain)
  ///
  /// In en, this message translates to:
  /// **'Spanish (Spain)'**
  String get lang_es_ES;

  /// Language name for Spanish (Mexico)
  ///
  /// In en, this message translates to:
  /// **'Spanish (Mexico)'**
  String get lang_es_MX;

  /// Language name for French
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get lang_fr_FR;

  /// Language name for German
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get lang_de_DE;

  /// Message when messages are deleted
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Deleted 1 message} other{Deleted {count} messages}}'**
  String chat_messagesDeleted(num count);

  /// Message when a scene is deleted
  ///
  /// In en, this message translates to:
  /// **'Scene deleted'**
  String get home_sceneDeleted;

  /// Prefix for example sentence
  ///
  /// In en, this message translates to:
  /// **'Example: {text}'**
  String study_example(String text);

  /// Toast message when a scenario is saved to favorites
  ///
  /// In en, this message translates to:
  /// **'Saved to Favorites'**
  String get home_savedToFavorites;

  /// Option to clear conversation
  ///
  /// In en, this message translates to:
  /// **'Clear Conversation'**
  String get home_clearConversation;

  /// Content for clear conversation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear this conversation and start over?'**
  String get home_clearConversationContent;

  /// Toast message when conversation is cleared
  ///
  /// In en, this message translates to:
  /// **'Conversation cleared'**
  String get home_conversationCleared;

  /// Button to clear content
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get home_clear;

  /// Error message when trying to bookmark empty conversation
  ///
  /// In en, this message translates to:
  /// **'No messages to bookmark'**
  String get home_noMessagesToBookmark;

  /// Feedback message for great intonation score
  ///
  /// In en, this message translates to:
  /// **'Great intonation! You sound natural.'**
  String get feedback_greatStatus;

  /// Tip for great question intonation
  ///
  /// In en, this message translates to:
  /// **'Your question intonation is spot-on! Keep it up.'**
  String get feedback_greatTipQuestion;

  /// Tip for great intonation
  ///
  /// In en, this message translates to:
  /// **'Your tone matches the native speaker perfectly.'**
  String get feedback_greatTipDefault;

  /// Feedback message for good intonation score
  ///
  /// In en, this message translates to:
  /// **'Good start. Try to express more emotion.'**
  String get feedback_goodStatus;

  /// Tip for good question intonation
  ///
  /// In en, this message translates to:
  /// **'💡 Tip: Raise your pitch more at the end of the question.'**
  String get feedback_goodTipQuestion;

  /// Tip for good exclamation intonation
  ///
  /// In en, this message translates to:
  /// **'💡 Tip: Add more energy and emphasis on key words.'**
  String get feedback_goodTipExclamation;

  /// Tip for good intonation
  ///
  /// In en, this message translates to:
  /// **'💡 Tip: Vary your pitch to sound less monotone.'**
  String get feedback_goodTipDefault;

  /// Feedback message for flat intonation score
  ///
  /// In en, this message translates to:
  /// **'Too flat. Mimic the ups and downs.'**
  String get feedback_flatStatus;

  /// Tip for flat question intonation
  ///
  /// In en, this message translates to:
  /// **'💡 Tip: Questions should rise at the end ↗️. Practice with exaggerated pitch.'**
  String get feedback_flatTipQuestion;

  /// Tip for flat exclamation intonation
  ///
  /// In en, this message translates to:
  /// **'💡 Tip: Show excitement! Emphasize important words with higher pitch.'**
  String get feedback_flatTipExclamation;

  /// Tip for flat intonation
  ///
  /// In en, this message translates to:
  /// **'💡 Tip: Your voice sounds robotic. Copy the rhythm and melody of the native speaker.'**
  String get feedback_flatTipDefault;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
