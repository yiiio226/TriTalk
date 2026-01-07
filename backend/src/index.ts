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
  OptimizeRequest,
  OptimizeResponse,
  TTSRequest,
  TTSResponse,
  Env,
} from "./types";
import { createClient } from "@supabase/supabase-js";

// Allowed origins for CORS
const ALLOWED_ORIGINS = [
  "http://localhost:8080",
  "http://localhost:3000",
  "http://127.0.0.1:8080",
  "http://127.0.0.1:3000",
  // Add production domain here when deployed
  // 'https://yourdomain.com',
];

// Helper to authenticate user via Supabase
async function authenticateUser(request: Request, env: Env): Promise<any> {
  const authHeader = request.headers.get("Authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return null;
  }

  const token = authHeader.split(" ")[1];

  try {
    // Create a Supabase client with the user's token.
    // This ensures that subsequent DB queries respect RLS (Row Level Security).
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY, {
      global: {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      },
    });

    // 1. Verify Token
    const {
      data: { user },
      error,
    } = await supabase.auth.getUser();

    if (error || !user) {
      console.error("Auth Error:", error);
      return null;
    }

    // 2. Check Subscription/Balance (Optional/Extensible)
    // Since we are now authenticated as the user (via the client headers), we can access RLS-protected data.
    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", user.id)
      .single();

    if (profileError || !profile) {
      console.error("Profile Error:", profileError);
      // If strict mode, return null. For now, we allow if Auth is valid.
      // return null;
    }

    return user;
  } catch (e) {
    console.error("Auth Exception:", e);
    return null;
  }
}

// Helper to create CORS headers
function corsHeaders(origin: string | null) {
  // Check if origin is allowed
  const allowedOrigin =
    origin &&
    (ALLOWED_ORIGINS.includes(origin) ||
      origin.startsWith("http://localhost:") ||
      origin.startsWith("http://127.0.0.1:"));

  return {
    "Access-Control-Allow-Origin": allowedOrigin ? origin : "null",
    "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization, X-API-Key",
  };
}

// Helper to parse JSON from LLM response (handles markdown wrapping)
function parseJSON(content: string): any {
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
  const response = await fetch(
    "https://openrouter.ai/api/v1/chat/completions",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "https://tritalk.app",
        "X-Title": "TriTalk",
      },
      body: JSON.stringify({
        model,
        messages,
        ...(jsonMode && { response_format: { type: "json_object" } }),
      }),
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    console.error("OpenRouter API Response:", errorText);
    throw new Error(
      `OpenRouter API error: ${response.status} ${response.statusText} - ${errorText}`
    );
  }

  const data = (await response.json()) as any;
  return data.choices[0].message.content;
}

