// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'TriTalk';

  @override
  String get home_greeting => 'こんにちは！練習の準備はできましたか？';

  @override
  String get home_dailyGoal => '今日の目標';

  @override
  String get home_recentScenarios => '最近のシナリオ';

  @override
  String get home_exploreScenarios => 'シナリオを探す';

  @override
  String get home_startChat => 'チャットを開始';

  @override
  String get home_cancel => 'キャンセル';

  @override
  String get chat_typeAMessage => 'メッセージを入力...';

  @override
  String get chat_pressToSpeak => '押して話す';

  @override
  String get chat_releaseToSend => '離して送信';

  @override
  String get chat_optimizeWithAi => 'AIで最適化';

  @override
  String get chat_retry => '再試行';

  @override
  String get chat_delete => '削除';

  @override
  String get profile_languageSettings => '言語設定';

  @override
  String get profile_appLanguage => 'アプリの言語';

  @override
  String get profile_nativeLanguage => '母国語';

  @override
  String get profile_learningLanguage => '学習する言語';

  @override
  String get profile_upgradeToPro => 'Proにアップグレード';

  @override
  String get profile_logOut => 'ログアウト';

  @override
  String get profile_vocabularySentencesChatHistory => '単語、文、履歴';

  @override
  String get common_loading => '読み込み中...';

  @override
  String get common_error => 'エラー';

  @override
  String get common_success => '成功';

  @override
  String get common_save => '保存';

  @override
  String get common_confirm => '確認';

  @override
  String subscription_currentTier(Object tier) {
    return '現在のプラン: $tier';
  }

  @override
  String get subscription_restore => '購入を復元';

  @override
  String get subscription_unlockPotential => '可能性を最大限に';

  @override
  String get subscription_description =>
      '無制限の会話、高度な文法分析、すべてのプレミアムシナリオへのアクセスを入手しましょう。';

  @override
  String get subscription_recommended => '人気';

  @override
  String get subscription_monthlyPlan => '月額';

  @override
  String get subscription_yearlyPlan => '年額';

  @override
  String get subscription_purchaseSuccess => 'サブスクリプションが有効になりました！ようこそ！';

  @override
  String get subscription_purchaseFailed => '購入に失敗しました。もう一度お試しください。';

  @override
  String get subscription_noPurchasesToRestore => '以前の購入が見つかりませんでした。';

  @override
  String get subscription_restoreFailed => '復元に失敗しました。もう一度お試しください。';

  @override
  String get subscription_noProductsAvailable => '利用可能な商品がありません。';

  @override
  String get subscription_featureUnlimitedMessages => '無制限のメッセージ';

  @override
  String get subscription_featureAdvancedFeedback => '高度な文法フィードバック';

  @override
  String get subscription_featureAllPlusFeatures => 'すべてのPlus機能を含む';

  @override
  String get subscription_featurePremiumScenarios => 'プレミアムシナリオ';

  @override
  String get subscription_featurePrioritySupport => '優先サポート';

  @override
  String get chat_listen => '聞く';

  @override
  String get chat_stop => '停止';

  @override
  String get chat_perfect => '完璧';

  @override
  String get chat_feedback => 'フィードバック';

  @override
  String get chat_analyzing => '分析中...';

  @override
  String get chat_analyze => '分析';

  @override
  String get chat_hide_text => 'テキストを隠す';

  @override
  String get chat_text => 'テキスト';

  @override
  String get chat_voiceToTextLabel => 'テキスト';

  @override
  String get chat_shadow => 'シャドーイング';

  @override
  String get chat_translate => '翻訳';

  @override
  String get chat_save => '保存';

  @override
  String get scenes_favorites => 'お気に入り';

  @override
  String get scenes_clearConversation => '会話をクリア';

  @override
  String get scenes_bookmarkConversation => '会話をブックマーク';

  @override
  String get analysis_title => '文の分析';

  @override
  String get analysis_originalSentence => '元の文';

  @override
  String analysis_savedToVocab(Object word) {
    return '「$word」を単語帳に保存しました';
  }

  @override
  String get analysis_savedIdiom => 'イディオムを保存しました';

  @override
  String get shadowing_title => 'シャドーイング練習';

  @override
  String get shadowing_holdToRecord => '長押しで録音';

  @override
  String get shadowing_recordAgain => '再録音';

  @override
  String get shadowing_complete => '完了';

  @override
  String get shadowing_notRated => '未評価';

  @override
  String get shadowing_myScore => 'マイスコア';

  @override
  String get saveNote_title => 'クイック保存';

  @override
  String get saveNote_instruction => '単語をタップして選択するか、文全体を保存してください。';

  @override
  String get saveNote_saveSentence => '文全体を保存';

  @override
  String saveNote_saveSelected(Object count) {
    return '選択した項目を保存 ($count)';
  }

  @override
  String get chat_suggestions => '提案';

  @override
  String chat_suggestionsFailed(Object error) {
    return '提案の読み込みに失敗しました: $error';
  }

  @override
  String get chat_deleteConversation => '会話を削除';

  @override
  String get chat_deleteConversationContent =>
      'この会話を削除してもよろしいですか？ホーム画面からも削除されます。';

  @override
  String get home_createScenario => 'シナリオを作成';

  @override
  String get home_createScenarioDescription =>
      '練習したい状況を説明してください。AIがロールプレイシナリオを作成します。';

  @override
  String get home_createScenarioHint => '例：不良品を返品したいが、店員の対応が難しい...';

  @override
  String get home_generateScenario => 'シナリオを生成';

  @override
  String get profile_selectNative => '母国語を選択';

  @override
  String get profile_selectLearning => '学習言語を選択';

  @override
  String get profile_tools => 'ツール';

  @override
  String get tab_vocabulary => '単語';

  @override
  String get tab_sentence => '文';

  @override
  String get tab_grammar => '文法';

  @override
  String get tab_chat => 'チャット';

  @override
  String get study_noSavedSentences => '分析された文はまだ保存されていません';

  @override
  String get profile_selectAppLanguage => 'アプリの言語を選択';

  @override
  String get profile_systemDefault => 'システムデフォルト';

  @override
  String home_chooseScenario(String language) {
    return '$languageを練習するシナリオを選択';
  }

  @override
  String get onboarding_sessionExpiredPleaseLog =>
      'セッションの有効期限が切れました。再度ログインしてください。';

  @override
  String get study_summary => '要約';

  @override
  String get study_sentenceStructure => '文構造';

  @override
  String get study_grammarPoints => '文法ポイント';

  @override
  String get study_vocabulary => '単語';

  @override
  String get study_idiomsSlang => 'イディオムとスラング';

  @override
  String get study_analysisNotAvailable => '分析は利用できません';

  @override
  String get study_savedToNotebook => 'ノートに保存しました';

  @override
  String get chat_conversationDeleted => '会話を削除しました';

  @override
  String get analysis_savedGrammarPoint => '文法ポイントを保存しました';

  @override
  String get lang_en_US => '英語 (米国)';

  @override
  String get lang_en_GB => '英語 (英国)';

  @override
  String get lang_zh_CN => '中国語 (簡体字)';

  @override
  String get lang_ja_JP => '日本語';

  @override
  String get lang_ko_KR => '韓国語';

  @override
  String get lang_es_ES => 'スペイン語 (スペイン)';

  @override
  String get lang_es_MX => 'スペイン語 (メキシコ)';

  @override
  String get lang_fr_FR => 'フランス語';

  @override
  String get lang_de_DE => 'ドイツ語';

  @override
  String chat_messagesDeleted(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のメッセージを削除しました',
      one: '1件のメッセージを削除しました',
    );
    return '$_temp0';
  }

  @override
  String get home_sceneDeleted => 'シナリオを削除しました';

  @override
  String study_example(String text) {
    return '例: $text';
  }

  @override
  String get home_savedToFavorites => 'お気に入りに保存しました';

  @override
  String get home_clearConversation => '会話をクリア';

  @override
  String get home_clearConversationContent => 'この会話をクリアして最初からやり直してもよろしいですか？';

  @override
  String get home_conversationCleared => '会話をクリアしました';

  @override
  String get home_clear => 'クリア';

  @override
  String get home_noMessagesToBookmark => 'ブックマークするメッセージがありません';

  @override
  String get feedback_greatStatus => '素晴らしいイントネーションです！自然に聞こえます。';

  @override
  String get feedback_greatTipQuestion => '質問のイントネーションは完璧です！その調子で。';

  @override
  String get feedback_greatTipDefault => 'トーンがネイティブスピーカーと完全に一致しています。';

  @override
  String get feedback_goodStatus => '良いスタートです。もっと感情を込めてみましょう。';

  @override
  String get feedback_goodTipQuestion => '💡 ヒント: 質問の最後でもっとピッチを上げましょう。';

  @override
  String get feedback_goodTipExclamation =>
      '💡 ヒント: もっとエネルギーを込めて、キーワードを強調しましょう。';

  @override
  String get feedback_goodTipDefault => '💡 ヒント: トーンに変化をつけて、単調にならないようにしましょう。';

  @override
  String get feedback_flatStatus => '平坦すぎます。抑揚を真似してください。';

  @override
  String get feedback_flatTipQuestion =>
      '💡 ヒント: 質問は最後が上がるべきです ↗️。大げさなピッチで練習しましょう。';

  @override
  String get feedback_flatTipExclamation =>
      '💡 ヒント: ドキドキ感を表現しましょう！重要な単語を高いピッチで強調してください。';

  @override
  String get feedback_flatTipDefault =>
      '💡 ヒント: 声がロボットのように聞こえます。ネイティブスピーカーのリズムとメロディーをコピーしましょう。';

  @override
  String get common_retry => '再試行';

  @override
  String get common_azureAi => 'Azure AI';

  @override
  String get scenes_configureSession => '練習セッションを設定';

  @override
  String get study_pitchContour => 'ピッチ曲線';

  @override
  String get study_tapCurve => '曲線をタップ';

  @override
  String get study_pronunciation => '発音';

  @override
  String get study_tapWords => '単語をタップ';

  @override
  String get chat_deleteMessagesConfirm =>
      '選択したメッセージを削除してもよろしいですか？この操作は取り消せません。';

  @override
  String get chat_textModeIcon => 'テキスト';

  @override
  String get feedback_grammarCorrect => '文法は正しいです！素晴らしい表現です！';

  @override
  String get feedback_pronunciationLabel => '発音:';

  @override
  String get feedback_sentenceLabel => '文:';

  @override
  String get feedback_intonationLabel => '🌊 イントネーション:';

  @override
  String get onboarding_tellUsAboutYourself => 'あなたについて教えてください';

  @override
  String get onboarding_nativeLanguageQuestion => 'あなたの母国語は何ですか？';

  @override
  String get onboarding_learningLanguageQuestion => '何を学びたいですか？';

  @override
  String get deleteAccount => 'アカウント削除';

  @override
  String get deleteAccountConfirmationTitle => 'アカウントを削除しますか？';

  @override
  String get deleteAccountConfirmationContent =>
      'この操作は永続的であり、元に戻すことはできません。すべてのデータが削除されます。';

  @override
  String get deleteAccountSubscriptionWarning =>
      'アカウントを削除しても、サブスクリプションはキャンセルされません。端末の設定でサブスクリプションを管理してください。';

  @override
  String get deleteAccountTypeConfirm => '確認のため DELETE と入力してください';

  @override
  String get deleteAccountTypeHint => 'DELETE';

  @override
  String get deleteAction => '削除';

  @override
  String get cancelAction => 'キャンセル';

  @override
  String get deleteAccountLoading => 'アカウント削除中...';

  @override
  String get deleteAccountFailed => 'アカウント削除に失敗しました';

  @override
  String get profile_dangerZone => '危険エリア';
}
