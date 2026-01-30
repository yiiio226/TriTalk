// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'TriTalk';

  @override
  String get home_greeting => '¡Hola! ¿Listo para practicar?';

  @override
  String get home_dailyGoal => 'Meta Diaria';

  @override
  String get home_recentScenarios => 'Escenarios Recientes';

  @override
  String get home_exploreScenarios => 'Explorar Escenarios';

  @override
  String get home_startChat => 'Iniciar Chat';

  @override
  String get home_cancel => 'Cancelar';

  @override
  String get chat_typeAMessage => 'Escribe un mensaje...';

  @override
  String get chat_pressToSpeak => 'Presiona para hablar';

  @override
  String get chat_releaseToSend => 'Suelta para enviar';

  @override
  String get chat_optimizeWithAi => 'Optimizar con IA';

  @override
  String get chat_retry => 'Reintentar';

  @override
  String get chat_delete => 'Eliminar';

  @override
  String get profile_languageSettings => 'Configuración de Idioma';

  @override
  String get profile_appLanguage => 'Idioma de la App';

  @override
  String get profile_nativeLanguage => 'Idioma Nativo';

  @override
  String get profile_learningLanguage => 'Idioma de Aprendizaje';

  @override
  String get profile_upgradeToPro => 'Mejorar a Pro';

  @override
  String get profile_logOut => 'Cerrar Sesión';

  @override
  String get profile_vocabularySentencesChatHistory =>
      'Vocabulario, Frases, Historial';

  @override
  String get common_loading => 'Cargando...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Éxito';

  @override
  String get common_save => 'Guardar';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String subscription_currentTier(Object tier) {
    return 'Plan Actual: $tier';
  }

  @override
  String get subscription_restore => 'Restaurar Compras';

  @override
  String get subscription_unlockPotential => 'Desbloquea Todo el Potencial';

  @override
  String get subscription_description =>
      'Obtén conversaciones ilimitadas, análisis gramatical avanzado y acceso a todos los escenarios premium.';

  @override
  String get subscription_recommended => 'POPULAR';

  @override
  String get subscription_monthlyPlan => 'Mensual';

  @override
  String get subscription_yearlyPlan => 'Anual';

  @override
  String get subscription_purchaseSuccess =>
      '¡Suscripción activada! ¡Bienvenido!';

  @override
  String get subscription_purchaseFailed =>
      'La compra falló. Por favor intenta de nuevo.';

  @override
  String get subscription_noPurchasesToRestore =>
      'No se encontraron compras previas.';

  @override
  String get subscription_restoreFailed =>
      'No se pudieron restaurar las compras. Intenta de nuevo.';

  @override
  String get subscription_noProductsAvailable =>
      'No hay productos disponibles.';

  @override
  String get subscription_featureUnlimitedMessages => 'Mensajes ilimitados';

  @override
  String get subscription_featureAdvancedFeedback =>
      'Retroalimentación gramatical avanzada';

  @override
  String get subscription_featureAllPlusFeatures =>
      'Todas las funciones Plus incluidas';

  @override
  String get subscription_featurePremiumScenarios => 'Escenarios Premium';

  @override
  String get subscription_featurePrioritySupport => 'Soporte prioritario';

  @override
  String get chat_listen => 'Escuchar';

  @override
  String get chat_stop => 'Detener';

  @override
  String get chat_perfect => 'Perfecto';

  @override
  String get chat_feedback => 'Retroalimentación';

  @override
  String get chat_analyzing => 'Analizando...';

  @override
  String get chat_analyze => 'Analizar';

  @override
  String get chat_hide_text => 'Ocultar Texto';

  @override
  String get chat_text => 'Texto';

  @override
  String get chat_voiceToTextLabel => 'Texto';

  @override
  String get chat_shadow => 'Shadowing';

  @override
  String get chat_translate => 'Traducir';

  @override
  String get chat_save => 'Guardar';

  @override
  String get scenes_favorites => 'Favoritos';

  @override
  String get scenes_clearConversation => 'Borrar Conversación';

  @override
  String get scenes_bookmarkConversation => 'Marcar Conversación';

  @override
  String get analysis_title => 'Análisis de Frase';

  @override
  String get analysis_originalSentence => 'ORACIÓN ORIGINAL';

  @override
  String analysis_savedToVocab(Object word) {
    return 'Guardado \"$word\" en Vocabulario';
  }

  @override
  String get analysis_savedIdiom => 'Modismo Guardado';

  @override
  String get shadowing_title => 'Práctica de Shadowing';

  @override
  String get shadowing_holdToRecord => 'Mantén para Grabar';

  @override
  String get shadowing_recordAgain => 'Grabar de Nuevo';

  @override
  String get shadowing_complete => 'Completado';

  @override
  String get shadowing_notRated => 'Sin Calificar';

  @override
  String get shadowing_myScore => 'Mi Puntuación';

  @override
  String get saveNote_title => 'Guardado Rápido';

  @override
  String get saveNote_instruction =>
      'Toca palabras para seleccionar vocabulario específico, o guarda la frase completa.';

  @override
  String get saveNote_saveSentence => 'Guardar Frase Completa';

  @override
  String saveNote_saveSelected(Object count) {
    return 'Guardar Seleccionado ($count)';
  }

  @override
  String get chat_suggestions => 'Sugerencias';

  @override
  String chat_suggestionsFailed(Object error) {
    return 'Error al cargar sugerencias: $error';
  }

  @override
  String get chat_deleteConversation => 'Eliminar Conversación';

  @override
  String get chat_deleteConversationContent =>
      '¿Seguro que quieres eliminar esta conversación? Esto también la eliminará de tu inicio.';

  @override
  String get home_createScenario => 'Crear Escenario';

  @override
  String get home_createScenarioDescription =>
      'Describe una situación que quieras practicar. La IA creará un escenario para ti.';

  @override
  String get home_createScenarioHint =>
      'Ejemplo: Necesito devolver un producto defectuoso pero el vendedor es difícil...';

  @override
  String get home_generateScenario => 'Generar Escenario';

  @override
  String get profile_selectNative => 'Seleccionar Idioma Nativo';

  @override
  String get profile_selectLearning => 'Seleccionar Idioma de Aprendizaje';

  @override
  String get profile_tools => 'Herramientas';

  @override
  String get tab_vocabulary => 'Vocabulario';

  @override
  String get tab_sentence => 'Frases';

  @override
  String get tab_grammar => 'Gramática';

  @override
  String get tab_chat => 'Chat';

  @override
  String get study_noSavedSentences => 'Aún no hay frases analizadas guardadas';

  @override
  String get profile_selectAppLanguage => 'Seleccionar Idioma de la App';

  @override
  String get profile_systemDefault => 'Predeterminado del Sistema';

  @override
  String home_chooseScenario(String language) {
    return 'Elige un escenario para practicar $language';
  }

  @override
  String get onboarding_sessionExpiredPleaseLog =>
      'La sesión expiró. Por favor inicia sesión de nuevo.';

  @override
  String get study_summary => 'Resumen';

  @override
  String get study_sentenceStructure => 'Estructura de la Oración';

  @override
  String get study_grammarPoints => 'Puntos Gramaticales';

  @override
  String get study_vocabulary => 'Vocabulario';

  @override
  String get study_idiomsSlang => 'Modismos y Jerga';

  @override
  String get study_analysisNotAvailable => 'Análisis no disponible';

  @override
  String get study_savedToNotebook => 'Guardado en el Cuaderno';

  @override
  String get chat_conversationDeleted => 'Conversación eliminada';

  @override
  String get analysis_savedGrammarPoint => 'Punto Gramatical Guardado';

  @override
  String get lang_en_US => 'Inglés (EE. UU.)';

  @override
  String get lang_en_GB => 'Inglés (Reino Unido)';

  @override
  String get lang_zh_CN => 'Chino (Simplificado)';

  @override
  String get lang_ja_JP => 'Japonés';

  @override
  String get lang_ko_KR => 'Coreano';

  @override
  String get lang_es_ES => 'Español (España)';

  @override
  String get lang_es_MX => 'Español (México)';

  @override
  String get lang_fr_FR => 'Francés';

  @override
  String get lang_de_DE => 'Alemán';

  @override
  String chat_messagesDeleted(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes eliminados',
      one: '1 mensaje eliminado',
    );
    return '$_temp0';
  }

  @override
  String get home_sceneDeleted => 'Escenario eliminado';

  @override
  String study_example(String text) {
    return 'Ejemplo: $text';
  }

  @override
  String get home_savedToFavorites => 'Guardado en Favoritos';

  @override
  String get home_clearConversation => 'Limpiar Conversación';

  @override
  String get home_clearConversationContent =>
      '¿Seguro que quieres limpiar esta conversación y empezar de nuevo?';

  @override
  String get home_conversationCleared => 'Conversación limpiada';

  @override
  String get home_clear => 'Limpiar';

  @override
  String get home_noMessagesToBookmark => 'No hay mensajes para marcar';

  @override
  String get feedback_greatStatus => '¡Gran entonación! Suenas natural.';

  @override
  String get feedback_greatTipQuestion =>
      '¡Tu entonación de pregunta es perfecta! Sigue así.';

  @override
  String get feedback_greatTipDefault =>
      'Tu tono coincide perfectamente con el del hablante nativo.';

  @override
  String get feedback_goodStatus =>
      'Buen comienzo. Intenta expresar más emoción.';

  @override
  String get feedback_goodTipQuestion =>
      '💡 Consejo: Eleva más el tono al final de la pregunta.';

  @override
  String get feedback_goodTipExclamation =>
      '💡 Consejo: ¡Añade más energía y énfasis en las palabras clave!';

  @override
  String get feedback_goodTipDefault =>
      '💡 Consejo: Varía tu tono para sonar menos monótono.';

  @override
  String get feedback_flatStatus =>
      'Demasiado plano. Imita las subidas y bajadas.';

  @override
  String get feedback_flatTipQuestion =>
      '💡 Consejo: Las preguntas deben subir al final ↗️. Practica con un tono exagerado.';

  @override
  String get feedback_flatTipExclamation =>
      '💡 Consejo: ¡Muestra emoción! Enfatiza palabras importantes con un tono más alto.';

  @override
  String get feedback_flatTipDefault =>
      '💡 Consejo: Tu voz suena robótica. Copia el ritmo y la melodía del hablante nativo.';

  @override
  String get common_retry => 'Reintentar';

  @override
  String get common_azureAi => 'Azure AI';

  @override
  String get scenes_configureSession => 'Configura tu sesión de práctica';

  @override
  String get study_pitchContour => 'Contorno de Tono';

  @override
  String get study_tapCurve => 'Toca la curva';

  @override
  String get study_pronunciation => 'Pronunciación';

  @override
  String get study_tapWords => 'Toca las palabras';

  @override
  String get chat_deleteMessagesConfirm =>
      '¿Seguro que quieres eliminar los mensajes seleccionados? No se puede deshacer.';

  @override
  String get chat_textModeIcon => 'Texto';

  @override
  String get feedback_grammarCorrect =>
      '¡La gramática es correcta! ¡Gran expresión!';

  @override
  String get feedback_pronunciationLabel => 'Pronunciación:';

  @override
  String get feedback_sentenceLabel => 'Oración:';

  @override
  String get feedback_intonationLabel => '🌊 Entonación:';

  @override
  String get onboarding_tellUsAboutYourself => 'Cuéntanos sobre ti';

  @override
  String get onboarding_nativeLanguageQuestion => '¿Cuál es tu idioma nativo?';

  @override
  String get onboarding_learningLanguageQuestion => '¿Qué quieres aprender?';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAccountConfirmationTitle => '¿Eliminar Cuenta?';

  @override
  String get deleteAccountConfirmationContent =>
      'Esta acción es permanente y no se puede deshacer. Se borrarán todos tus datos.';

  @override
  String get deleteAccountSubscriptionWarning =>
      'Eliminar tu cuenta NO cancela tu suscripción. Gestiona las suscripciones en la configuración de tu dispositivo.';

  @override
  String get deleteAccountTypeConfirm => 'Escribe DELETE para confirmar';

  @override
  String get deleteAccountTypeHint => 'DELETE';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get deleteAccountLoading => 'Eliminando cuenta...';

  @override
  String get deleteAccountFailed => 'Error al eliminar cuenta';

  @override
  String get profile_dangerZone => 'Zona de Peligro';
}

