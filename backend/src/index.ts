import { Hono } from "hono";
import { cors } from "hono/cors";
import type { Context } from "hono";
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
  TranscribeResponse,
  Env,
} from "./types";
import { createClient } from "@supabase/supabase-js";

// Initialize Hono app with Env bindings
const app = new Hono<{ Bindings: Env; Variables: { user: any } }>();

// Allowed origins for CORS
const ALLOWED_ORIGINS = [
  "http://localhost:8080",
  "http://localhost:3000",
  "http://127.0.0.1:8080",
  "http://127.0.0.1:3000",
  // Add production domain here when deployed
  // 'https://yourdomain.com',
];

// ============================================
// CORS Middleware (Global)
// ============================================
app.use(
  "/*",
  cors({
    origin: (origin) => {
      // Allow localhost and specific domains
      if (
        ALLOWED_ORIGINS.includes(origin) ||
        origin.startsWith("http://localhost:") ||
        origin.startsWith("http://127.0.0.1:")
      ) {
        return origin;
      }
      return "null";
    },
    allowMethods: ["GET", "POST", "DELETE", "OPTIONS"],
    allowHeaders: ["Content-Type", "Authorization", "X-API-Key"],
    exposeHeaders: ["Content-Length"],
  })
);

// ============================================
// Helper Functions
// ============================================

// Helper to authenticate user via Supabase
async function authenticateUser(c: Context): Promise<any> {
  const authHeader = c.req.header("Authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return null;
  }

  const token = authHeader.split(" ")[1];
  const env = c.env as Env;

  try {
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY, {
      global: {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      },
    });

    const {
      data: { user },
      error,
    } = await supabase.auth.getUser();

    if (error || !user) {
      console.error("Auth Error:", error);
      return null;
    }

    // Optional: Check profile
    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", user.id)
      .single();

    if (profileError || !profile) {
      console.error("Profile Error:", profileError);
      // Allow if Auth is valid even if profile fetch fails
    }

    return user;
  } catch (e) {
    console.error("Auth Exception:", e);
    return null;
  }
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

// Helper to sanitize text (remove invalid UTF-16 characters)
function sanitizeText(text: string): string {
  if (!text) return "";
  return text
    .replace(/[\uD800-\uDFFF]/g, "")
    .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, "");
}

// ============================================
// Authentication Middleware
// ============================================
const authMiddleware = async (c: Context, next: any) => {
  const user = await authenticateUser(c);
  if (!user) {
    return c.json(
      {
        error: "Unauthorized: Invalid User Token or Subscription",
      },
      401
    );
  }
  c.set("user", user);
  await next();
};

// ============================================
// Routes
// ============================================

// GET / - Root
app.get("/", (c) => {
  return c.json({
    message: "TriTalk Backend Running on Cloudflare Workers with Hono",
  });
});

// GET /health - Health check (no auth required)
app.get("/health", (c) => {
  return c.json({ status: "ok" });
});

// POST /chat/send - Main chat logic (requires auth)
app.post("/chat/send", authMiddleware, async (c) => {
  try {
    const body: ChatRequest = await c.req.json();
    const env = c.env as Env;
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
      env.OPENROUTER_CHAT_MODEL,
      messages
    );
    const data = parseJSON(content);

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

    return c.json(response);
  } catch (error) {
    console.error("Error in /chat/send:", error);
    return c.json(
      {
        message: "Sorry, I'm having trouble connecting to the AI right now.",
        debug_error: String(error),
      },
      500
    );
  }
});