// Handle /chat/send endpoint
async function handleChatSend(request: Request, env: Env): Promise<Response> {
  try {
    const body: ChatRequest = await request.json();
    const nativeLang = body.native_language || "Chinese (Simplified)";
    const targetLang = body.target_language || "English";

    const systemPrompt = `You are roleplaying in a language learning scenario.
    
    SCENARIO CONTEXT: ${body.scene_context}
    
    CRITICAL ROLE INSTRUCTIONS:
    1. Carefully read the scenario context above. It describes TWO roles: the AI role (YOUR role) and the user role (the learner's role).
    2. You MUST play the AI role specified in "AI Role:" field. The user will play the "User Role:" field.
    3. NEVER switch roles with the user. The user is practicing their language skills by playing their assigned role.
    4. STAY IN CHARACTER at all times. Never break the fourth wall or mention that this is practice/learning.
    5. Respond naturally as your character would in this real-world situation.
    6. Keep responses conversational and realistic for the scenario.
    7. Your goal is to help the user practice ${targetLang} by maintaining an authentic conversation.
    
    
    === TASK 1: GENERATE YOUR ROLEPLAY REPLY ===
    First, generate your in-character reply to the user's LATEST message.
    - Read the conversation history to understand context
    - Respond naturally as your character would
    - Stay in role, never break character
    - Your reply goes in the "reply" field
    
    === TASK 2: ANALYZE USER'S LATEST MESSAGE (SEPARATE FROM YOUR REPLY) ===
    Second, analyze ONLY the user's LATEST message for grammar and naturalness.
    
    CRITICAL: The user's LATEST message will be marked with <<LATEST_USER_MESSAGE>> tags.
    - Extract ONLY the text between <<LATEST_USER_MESSAGE>> and <</LATEST_USER_MESSAGE>>
    - DO NOT analyze your own (assistant) messages
    - DO NOT analyze previous user messages from history
    - DO NOT combine the user's message with conversation history
    - DO NOT include the marker tags in your analysis
    
    WARNING: The "corrected_text", "native_expression", and "example_answer" fields MUST be in ${targetLang}, NOT in ${nativeLang}. These fields should ONLY show alternative ways for the USER to express THEIR LATEST message.
    
    
    Example (assuming Native=${nativeLang}, Target=${targetLang}):
    Conversation history: 
      Assistant: "Is everything okay?"
      User: "good"  ← THIS is the LATEST message to analyze
    
    CORRECT Analysis:
    - corrected_text: "Good" or "I'm good"
    - native_expression: "I'm doing well"
    - example_answer: "Everything's fine, thanks"
    
    WRONG Analysis (DO NOT DO THIS):
    - corrected_text: "Is everything okay? Good" ❌
    - native_expression: "Is everything okay? I'm doing well" ❌
    
    You MUST return your response in valid JSON format:
    {
        "reply": "Your in-character conversational reply to the user's LATEST message (stay in role)",
        "analysis": {
            "is_perfect": boolean,
            "corrected_text": "Grammatically correct version of ONLY the user's LATEST message (in ${targetLang})",
            "native_expression": "More natural way for the USER to express THEIR LATEST message (MUST be in ${targetLang}, NOT in ${nativeLang})",
            "explanation": "Explanation in ${nativeLang} about the user's LATEST message. DO NOT include Pinyin.",
            "example_answer": "Alternative way for the USER to express THEIR LATEST message (MUST be in ${targetLang}, NOT in ${nativeLang})"
        }
    }`;

    const messages = [{ role: "system", content: systemPrompt }];

    // Add conversation history (limit to last 10 messages to avoid token limits)
    if (body.history && body.history.length > 0) {
      const recentHistory = body.history.slice(-10);
      messages.push(...recentHistory);
    }

    // Add current user message with EXPLICIT marker to help AI identify it
    messages.push({
      role: "user",
      content: `<<LATEST_USER_MESSAGE>>${body.message}<</LATEST_USER_MESSAGE>>`,
    });

    const content = await callOpenRouter(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_MODEL,
      messages
    );
    const data = parseJSON(content);

    // Helper to sanitize text (remove invalid UTF-16 characters)
    const sanitizeText = (text: string): string => {
      if (!text) return "";
      // Remove any invalid UTF-16 surrogate pairs and control characters
      return text
        .replace(/[\uD800-\uDFFF]/g, "")
        .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, "");
    };

    const replyText = sanitizeText(data.reply || "");
    const analysisData = data.analysis || {};

    const feedback: ReviewFeedback = {
      is_perfect: analysisData.is_perfect || false,
      corrected_text: sanitizeText(analysisData.corrected_text || body.message),
      native_expression: sanitizeText(analysisData.native_expression || ""),
      explanation: sanitizeText(analysisData.explanation || ""),
      example_answer: sanitizeText(analysisData.example_answer || ""),
    };

    const response: ChatResponse = {
      message: replyText,
      review_feedback: feedback,
    };

    return new Response(JSON.stringify(response), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders(request.headers.get("Origin")),
      },
    });
  } catch (error) {
    console.error("Error in /chat/send:", error);
    return new Response(
      JSON.stringify({
        message: "Sorry, I'm having trouble connecting to the AI right now.",
        debug_error: String(error),
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      }
    );
  }
}

// Handle /chat/transcribe endpoint
async function handleChatTranscribe(
  request: Request,
  env: Env
): Promise<Response> {
  try {
    const formData = await request.formData();
    const audioFile = formData.get("audio");

    if (!audioFile || typeof audioFile === "string") {
      throw new Error("No audio file uploaded");
    }

    // MOCK TRANSCRIPTION for MVP
    // In production, integrate with OpenAI Whisper or Cloudflare Workers AI
    const transcribedText =
      "This simulates the transcription of your voice message.";

    return new Response(JSON.stringify({ text: transcribedText }), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders(request.headers.get("Origin")),
      },
    });
  } catch (error) {
    console.error("Error in /chat/transcribe:", error);
    return new Response(
      JSON.stringify({ error: "Failed to transcribe audio" }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      }
    );
  }
}