/// The translations for Spanish Castilian, as used in Mexico (`es_MX`).
class AppLocalizationsEsMx extends AppLocalizationsEs {
  AppLocalizationsEsMx() : super('es_MX');

  @override
  String get appTitle => 'TriTalk';

  @override
  String get home_greeting => '¡Hola! ¿Listo para practicar?';

  @override
  String get home_dailyGoal => 'Meta Diaria';

  @override
  String get home_recentScenarios => 'Escenarios Recientes';

  @override
  String get home_exploreScenarios => 'Explorar Escenarios';

  @override
  String get home_startChat => 'Iniciar Chat';

  @override
  String get home_cancel => 'Cancelar';

  @override
  String get chat_typeAMessage => 'Escribe un mensaje...';

  @override
  String get chat_pressToSpeak => 'Presiona para hablar';

  @override
  String get chat_releaseToSend => 'Suelta para enviar';

  @override
  String get chat_optimizeWithAi => 'Optimizar con IA';

  @override
  String get chat_retry => 'Reintentar';

  @override
  String get chat_delete => 'Eliminar';

  @override
  String get profile_languageSettings => 'Configuración de Idioma';

  @override
  String get profile_appLanguage => 'Idioma de la App';

  @override
  String get profile_nativeLanguage => 'Idioma Nativo';

