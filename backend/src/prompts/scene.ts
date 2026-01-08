/**
 * Scene-related prompts
 */

/**
 * Build the scene generation prompt for scene/generate endpoint.
 */
export function buildSceneGeneratePrompt(
  description: string,
  tone: string | undefined
): string {
  return `Act as a creative educational scenario designer.
    User Request: "${description}"
    Tone: ${tone || "Casual"}
    
    Create a roleplay scenario for learning English.
    Output JSON ONLY with these fields:
    - title: Short, catchy title (e.g. "Coffee Shop Chat")
    - ai_role: Who you (AI) will play (e.g. "Barista")
    - user_role: Who the user will play (e.g. "Customer")
    - goal: The user's objective (e.g. "Order a latte with oat milk")
    - description: A brief context setting (e.g. "You are at a busy cafe in London...")
    - initial_message: The first thing the AI says to start the conversation.
    - emoji: A single relevant emoji char.`;
}

/**
 * Build the scene polish prompt for scene/polish endpoint.
 */
export function buildScenePolishPrompt(description: string): string {
  return `Refine and expand the following scenario description for an English roleplay practice session. 
    User Input: "${description}"
    
    Make it more specific and suitable for setting up a roleplay context in a few sentences. 
    It should describe the situation clearly so the AI knows how to roleplay.
    Output JSON ONLY: { "polished_text": "..." }`;
}