// Handle /chat/send-voice endpoint
async function handleChatSendVoice(
  request: Request,
  env: Env
): Promise<Response> {
  try {
    const formData = await request.formData();
    const audioFile = formData.get("audio");
    const sceneContext = (formData.get("scene_context") as string) || "";
    const historyStr = (formData.get("history") as string) || "[]";
    const nativeLang =
      (formData.get("native_language") as string) || "Chinese (Simplified)";
    const targetLang = (formData.get("target_language") as string) || "English";

    let history = [];
    try {
      history = JSON.parse(historyStr);
    } catch (e) {}

    if (!audioFile || typeof audioFile === "string") {
      throw new Error("No audio file uploaded");
    }

    // 1. MOCK TRANSCRIPTION
    // In production, send audio to STT service
    const transcribedText = "I want to live in a hotel.";

    // 2. Process with LLM (Reusing logic structure from handleChatSend)
    const systemPrompt = `You are roleplaying in a language learning scenario.
    
    SCENARIO CONTEXT: ${sceneContext}
    
    CRITICAL ROLE INSTRUCTIONS:
    1. Carefully read the scenario context above. It describes TWO roles: the AI role (YOUR role) and the user role (the learner's role).
    2. You MUST play the AI role specified in "AI Role:" field. The user will play the "User Role:" field.
    3. NEVER switch roles with the user. The user is practicing their language skills by playing their assigned role.
    4. STAY IN CHARACTER at all times. Never break the fourth wall or mention that this is practice/learning.
    5. Respond naturally as your character would in this real-world situation.
    6. Keep responses conversational and realistic for the scenario.
    7. Your goal is to help the user practice ${targetLang} by maintaining an authentic conversation.
    
    === TASK 1: GENERATE YOUR ROLEPLAY REPLY ===
    First, generate your in-character reply to the user's LATEST message.
    
    === TASK 2: ANALYZE PRONUNCIATION & GRAMMAR ===
    Instead of full text analysis, assume the user SPOKE this message.
    Provide feedback on what a native speaker would say instead.
    
    You MUST return your response in valid JSON format:
    {
        "reply": "Your in-character conversational reply",
        "translation": "Translation of your reply in ${nativeLang}",
        "analysis": {
            "corrected_text": "Grammatically correct version of USER message",
            "native_expression": "More natural spoken expression for USER message",
            "explanation": "Brief explanation",
            "example_answer": "Alternative answer"
        }
    }`;

    const messages = [{ role: "system", content: systemPrompt }];

    if (history && history.length > 0) {
      const recentHistory = history.slice(-10);
      messages.push(...recentHistory);
    }

    messages.push({
      role: "user",
      content: `<<LATEST_USER_MESSAGE>>${transcribedText}<</LATEST_USER_MESSAGE>>`,
    });

    const content = await callOpenRouter(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_MODEL,
      messages
    );
    const data = parseJSON(content);

    // Helper to sanitize text
    const sanitizeText = (text: string): string => {
      if (!text) return "";
      return text
        .replace(/[\uD800-\uDFFF]/g, "")
        .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, "");
    };

    const replyText = sanitizeText(data.reply || "");
    const analysisData = data.analysis || {};

    // 3. MOCK PRONUNCIATION SCORE
    // In production, get this from the STT service or audio analysis model
    const pronunciationScore = Math.floor(Math.random() * 15) + 80; // Random score 80-95

    // Mock sentence breakdown
    const cleanText = sanitizeText(
      analysisData.corrected_text || transcribedText
    ).replace(/[.,!?]/g, "");
    const words = cleanText.split(/\s+/);
    const sentenceBreakdown = words.map((word) => {
      const rand = Math.random();
      let score;
      // Force 'live' to be low score if present (for demo)
      if (word.toLowerCase() === "live") score = 45;
      else if (rand > 0.3)
        score = Math.floor(Math.random() * 20) + 81; // 81-100
      else if (rand > 0.1) score = Math.floor(Math.random() * 20) + 61; // 61-80
      else score = Math.floor(Math.random() * 20) + 40; // 40-59
      return { word, score };
    });

    // Identify error focus
    const lowestScoreWord = sentenceBreakdown.reduce(
      (prev, curr) => (prev.score < curr.score ? prev : curr),
      sentenceBreakdown[0] || { word: "none", score: 100 }
    );

    const errorFocus =
      lowestScoreWord.score < 80
        ? {
            word: lowestScoreWord.word,
            user_ipa: `/liːv/`,
            correct_ipa: `/lɪv/`,
            tip: `/${
              lowestScoreWord.word === "live" ? "ɪ" : "ə"
            }/ is a short vowel, relax your mouth.`,
          }
        : null;

    const voiceFeedback = {
      pronunciation_score: pronunciationScore,
      corrected_text: sanitizeText(
        analysisData.corrected_text || transcribedText
      ),
      native_expression: sanitizeText(analysisData.native_expression || ""),
      feedback: sanitizeText(analysisData.explanation || "Good pronunciation!"),
      sentence_breakdown: sentenceBreakdown,
      error_focus: errorFocus,
    };

    const response = {
      message: replyText,
      translation: data.translation,
      voice_feedback: voiceFeedback,
      // Also include standard review feedback structure if needed by frontend
      review_feedback: {
        is_perfect: false,
        corrected_text: voiceFeedback.corrected_text,
        native_expression: voiceFeedback.native_expression,
        explanation: voiceFeedback.feedback,
        example_answer: sanitizeText(analysisData.example_answer || ""),
      },
    };

    return new Response(JSON.stringify(response), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders(request.headers.get("Origin")),
      },
    });
  } catch (error) {
    console.error("Error in /chat/send-voice:", error);
    return new Response(
      JSON.stringify({
        message: "Sorry, I'm having trouble processing your voice message.",
        debug_error: String(error),
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      }
    );
  }
}

