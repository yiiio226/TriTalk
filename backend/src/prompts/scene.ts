/**
 * Scene-related prompts
 */

/**
 * Build the scene generation prompt for scene/generate endpoint.
 */
export function buildSceneGeneratePrompt(
  description: string,
  tone: string | undefined,
  targetLanguage: string = "English"
): string {
  return `Act as a creative educational scenario designer.
    User Request: "${description}"
    Tone: ${tone || "Casual"}
    Target Language: ${targetLanguage}
    
    Create a roleplay scenario for learning ${targetLanguage}.
    IMPORTANT: The initial_message MUST be written entirely in ${targetLanguage}.
    
    Output JSON ONLY with these fields:
    - title: Short, catchy title (in English for UI display)
    - ai_role: Who you (AI) will play (in English for UI display)
    - user_role: Who the user will play (in English for UI display)
    - goal: The user's objective (in English for UI display)
    - description: A brief context setting (in English for UI display)
    - initial_message: The first thing the AI says to start the conversation. MUST BE IN ${targetLanguage}.
    - emoji: A single relevant emoji char.`;
}

/**
 * Build the scene polish prompt for scene/polish endpoint.
 */
export function buildScenePolishPrompt(description: string): string {
  return `Refine and expand the following scenario description for an English roleplay practice session. 
    User Input: "${description}"
    
    Make it more specific and suitable for setting up a roleplay context in a few sentences. 
    IMPORTANT: Write the description from the USER's first-person perspective. Use "I" to refer to the user, and "you" to refer to what the user is doing.
    The description should clearly set up the roleplay situation so the AI knows its role.
    Output JSON ONLY: { "polished_text": "..." }`;
}