// POST /chat/transcribe - Audio transcription (requires auth)
app.post("/chat/transcribe", authMiddleware, async (c) => {
  try {
    const formData = await c.req.formData();
    const env = c.env as Env;
    const audioFile = formData.get("audio");
    const targetLanguage =
      (formData.get("target_language") as string) || "English";

    if (!audioFile || typeof audioFile === "string") {
      throw new Error("No audio file uploaded");
    }

    // Convert audio file to base64 with improved binary handling
    const audioBlob = audioFile as File;
    const arrayBuffer = await audioBlob.arrayBuffer();
    const uint8Array = new Uint8Array(arrayBuffer);

    // Convert to base64 using a chunked approach to handle large files
    const CHUNK_SIZE = 65536; // 64KB chunks
    let binary = "";
    for (let i = 0; i < uint8Array.length; i += CHUNK_SIZE) {
      const chunk = uint8Array.subarray(
        i,
        Math.min(i + CHUNK_SIZE, uint8Array.length)
      );
      binary += String.fromCharCode.apply(null, Array.from(chunk));
    }
    const audioBase64 = btoa(binary);

    // Determine audio format from file extension
    const fileName = audioBlob.name || "audio.wav";
    let audioFormat = "wav"; // default
    if (fileName.endsWith(".mp3")) {
      audioFormat = "mp3";
    } else if (fileName.endsWith(".wav")) {
      audioFormat = "wav";
    } else if (fileName.endsWith(".webm")) {
      audioFormat = "webm";
    } else if (fileName.endsWith(".ogg")) {
      audioFormat = "ogg";
    } else if (fileName.endsWith(".flac")) {
      audioFormat = "flac";
    } else if (fileName.endsWith(".aac")) {
      audioFormat = "aac";
    } else if (fileName.endsWith(".m4a")) {
      audioFormat = "m4a";
    }

    console.log(
      `[Transcribe] File: ${fileName}, Format: ${audioFormat}, Size: ${arrayBuffer.byteLength} bytes`
    );

    // Build the multimodal prompt for Gemini
    const transcribePrompt = `You are a professional transcription and editing assistant.

Listen to the audio and perform these tasks:
1. Transcribe the speech accurately in ${targetLanguage}.
2. Correct any grammatical and spelling errors.
3. Remove filler words (e.g., 'uh', 'um', 'well', 'you know', 'like').
4. Polish the phrasing for better flow while strictly preserving the original meaning.

Return ONLY a JSON object in this exact format:
{ "optimized_text": "the polished transcription here" }`;

    // Call OpenRouter with multimodal content (audio + text)
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
          model: env.OPENROUTER_TRANSCRIBE_MODEL,
          messages: [
            {
              role: "system",
              content: transcribePrompt,
            },
            {
              role: "user",
              content: [
                {
                  type: "text",
                  text: "Please transcribe the attached audio.",
                },
                {
                  type: "input_audio",
                  input_audio: {
                    data: audioBase64,
                    format: audioFormat,
                  },
                },
              ],
            },
          ],
          response_format: { type: "json_object" },
        }),
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      console.error("OpenRouter API error:", errorText);
      throw new Error(
        `OpenRouter API error: ${response.status} - ${errorText}`
      );
    }

    const data = (await response.json()) as any;
    const content = data.choices[0].message.content;
    const parsedData = parseJSON(content);
    const optimizedText = parsedData.optimized_text || "";

    const transcribeResponse: TranscribeResponse = {
      text: optimizedText,
    };

    return c.json(transcribeResponse);
  } catch (error) {
    console.error("Error in /chat/transcribe:", error);
    return c.json(
      {
        error: "Failed to transcribe audio",
        details: String(error),
      },
      500
    );
  }
});