// Handle /chat/hint endpoint
async function handleChatHint(request: Request, env: Env): Promise<Response> {
  try {
    const body: HintRequest = await request.json();
    const targetLang = body.target_language || "English";

    const hintPrompt = `You are a helpful conversation tutor teaching ${targetLang}.
    Key Scenario Context: ${body.scene_context}.
    
    Based on the conversation history, suggest 3 natural, diverse, and appropriate short responses for the user (learner) to say next in ${targetLang}.
    
    Guidelines:
    1. Keep them short (1 sentence).
    2. Vary the intent (e.g., one agreement, one question, one alternative).
    3. Output JSON format only: { "hints": ["Hint 1", "Hint 2", "Hint 3"] }`;

    const messages = [{ role: "system", content: hintPrompt }];

    // Add recent history (last 5 messages)
    if (body.history && body.history.length > 0) {
      messages.push(...body.history.slice(-5));
    }

    const content = await callOpenRouter(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_MODEL,
      messages
    );
    const data = parseJSON(content);

    let hints = data.hints || [];
    if (hints.length === 0) {
      hints = ["Yes, please.", "No, thank you.", "Could you repeat that?"];
    }

    const response: HintResponse = { hints };

    return new Response(JSON.stringify(response), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders(request.headers.get("Origin")),
      },
    });
  } catch (error) {
    console.error("Error in /chat/hint:", error);
    return new Response(
      JSON.stringify({
        hints: [
          "Could you help me?",
          "I don't understand.",
          "Please continue.",
        ],
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      }
    );
  }
}

