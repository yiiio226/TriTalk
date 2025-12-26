import {
    ChatRequest,
    ChatResponse,
    HintRequest,
    HintResponse,
    SceneGenerationRequest,
    SceneGenerationResponse,
    AnalyzeRequest,
    AnalyzeResponse,
    ReviewFeedback,
    PolishRequest,
    PolishResponse,
    TranslateRequest,
    TranslateResponse,
    ShadowRequest,
    ShadowResponse,
    Env,
} from './types';

// Helper to create CORS headers
function corsHeaders() {
    return {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
    };
}

// Helper to parse JSON from LLM response (handles markdown wrapping)
function parseJSON(content: string): any {
    let cleaned = content.trim();
    if (cleaned.startsWith('```json')) {
        cleaned = cleaned.slice(7);
    } else if (cleaned.startsWith('```')) {
        cleaned = cleaned.slice(3);
    }
    if (cleaned.endsWith('```')) {
        cleaned = cleaned.slice(0, -3);
    }
    
    const parsed = JSON.parse(cleaned.trim());
    
    // Handle case where LLM returns an array with a single object
    if (Array.isArray(parsed) && parsed.length > 0) {
        return parsed[0];
    }
    
    return parsed;
}

// Call OpenRouter API
async function callOpenRouter(
    apiKey: string,
    model: string,
    messages: Array<{ role: string; content: string }>,
    jsonMode: boolean = true
): Promise<any> {
    const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${apiKey}`,
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://tritalk.app',
            'X-Title': 'TriTalk',
        },
        body: JSON.stringify({
            model,
            messages,
            ...(jsonMode && { response_format: { type: 'json_object' } }),
        }),
    });

    if (!response.ok) {
        const errorText = await response.text();
        console.error('OpenRouter API Response:', errorText);
        throw new Error(`OpenRouter API error: ${response.status} ${response.statusText} - ${errorText}`);
    }

    const data = await response.json() as any;
    return data.choices[0].message.content;
}

// Handle /chat/send endpoint
async function handleChatSend(request: Request, env: Env): Promise<Response> {
    try {
        const body: ChatRequest = await request.json();
        const nativeLang = body.native_language || 'Chinese (Simplified)';
        const targetLang = body.target_language || 'English';

        const systemPrompt = `You are roleplaying in a language learning scenario. Key Scenario Context: ${body.scene_context}.
    
    CRITICAL RULES:
    1. STAY IN CHARACTER at all times. Never break the fourth wall or mention that this is practice/learning.
    2. Respond naturally as your character would in this real-world situation.
    3. Keep responses conversational and realistic for the scenario.
    4. Your goal is to help the user practice ${targetLang}.
    
    Analyze the user's message for grammar, naturalness, and appropriateness.
    
    IMPORTANT: Both "native_expression" and "example_answer" should show how the USER (learner) could better express THEIR OWN message. These are NOT your (AI character's) responses.
    
    Example (assuming Native=${nativeLang}, Target=${targetLang}):
    - User says: "I want coffee"
    - native_expression: "I'd like a coffee, please" (more polite way for USER to say it in ${targetLang})
    - example_answer: "Could I get a coffee?" (alternative way for USER to say it in ${targetLang})
    - reply: "Sure! What size would you like?" (this is YOUR response as the AI character)
    
    You MUST return your response in valid JSON format:
    {
        "reply": "Your in-character conversational reply (stay in role, never mention practice/learning)",
        "analysis": {
            "is_perfect": boolean,
            "corrected_text": "Grammatically correct version of what the USER said (in ${targetLang})",
            "native_expression": "More natural/idiomatic way for the USER to express their message in ${targetLang} (NOT your AI response, MUST be in ${targetLang} only)",
            "explanation": "Explanation in ${nativeLang}. If perfect, compliment in ${nativeLang}. DO NOT include Pinyin.",
            "example_answer": "Alternative way for the USER to express the same idea in ${targetLang} (NOT your AI response, MUST be in ${targetLang} only)"
        }
    }`;

        const messages = [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: body.message },
        ];

        const content = await callOpenRouter(env.OPENROUTER_API_KEY, env.OPENROUTER_MODEL, messages);
        const data = parseJSON(content);

        const replyText = data.reply || '';
        const analysisData = data.analysis || {};

        const feedback: ReviewFeedback = {
            is_perfect: analysisData.is_perfect || false,
            corrected_text: analysisData.corrected_text || body.message,
            native_expression: analysisData.native_expression || '',
            explanation: analysisData.explanation || '',
            example_answer: analysisData.example_answer || '',
        };

        const response: ChatResponse = {
            message: replyText,
            review_feedback: feedback,
        };

        return new Response(JSON.stringify(response), {
            headers: { 'Content-Type': 'application/json', ...corsHeaders() },
        });
    } catch (error) {
        console.error('Error in /chat/send:', error);
        return new Response(
            JSON.stringify({
                message: "Sorry, I'm having trouble connecting to the AI right now.",
                debug_error: String(error)
            }),
            { status: 500, headers: { 'Content-Type': 'application/json', ...corsHeaders() } }
        );
    }
}

// Handle /chat/hint endpoint
async function handleChatHint(request: Request, env: Env): Promise<Response> {
    try {
        const body: HintRequest = await request.json();
        const targetLang = body.target_language || 'English';

        const hintPrompt = `You are a helpful conversation tutor teaching ${targetLang}.
    Key Scenario Context: ${body.scene_context}.
    
    Based on the conversation history, suggest 3 natural, diverse, and appropriate short responses for the user (learner) to say next in ${targetLang}.
    
    Guidelines:
    1. Keep them short (1 sentence).
    2. Vary the intent (e.g., one agreement, one question, one alternative).
    3. Output JSON format only: { "hints": ["Hint 1", "Hint 2", "Hint 3"] }`;

        const messages = [{ role: 'system', content: hintPrompt }];

        // Add recent history (last 5 messages)
        if (body.history && body.history.length > 0) {
            messages.push(...body.history.slice(-5));
        }

        const content = await callOpenRouter(env.OPENROUTER_API_KEY, env.OPENROUTER_MODEL, messages);
        const data = parseJSON(content);

        let hints = data.hints || [];
        if (hints.length === 0) {
            hints = ['Yes, please.', 'No, thank you.', 'Could you repeat that?'];
        }

        const response: HintResponse = { hints };

        return new Response(JSON.stringify(response), {
            headers: { 'Content-Type': 'application/json', ...corsHeaders() },
        });
    } catch (error) {
        console.error('Error in /chat/hint:', error);
        return new Response(
            JSON.stringify({ hints: ['Could you help me?', "I don't understand.", 'Please continue.'] }),
            { status: 500, headers: { 'Content-Type': 'application/json', ...corsHeaders() } }
        );
    }
}

// Handle /chat/analyze endpoint
// Handle /chat/analyze endpoint
async function handleChatAnalyze(request: Request, env: Env): Promise<Response> {
    try {
        const body: AnalyzeRequest = await request.json();
        const nativeLang = body.native_language || 'Chinese (Simplified)';

        const analyzePrompt = `Act as a language tutor. Analyze this sentence: "${body.message}"
    
    Provide a detailed breakdown in ${nativeLang}:
    1. Grammar points used.
    2. Key vocabulary with definitions.
    3. Sentence structure explanation.
    4. Overall summary of the meaning and nuance.
    5. Pragmatic Analysis: Explain *WHY* it was said this way. Identify the social logic (e.g., "Used subjunctive 'Could' to make a polite suggestion", "Short sentence indicates urgency"). Connect the grammar/words to the speaker's intent.
    6. Emotion/Tone tags (e.g., Polite, Casual, Professional, Sarcastic).
    7. Identify Idioms or Slang if any.
    8. Sentence Breakdown: Split the sentence into key segments (Subject, Verb, Clause, etc.) for visual tagging.

    Output JSON ONLY. All explanations, definitions, and analysis text MUST be in ${nativeLang}. DO NOT include Pinyin in any field, especially in examples.
    {
        "grammar_points": [{"structure": "...", "explanation": "(in ${nativeLang}, NO Pinyin)...", "example": "Sentence in the identified language of the message (Translation in ${nativeLang})"}],
        "vocabulary": [{"word": "...", "definition": "(in ${nativeLang}, NO Pinyin)...", "example": "Sentence in the identified language of the message (Translation in ${nativeLang})", "level": "A1/B2/etc"}],
        "sentence_structure": "(in ${nativeLang})...",
        "sentence_breakdown": [{"text": "segment text", "tag": "Subject/Verb/Clause/etc"}],
        "overall_summary": "(in ${nativeLang})...",
        "pragmatic_analysis": "Explanation of the social intent and why specific phrasing was chosen (in ${nativeLang})...",
        "emotion_tags": ["(in ${nativeLang})..."],
        "idioms_slang": [{"text": "...", "explanation": "(in ${nativeLang})...", "type": "Idiom/Slang"}]
    }`;

        const messages = [{ role: 'user', content: analyzePrompt }];

        const content = await callOpenRouter(env.OPENROUTER_API_KEY, env.OPENROUTER_MODEL, messages);

        let data: any = {};
        try {
            data = parseJSON(content);
        } catch (e) {
            console.error("JSON Parse Error:", e);
            data = { overall_summary: "Error parsing analysis results.", sentence_structure: "Data format error." };
        }

        const response: AnalyzeResponse = {
            grammar_points: data.grammar_points || [],
            vocabulary: data.vocabulary || [],
            sentence_structure: data.sentence_structure || 'No structure analysis available.',
            sentence_breakdown: data.sentence_breakdown || [],
            overall_summary: data.overall_summary || 'No summary available.',
            pragmatic_analysis: data.pragmatic_analysis || '',
            emotion_tags: data.emotion_tags || [],
            idioms_slang: data.idioms_slang || [],
        };

        return new Response(JSON.stringify(response), {
            headers: { 'Content-Type': 'application/json', ...corsHeaders() },
        });
    } catch (error) {
        console.error('Error in /chat/analyze:', error);
        return new Response(
            JSON.stringify({
                grammar_points: [],
                vocabulary: [],
                sentence_structure: 'Analysis unavailable (Server Error)',
                overall_summary: 'Description unavailable.',
                debug_error: String(error)
            }),
            { status: 500, headers: { 'Content-Type': 'application/json', ...corsHeaders() } }
        );
    }
}

// Handle /scene/generate endpoint
async function handleSceneGenerate(request: Request, env: Env): Promise<Response> {
    try {
        const body: SceneGenerationRequest = await request.json();

        const prompt = `Act as a creative educational scenario designer.
    User Request: "${body.description}"
    Tone: ${body.tone || 'Casual'}
    
    Create a roleplay scenario for learning English.
    Output JSON ONLY with these fields:
    - title: Short, catchy title (e.g. "Coffee Shop Chat")
    - ai_role: Who you (AI) will play (e.g. "Barista")
    - user_role: Who the user will play (e.g. "Customer")
    - goal: The user's objective (e.g. "Order a latte with oat milk")
    - description: A brief context setting (e.g. "You are at a busy cafe in London...")
    - initial_message: The first thing the AI says to start the conversation.
    - emoji: A single relevant emoji char.`;

        const messages = [{ role: 'user', content: prompt }];

        const content = await callOpenRouter(env.OPENROUTER_API_KEY, env.OPENROUTER_MODEL, messages);
        let data = parseJSON(content);

        // Handle list response (some models return [{}])
        if (Array.isArray(data) && data.length > 0) {
            data = data[0];
        }

        const response: SceneGenerationResponse = {
            title: data.title || 'Custom Scene',
            ai_role: data.ai_role || 'Assistant',
            user_role: data.user_role || 'Learner',
            goal: data.goal || 'Practice English',
            description: data.description || body.description,
            initial_message: data.initial_message || 'Hello! Ready to practice?',
            emoji: data.emoji || '✨',
        };

        return new Response(JSON.stringify(response), {
            headers: { 'Content-Type': 'application/json', ...corsHeaders() },
        });
    } catch (error) {
        console.error('Error in /scene/generate:', error);
        const body: SceneGenerationRequest = await request.json();
        return new Response(
            JSON.stringify({
                title: 'Custom Scene',
                ai_role: 'Assistant',
                user_role: 'User',
                goal: 'Practice conversation',
                description: body.description,
                initial_message: "Hi! Let's start practicing.",
                emoji: '📝',
            }),
            { status: 500, headers: { 'Content-Type': 'application/json', ...corsHeaders() } }
        );
    }
}



// Handle /scene/polish endpoint
async function handleScenePolish(request: Request, env: Env): Promise<Response> {
    try {
        const body: PolishRequest = await request.json();

        const prompt = `Refine and expand the following scenario description for an English roleplay practice session. 
    User Input: "${body.description}"
    
    Make it more specific and suitable for setting up a roleplay context in a few sentences. 
    It should describe the situation clearly so the AI knows how to roleplay.
    Output JSON ONLY: { "polished_text": "..." }`;

        const messages = [{ role: 'user', content: prompt }];
        const content = await callOpenRouter(env.OPENROUTER_API_KEY, env.OPENROUTER_MODEL, messages);
        const data = parseJSON(content);

        const response: PolishResponse = {
            polished_text: data.polished_text || body.description,
        };

        return new Response(JSON.stringify(response), {
            headers: { 'Content-Type': 'application/json', ...corsHeaders() },
        });
    } catch (error) {
        console.error('Error in /scene/polish:', error);
        return new Response(
            JSON.stringify({
                polished_text: "Could not polish text at this time.",
            }),
            { status: 500, headers: { 'Content-Type': 'application/json', ...corsHeaders() } }
        );
    }
}

// Handle /common/translate endpoint
async function handleTranslate(request: Request, env: Env): Promise<Response> {
    try {
        const body: TranslateRequest = await request.json();

        const prompt = `Translate the following text to ${body.target_language}.
    Text: "${body.text}"
    
    Output JSON ONLY: { "translation": "..." }`;

        const messages = [{ role: 'user', content: prompt }];
        const content = await callOpenRouter(env.OPENROUTER_API_KEY, env.OPENROUTER_MODEL, messages);
        const data = parseJSON(content);

        const response: TranslateResponse = {
            translation: data.translation || body.text,
        };

        return new Response(JSON.stringify(response), {
            headers: { 'Content-Type': 'application/json', ...corsHeaders() },
        });
    } catch (error) {
        console.error('Error in /common/translate:', error);
        return new Response(
            JSON.stringify({
                translation: "Translation unavailable.",
            }),
            { status: 500, headers: { 'Content-Type': 'application/json', ...corsHeaders() } }
        );
    }
}

// Handle /chat/shadow endpoint (Simulated for MVP)
async function handleShadowAnalysis(request: Request, env: Env): Promise<Response> {
    try {
        const body: ShadowRequest = await request.json();

        // SIMULATION: Compare texts for a rough score
        const target = body.target_text.toLowerCase().replace(/[^\w\s]/g, '');
        const user = body.user_audio_text.toLowerCase().replace(/[^\w\s]/g, '');
        
        // Simple Levenshtein-like ratio or word match (Simplified for speed)
        const targetWords = target.split(/\s+/);
        const userWords = user.split(/\s+/);
        const matchCount = userWords.filter(w => targetWords.includes(w)).length;
        let score = Math.round((matchCount / Math.max(targetWords.length, 1)) * 100);
        
        // Cap and floor
        score = Math.max(0, Math.min(100, score));

        // Generate heuristic feedback
        let feedback = "Good effort!";
        if (score > 90) feedback = "Excellent! Your pronunciation is very clear.";
        else if (score > 70) feedback = "Great job, but watch your intonation on the key words.";
        else if (score > 50) feedback = "You're getting there. Try to mimic the stress on verbs.";
        else feedback = "Keep practicing! Listen closely to the original audio.";

        const response: ShadowResponse = {
            score: score,
            details: {
                intonation_score: Math.max(0, score - 10), // Simulated variety
                pronunciation_score: score,
                feedback: feedback
            }
        };

        return new Response(JSON.stringify(response), {
            headers: { 'Content-Type': 'application/json', ...corsHeaders() },
        });
    } catch (error) {
        console.error('Error in /chat/shadow:', error);
        return new Response(
            JSON.stringify({
                score: 0,
                details: { intonation_score: 0, pronunciation_score: 0, feedback: "Analysis failed." }
            }),
            { status: 500, headers: { 'Content-Type': 'application/json', ...corsHeaders() } }
        );
    }
}

// Main worker handler
export default {
    async fetch(request: Request, env: Env): Promise<Response> {
        const url = new URL(request.url);

        // Handle CORS preflight
        if (request.method === 'OPTIONS') {
            return new Response(null, { headers: corsHeaders() });
        }

        // Route requests
        if (url.pathname === '/' && request.method === 'GET') {
            return new Response(JSON.stringify({ message: 'TriTalk Backend Running on Cloudflare Workers' }), {
                headers: { 'Content-Type': 'application/json', ...corsHeaders() },
            });
        }

        if (url.pathname === '/health' && request.method === 'GET') {
            return new Response(JSON.stringify({ status: 'ok' }), {
                headers: { 'Content-Type': 'application/json', ...corsHeaders() },
            });
        }

        if (url.pathname === '/chat/send' && request.method === 'POST') {
            return handleChatSend(request, env);
        }

        if (url.pathname === '/chat/hint' && request.method === 'POST') {
            return handleChatHint(request, env);
        }

        if (url.pathname === '/chat/analyze' && request.method === 'POST') {
            return handleChatAnalyze(request, env);
        }

        if (url.pathname === '/scene/generate' && request.method === 'POST') {
            return handleSceneGenerate(request, env);
        }

        if (url.pathname === '/scene/polish' && request.method === 'POST') {
            return handleScenePolish(request, env);
        }

        if (url.pathname === '/common/translate' && request.method === 'POST') {
            return handleTranslate(request, env);
        }

        if (url.pathname === '/chat/shadow' && request.method === 'POST') {
            return handleShadowAnalysis(request, env);
        }

        // 404 for unknown routes
        return new Response(JSON.stringify({ error: 'Not Found' }), {
            status: 404,
            headers: { 'Content-Type': 'application/json', ...corsHeaders() },
        });
    },
};
