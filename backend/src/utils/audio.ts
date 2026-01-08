/**
 * Audio processing utilities
 */

/**
 * Detect audio format from file name.
 * Returns the format string for use with APIs.
 */
export function detectAudioFormat(fileName: string): string {
  const formatMap: Record<string, string> = {
    ".mp3": "mp3",
    ".wav": "wav",
    ".webm": "webm",
    ".ogg": "ogg",
    ".flac": "flac",
    ".aac": "aac",
    ".m4a": "m4a",
  };

  const lowerFileName = fileName.toLowerCase();
  for (const [ext, format] of Object.entries(formatMap)) {
    if (lowerFileName.endsWith(ext)) {
      return format;
    }
  }

  return "wav"; // default
}