// Handle /chat/analyze endpoint
// Handle /chat/analyze endpoint
async function handleChatAnalyze(
  request: Request,
  env: Env
): Promise<Response> {
  try {
    const body: AnalyzeRequest = await request.json();
    const nativeLang = body.native_language || "Chinese (Simplified)";

    const analyzePrompt = `Act as a language tutor. Analyze this sentence: "${body.message}"
    
    Provide a detailed breakdown in ${nativeLang}.
    
    CRITICAL OUTPUT FORMAT RULES:
    1. Output ONLY raw JSON objects, one per line (NDJSON format)
    2. DO NOT use markdown code blocks (no \`\`\`json or \`\`\`)
    3. DO NOT add any explanatory text before or after the JSON
    4. Each line must be a complete, valid JSON object
    5. Do NOT wrap the entire output in an array or object
    
    IMPORTANT: For all examples in grammar points and vocabulary items, you MUST include a ${nativeLang} translation in parentheses immediately after the example sentence.
    Format: "English example sentence (${nativeLang}翻译)"
    Example: "What made you change your mind? (是什么让你改变主意了?)"
    
    CRITICAL: For grammar points, ALWAYS provide a "structure" field that summarizes the grammar pattern (e.g., "If + 主语 + 动词", "around/in about + 时间"). Never leave the structure field empty.
    
    CRITICAL: For vocabulary items, ALWAYS include a "part_of_speech" field using standard abbreviations:
    - n. (noun/名词)
    - v. (verb/动词)
    - adj. (adjective/形容词)
    - adv. (adverb/副词)
    - prep. (preposition/介词)
    - conj. (conjunction/连词)
    - pron. (pronoun/代词)
    - interj. (interjection/感叹词)
    
    IMPORTANT: For the Overall Summary, provide VALUABLE insights that help learners understand:
    - When and where this expression is commonly used (formal/informal contexts, specific situations)
    - Cultural or pragmatic nuances (tone, politeness level, emotional undertones)
    - Key learning points or common mistakes to avoid
    - How native speakers typically use this pattern
    DO NOT just describe the sentence type or structure - focus on practical usage insights.
    
    Order of output (one JSON object per line):
    1. Overall Summary
    2. Sentence Structure
    3. Grammar Points
    4. Vocabulary
    5. Idioms & Slang (if applicable)
    6. Pragmatic Analysis (if applicable)
    7. Emotion Tags (if applicable)

    EXACT FORMAT (copy this structure, replace content only):
    {"type":"summary","data":"这是一段充满情感且具有反思意义的口语表达,通常出现在跨年夜等重大时刻。它结合了即时感官体验(描述美景)和深度对话引导(回顾过去的一年),语气亲切且富有启发性。"}
    {"type":"structure","data":{"structure":"这是一个疑问句...","breakdown":[{"text":"Ah, okay!","tag":"感叹词"},{"text":"What","tag":"疑问代词"}]}}
    {"type":"grammar","data":[{"structure":"What + 动词 + 主语","explanation":"这是典型的'What'疑问句的结构...","example":"What made you change your mind? (是什么让你改变主意了?)"}]}
    {"type":"vocabulary","data":[{"word":"brings","definition":"带来;引起","example":"What brings you here? (什么风把你吹来了?)","level":"A2","part_of_speech":"v."}]}
    {"type":"idioms","data":[{"text":"What brings you here","explanation":"这是一个常用的口语习惯用语,用于询问某人来访的原因,比直接问'Why are you here?'更友好和礼貌","type":"Common Phrase"}]}
    {"type":"pragmatic","data":"说话者使用这个句式表达好奇和友好..."}
    {"type":"emotion","data":["友好","好奇"]}
    
    Remember: Output ONLY the JSON lines above, nothing else. No markdown, no explanations, no code blocks.`;

    const messages = [{ role: "user", content: analyzePrompt }];

    const response = await fetch(
      "https://openrouter.ai/api/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${env.OPENROUTER_API_KEY}`,
          "Content-Type": "application/json",
          "HTTP-Referer": "https://tritalk.app",
          "X-Title": "TriTalk",
        },
        body: JSON.stringify({
          model: env.OPENROUTER_MODEL,
          messages,
          stream: true, // Enable streaming
        }),
      }
    );

    if (!response.ok) {
      throw new Error(`OpenRouter API error: ${response.status}`);
    }

    // Create a transform stream to parse SSE and emit raw text chunks (NDJSON)
    const { readable, writable } = new TransformStream();
    const writer = writable.getWriter();

    // Process the stream
    const reader = response.body?.getReader();
    const decoder = new TextDecoder();

    let buffer = "";
    let accumulatedContent = ""; // Accumulate content to detect and strip markdown blocks

    (async () => {
      try {
        if (!reader) throw new Error("No response body");

        while (true) {
          const { done, value } = await reader.read();
          if (done) break;

          const chunk = decoder.decode(value, { stream: true });
          buffer += chunk;

          const lines = buffer.split("\n");
          buffer = lines.pop() || ""; // Keep the incomplete line

          for (const line of lines) {
            const trimmed = line.trim();
            if (!trimmed || trimmed === "data: [DONE]") continue;

            if (trimmed.startsWith("data: ")) {
              try {
                const jsonStr = trimmed.slice(6);
                const parsed = JSON.parse(jsonStr);
                const content = parsed.choices?.[0]?.delta?.content || "";
                if (content) {
                  accumulatedContent += content;

                  // Clean up markdown code blocks
                  let cleanContent = content;
                  // Don't write if it's part of a markdown fence
                  if (content.includes("```")) {
                    // Skip writing markdown fences
                    continue;
                  }

                  await writer.write(new TextEncoder().encode(cleanContent));
                }
              } catch (e) {
                // Ignore parse errors for intermediate chunks
              }
            }
          }
        }
        await writer.close();
      } catch (e) {
        console.error("Stream processing error:", e);
        await writer.abort(e);
      }
    })();

    return new Response(readable, {
      headers: {
        "Content-Type": "application/x-ndjson",
        ...corsHeaders(request.headers.get("Origin")),
      },
    });
  } catch (error) {
    console.error("Error in /chat/analyze:", error);
    return new Response(
      JSON.stringify({
        grammar_points: [],
        vocabulary: [],
        sentence_structure: "Analysis unavailable (Server Error)",
        overall_summary: "Description unavailable.",
        debug_error: String(error),
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      }
    );
  }
}