// POST /chat/send-voice - Voice message handling (requires auth)
app.post("/chat/send-voice", authMiddleware, async (c) => {
  try {
    const formData = await c.req.formData();
    const env = c.env as Env;
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

    // MOCK TRANSCRIPTION
    const transcribedText = "I want to live in a hotel.";

    // Process with LLM
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
      env.OPENROUTER_CHAT_MODEL,
      messages
    );
    const data = parseJSON(content);

    const replyText = sanitizeText(data.reply || "");
    const analysisData = data.analysis || {};

    // MOCK PRONUNCIATION SCORE
    const pronunciationScore = Math.floor(Math.random() * 15) + 80;

    // Mock sentence breakdown
    const cleanText = sanitizeText(
      analysisData.corrected_text || transcribedText
    ).replace(/[.,!?]/g, "");
    const words = cleanText.split(/\s+/);
    const sentenceBreakdown = words.map((word) => {
      const rand = Math.random();
      let score;
      if (word.toLowerCase() === "live") score = 45;
      else if (rand > 0.3) score = Math.floor(Math.random() * 20) + 81;
      else if (rand > 0.1) score = Math.floor(Math.random() * 20) + 61;
      else score = Math.floor(Math.random() * 20) + 40;
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
      review_feedback: {
        is_perfect: false,
        corrected_text: voiceFeedback.corrected_text,
        native_expression: voiceFeedback.native_expression,
        explanation: voiceFeedback.feedback,
        example_answer: sanitizeText(analysisData.example_answer || ""),
      },
    };

    return c.json(response);
  } catch (error) {
    console.error("Error in /chat/send-voice:", error);
    return c.json(
      {
        message: "Sorry, I'm having trouble processing your voice message.",
        debug_error: String(error),
      },
      500
    );
  }
});

// POST /chat/hint - Get conversation hints (requires auth)
app.post("/chat/hint", authMiddleware, async (c) => {
  try {
    const body: HintRequest = await c.req.json();
    const env = c.env as Env;
    const targetLang = body.target_language || "English";

    const hintPrompt = `You are a helpful conversation tutor teaching ${targetLang}.
    Key Scenario Context: ${body.scene_context}.
    
    Based on the conversation history, suggest 3 natural, diverse, and appropriate short responses for the user (learner) to say next in ${targetLang}.
    
    Guidelines:
    1. Keep them short (1 sentence).
    2. Vary the intent (e.g., one agreement, one question, one alternative).
    3. Output JSON format only: { "hints": ["Hint 1", "Hint 2", "Hint 3"] }`;

    const messages = [{ role: "system", content: hintPrompt }];

    if (body.history && body.history.length > 0) {
      messages.push(...body.history.slice(-5));
    }

    const content = await callOpenRouter(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_CHAT_MODEL,
      messages
    );
    const data = parseJSON(content);

    let hints = data.hints || [];
    if (hints.length === 0) {
      hints = ["Yes, please.", "No, thank you.", "Could you repeat that?"];
    }

    const response: HintResponse = { hints };
    return c.json(response);
  } catch (error) {
    console.error("Error in /chat/hint:", error);
    return c.json(
      {
        hints: [
          "Could you help me?",
          "I don't understand.",
          "Please continue.",
        ],
      },
      500
    );
  }
});

