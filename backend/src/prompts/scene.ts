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
    
    IMPORTANT RULES:
    1. The initial_message MUST be written entirely in ${targetLanguage}.
    2. Do NOT mention the language in the title, ai_role, user_role, goal, or description.
       - BAD examples: "Spanish-speaking waiter", "Practice Spanish ordering", "Learn Spanish at cafe"
       - GOOD examples: "Friendly waiter", "Order your favorite coffee", "Local coffee shop"
    3. The scenario should feel natural, as if set in a country where ${targetLanguage} is spoken natively.
    
    Output JSON ONLY with these fields:
    - title: Short, catchy title (in English, NO language references)
    - ai_role: Who you (AI) will play (in English, NO language references like "Spanish-speaking")
    - user_role: Who the user will play (in English, NO language references)
    - goal: The user's objective (in English, NO language references)
    - description: A brief context setting (in English, NO language references)
    - initial_message: The first thing the AI says to start the conversation. MUST BE IN ${targetLanguage}.
    - emoji: A single relevant emoji char.`;
}

/**
 * Build the scene polish prompt for scene/polish endpoint.
 * The polished text will be in the same language as the user's input.
 */
export function buildScenePolishPrompt(description: string): string {
  return `Refine and expand the following scenario description for a roleplay practice session.
    User Input: "${description}"
    
    Make it more specific and suitable for setting up a roleplay context in a few sentences. 
    IMPORTANT RULES:
    1. Write the description from the USER's first-person perspective. Use "I" to refer to the user, and "you" to refer to what the user is doing.
    2. The description should clearly set up the roleplay situation so the AI knows its role.
    3. **CRITICAL**: The polished text MUST be in the SAME LANGUAGE as the user's input. If the user wrote in Chinese, output in Chinese. If in English, output in English. If in Japanese, output in Japanese. Etc.
    
    Output JSON ONLY: { "polished_text": "..." }`;
}
