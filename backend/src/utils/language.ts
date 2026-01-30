export const LANGUAGE_CODE_MAP: Record<string, string> = {
  // Chinese
  "zh-CN": "Chinese (Simplified)",
  "zh-TW": "Chinese (Traditional)",
  "zh-HK": "Chinese (Cantonese)",
  zh: "Chinese",

  // English
  "en-US": "English",
  "en-GB": "English (UK)",
  "en-AU": "English (Australia)",
  en: "English",

  // Japanese
  "ja-JP": "Japanese",
  ja: "Japanese",

  // Korean
  "ko-KR": "Korean",
  ko: "Korean",

  // European Languages
  "es-ES": "Spanish (Spain)",
  "es-MX": "Spanish (Latin America)",
  es: "Spanish",
  "fr-FR": "French",
  "fr-CA": "French (Canada)",
  fr: "French",
  "de-DE": "German",
  de: "German",
  "it-IT": "Italian",
  it: "Italian",
  "pt-BR": "Portuguese (Brazil)",
  "pt-PT": "Portuguese (Portugal)",
  pt: "Portuguese",
  "ru-RU": "Russian",
  ru: "Russian",
  "nl-NL": "Dutch",
  nl: "Dutch",
  "pl-PL": "Polish",
  pl: "Polish",

  // Others (Common learners)
  "tr-TR": "Turkish",
  tr: "Turkish",
  "vi-VN": "Vietnamese",
  vi: "Vietnamese",
  "th-TH": "Thai",
  th: "Thai",
  "hi-IN": "Hindi",
  hi: "Hindi",
  "id-ID": "Indonesian",
  id: "Indonesian",
  "ar-SA": "Arabic",
  ar: "Arabic",
};

/**
 * Converts an ISO language code (e.g., zh-CN, en-US) to its full English name.
 * Falls back to the input string if no match is found (handling legacy full names).
 *
 * @param code ISO language code or language name
 * @param defaultLang Default language name if code is empty/null
 * @returns Full English language name (e.g., "Chinese (Simplified)")
 */
export function getLanguageNameFromCode(
  code: string | null | undefined,
): string {
  if (!code) {
    // If we want to strictly require the code, throw.
    // However, if the field is optional in some contexts, caller should handle it?
    // User said: "If not found we should throw error".
    throw new Error("Language code is missing");
  }

  // clean code (trim)
  const cleanCode = code.trim();

  // Direct match
  if (LANGUAGE_CODE_MAP[cleanCode]) {
    return LANGUAGE_CODE_MAP[cleanCode];
  }

  // Try matching just the language part (e.g., "en" from "en-US" if not found)
  const baseLang = cleanCode.split("-")[0];
  if (LANGUAGE_CODE_MAP[baseLang]) {
    return LANGUAGE_CODE_MAP[baseLang];
  }

  // If no match found, throw error as requested
  throw new Error(`Unsupported language code: ${code}`);
}