// POST /chat/analyze - Analyze message (requires auth, streaming)
app.post("/chat/analyze", authMiddleware, async (c) => {
  try {
    const body: AnalyzeRequest = await c.req.json();
    const env = c.env as Env;
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
          model: env.OPENROUTER_CHAT_MODEL,
          messages,
          stream: true,
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
    let accumulatedContent = "";

    (async () => {
      try {
        if (!reader) throw new Error("No response body");

        while (true) {
          const { done, value } = await reader.read();
          if (done) break;

          const chunk = decoder.decode(value, { stream: true });
          buffer += chunk;

          const lines = buffer.split("\n");
          buffer = lines.pop() || "";

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

                  let cleanContent = content;
                  if (content.includes("```")) {
                    continue;
                  }

                  await writer.write(new TextEncoder().encode(cleanContent));
                }
              } catch (e) {
                // Ignore parse errors
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

    // For streaming responses, we need to manually add CORS headers
    // since Hono's CORS middleware doesn't automatically apply to raw Response objects
    const origin = c.req.header("Origin") || "";
    const allowedOrigin =
      ALLOWED_ORIGINS.includes(origin) ||
      origin.startsWith("http://localhost:") ||
      origin.startsWith("http://127.0.0.1:")
        ? origin
        : "null";

    return new Response(readable, {
      headers: {
        "Content-Type": "application/x-ndjson",
        "Access-Control-Allow-Origin": allowedOrigin,
        "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS",
        "Access-Control-Allow-Headers":
          "Content-Type, Authorization, X-API-Key",
      },
    });
  } catch (error) {
    console.error("Error in /chat/analyze:", error);
    return c.json(
      {
        grammar_points: [],
        vocabulary: [],
        sentence_structure: "Analysis unavailable (Server Error)",
        overall_summary: "Description unavailable.",
        debug_error: String(error),
      },
      500
    );
  }
});

// POST /scene/generate - Generate scene (requires auth)
app.post("/scene/generate", authMiddleware, async (c) => {
  let body: SceneGenerationRequest | undefined;
  try {
    body = await c.req.json();
    const env = c.env as Env;
    if (!body) {
      throw new Error("Invalid request body");
    }

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
      env.OPENROUTER_CHAT_MODEL,
      messages
    );
    let data = parseJSON(content);

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

    return c.json(response);
  } catch (error) {
    console.error("Error in /scene/generate:", error);
    return c.json(
      {
        title: "Custom Scene",
        ai_role: "Assistant",
        user_role: "User",
        goal: "Practice conversation",
        description: body?.description || "Custom scenario",
        initial_message: "Hi! Let's start practicing.",
        emoji: "📝",
      },
      500
    );
  }
});

// POST /scene/polish - Polish scene description (requires auth)
app.post("/scene/polish", authMiddleware, async (c) => {
  try {
    const body: PolishRequest = await c.req.json();
    const env = c.env as Env;

    const prompt = `Refine and expand the following scenario description for an English roleplay practice session. 
    User Input: "${body.description}"
    
    Make it more specific and suitable for setting up a roleplay context in a few sentences. 
    It should describe the situation clearly so the AI knows how to roleplay.
    Output JSON ONLY: { "polished_text": "..." }`;

    const messages = [{ role: "user", content: prompt }];
    const content = await callOpenRouter(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_CHAT_MODEL,
      messages
    );
    const data = parseJSON(content);

    const response: PolishResponse = {
      polished_text: data.polished_text || body.description,
    };

    return c.json(response);
  } catch (error) {
    console.error("Error in /scene/polish:", error);
    return c.json(
      {
        polished_text: "Could not polish text at this time.",
      },
      500
    );
  }
});

// POST /common/translate - Translate text (requires auth)
app.post("/common/translate", authMiddleware, async (c) => {
  try {
    const body: TranslateRequest = await c.req.json();
    const env = c.env as Env;

    const prompt = `Translate the following text to ${body.target_language}.
    Text: "${body.text}"
    
    Output JSON ONLY: { "translation": "..." }`;

    const messages = [{ role: "user", content: prompt }];
    const content = await callOpenRouter(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_CHAT_MODEL,
      messages
    );
    const data = parseJSON(content);

    const response: TranslateResponse = {
      translation: data.translation || body.text,
    };

    return c.json(response);
  } catch (error) {
    console.error("Error in /common/translate:", error);
    return c.json(
      {
        translation: "Translation unavailable.",
      },
      500
    );
  }
});

// POST /chat/shadow - Shadow analysis (requires auth)
app.post("/chat/shadow", authMiddleware, async (c) => {
  try {
    const body: ShadowRequest = await c.req.json();

    // SIMULATION: Compare texts for a rough score
    const target = body.target_text.toLowerCase().replace(/[^\w\s]/g, "");
    const user = body.user_audio_text.toLowerCase().replace(/[^\w\s]/g, "");

    const targetWords = target.split(/\s+/);
    const userWords = user.split(/\s+/);
    const matchCount = userWords.filter((w) => targetWords.includes(w)).length;
    let score = Math.round(
      (matchCount / Math.max(targetWords.length, 1)) * 100
    );

    score = Math.max(0, Math.min(100, score));

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
        intonation_score: Math.max(0, score - 10),
        pronunciation_score: score,
        feedback: feedback,
      },
    };

    return c.json(response);
  } catch (error) {
    console.error("Error in /chat/shadow:", error);
    return c.json(
      {
        score: 0,
        details: {
          intonation_score: 0,
          pronunciation_score: 0,
          feedback: "Analysis failed.",
        },
      },
      500
    );
  }
});

