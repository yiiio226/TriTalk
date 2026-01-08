/**
 * Text processing utilities
 */

/**
 * Sanitize text by removing invalid UTF-16 characters and control characters.
 * This prevents issues with rendering and storage.
 */
export function sanitizeText(text: string): string {
  if (!text) return "";
  return text
    .replace(
      /[\uD800-\uDBFF](?![\uDC00-\uDFFF])|(?<![\uD800-\uDBFF])[\uDC00-\uDFFF]/g,
      ""
    )
    .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, "");
}