// Handle /scene/generate endpoint
async function handleSceneGenerate(
  request: Request,
  env: Env
): Promise<Response> {
  let body: SceneGenerationRequest | undefined;
  try {
    body = await request.json();
    if (!body) {
      throw new Error("Invalid request body");
    }

    // At this point body is guaranteed to be defined
    const { description, tone } = body;

    const prompt = `Act as a creative educational scenario designer.
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

    const messages = [{ role: "user", content: prompt }];

    const content = await callOpenRouter(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_MODEL,
      messages
    );
    let data = parseJSON(content);

    // Handle list response (some models return [{}])
    if (Array.isArray(data) && data.length > 0) {
      data = data[0];
    }

    const response: SceneGenerationResponse = {
      title: data.title || "Custom Scene",
      ai_role: data.ai_role || "Assistant",
      user_role: data.user_role || "Learner",
      goal: data.goal || "Practice English",
      description: data.description || description,
      initial_message: data.initial_message || "Hello! Ready to practice?",
      emoji: data.emoji || "✨",
    };

    return new Response(JSON.stringify(response), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders(request.headers.get("Origin")),
      },
    });
  } catch (error) {
    console.error("Error in /scene/generate:", error);
    return new Response(
      JSON.stringify({
        title: "Custom Scene",
        ai_role: "Assistant",
        user_role: "User",
        goal: "Practice conversation",
        description: body?.description || "Custom scenario",
        initial_message: "Hi! Let's start practicing.",
        emoji: "📝",
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      }
    );
  }
}

// Handle /scene/polish endpoint
async function handleScenePolish(
  request: Request,
  env: Env
): Promise<Response> {
  try {
    const body: PolishRequest = await request.json();

    const prompt = `Refine and expand the following scenario description for an English roleplay practice session. 
    User Input: "${body.description}"
    
    Make it more specific and suitable for setting up a roleplay context in a few sentences. 
    It should describe the situation clearly so the AI knows how to roleplay.
    Output JSON ONLY: { "polished_text": "..." }`;

    const messages = [{ role: "user", content: prompt }];
    const content = await callOpenRouter(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_MODEL,
      messages
    );
    const data = parseJSON(content);

    const response: PolishResponse = {
      polished_text: data.polished_text || body.description,
    };

    return new Response(JSON.stringify(response), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders(request.headers.get("Origin")),
      },
    });
  } catch (error) {
    console.error("Error in /scene/polish:", error);
    return new Response(
      JSON.stringify({
        polished_text: "Could not polish text at this time.",
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      }
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

    const messages = [{ role: "user", content: prompt }];
    const content = await callOpenRouter(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_MODEL,
      messages
    );
    const data = parseJSON(content);

    const response: TranslateResponse = {
      translation: data.translation || body.text,
    };

    return new Response(JSON.stringify(response), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders(request.headers.get("Origin")),
      },
    });
  } catch (error) {
    console.error("Error in /common/translate:", error);
    return new Response(
      JSON.stringify({
        translation: "Translation unavailable.",
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      }
    );
  }
}

// Handle /chat/shadow endpoint (Simulated for MVP)
async function handleShadowAnalysis(
  request: Request,
  env: Env
): Promise<Response> {
  try {
    const body: ShadowRequest = await request.json();

    // SIMULATION: Compare texts for a rough score
    const target = body.target_text.toLowerCase().replace(/[^\w\s]/g, "");
    const user = body.user_audio_text.toLowerCase().replace(/[^\w\s]/g, "");

    // Simple Levenshtein-like ratio or word match (Simplified for speed)
    const targetWords = target.split(/\s+/);
    const userWords = user.split(/\s+/);
    const matchCount = userWords.filter((w) => targetWords.includes(w)).length;
    let score = Math.round(
      (matchCount / Math.max(targetWords.length, 1)) * 100
    );

    // Cap and floor
    score = Math.max(0, Math.min(100, score));

    // Generate heuristic feedback
    let feedback = "Good effort!";
    if (score > 90) feedback = "Excellent! Your pronunciation is very clear.";
    else if (score > 70)
      feedback = "Great job, but watch your intonation on the key words.";
    else if (score > 50)
      feedback = "You're getting there. Try to mimic the stress on verbs.";
    else feedback = "Keep practicing! Listen closely to the original audio.";

    const response: ShadowResponse = {
      score: score,
      details: {
        intonation_score: Math.max(0, score - 10), // Simulated variety
        pronunciation_score: score,
        feedback: feedback,
      },
    };

    return new Response(JSON.stringify(response), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders(request.headers.get("Origin")),
      },
    });
  } catch (error) {
    console.error("Error in /chat/shadow:", error);
    return new Response(
      JSON.stringify({
        score: 0,
        details: {
          intonation_score: 0,
          pronunciation_score: 0,
          feedback: "Analysis failed.",
        },
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      }
    );
  }
}

// Handle /chat/optimize endpoint
async function handleChatOptimize(
  request: Request,
  env: Env
): Promise<Response> {
  try {
    const body: OptimizeRequest = await request.json();

    const targetLang = body.target_language || "English";

    const prompt = `You are a helpful language tutor.
    Context: The user is in a roleplay scenario described as: "${body.scene_context}".
    Goal: Optimize the user's draft message into natural, correct ${targetLang} suitable for this context.
    Draft: "${body.message}"
    
    Guidelines:
    1. Keep the meaning close to the draft but make it sound like a native speaker.
    2. Maintain the persona/role if apparent from context.
    3. Output JSON ONLY: { "optimized_text": "..." }`;

    const messages = [{ role: "system", content: prompt }];

    // Add recent history for context if available
    if (body.history && body.history.length > 0) {
      messages.push(...body.history.slice(-5));
    }

    const content = await callOpenRouter(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_MODEL,
      messages
    );
    const data = parseJSON(content);

    const response: OptimizeResponse = {
      optimized_text: data.optimized_text || body.message,
    };

    return new Response(JSON.stringify(response), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders(request.headers.get("Origin")),
      },
    });
  } catch (error) {
    console.error("Error in /chat/optimize:", error);
    return new Response(
      JSON.stringify({
        optimized_text: "Optimization unavailable.",
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      }
    );
  }
}

// Handle /tts/generate endpoint
// Generates speech audio from text using MiniMax T2A V2 API
async function handleTTSGenerate(
  request: Request,
  env: Env
): Promise<Response> {
  try {
    // Check if MiniMax credentials are configured
    if (!env.MINIMAX_API_KEY || !env.MINIMAX_GROUP_ID) {
      return new Response(
        JSON.stringify({
          error:
            "TTS service not configured. Please set MINIMAX_API_KEY and MINIMAX_GROUP_ID.",
        } as TTSResponse),
        {
          status: 503,
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders(request.headers.get("Origin")),
          },
        }
      );
    }

    const body: TTSRequest = await request.json();

    if (!body.text || body.text.trim().length === 0) {
      return new Response(
        JSON.stringify({
          error: "Text is required for TTS generation.",
        } as TTSResponse),
        {
          status: 400,
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders(request.headers.get("Origin")),
          },
        }
      );
    }

    // Limit text length to avoid excessive API costs
    const text = body.text.slice(0, 2000);

    // MiniMax T2A V2 API endpoint
    const apiUrl = `https://api.minimax.chat/v1/t2a_v2?GroupId=${env.MINIMAX_GROUP_ID}`;

    // Default voice settings - using a natural English voice
    const voiceId = body.voice_id || "male-qn-qingse"; // Default voice

    const ttsRequestBody = {
      model: "speech-01-turbo", // Fast, low-latency model
      text: text,
      stream: false,
      voice_setting: {
        voice_id: voiceId,
        speed: 1.0,
        vol: 1.0,
        pitch: 0,
      },
      audio_setting: {
        sample_rate: 32000,
        bitrate: 128000,
        format: "mp3",
        channel: 1,
      },
    };

    const ttsResponse = await fetch(apiUrl, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${env.MINIMAX_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(ttsRequestBody),
    });

    if (!ttsResponse.ok) {
      const errorText = await ttsResponse.text();
      console.error("MiniMax TTS API Error:", errorText);
      return new Response(
        JSON.stringify({
          error: `TTS generation failed: ${ttsResponse.status}`,
        } as TTSResponse),
        {
          status: 502,
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders(request.headers.get("Origin")),
          },
        }
      );
    }

    const ttsData = (await ttsResponse.json()) as any;

    // Check for API-level errors
    if (ttsData.base_resp?.status_code !== 0) {
      console.error("MiniMax TTS API returned error:", ttsData.base_resp);
      return new Response(
        JSON.stringify({
          error: ttsData.base_resp?.status_msg || "TTS generation failed",
        } as TTSResponse),
        {
          status: 502,
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders(request.headers.get("Origin")),
          },
        }
      );
    }

    // Extract audio data (hex-encoded) and convert to base64
    const audioHex = ttsData.data?.audio;
    if (!audioHex) {
      return new Response(
        JSON.stringify({
          error: "No audio data received from TTS API",
        } as TTSResponse),
        {
          status: 502,
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders(request.headers.get("Origin")),
          },
        }
      );
    }

    // Convert hex to base64
    const hexToBase64 = (hexString: string): string => {
      const bytes = new Uint8Array(
        hexString.match(/.{1,2}/g)!.map((byte) => parseInt(byte, 16))
      );
      let binary = "";
      bytes.forEach((byte) => (binary += String.fromCharCode(byte)));
      return btoa(binary);
    };

    const audioBase64 = hexToBase64(audioHex);

    const response: TTSResponse = {
      audio_base64: audioBase64,
      duration_ms: ttsData.extra_info?.audio_length,
    };

    return new Response(JSON.stringify(response), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders(request.headers.get("Origin")),
      },
    });
  } catch (error) {
    console.error("Error in /tts/generate:", error);
    return new Response(
      JSON.stringify({
        error: "TTS generation failed.",
      } as TTSResponse),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      }
    );
  }
}