// POST /chat/optimize - Optimize message (requires auth)
app.post("/chat/optimize", authMiddleware, async (c) => {
  try {
    const body: OptimizeRequest = await c.req.json();
    const env = c.env as Env;

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

    if (body.history && body.history.length > 0) {
      messages.push(...body.history.slice(-5));
    }

    const content = await callOpenRouter(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_CHAT_MODEL,
      messages
    );
    const data = parseJSON(content);

    const response: OptimizeResponse = {
      optimized_text: data.optimized_text || body.message,
    };

    return c.json(response);
  } catch (error) {
    console.error("Error in /chat/optimize:", error);
    return c.json(
      {
        optimized_text: "Optimization unavailable.",
      },
      500
    );
  }
});

// POST /tts/generate - Generate TTS (requires auth, streaming)
app.post("/tts/generate", authMiddleware, async (c) => {
  try {
    const env = c.env as Env;

    // Check if MiniMax credentials are configured
    if (!env.MINIMAX_API_KEY || !env.MINIMAX_GROUP_ID) {
      return c.json(
        {
          error:
            "TTS service not configured. Please set MINIMAX_API_KEY and MINIMAX_GROUP_ID.",
        } as TTSResponse,
        503
      );
    }

    const body: TTSRequest = await c.req.json();

    if (!body.text || body.text.trim().length === 0) {
      return c.json(
        {
          error: "Text is required for TTS generation.",
        } as TTSResponse,
        400
      );
    }

    const text = body.text.slice(0, 2000);
    const apiUrl = `https://api.minimax.chat/v1/t2a_v2?GroupId=${env.MINIMAX_GROUP_ID}`;
    const voiceId = body.voice_id || "English_Trustworthy_Man";

    const ttsRequestBody = {
      model: "speech-2.6-turbo",
      text: text,
      stream: true,
      stream_options: {
        exclude_aggregated_audio: true,
      },
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
      return c.json(
        {
          error: `TTS generation failed: ${ttsResponse.status}`,
        } as TTSResponse,
        502
      );
    }

    // Helper: Convert hex to base64
    const hexToBase64 = (hexString: string): string => {
      const bytes = new Uint8Array(
        hexString.match(/.{1,2}/g)!.map((byte) => parseInt(byte, 16))
      );
      let binary = "";
      bytes.forEach((byte) => (binary += String.fromCharCode(byte)));
      return btoa(binary);
    };

    // Create a streaming response
    const { readable, writable } = new TransformStream();
    const writer = writable.getWriter();
    const encoder = new TextEncoder();

    (async () => {
      try {
        const reader = ttsResponse.body?.getReader();
        if (!reader) {
          await writer.write(
            encoder.encode(
              JSON.stringify({ type: "error", error: "No response body" }) +
                "\n"
            )
          );
          await writer.close();
          return;
        }

        const decoder = new TextDecoder();
        let buffer = "";
        let chunkIndex = 0;

        while (true) {
          const { done, value } = await reader.read();
          if (done) break;

          buffer += decoder.decode(value, { stream: true });

          const lines = buffer.split("\n");
          buffer = lines.pop() || "";

          for (const line of lines) {
            const trimmedLine = line.trim();
            if (!trimmedLine || !trimmedLine.startsWith("data:")) continue;

            const jsonStr = trimmedLine.slice(5).trim();
            if (!jsonStr || jsonStr === "[DONE]") continue;

            try {
              const chunkData = JSON.parse(jsonStr);

              if (
                chunkData.base_resp &&
                chunkData.base_resp.status_code !== 0
              ) {
                await writer.write(
                  encoder.encode(
                    JSON.stringify({
                      type: "error",
                      error:
                        chunkData.base_resp.status_msg ||
                        "TTS generation failed",
                    }) + "\n"
                  )
                );
                continue;
              }

              const audioHex = chunkData.data?.audio;
              if (audioHex) {
                const audioBase64 = hexToBase64(audioHex);
                const chunkResponse = {
                  type: "audio_chunk",
                  chunk_index: chunkIndex++,
                  audio_base64: audioBase64,
                };
                await writer.write(
                  encoder.encode(JSON.stringify(chunkResponse) + "\n")
                );
              }

              if (chunkData.extra_info?.audio_length) {
                const infoResponse = {
                  type: "info",
                  duration_ms: chunkData.extra_info.audio_length,
                };
                await writer.write(
                  encoder.encode(JSON.stringify(infoResponse) + "\n")
                );
              }
            } catch (e) {
              console.error("Error parsing TTS chunk:", e);
            }
          }
        }

        await writer.write(
          encoder.encode(JSON.stringify({ type: "done" }) + "\n")
        );
        await writer.close();
      } catch (e) {
        console.error("Stream processing error:", e);
        await writer.abort(e);
      }
    })();

    // For streaming responses, we need to manually add CORS headers
    const origin = c.req.header("Origin") || "";
    const allowedOrigin =
      ALLOWED_ORIGINS.includes(origin) ||
      origin.startsWith("http://localhost:") ||
      origin.startsWith("http://127.0.0.1:")
        ? origin
        : "null";

    return new Response(readable, {
      headers: {
        "Content-Type": "application/x-ndjson",
        "Access-Control-Allow-Origin": allowedOrigin,
        "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS",
        "Access-Control-Allow-Headers":
          "Content-Type, Authorization, X-API-Key",
      },
    });
  } catch (error) {
    console.error("Error in /tts/generate:", error);
    return c.json(
      {
        error: "TTS generation failed.",
      } as TTSResponse,
      500
    );
  }
});

