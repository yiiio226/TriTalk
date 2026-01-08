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
    .replace(/[\uD800-\uDFFF]/g, "")
    .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, "");
}