  @override
  String get profile_learningLanguage => 'Idioma de Aprendizaje';

  @override
  String get profile_upgradeToPro => 'Mejorar a Pro';

  @override
  String get profile_logOut => 'Cerrar Sesión';

  @override
  String get profile_vocabularySentencesChatHistory =>
      'Vocabulario, Frases, Historial';

  @override
  String get common_loading => 'Cargando...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Éxito';

  @override
  String get common_save => 'Guardar';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String subscription_currentTier(Object tier) {
    return 'Plan Actual: $tier';
  }

  @override
  String get subscription_restore => 'Restaurar Compras';

  @override
  String get subscription_unlockPotential => 'Desbloquea Todo el Potencial';

  @override
  String get subscription_description =>
      'Obtén conversaciones ilimitadas, análisis gramatical avanzado y acceso a todos los escenarios premium.';

  @override
  String get subscription_recommended => 'POPULAR';

  @override
  String get subscription_monthlyPlan => 'Mensual';

  @override
  String get subscription_yearlyPlan => 'Anual';

  @override
  String get subscription_purchaseSuccess =>
      '¡Suscripción activada! ¡Bienvenido!';

  @override
  String get subscription_purchaseFailed =>
      'La compra falló. Por favor intenta de nuevo.';

  @override
  String get subscription_noPurchasesToRestore =>
      'No se encontraron compras previas.';