// DELETE /chat/messages - Delete messages (requires auth)
app.delete("/chat/messages", authMiddleware, async (c) => {
  try {
    const body: any = await c.req.json();
    const env = c.env as Env;
    const sceneKey = body.scene_key;
    const messageIds: string[] = body.message_ids || [];

    if (!sceneKey || !messageIds || messageIds.length === 0) {
      return c.json({ error: "Missing scene_key or message_ids" }, 400);
    }

    // Get authenticated user from context (already authenticated by authMiddleware)
    const user = c.get("user");

    // Create Supabase client with user's token for RLS
    const authHeader = c.req.header("Authorization");
    const token = authHeader!.split(" ")[1];
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY, {
      global: {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      },
    });

    // Fetch current messages for this scene
    const { data: chatHistory, error: fetchError } = await supabase
      .from("chat_history")
      .select("messages")
      .eq("user_id", user.id)
      .eq("scene_key", sceneKey)
      .maybeSingle();

    if (fetchError) {
      console.error("Error fetching chat history:", fetchError);
      return c.json({ error: "Failed to fetch chat history" }, 500);
    }

    if (!chatHistory || !chatHistory.messages) {
      return c.json({ success: true, deleted_count: 0 });
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
      return c.json({ error: "Failed to delete messages" }, 500);
    }

    return c.json({ success: true, deleted_count: deletedCount });
  } catch (error) {
    console.error("Error in /chat/messages DELETE:", error);
    return c.json({ error: "Failed to delete messages" }, 500);
  }
});

// POST /user/sync - User sync (no auth required)
app.post("/user/sync", async (c) => {
  try {
    const body: any = await c.req.json();

    console.log("Received user sync:", body.id, body.email);

    return c.json({
      status: "success",
      synced_at: new Date().toISOString(),
    });
  } catch (error) {
    console.error("Error in /user/sync:", error);
    return c.json({ error: "Failed to sync user data" }, 500);
  }
});

// 404 handler
app.notFound((c) => {
  return c.json({ error: "Not Found" }, 404);
});

// Export for Cloudflare Workers
export default app;
