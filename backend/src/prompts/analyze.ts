/**
 * Analyze-related prompts
 */

/**
 * Build the analyze prompt for chat/analyze endpoint.
 */
export function buildAnalyzePrompt(
  message: string,
  nativeLang: string
): string {
  return `Act as a language tutor. Analyze this sentence: "${message}"
    
    Provide a detailed breakdown in ${nativeLang}.
    
    CRITICAL OUTPUT FORMAT RULES:
    1. Output ONLY raw JSON objects, one per line (NDJSON format)
    2. DO NOT use markdown code blocks (no \`\`\`json or \`\`\`)
    3. DO NOT add any explanatory text before or after the JSON
    4. Each line must be a complete, valid JSON object
    5. Do NOT wrap the entire output in an array or object
    
    IMPORTANT: For all examples in grammar points and vocabulary items, you MUST include a ${nativeLang} translation in parentheses immediately after the example sentence.
    Format: "English example sentence (${nativeLang}翻译)"
    Example: "What made you change your mind? (是什么让你改变主意了?)"
    
    CRITICAL: For grammar points, ALWAYS provide a "structure" field that summarizes the grammar pattern (e.g., "If + 主语 + 动词", "around/in about + 时间"). Never leave the structure field empty.
    
    CRITICAL: For vocabulary items, ALWAYS include a "part_of_speech" field using standard abbreviations:
    - n. (noun/名词)
    - v. (verb/动词)
    - adj. (adjective/形容词)
    - adv. (adverb/副词)
    - prep. (preposition/介词)
    - conj. (conjunction/连词)
    - pron. (pronoun/代词)
    - interj. (interjection/感叹词)
    
    IMPORTANT: For the Overall Summary, provide VALUABLE insights that help learners understand:
    - When and where this expression is commonly used (formal/informal contexts, specific situations)
    - Cultural or pragmatic nuances (tone, politeness level, emotional undertones)
    - Key learning points or common mistakes to avoid
    - How native speakers typically use this pattern
    DO NOT just describe the sentence type or structure - focus on practical usage insights.
    
    Order of output (one JSON object per line):
    1. Overall Summary
    2. Sentence Structure
    3. Grammar Points
    4. Vocabulary
    5. Idioms & Slang (if applicable)
    6. Pragmatic Analysis (if applicable)
    7. Emotion Tags (if applicable)

    EXACT FORMAT (copy this structure, replace content only):
    {"type":"summary","data":"这是一段充满情感且具有反思意义的口语表达,通常出现在跨年夜等重大时刻。它结合了即时感官体验(描述美景)和深度对话引导(回顾过去的一年),语气亲切且富有启发性。"}
    {"type":"structure","data":{"structure":"这是一个疑问句...","breakdown":[{"text":"Ah, okay!","tag":"感叹词"},{"text":"What","tag":"疑问代词"}]}}
    {"type":"grammar","data":[{"structure":"What + 动词 + 主语","explanation":"这是典型的'What'疑问句的结构...","example":"What made you change your mind? (是什么让你改变主意了?)"}]}
    {"type":"vocabulary","data":[{"word":"brings","definition":"带来;引起","example":"What brings you here? (什么风把你吹来了?)","level":"A2","part_of_speech":"v."}]}
    {"type":"idioms","data":[{"text":"What brings you here","explanation":"这是一个常用的口语习惯用语,用于询问某人来访的原因,比直接问'Why are you here?'更友好和礼貌","type":"Common Phrase"}]}
    {"type":"pragmatic","data":"说话者使用这个句式表达好奇和友好..."}
    {"type":"emotion","data":["友好","好奇"]}
    
    Remember: Output ONLY the JSON lines above, nothing else. No markdown, no explanations, no code blocks.`;
}
