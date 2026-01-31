// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'TriTalk';

  @override
  String get home_greeting => '안녕하세요! 연습할 준비 되셨나요?';

  @override
  String get home_dailyGoal => '일일 목표';

  @override
  String get home_recentScenarios => '최근 시나리오';

  @override
  String get home_exploreScenarios => '시나리오 탐색';

  @override
  String get home_startChat => '채팅 시작';

  @override
  String get home_cancel => '취소';

  @override
  String get chat_typeAMessage => '메시지를 입력하세요...';

  @override
  String get chat_pressToSpeak => '눌러서 말하기';

  @override
  String get chat_releaseToSend => '놓아서 보내기';

  @override
  String get chat_optimizeWithAi => 'AI로 최적화';

  @override
  String get chat_retry => '재시도';

  @override
  String get chat_delete => '삭제';

  @override
  String get profile_languageSettings => '언어 설정';

  @override
  String get profile_appLanguage => '앱 언어';

  @override
  String get profile_nativeLanguage => '모국어';

  @override
  String get profile_learningLanguage => '학습 언어';

  @override
  String get profile_upgradeToPro => 'Pro로 업그레이드';

  @override
  String get profile_logOut => '로그아웃';

  @override
  String get profile_preferences => 'Preferences';

  @override
  String get profile_notifications => 'Notifications';

  @override
  String get profile_statsChats => 'Chats';

  @override
  String get profile_statsMins => 'Mins';

  @override
  String get profile_vocabularySentencesChatHistory => '단어장, 문장, 채팅 기록';

  @override
  String get common_loading => '로딩 중...';

  @override
  String get common_error => '오류';

  @override
  String get common_success => '성공';

  @override
  String get common_save => '저장';

  @override
  String get common_confirm => '확인';

  @override
  String subscription_currentTier(Object tier) {
    return '현재 요금제: $tier';
  }

  @override
  String get subscription_restore => '구매 복원';

  @override
  String get subscription_unlockPotential => '잠재력을 깨우세요';

  @override
  String get subscription_description =>
      '무제한 대화, 고급 문법 분석, 모든 프리미엄 시나리오 이용권을 받으세요.';

  @override
  String get subscription_recommended => '인기';

  @override
  String get subscription_monthlyPlan => '월간';

  @override
  String get subscription_yearlyPlan => '연간';

  @override
  String get subscription_purchaseSuccess => '구독이 활성화되었습니다! 환영합니다!';

  @override
  String get subscription_purchaseFailed => '구매에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get subscription_noPurchasesToRestore => '이전 구매 내역이 없습니다.';

  @override
  String get subscription_restoreFailed => '복원에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get subscription_noProductsAvailable => '사용 가능한 상품이 없습니다.';

  @override
  String get subscription_featureUnlimitedMessages => '무제한 메시지';

  @override
  String get subscription_featureAdvancedFeedback => '고급 문법 피드백';

  @override
  String get subscription_featureAllPlusFeatures => '모든 Plus 기능 포함';

  @override
  String get subscription_featurePremiumScenarios => '프리미엄 시나리오';

  @override
  String get subscription_featurePrioritySupport => '우선 지원';

  @override
  String get chat_listen => '듣기';

  @override
  String get chat_stop => '정지';

  @override
  String get chat_perfect => '완벽해요';

  @override
  String get chat_feedback => '피드백';

  @override
  String get chat_analyzing => '분석 중...';

  @override
  String get chat_analyze => '분석';

  @override
  String get chat_hide_text => '텍스트 숨기기';

  @override
  String get chat_text => '텍스트';

  @override
  String get chat_voiceToTextLabel => '텍스트';

  @override
  String get chat_shadow => '섀도잉';

  @override
  String get chat_translate => '번역';

  @override
  String get chat_save => '저장';

  @override
  String get scenes_favorites => '즐겨찾기';

  @override
  String get scenes_clearConversation => '대화 지우기';

  @override
  String get scenes_bookmarkConversation => '대화 북마크';

  @override
  String get analysis_title => '문장 분석';

  @override
  String get analysis_originalSentence => '원문';

  @override
  String analysis_savedToVocab(Object word) {
    return '단어장에 \"$word\" 저장됨';
  }

  @override
  String get analysis_savedIdiom => '숙어 저장됨';

  @override
  String get shadowing_title => '섀도잉 연습';

  @override
  String get shadowing_holdToRecord => '길게 눌러 녹음';

  @override
  String get shadowing_recordAgain => '다시 녹음';

  @override
  String get shadowing_complete => '완료';

  @override
  String get shadowing_notRated => '평가 안 됨';

  @override
  String get shadowing_myScore => '내 점수';

  @override
  String get saveNote_title => '빠른 저장';

  @override
  String get saveNote_instruction => '단어를 탭하여 선택하거나 문장 전체를 저장하세요.';

  @override
  String get saveNote_saveSentence => '전체 문장 저장';

  @override
  String saveNote_saveSelected(Object count) {
    return '선택 항목 저장 ($count)';
  }

  @override
  String get chat_suggestions => '제안';

  @override
  String chat_suggestionsFailed(Object error) {
    return '제안을 불러오는 데 실패했습니다: $error';
  }

  @override
  String get chat_deleteConversation => '대화 삭제';

  @override
  String get chat_deleteConversationContent => '이 대화를 삭제하시겠습니까? 홈 화면에서도 삭제됩니다.';

  @override
  String get home_createScenario => '시나리오 만들기';

  @override
  String get home_createScenarioDescription =>
      '연습하고 싶은 상황을 설명하세요. AI가 롤플레잉 시나리오를 만들어 드립니다.';

  @override
  String get home_createScenarioHint => '예: 불량품을 반품해야 하는데 점원이 까다롭게 구는 상황...';

  @override
  String get home_generateScenario => '시나리오 생성';

  @override
  String get profile_selectNative => '모국어 선택';

  @override
  String get profile_selectLearning => '학습 언어 선택';

  @override
  String get profile_tools => '도구';

  @override
  String get tab_vocabulary => '단어장';

  @override
  String get tab_sentence => '문장';

  @override
  String get tab_grammar => '문법';

  @override
  String get tab_chat => '채팅';

  @override
  String get study_noSavedSentences => '저장된 분석 문장이 없습니다';

  @override
  String get profile_selectAppLanguage => '앱 언어 선택';

  @override
  String get profile_systemDefault => '시스템 기본값';

  @override
  String home_chooseScenario(String language) {
    return '$language 연습을 위한 시나리오 선택';
  }

  @override
  String get onboarding_sessionExpiredPleaseLog => '세션이 만료되었습니다. 다시 로그인해 주세요.';

  @override
  String get study_summary => '요약';

  @override
  String get study_sentenceStructure => '문장 구조';

  @override
  String get study_grammarPoints => '문법 포인트';

  @override
  String get study_vocabulary => '어휘';

  @override
  String get study_idiomsSlang => '숙어 및 속어';

  @override
  String get study_analysisNotAvailable => '분석을 이용할 수 없습니다';

  @override
  String get study_savedToNotebook => '노트에 저장됨';

  @override
  String get chat_conversationDeleted => '대화가 삭제되었습니다';

  @override
  String get analysis_savedGrammarPoint => '문법 포인트 저장됨';

  @override
  String get lang_en_US => '영어 (미국)';

  @override
  String get lang_en_GB => '영어 (영국)';

  @override
  String get lang_zh_CN => '중국어 (간체)';

  @override
  String get lang_ja_JP => '일본어';

  @override
  String get lang_ko_KR => '한국어';

  @override
  String get lang_es_ES => '스페인어 (스페인)';

  @override
  String get lang_es_MX => '스페인어 (멕시코)';

  @override
  String get lang_fr_FR => '프랑스어';

  @override
  String get lang_de_DE => '독일어';

  @override
  String chat_messagesDeleted(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '메시지 $count개 삭제됨',
      one: '메시지 1개 삭제됨',
    );
    return '$_temp0';
  }

  @override
  String get home_sceneDeleted => '시나리오 삭제됨';

  @override
  String study_example(String text) {
    return '예: $text';
  }

  @override
  String get home_savedToFavorites => '즐겨찾기에 저장됨';

  @override
  String get home_clearConversation => '대화 지우기';

  @override
  String get home_clearConversationContent => '이 대화를 지우고 처음부터 다시 시작하시겠습니까?';

  @override
  String get home_conversationCleared => '대화가 지워졌습니다';

  @override
  String get home_clear => '지우기';

  @override
  String get home_noMessagesToBookmark => '북마크할 메시지가 없습니다';

  @override
  String get feedback_greatStatus => '훌륭한 억양이에요! 자연스럽게 들립니다.';

  @override
  String get feedback_greatTipQuestion => '질문 억양이 완벽해요! 계속 유지하세요.';

  @override
  String get feedback_greatTipDefault => '원어민과 톤이 완벽하게 일치합니다.';

  @override
  String get feedback_goodStatus => '좋은 시작이에요. 감정을 더 표현해 보세요.';

  @override
  String get feedback_goodTipQuestion => '💡 팁: 질문 끝에서 음을 더 높이세요.';

  @override
  String get feedback_goodTipExclamation => '💡 팁: 더 활기차게, 핵심 단어를 강조하세요.';

  @override
  String get feedback_goodTipDefault => '💡 팁: 단조롭지 않게 톤에 변화를 주세요.';

  @override
  String get feedback_flatStatus => '너무 평탄해요. 높낮이를 따라해 보세요.';

  @override
  String get feedback_flatTipQuestion =>
      '💡 팁: 질문은 끝이 올라가야 합니다 ↗️. 과장된 톤으로 연습해 보세요.';

  @override
  String get feedback_flatTipExclamation =>
      '💡 팁: 감정을 보여주세요! 중요한 단어는 높은 음으로 강조하세요.';

  @override
  String get feedback_flatTipDefault =>
      '💡 팁: 목소리가 로봇 같아요. 원어민의 리듬과 멜로디를 따라해 보세요.';

  @override
  String get common_retry => '재시도';

  @override
  String get common_azureAi => 'Azure AI';

  @override
  String get scenes_configureSession => '연습 세션 설정';

  @override
  String get study_pitchContour => '피치 윤곽선';

  @override
  String get study_tapCurve => '곡선 탭하기';

  @override
  String get study_pronunciation => '발음';

  @override
  String get study_tapWords => '단어 탭하기';

  @override
  String get chat_deleteMessagesConfirm =>
      '선택한 메시지를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get chat_textModeIcon => '텍스트';

  @override
  String get feedback_grammarCorrect => '문법이 정확합니다! 훌륭한 표현이에요!';

  @override
  String get feedback_pronunciationLabel => '발음:';

  @override
  String get feedback_sentenceLabel => '문장:';

  @override
  String get feedback_intonationLabel => '🌊 억양:';

  @override
  String get onboarding_tellUsAboutYourself => '자신에 대해 알려주세요';

  @override
  String get onboarding_nativeLanguageQuestion => '모국어는 무엇인가요?';

  @override
  String get onboarding_learningLanguageQuestion => '무엇을 배우고 싶으신가요?';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get deleteAccountConfirmationTitle => '계정 삭제?';

  @override
  String get deleteAccountConfirmationContent =>
      '이 작업은 영구적이며 되돌릴 수 없습니다. 모든 데이터가 삭제됩니다.';

  @override
  String get deleteAccountSubscriptionWarning =>
      '계정을 삭제해도 구독은 취소되지 않습니다. 기기 설정에서 구독을 관리해 주세요.';

  @override
  String get deleteAccountTypeConfirm => '확인을 위해 DELETE를 입력하세요';

  @override
  String get deleteAccountTypeHint => 'DELETE';

  @override
  String get deleteAction => '삭제';

  @override
  String get cancelAction => '취소';

  @override
  String get deleteAccountLoading => '계정 삭제 중...';

  @override
  String get deleteAccountFailed => '계정 삭제 실패';

  @override
  String get profile_dangerZone => '위험 구역';
}