  @override
  String get subscription_restoreFailed =>
      'No se pudieron restaurar las compras. Intenta de nuevo.';

  @override
  String get subscription_noProductsAvailable =>
      'No hay productos disponibles.';

  @override
  String get subscription_featureUnlimitedMessages => 'Mensajes ilimitados';

  @override
  String get subscription_featureAdvancedFeedback =>
      'Retroalimentación gramatical avanzada';

  @override
  String get subscription_featureAllPlusFeatures =>
      'Todas las funciones Plus incluidas';

  @override
  String get subscription_featurePremiumScenarios => 'Escenarios Premium';

  @override
  String get subscription_featurePrioritySupport => 'Soporte prioritario';

  @override
  String get chat_listen => 'Escuchar';

  @override
  String get chat_stop => 'Detener';

  @override
  String get chat_perfect => 'Perfecto';

  @override
  String get chat_feedback => 'Retroalimentación';

  @override
  String get chat_analyzing => 'Analizando...';

  @override
  String get chat_analyze => 'Analizar';

  @override
  String get chat_hide_text => 'Ocultar Texto';

  @override
  String get chat_text => 'Texto';

  @override
  String get chat_voiceToTextLabel => 'Texto';

  @override
  String get chat_shadow => 'Shadowing';

  @override
  String get chat_translate => 'Traducir';

  @override
  String get chat_save => 'Guardar';

  @override
  String get scenes_favorites => 'Favoritos';

  @override
  String get scenes_clearConversation => 'Borrar Conversación';

  @override
  String get scenes_bookmarkConversation => 'Marcar Conversación';

  @override
  String get analysis_title => 'Análisis de Frase';

