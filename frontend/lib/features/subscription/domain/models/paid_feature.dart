enum PaidFeature {
  // --- 次数限制类 (Quota Limited) ---
  dailyConversation, // AI 对话 (每日会话/消息数)
  voiceInput, // 语音输入
  speechAssessment, // 句子发音评估
  wordPronunciation, // 单词发音 (Free: 10/day, Plus/Pro: Unlimited)
  grammarAnalysis, // 语法深度分析
  ttsSpeak, // AI 消息朗读
  // --- 访问权限类 (Gatekeepers) ---
  pitchAnalysis, // 音高对比分析 (仅 Plus/Pro)
  customScenarios, // 自定义场景 (Free: 不可创建, Plus: 10个, Pro: 50个)
}
