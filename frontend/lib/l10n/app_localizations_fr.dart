// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'TriTalk';

  @override
  String get home_greeting => 'Salut ! Prêt à pratiquer ?';

  @override
  String get home_dailyGoal => 'Objectif Quotidien';

  @override
  String get home_recentScenarios => 'Scénarios Récents';

  @override
  String get home_exploreScenarios => 'Explorer Scénarios';

  @override
  String get home_startChat => 'Commencer Chat';

  @override
  String get home_cancel => 'Annuler';

  @override
  String get chat_typeAMessage => 'Tapez un message...';

  @override
  String get chat_pressToSpeak => 'Appuyez pour parler';

  @override
  String get chat_releaseToSend => 'Relâchez pour envoyer';

  @override
  String get chat_optimizeWithAi => 'Optimiser avec IA';

  @override
  String get chat_retry => 'Réessayer';

  @override
  String get chat_delete => 'Supprimer';

  @override
  String get profile_languageSettings => 'Paramètres de Langue';

  @override
  String get profile_appLanguage => 'Langue de l\'App';

  @override
  String get profile_nativeLanguage => 'Langue Maternelle';

  @override
  String get profile_learningLanguage => 'Langue d\'Apprentissage';

  @override
  String get profile_upgradeToPro => 'Passer à Pro';

  @override
  String get profile_logOut => 'Déconnexion';

  @override
  String get profile_vocabularySentencesChatHistory =>
      'Vocabulaire, Phrases, Historique';

  @override
  String get common_loading => 'Chargement...';

  @override
  String get common_error => 'Erreur';

  @override
  String get common_success => 'Succès';

  @override
  String get common_save => 'Enregistrer';

  @override
  String get common_confirm => 'Confirmer';

  @override
  String subscription_currentTier(Object tier) {
    return 'Plan Actuel : $tier';
  }

  @override
  String get subscription_restore => 'Restaurer les achats';

  @override
  String get subscription_unlockPotential => 'Libérez tout le potentiel';

  @override
  String get subscription_description =>
      'Obtenez des conversations illimitées, une analyse grammaticale avancée et accès à tous les scénarios premium.';

  @override
  String get subscription_recommended => 'POPULAIRE';

  @override
  String get subscription_monthlyPlan => 'Mensuel';

  @override
  String get subscription_yearlyPlan => 'Annuel';

  @override
  String get subscription_purchaseSuccess => 'Abonnement activé ! Bienvenue !';

  @override
  String get subscription_purchaseFailed =>
      'Échec de l\'achat. Veuillez réessayer.';

  @override
  String get subscription_noPurchasesToRestore =>
      'Aucun achat précédent trouvé.';

  @override
  String get subscription_restoreFailed =>
      'Échec de la restauration. Veuillez réessayer.';

  @override
  String get subscription_noProductsAvailable => 'Aucun produit disponible.';

  @override
  String get subscription_featureUnlimitedMessages => 'Messages illimités';

  @override
  String get subscription_featureAdvancedFeedback =>
      'Feedback grammatical avancé';

  @override
  String get subscription_featureAllPlusFeatures =>
      'Toutes les fonctions Plus incluses';

  @override
  String get subscription_featurePremiumScenarios => 'Scénarios Premium';

  @override
  String get subscription_featurePrioritySupport => 'Support prioritaire';

  @override
  String get chat_listen => 'Écouter';

  @override
  String get chat_stop => 'Arrêter';

  @override
  String get chat_perfect => 'Parfait';

  @override
  String get chat_feedback => 'Feedback';

  @override
  String get chat_analyzing => 'Analyse...';

  @override
  String get chat_analyze => 'Analyser';

  @override
  String get chat_hide_text => 'Masquer le texte';

  @override
  String get chat_text => 'Texte';

  @override
  String get chat_voiceToTextLabel => 'Texte';

  @override
  String get chat_shadow => 'Shadowing';

  @override
  String get chat_translate => 'Traduire';

  @override
  String get chat_save => 'Enregistrer';

  @override
  String get scenes_favorites => 'Favoris';

  @override
  String get scenes_clearConversation => 'Effacer la conversation';

  @override
  String get scenes_bookmarkConversation => 'Marquer la conversation';

  @override
  String get analysis_title => 'Analyse de Phrase';

  @override
  String get analysis_originalSentence => 'PHRASE ORIGINALE';

  @override
  String analysis_savedToVocab(Object word) {
    return 'Enregistré \"$word\" dans Vocabulaire';
  }

  @override
  String get analysis_savedIdiom => 'Idiome enregistré';

  @override
  String get shadowing_title => 'Pratique du Shadowing';

  @override
  String get shadowing_holdToRecord => 'Maintenez pour enregistrer';

  @override
  String get shadowing_recordAgain => 'Enregistrer à nouveau';

  @override
  String get shadowing_complete => 'Terminé';

  @override
  String get shadowing_notRated => 'Non noté';

  @override
  String get shadowing_myScore => 'Mon Score';

  @override
  String get saveNote_title => 'Sauvegarde Rapide';

  @override
  String get saveNote_instruction =>
      'Touchez les mots pour sélectionner du vocabulaire, ou enregistrez toute la phrase.';

  @override
  String get saveNote_saveSentence => 'Enregistrer la Phrase';

  @override
  String saveNote_saveSelected(Object count) {
    return 'Enregistrer la Sélection ($count)';
  }

  @override
  String get chat_suggestions => 'Suggestions';

  @override
  String chat_suggestionsFailed(Object error) {
    return 'Échec du chargement des suggestions : $error';
  }

  @override
  String get chat_deleteConversation => 'Supprimer la conversation';

  @override
  String get chat_deleteConversationContent =>
      'Voulez-vous vraiment supprimer cette conversation ? Cela la supprimera aussi de l\'accueil.';

  @override
  String get home_createScenario => 'Créer un Scénario';

  @override
  String get home_createScenarioDescription =>
      'Décrivez une situation à pratiquer. L\'IA créera un jeu de rôle pour vous.';

  @override
  String get home_createScenarioHint =>
      'Exemple : Je dois retourner un produit défectueux mais le vendeur est difficile...';

  @override
  String get home_generateScenario => 'Générer Scénario';

  @override
  String get profile_selectNative => 'Sélectionner la Langue Maternelle';

  @override
  String get profile_selectLearning =>
      'Sélectionner la Langue d\'Apprentissage';

  @override
  String get profile_tools => 'Outils';

  @override
  String get tab_vocabulary => 'Vocabulaire';

  @override
  String get tab_sentence => 'Phrases';

  @override
  String get tab_grammar => 'Grammaire';

  @override
  String get tab_chat => 'Chat';

  @override
  String get study_noSavedSentences => 'Aucune phrase analysée enregistrée';

  @override
  String get profile_selectAppLanguage => 'Sélectionner la Langue de l\'App';

  @override
  String get profile_systemDefault => 'Défaut Système';

  @override
  String home_chooseScenario(String language) {
    return 'Choisissez un scénario pour pratiquer le $language';
  }

  @override
  String get onboarding_sessionExpiredPleaseLog =>
      'Session expirée. Veuillez vous reconnecter.';

  @override
  String get study_summary => 'Résumé';

  @override
  String get study_sentenceStructure => 'Structure de la Phrase';

  @override
  String get study_grammarPoints => 'Points de Grammaire';

  @override
  String get study_vocabulary => 'Vocabulaire';

  @override
  String get study_idiomsSlang => 'Idiomes et Argot';

  @override
  String get study_analysisNotAvailable => 'Analyse non disponible';

  @override
  String get study_savedToNotebook => 'Enregistré dans le Carnet';

  @override
  String get chat_conversationDeleted => 'Conversation supprimée';

  @override
  String get analysis_savedGrammarPoint => 'Point de Grammaire Enregistré';

  @override
  String get lang_en_US => 'Anglais (États-Unis)';

  @override
  String get lang_en_GB => 'Anglais (Royaume-Uni)';

  @override
  String get lang_zh_CN => 'Chinois (Simplifié)';

  @override
  String get lang_ja_JP => 'Japonais';

  @override
  String get lang_ko_KR => 'Coréen';

  @override
  String get lang_es_ES => 'Espagnol (Espagne)';

  @override
  String get lang_es_MX => 'Espagnol (Mexique)';

  @override
  String get lang_fr_FR => 'Français';

  @override
  String get lang_de_DE => 'Allemand';

  @override
  String chat_messagesDeleted(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages supprimés',
      one: '1 message supprimé',
    );
    return '$_temp0';
  }

  @override
  String get home_sceneDeleted => 'Scénario supprimé';

  @override
  String study_example(String text) {
    return 'Exemple : $text';
  }

  @override
  String get home_savedToFavorites => 'Enregistré dans Favoris';

  @override
  String get home_clearConversation => 'Effacer la conversation';

  @override
  String get home_clearConversationContent =>
      'Voulez-vous effacer cette conversation et recommencer ?';

  @override
  String get home_conversationCleared => 'Conversation effacée';

  @override
  String get home_clear => 'Effacer';

  @override
  String get home_noMessagesToBookmark => 'Aucun message à marquer';

  @override
  String get feedback_greatStatus => 'Super intonation ! Vous sonnez naturel.';

  @override
  String get feedback_greatTipQuestion =>
      'Votre intonation de question est parfaite ! Continuez.';

  @override
  String get feedback_greatTipDefault =>
      'Votre ton correspond parfaitement au locuteur natif.';

  @override
  String get feedback_goodStatus =>
      'Bon début. Essayez d\'exprimer plus d\'émotion.';

  @override
  String get feedback_goodTipQuestion =>
      '💡 Conseil : Montez plus le ton à la fin de la question.';

  @override
  String get feedback_goodTipExclamation =>
      '💡 Conseil : Mettez plus d\'énergie et d\'insistance sur les mots clés.';

  @override
  String get feedback_goodTipDefault =>
      '💡 Conseil : Variez votre ton pour sonner moins monotone.';

  @override
  String get feedback_flatStatus =>
      'Trop plat. Imitez les montées et descentes.';

  @override
  String get feedback_flatTipQuestion =>
      '💡 Conseil : Les questions doivent monter à la fin ↗️. Pratiquez avec un ton exagéré.';

  @override
  String get feedback_flatTipExclamation =>
      '💡 Conseil : Montrez de l\'excitation ! Insistez sur les mots importants.';

  @override
  String get feedback_flatTipDefault =>
      '💡 Conseil : Votre voix sonne robotique. Copiez le rythme et la mélodie du natif.';

  @override
  String get common_retry => 'Réessayer';

  @override
  String get common_azureAi => 'Azure AI';

  @override
  String get scenes_configureSession => 'Configurez votre session';

  @override
  String get study_pitchContour => 'Courbe de Tonalité';

  @override
  String get study_tapCurve => 'Touchez la courbe';

  @override
  String get study_pronunciation => 'Prononciation';

  @override
  String get study_tapWords => 'Touchez les mots';

  @override
  String get chat_deleteMessagesConfirm =>
      'Voulez-vous supprimer les messages sélectionnés ? Impossible d\'annuler.';

  @override
  String get chat_textModeIcon => 'Texte';

  @override
  String get feedback_grammarCorrect =>
      'La grammaire est correcte ! Superbe expression !';

  @override
  String get feedback_pronunciationLabel => 'Prononciation :';

  @override
  String get feedback_sentenceLabel => 'Phrase :';

  @override
  String get feedback_intonationLabel => '🌊 Intonation :';

  @override
  String get onboarding_tellUsAboutYourself => 'Parlez-nous de vous';

  @override
  String get onboarding_nativeLanguageQuestion =>
      'Quelle est votre langue maternelle ?';

  @override
  String get onboarding_learningLanguageQuestion =>
      'Que voulez-vous apprendre ?';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountConfirmationTitle => 'Supprimer le compte ?';

  @override
  String get deleteAccountConfirmationContent =>
      'Cette action est permanente et irréversible. Toutes vos données seront effacées.';

  @override
  String get deleteAccountSubscriptionWarning =>
      'Supprimer votre compte n\'annule PAS votre abonnement. Gérez vos abonnements dans les réglages de votre appareil.';

  @override
  String get deleteAccountTypeConfirm => 'Tapez DELETE pour confirmer';

  @override
  String get deleteAccountTypeHint => 'DELETE';

  @override
  String get deleteAction => 'Supprimer';

  @override
  String get cancelAction => 'Annuler';

  @override
  String get deleteAccountLoading => 'Suppression du compte...';

  @override
  String get deleteAccountFailed => 'Échec de la suppression';

  @override
  String get profile_dangerZone => 'Zone de Danger';
}