  @override
  String get analysis_originalSentence => 'ORACIÓN ORIGINAL';

  @override
  String analysis_savedToVocab(Object word) {
    return 'Guardado \"$word\" en Vocabulario';
  }

  @override
  String get analysis_savedIdiom => 'Modismo Guardado';

  @override
  String get shadowing_title => 'Práctica de Shadowing';

  @override
  String get shadowing_holdToRecord => 'Mantén para Grabar';

  @override
  String get shadowing_recordAgain => 'Grabar de Nuevo';

  @override
  String get shadowing_complete => 'Completado';

  @override
  String get shadowing_notRated => 'Sin Calificar';

  @override
  String get shadowing_myScore => 'Mi Puntuación';

  @override
  String get saveNote_title => 'Guardado Rápido';

  @override
  String get saveNote_instruction =>
      'Toca palabras para seleccionar vocabulario específico, o guarda la frase completa.';

  @override
  String get saveNote_saveSentence => 'Guardar Frase Completa';

  @override
  String saveNote_saveSelected(Object count) {
    return 'Guardar Seleccionado ($count)';
  }

  @override
  String get chat_suggestions => 'Sugerencias';

  @override
  String chat_suggestionsFailed(Object error) {
    return 'Error al cargar sugerencias: $error';
  }

  @override
  String get chat_deleteConversation => 'Eliminar Conversación';

  @override
  String get chat_deleteConversationContent =>
      '¿Seguro que quieres eliminar esta conversación? Esto también la eliminará de tu inicio.';

  @override
  String get home_createScenario => 'Crear Escenario';

  @override
  String get home_createScenarioDescription =>
      'Describe una situación que quieras practicar. La IA creará un escenario para ti.';

  @override
  String get home_createScenarioHint =>
      'Ejemplo: Necesito devolver un producto defectuoso pero el vendedor es difícil...';

  @override
  String get home_generateScenario => 'Generar Escenario';

  @override
  String get profile_selectNative => 'Seleccionar Idioma Nativo';

  @override
  String get profile_selectLearning => 'Seleccionar Idioma de Aprendizaje';

  @override
  String get profile_tools => 'Herramientas';

  @override
  String get tab_vocabulary => 'Vocabulario';

  @override
  String get tab_sentence => 'Frases';

  @override
  String get tab_grammar => 'Gramática';

  @override
  String get tab_chat => 'Chat';

  @override
  String get study_noSavedSentences => 'Aún no hay frases analizadas guardadas';

  @override
  String get profile_selectAppLanguage => 'Seleccionar Idioma de la App';

  @override
  String get profile_systemDefault => 'Predeterminado del Sistema';

  @override
  String home_chooseScenario(String language) {
    return 'Elige un escenario para practicar $language';
  }

  @override
  String get onboarding_sessionExpiredPleaseLog =>
      'La sesión expiró. Por favor inicia sesión de nuevo.';

  @override
  String get study_summary => 'Resumen';

  @override
  String get study_sentenceStructure => 'Estructura de la Oración';

  @override
  String get study_grammarPoints => 'Puntos Gramaticales';

  @override
  String get study_vocabulary => 'Vocabulario';

  @override
  String get study_idiomsSlang => 'Modismos y Jerga';

  @override
  String get study_analysisNotAvailable => 'Análisis no disponible';

  @override
  String get study_savedToNotebook => 'Guardado en el Cuaderno';

  @override
  String get chat_conversationDeleted => 'Conversación eliminada';

  @override
  String get analysis_savedGrammarPoint => 'Punto Gramatical Guardado';

  @override
  String get lang_en_US => 'Inglés (EE. UU.)';

  @override
  String get lang_en_GB => 'Inglés (Reino Unido)';

  @override
  String get lang_zh_CN => 'Chino (Simplificado)';

  @override
  String get lang_ja_JP => 'Japonés';

  @override
  String get lang_ko_KR => 'Coreano';

  @override
  String get lang_es_ES => 'Español (España)';

  @override
  String get lang_es_MX => 'Español (México)';

  @override
  String get lang_fr_FR => 'Francés';

  @override
  String get lang_de_DE => 'Alemán';

