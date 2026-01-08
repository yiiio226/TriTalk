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
2. Correct any grammatical and spelling errors.
3. Remove filler words (e.g., 'uh', 'um', 'well', 'you know', 'like').
4. Polish the phrasing for better flow while strictly preserving the original meaning.

Return ONLY a JSON object in this exact format:
{ "optimized_text": "the polished transcription here" }`;
}
