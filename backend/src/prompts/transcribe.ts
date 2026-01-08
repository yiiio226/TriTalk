/**
 * Transcription-related prompts
 */

/**
 * Build the transcription prompt for chat/transcribe endpoint.
 */
export function buildTranscribePrompt(): string {
  return `You are a professional transcription and editing assistant.

Listen to the audio and perform these tasks:
1. Transcribe the speech accurately in the language spoken.
2. Remove filler words (e.g., 'uh', 'um', 'well', 'you know', 'like'), but do NOT correct grammatical errors yet.

Return ONLY a JSON object with two distinct versions:
{
  "raw_text": "The transcription with filler words (um, uh, er) REMOVED, but STRICTLY PRESERVING all grammatical errors, wrong word choices, and sentence structure issues. Do NOT correct the user's English here.",
  "optimized_text": "The fully corrected, grammatically checked, and polished version of what the user intended to say."
}`;
}
