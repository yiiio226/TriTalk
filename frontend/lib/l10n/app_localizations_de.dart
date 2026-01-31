// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'TriTalk';

  @override
  String get home_greeting => 'Hallo! Bereit zum Üben?';

  @override
  String get home_dailyGoal => 'Tagesziel';

  @override
  String get home_recentScenarios => 'Letzte Szenarien';

  @override
  String get home_exploreScenarios => 'Szenarien erkunden';

  @override
  String get home_startChat => 'Chat starten';

  @override
  String get home_cancel => 'Abbrechen';

  @override
  String get chat_typeAMessage => 'Nachricht eingeben...';

  @override
  String get chat_pressToSpeak => 'Drücken zum Sprechen';

  @override
  String get chat_releaseToSend => 'Loslassen zum Senden';

  @override
  String get chat_optimizeWithAi => 'Mit KI optimieren';

  @override
  String get chat_retry => 'Wiederholen';

  @override
  String get chat_delete => 'Löschen';

  @override
  String get profile_languageSettings => 'Spracheinstellungen';

  @override
  String get profile_appLanguage => 'App-Sprache';

  @override
  String get profile_nativeLanguage => 'Muttersprache';

  @override
  String get profile_learningLanguage => 'Lernsprache';

  @override
  String get profile_upgradeToPro => 'Auf Pro upgraden';

  @override
  String get profile_logOut => 'Abmelden';

  @override
  String get profile_preferences => 'Preferences';

  @override
  String get profile_notifications => 'Notifications';

  @override
  String get profile_statsChats => 'Chats';

  @override
  String get profile_statsMins => 'Mins';

  @override
  String get profile_vocabularySentencesChatHistory =>
      'Wortschatz, Sätze, Verlauf';

  @override
  String get common_loading => 'Laden...';

  @override
  String get common_error => 'Fehler';

  @override
  String get common_success => 'Erfolg';

  @override
  String get common_save => 'Speichern';

  @override
  String get common_confirm => 'Bestätigen';

  @override
  String subscription_currentTier(Object tier) {
    return 'Aktueller Plan: $tier';
  }

  @override
  String get subscription_restore => 'Käufe wiederherstellen';

  @override
  String get subscription_unlockPotential => 'Volles Potenzial freischalten';

  @override
  String get subscription_description =>
      'Erhalten Sie unbegrenzte Gespräche, erweiterte Grammatikanalyse und Zugriff auf alle Premium-Szenarien.';

  @override
  String get subscription_recommended => 'BELIEBT';

  @override
  String get subscription_monthlyPlan => 'Monatlich';

  @override
  String get subscription_yearlyPlan => 'Jährlich';

  @override
  String get subscription_purchaseSuccess => 'Abo aktiviert! Willkommen!';

  @override
  String get subscription_purchaseFailed =>
      'Kauf fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get subscription_noPurchasesToRestore =>
      'Keine früheren Käufe gefunden.';

  @override
  String get subscription_restoreFailed =>
      'Wiederherstellung fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get subscription_noProductsAvailable => 'Keine Produkte verfügbar.';

  @override
  String get subscription_featureUnlimitedMessages => 'Unbegrenzte Nachrichten';

  @override
  String get subscription_featureAdvancedFeedback =>
      'Erweitertes Grammatik-Feedback';

  @override
  String get subscription_featureAllPlusFeatures =>
      'Alle Plus-Funktionen enthalten';

  @override
  String get subscription_featurePremiumScenarios => 'Premium-Szenarien';

  @override
  String get subscription_featurePrioritySupport => 'Bevorzugter Support';

  @override
  String get chat_listen => 'Anhören';

  @override
  String get chat_stop => 'Stopp';

  @override
  String get chat_perfect => 'Perfekt';

  @override
  String get chat_feedback => 'Feedback';

  @override
  String get chat_analyzing => 'Analysiere...';

  @override
  String get chat_analyze => 'Analysieren';

  @override
  String get chat_hide_text => 'Text ausblenden';

  @override
  String get chat_text => 'Text';

  @override
  String get chat_voiceToTextLabel => 'Text';

  @override
  String get chat_shadow => 'Shadowing';

  @override
  String get chat_translate => 'Übersetzen';

  @override
  String get chat_save => 'Speichern';

  @override
  String get scenes_favorites => 'Favoriten';

  @override
  String get scenes_clearConversation => 'Konversation löschen';

  @override
  String get scenes_bookmarkConversation => 'Konversation merken';

  @override
  String get analysis_title => 'Satzanalyse';

  @override
  String get analysis_originalSentence => 'ORIGINALSATZ';

  @override
  String analysis_savedToVocab(Object word) {
    return '\"$word\" im Wortschatz gespeichert';
  }

  @override
  String get analysis_savedIdiom => 'Redewendung gespeichert';

  @override
  String get shadowing_title => 'Shadowing-Übung';

  @override
  String get shadowing_holdToRecord => 'Zum Aufnehmen halten';

  @override
  String get shadowing_recordAgain => 'Erneut aufnehmen';

  @override
  String get shadowing_complete => 'Abgeschlossen';

  @override
  String get shadowing_notRated => 'Nicht bewertet';

  @override
  String get shadowing_myScore => 'Mein Punktestand';

  @override
  String get saveNote_title => 'Schnellspeichern';

  @override
  String get saveNote_instruction =>
      'Tippen Sie auf Wörter, um Vokabeln auszuwählen, oder speichern Sie den ganzen Satz.';

  @override
  String get saveNote_saveSentence => 'Ganzen Satz speichern';

  @override
  String saveNote_saveSelected(Object count) {
    return 'Ausgewählte speichern ($count)';
  }

  @override
  String get chat_suggestions => 'Vorschläge';

  @override
  String chat_suggestionsFailed(Object error) {
    return 'Vorschläge konnten nicht geladen werden: $error';
  }

  @override
  String get chat_deleteConversation => 'Konversation löschen';

  @override
  String get chat_deleteConversationContent =>
      'Sind Sie sicher, dass Sie diese Konversation löschen möchten? Sie wird auch vom Startbildschirm entfernt.';

  @override
  String get home_createScenario => 'Szenario erstellen';

  @override
  String get home_createScenarioDescription =>
      'Beschreiben Sie eine Situation, die Sie üben möchten. Die KI erstellt ein Rollenspiel für Sie.';

  @override
  String get home_createScenarioHint =>
      'Beispiel: Ich muss ein defektes Produkt zurückgeben, aber der Verkäufer ist schwierig...';

  @override
  String get home_generateScenario => 'Szenario generieren';

  @override
  String get profile_selectNative => 'Muttersprache auswählen';

  @override
  String get profile_selectLearning => 'Lernsprache auswählen';

  @override
  String get profile_tools => 'Werkzeuge';

  @override
  String get tab_vocabulary => 'Wortschatz';

  @override
  String get tab_sentence => 'Sätze';

  @override
  String get tab_grammar => 'Grammatik';

  @override
  String get tab_chat => 'Chat';

  @override
  String get study_noSavedSentences =>
      'Noch keine analysierten Sätze gespeichert';

  @override
  String get profile_selectAppLanguage => 'App-Sprache auswählen';

  @override
  String get profile_systemDefault => 'Systemstandard';

  @override
  String home_chooseScenario(String language) {
    return 'Wählen Sie ein Szenario, um $language zu üben';
  }

  @override
  String get onboarding_sessionExpiredPleaseLog =>
      'Sitzung abgelaufen. Bitte melden Sie sich erneut an.';

  @override
  String get study_summary => 'Zusammenfassung';

  @override
  String get study_sentenceStructure => 'Satzstruktur';

  @override
  String get study_grammarPoints => 'Grammatikpunkte';

  @override
  String get study_vocabulary => 'Wortschatz';

  @override
  String get study_idiomsSlang => 'Redewendungen & Slang';

  @override
  String get study_analysisNotAvailable => 'Analyse nicht verfügbar';

  @override
  String get study_savedToNotebook => 'Im Notizbuch gespeichert';

  @override
  String get chat_conversationDeleted => 'Konversation gelöscht';

  @override
  String get analysis_savedGrammarPoint => 'Grammatikpunkt gespeichert';

  @override
  String get lang_en_US => 'Englisch (USA)';

  @override
  String get lang_en_GB => 'Englisch (UK)';

  @override
  String get lang_zh_CN => 'Chinesisch (Vereinfacht)';

  @override
  String get lang_ja_JP => 'Japanisch';

  @override
  String get lang_ko_KR => 'Koreanisch';

  @override
  String get lang_es_ES => 'Spanisch (Spanien)';

  @override
  String get lang_es_MX => 'Spanisch (Mexiko)';

  @override
  String get lang_fr_FR => 'Französisch';

  @override
  String get lang_de_DE => 'Deutsch';

  @override
  String chat_messagesDeleted(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Nachrichten gelöscht',
      one: '1 Nachricht gelöscht',
    );
    return '$_temp0';
  }

  @override
  String get home_sceneDeleted => 'Szenario gelöscht';

  @override
  String study_example(String text) {
    return 'Beispiel: $text';
  }

  @override
  String get home_savedToFavorites => 'In Favoriten gespeichert';

  @override
  String get home_clearConversation => 'Konversation löschen';

  @override
  String get home_clearConversationContent =>
      'Sind Sie sicher, dass Sie diese Konversation löschen und neu beginnen möchten?';

  @override
  String get home_conversationCleared => 'Konversation gelöscht';

  @override
  String get home_clear => 'Löschen';

  @override
  String get home_noMessagesToBookmark => 'Keine Nachrichten zum Merken';

  @override
  String get feedback_greatStatus => 'Tolle Intonation! Du klingst natürlich.';

  @override
  String get feedback_greatTipQuestion =>
      'Deine Frage-Intonation ist genau richtig! Weiter so.';

  @override
  String get feedback_greatTipDefault =>
      'Dein Ton passt perfekt zum Muttersprachler.';

  @override
  String get feedback_goodStatus =>
      'Guter Anfang. Versuch mehr Emotionen auszudrücken.';

  @override
  String get feedback_goodTipQuestion =>
      '💡 Tipp: Hebe die Stimme am Ende der Frage mehr an.';

  @override
  String get feedback_goodTipExclamation =>
      '💡 Tipp: Füge mehr Energie hinzu und betone Schlüsselwörter.';

  @override
  String get feedback_goodTipDefault =>
      '💡 Tipp: Variiere deinen Ton, um weniger monoton zu klingen.';

  @override
  String get feedback_flatStatus => 'Zu flach. Imitiere das Auf und Ab.';

  @override
  String get feedback_flatTipQuestion =>
      '💡 Tipp: Fragen sollten am Ende ansteigen ↗️. Übe mit übertriebener Tonhöhe.';

  @override
  String get feedback_flatTipExclamation =>
      '💡 Tipp: Zeige Begeisterung! Betone wichtige Wörter mit höherer Tonlage.';

  @override
  String get feedback_flatTipDefault =>
      '💡 Tipp: Deine Stimme klingt robotisch. Kopiere Rhythmus und Melodie des Muttersprachlers.';

  @override
  String get common_retry => 'Wiederholen';

  @override
  String get common_azureAi => 'Azure AI';

  @override
  String get scenes_configureSession => 'Konfigurieren Sie Ihre Übungssitzung';

  @override
  String get study_pitchContour => 'Tonhöhenverlauf';

  @override
  String get study_tapCurve => 'Kurve antippen';

  @override
  String get study_pronunciation => 'Aussprache';

  @override
  String get study_tapWords => 'Wörter antippen';

  @override
  String get chat_deleteMessagesConfirm =>
      'Möchten Sie die ausgewählten Nachrichten wirklich löschen? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get chat_textModeIcon => 'Text';

  @override
  String get feedback_grammarCorrect =>
      'Grammatik ist korrekt! Toller Ausdruck!';

  @override
  String get feedback_pronunciationLabel => 'Aussprache:';

  @override
  String get feedback_sentenceLabel => 'Satz:';

  @override
  String get feedback_intonationLabel => '🌊 Intonation:';

  @override
  String get onboarding_tellUsAboutYourself => 'Erzählen Sie uns von sich';

  @override
  String get onboarding_nativeLanguageQuestion => 'Was ist Ihre Muttersprache?';

  @override
  String get onboarding_learningLanguageQuestion => 'Was möchten Sie lernen?';

  @override
  String get deleteAccount => 'Account löschen';

  @override
  String get deleteAccountConfirmationTitle => 'Account löschen?';

  @override
  String get deleteAccountConfirmationContent =>
      'Diese Aktion ist dauerhaft und kann nicht rückgängig gemacht werden. Alle Ihre Daten werden gelöscht.';

  @override
  String get deleteAccountSubscriptionWarning =>
      'Das Löschen Ihres Accounts kündigt NICHT Ihr Abonnement. Bitte verwalten Sie Abonnements in Ihren Geräteeinstellungen.';

  @override
  String get deleteAccountTypeConfirm => 'Geben Sie DELETE zur Bestätigung ein';

  @override
  String get deleteAccountTypeHint => 'DELETE';

  @override
  String get deleteAction => 'Löschen';

  @override
  String get cancelAction => 'Abbrechen';

  @override
  String get deleteAccountLoading => 'Account wird gelöscht...';

  @override
  String get deleteAccountFailed => 'Löschen fehlgeschlagen';

  @override
  String get profile_dangerZone => 'Gefahrenzone';
}
