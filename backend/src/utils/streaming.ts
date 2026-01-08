/**
 * Utilities for processing streams
 */

/**
 * Iterate over lines in a readable stream (e.g., from fetch Response).
 * Handles decoding and buffering of chunks.
 */
export async function* iterateStreamLines(
  response: Response
): AsyncGenerator<string> {
  const reader = response.body?.getReader();
  if (!reader) return;

  const decoder = new TextDecoder();
  let buffer = "";

  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split("\n");
      buffer = lines.pop() || "";

      for (const line of lines) {
        const trimmed = line.trim();
        if (trimmed) {
          yield trimmed;
        }
      }
    }
  } finally {
    reader.releaseLock();
  }
}