  @override
  String chat_messagesDeleted(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes eliminados',
      one: '1 mensaje eliminado',
    );
    return '$_temp0';
  }

  @override
  String get home_sceneDeleted => 'Escenario eliminado';

  @override
  String study_example(String text) {
    return 'Ejemplo: $text';
  }

  @override
  String get home_savedToFavorites => 'Guardado en Favoritos';

  @override
  String get home_clearConversation => 'Limpiar Conversación';

  @override
  String get home_clearConversationContent =>
      '¿Seguro que quieres limpiar esta conversación y empezar de nuevo?';

  @override
  String get home_conversationCleared => 'Conversación limpiada';

  @override
  String get home_clear => 'Limpiar';

  @override
  String get home_noMessagesToBookmark => 'No hay mensajes para marcar';

  @override
  String get feedback_greatStatus => '¡Gran entonación! Suenas natural.';

  @override
  String get feedback_greatTipQuestion =>
      '¡Tu entonación de pregunta es perfecta! Sigue así.';

  @override
  String get feedback_greatTipDefault =>
      'Tu tono coincide perfectamente con el del hablante nativo.';

  @override
  String get feedback_goodStatus =>
      'Buen comienzo. Intenta expresar más emoción.';

  @override
  String get feedback_goodTipQuestion =>
      '💡 Consejo: Eleva más el tono al final de la pregunta.';

  @override
  String get feedback_goodTipExclamation =>
      '💡 Consejo: ¡Añade más energía y énfasis en las palabras clave!';

  @override
  String get feedback_goodTipDefault =>
      '💡 Consejo: Varía tu tono para sonar menos monótono.';

  @override
  String get feedback_flatStatus =>
      'Demasiado plano. Imita las subidas y bajadas.';

  @override
  String get feedback_flatTipQuestion =>
      '💡 Consejo: Las preguntas deben subir al final ↗️. Practica con un tono exagerado.';

  @override
  String get feedback_flatTipExclamation =>
      '💡 Consejo: ¡Muestra emoción! Enfatiza palabras importantes con un tono más alto.';

  @override
  String get feedback_flatTipDefault =>
      '💡 Consejo: Tu voz suena robótica. Copia el ritmo y la melodía del hablante nativo.';

  @override
  String get common_retry => 'Reintentar';

  @override
  String get common_azureAi => 'Azure AI';

  @override
  String get scenes_configureSession => 'Configura tu sesión de práctica';

  @override
  String get study_pitchContour => 'Contorno de Tono';

  @override
  String get study_tapCurve => 'Toca la curva';

  @override
  String get study_pronunciation => 'Pronunciación';

  @override
  String get study_tapWords => 'Toca las palabras';

  @override
  String get chat_deleteMessagesConfirm =>
      '¿Seguro que quieres eliminar los mensajes seleccionados? No se puede deshacer.';

  @override
  String get chat_textModeIcon => 'Texto';

  @override
  String get feedback_grammarCorrect =>
      '¡La gramática es correcta! ¡Gran expresión!';

  @override
  String get feedback_pronunciationLabel => 'Pronunciación:';

  @override
  String get feedback_sentenceLabel => 'Oración:';

  @override
  String get feedback_intonationLabel => '🌊 Entonación:';

  @override
  String get onboarding_tellUsAboutYourself => 'Cuéntanos sobre ti';

  @override
  String get onboarding_nativeLanguageQuestion => '¿Cuál es tu idioma nativo?';

  @override
  String get onboarding_learningLanguageQuestion => '¿Qué quieres aprender?';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAccountConfirmationTitle => '¿Eliminar Cuenta?';

  @override
  String get deleteAccountConfirmationContent =>
      'Esta acción es permanente y no se puede deshacer. Se borrarán todos tus datos.';

  @override
  String get deleteAccountSubscriptionWarning =>
      'Eliminar tu cuenta NO cancela tu suscripción. Gestiona las suscripciones en la configuración de tu dispositivo.';

  @override
  String get deleteAccountTypeConfirm => 'Escribe DELETE para confirmar';

  @override
  String get deleteAccountTypeHint => 'DELETE';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get deleteAccountLoading => 'Eliminando cuenta...';

  @override
  String get deleteAccountFailed => 'Error al eliminar cuenta';

  @override
  String get profile_dangerZone => 'Zona de Peligro';
}
