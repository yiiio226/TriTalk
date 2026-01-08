/**
 * JSON parsing utilities for LLM responses
 */

/**
 * Parse JSON from LLM response (handles markdown wrapping)
 * LLMs often wrap JSON in markdown code blocks, this function handles that.
 * Also handles cases where LLM returns an array with a single object.
 * Throws an error if the array contains multiple objects.
 */
export function parseJSON(content: string): any {
  let cleaned = content.trim();
  if (cleaned.startsWith("```json")) {
    cleaned = cleaned.slice(7);
  } else if (cleaned.startsWith("```")) {
    cleaned = cleaned.slice(3);
  }
  if (cleaned.endsWith("```")) {
    cleaned = cleaned.slice(0, -3);
  }

  const parsed = JSON.parse(cleaned.trim());

  // Handle case where LLM returns an array with a single object
  if (Array.isArray(parsed)) {
    if (parsed.length > 1) {
      throw new Error(
        "LLM returned multiple items in array, expected single object: " +
          JSON.stringify(parsed)
      );
    }
    if (parsed.length > 0) {
      return parsed[0];
    }
  }

  return parsed;
}
