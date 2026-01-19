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

  /// Source: core/widgets/error_screen.dart:13 (title)
  ///
  /// In en, this message translates to:
  /// **'TriTalk - Error'**
  String get common_tritalkError;

  /// Source: features/home/presentation/pages/home_screen.dart:541 (Text)
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get home_cancel;

  /// Source: features/scenes/presentation/widgets/scene_options_drawer.dart:28 (Text)
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get scenes_favorites;

  /// Source: features/scenes/presentation/widgets/scene_options_drawer.dart:37 (Text)
  ///
  /// In en, this message translates to:
  /// **'Clear Conversation'**
  String get scenes_clearConversation;

  /// Source: features/scenes/presentation/widgets/scene_options_drawer.dart:46 (Text)
  ///
  /// In en, this message translates to:
  /// **'Bookmark Conversation'**
  String get scenes_bookmarkConversation;

  /// Source: features/study/presentation/widgets/save_note_sheet.dart:62 (Text)
  ///
  /// In en, this message translates to:
  /// **'Saved to Notebook!'**
  String get study_savedToNotebook;

  /// Source: features/study/presentation/widgets/analysis_sheet.dart:335 (title)
  ///
  /// In en, this message translates to:
  /// **'SUMMARY'**
  String get study_summary;

  /// Source: features/study/presentation/widgets/analysis_sheet.dart:358 (title)
  ///
  /// In en, this message translates to:
  /// **'SENTENCE STRUCTURE'**
  String get study_sentenceStructure;

  /// Source: features/study/presentation/widgets/analysis_sheet.dart:367 (title)
  ///
  /// In en, this message translates to:
  /// **'GRAMMAR POINTS'**
  String get study_grammarPoints;

  /// Source: features/study/presentation/widgets/analysis_sheet.dart:376 (title)
  ///
  /// In en, this message translates to:
  /// **'VOCABULARY'**
  String get study_vocabulary;

  /// Source: features/study/presentation/widgets/analysis_sheet.dart:385 (title)
  ///
  /// In en, this message translates to:
  /// **'IDIOMS & SLANG'**
  String get study_idiomsSlang;

  /// Source: features/study/presentation/widgets/analysis_sheet.dart:576 (Text)
  ///
  /// In en, this message translates to:
  /// **'Analysis not available'**
  String get study_analysisNotAvailable;

  /// Source: features/chat/presentation/pages/chat_screen.dart:807 (Text)
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chat_delete;

  /// Source: features/chat/presentation/pages/chat_screen.dart:977 (hintText)
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chat_typeAMessage;

  /// Source: features/chat/presentation/pages/chat_screen.dart:1012 (tooltip)
  ///
  /// In en, this message translates to:
  /// **'Optimize with AI'**
  String get chat_optimizeWithAi;

  /// Source: features/chat/presentation/widgets/chat_history_list_widget.dart:96 (Text)
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get chat_conversationDeleted;

  /// Source: features/chat/presentation/widgets/voice_feedback_sheet.dart:241 (Text)
  ///
  /// In en, this message translates to:
  /// **'Analyzing pronunciation...'**
  String get chat_analyzingPronunciation;

  /// Source: features/chat/presentation/widgets/voice_feedback_sheet.dart:477 (Text)
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get chat_retry;

  /// Source: features/subscription/presentation/pages/paywall_screen.dart:87 (Text)
  ///
  /// In en, this message translates to:
  /// **'Welcome to Pro!'**
  String get subscription_welcomeToPro;

  /// Source: features/subscription/presentation/pages/paywall_screen.dart:115 (Text)
  ///
  /// In en, this message translates to:
  /// **'Purchases Restored'**
  String get subscription_purchasesRestored;

  /// Source: features/profile/presentation/pages/profile_screen.dart:301 (title)
  ///
  /// In en, this message translates to:
  /// **'Native Language'**
  String get profile_nativeLanguage;

  /// Source: features/profile/presentation/pages/profile_screen.dart:316 (title)
  ///
  /// In en, this message translates to:
  /// **'Learning Language'**
  String get profile_learningLanguage;

  /// Source: features/profile/presentation/pages/profile_screen.dart:340 (title)
  ///
  /// In en, this message translates to:
  /// **'Vocabulary, Sentences, Chat History'**
  String get profile_vocabularySentencesChatHistory;

  /// Source: features/profile/presentation/pages/profile_screen.dart:356 (title)
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get profile_upgradeToPro;

  /// Source: features/profile/presentation/pages/profile_screen.dart:357 (title)
  ///
  /// In en, this message translates to:
  /// **'Get unlimited chats and advanced feedback'**
  String get profile_getUnlimitedChatsAnd;

  /// Source: features/profile/presentation/pages/profile_screen.dart:373 (title)
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profile_logOut;

  /// Source: features/onboarding/presentation/pages/onboarding_screen.dart:57 (Text)
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get onboarding_sessionExpiredPleaseLog;

  /// Source: main.dart:78 (title)
  ///
  /// In en, this message translates to:
  /// **'TriTalk'**
  String get tritalk;

  /// Label for app display language setting in profile screen
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get profile_appLanguage;

  /// Title for app language selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select App Language'**
  String get profile_selectAppLanguage;

  /// Section title for language settings in profile screen
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get profile_languageSettings;

  /// Option label for following system language setting
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get common_systemDefault;

  /// Subtitle on home screen prompting user to select a practice scenario
  ///
  /// In en, this message translates to:
  /// **'Choose a scenario to practice your {language}'**
  String home_chooseScenario(String language);

  /// Title for the upgrade/paywall screen
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get subscription_upgrade;

  /// Title for subscription plan selection
  ///
  /// In en, this message translates to:
  /// **'Choose a Plan'**
  String get subscription_choosePlan;

  /// Button text to restore previous purchases
  ///
  /// In en, this message translates to:
  /// **'Restore'**
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