// Handle /chat/messages DELETE endpoint
async function handleDeleteMessages(
  request: Request,
  env: Env
): Promise<Response> {
  try {
    const body: any = await request.json();
    const sceneKey = body.scene_key;
    const messageIds: string[] = body.message_ids || [];

    if (!sceneKey || !messageIds || messageIds.length === 0) {
      return new Response(
        JSON.stringify({ error: "Missing scene_key or message_ids" }),
        {
          status: 400,
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders(request.headers.get("Origin")),
          },
        }
      );
    }

    // Get authenticated user
    const authHeader = request.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      });
    }

    const token = authHeader.split(" ")[1];
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY, {
      global: {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      },
    });

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      });
    }

    // Fetch current messages for this scene
    const { data: chatHistory, error: fetchError } = await supabase
      .from("chat_history")
      .select("messages")
      .eq("user_id", user.id)
      .eq("scene_key", sceneKey)
      .maybeSingle();

    if (fetchError) {
      console.error("Error fetching chat history:", fetchError);
      return new Response(
        JSON.stringify({ error: "Failed to fetch chat history" }),
        {
          status: 500,
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders(request.headers.get("Origin")),
          },
        }
      );
    }

    if (!chatHistory || !chatHistory.messages) {
      // No messages to delete
      return new Response(JSON.stringify({ success: true, deleted_count: 0 }), {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      });
    }

    // Filter out messages with IDs in the messageIds array
    const currentMessages = chatHistory.messages as any[];
    const filteredMessages = currentMessages.filter(
      (msg) => !messageIds.includes(msg.id)
    );
    const deletedCount = currentMessages.length - filteredMessages.length;

    // Update the chat_history record with filtered messages
    const { error: updateError } = await supabase
      .from("chat_history")
      .update({
        messages: filteredMessages,
        updated_at: new Date().toISOString(),
      })
      .eq("user_id", user.id)
      .eq("scene_key", sceneKey);

    if (updateError) {
      console.error("Error updating chat history:", updateError);
      return new Response(
        JSON.stringify({ error: "Failed to delete messages" }),
        {
          status: 500,
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders(request.headers.get("Origin")),
          },
        }
      );
    }

    return new Response(
      JSON.stringify({ success: true, deleted_count: deletedCount }),
      {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      }
    );
  } catch (error) {
    console.error("Error in /chat/messages DELETE:", error);
    return new Response(
      JSON.stringify({ error: "Failed to delete messages" }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      }
    );
  }
}

