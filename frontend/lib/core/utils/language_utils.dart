class LanguageUtils {
  /// Checks if the language typically uses space delimiters to separate words.
  /// Returns false for languages like Chinese (zh), Japanese (ja), Thai (th).
  static bool isSpaceDelimited(String languageCode) {
    if (languageCode.isEmpty) return true;
    final lang = languageCode.toLowerCase();
    // Languages that don't use spaces between words
    return !['zh', 'ja', 'th'].any((code) => lang.startsWith(code));
  }

  /// Regex pattern matching "word characters" in most space-delimited languages.
  /// Includes:
  /// - Basic Latin (a-z, A-Z, 0-9)
  /// - Common punctuation inside words (apostrophe, hyphen)
  /// - Latin-1 Supplement (for accented chars like é, ñ, ü)
  /// - Latin Extended Additional (for more complex diacritics)
  static final RegExp _wordCharPattern = RegExp(
    r"[a-zA-Z0-9'\-\u00C0-\u024F\u1E00-\u1EFF]",
  );

  /// Extracts trailing punctuation from a token, considering the language.
  ///
  /// For space-delimited languages, this strips away the semantic "word" parts
  /// to reveal any attached punctuation (e.g., "Hello," -> ",").
  ///
  /// For non-space-delimited languages (like Chinese), this returns an empty string
  /// to avoid incorrectly identifying parts of the text as punctuation.
  static String extractPunctuation(String token, String languageCode) {
    if (!isSpaceDelimited(languageCode)) {
      return '';
    }

    // Replace all "word characters" with empty string, leaving only punctuation
    return token.replaceAll(_wordCharPattern, '');
  }
}
