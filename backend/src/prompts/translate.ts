/**
 * Translation-related prompts
 */

/**
 * Build the translation prompt for common/translate endpoint.
 */
export function buildTranslatePrompt(
  text: string,
  targetLanguage: string
): string {
  return `Translate the following text to ${targetLanguage}.
    Text: "${text}"
    
    Output JSON ONLY: { "translation": "..." }`;
}