// Handle /user/sync endpoint
async function handleUserSync(request: Request, env: Env): Promise<Response> {
  try {
    const body: any = await request.json();

    // In a real application, you would valid the user data and store it in a database (D1, KV, Supabase, etc)
    // For now, we just log it (in production logs) and return success.
    console.log("Received user sync:", body.id, body.email);

    return new Response(
      JSON.stringify({
        status: "success",
        synced_at: new Date().toISOString(),
      }),
      {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      }
    );
  } catch (error) {
    console.error("Error in /user/sync:", error);
    return new Response(JSON.stringify({ error: "Failed to sync user data" }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders(request.headers.get("Origin")),
      },
    });
  }
}

// Main worker handler
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const origin = request.headers.get("Origin");

    // Handle CORS preflight
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders(origin) });
    }

    // Validate User Authentication (Option C - Most Thorough)
    if (url.pathname !== "/health" && url.pathname !== "/user/sync") {
      const user = await authenticateUser(request, env);
      if (!user) {
        return new Response(
          JSON.stringify({
            error: "Unauthorized: Invalid User Token or Subscription",
          }),
          {
            status: 401,
            headers: {
              "Content-Type": "application/json",
              ...corsHeaders(origin),
            },
          }
        );
      }
      // Request is authenticated, proceed
    }

    // Route requests
    if (url.pathname === "/" && request.method === "GET") {
      return new Response(
        JSON.stringify({
          message: "TriTalk Backend Running on Cloudflare Workers",
        }),
        {
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders(request.headers.get("Origin")),
          },
        }
      );
    }

    if (url.pathname === "/health" && request.method === "GET") {
      return new Response(JSON.stringify({ status: "ok" }), {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders(request.headers.get("Origin")),
        },
      });
    }

    if (url.pathname === "/chat/send" && request.method === "POST") {
      return handleChatSend(request, env);
    }

    if (url.pathname === "/chat/transcribe" && request.method === "POST") {
      return handleChatTranscribe(request, env);
    }

    if (url.pathname === "/chat/send-voice" && request.method === "POST") {
      return handleChatSendVoice(request, env);
    }

    if (url.pathname === "/user/sync" && request.method === "POST") {
      return handleUserSync(request, env);
    }

    if (url.pathname === "/chat/hint" && request.method === "POST") {
      return handleChatHint(request, env);
    }

    if (url.pathname === "/chat/analyze" && request.method === "POST") {
      return handleChatAnalyze(request, env);
    }

    if (url.pathname === "/scene/generate" && request.method === "POST") {
      return handleSceneGenerate(request, env);
    }

    if (url.pathname === "/scene/polish" && request.method === "POST") {
      return handleScenePolish(request, env);
    }

    if (url.pathname === "/common/translate" && request.method === "POST") {
      return handleTranslate(request, env);
    }

    if (url.pathname === "/chat/shadow" && request.method === "POST") {
      return handleShadowAnalysis(request, env);
    }

    if (url.pathname === "/chat/optimize" && request.method === "POST") {
      return handleChatOptimize(request, env);
    }

    if (url.pathname === "/chat/messages" && request.method === "DELETE") {
      return handleDeleteMessages(request, env);
    }

    if (url.pathname === "/tts/generate" && request.method === "POST") {
      return handleTTSGenerate(request, env);
    }

    // 404 for unknown routes
    return new Response(JSON.stringify({ error: "Not Found" }), {
      status: 404,
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders(request.headers.get("Origin")),
      },
    });
  },
};
