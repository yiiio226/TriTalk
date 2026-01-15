import { swaggerUI } from "@hono/swagger-ui";
import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import { cors } from "hono/cors";
import { stream } from "hono/streaming";
import { Env } from "./types";

// Utils
import {
  ALLOWED_ORIGINS,
  arrayBufferToBase64,
  detectAudioFormat,
  hexToBase64,
  iterateStreamLines,
  parseJSON,
  sanitizeText,
} from "./utils";

// Services
import {
  authMiddleware,
  callAzureSpeechAssessment,
  callMiniMaxTTS,
  callOpenRouter,
  callOpenRouterMultimodal,
  callOpenRouterStreaming,
  createSupabaseClient,
  extractToken,
  getTTSConfig,
  isAzureSpeechConfigured,
  isTTSConfigured,
  processWordsForUI,
} from "./services";

// Prompts
import {
  buildAnalyzePrompt,
  buildChatSystemPrompt,
  buildHintPrompt,
  buildOptimizePrompt,
  buildSceneGeneratePrompt,
  buildScenePolishPrompt,
  buildStreamingVoiceChatSystemPrompt,
  buildTranscribePrompt,
  buildTranscriptionPrompt,
  buildTranslatePrompt,
} from "./prompts";

// Schemas
import {
  ChatRequestSchema,
  ChatResponseSchema,
  ErrorSchema,
  HintRequestSchema,
  HintResponseSchema,
  OptimizeRequestSchema,
  OptimizeResponseSchema,
  PolishRequestSchema,
  PolishResponseSchema,
  SceneGenerationRequestSchema,
  SceneGenerationResponseSchema,
  ShadowRequestSchema,
  ShadowResponseSchema,
  TranscribeResponseSchema,
  TranslateRequestSchema,
  TranslateResponseSchema,
} from "./schemas";

// Initialize OpenAPIHono app
const app = new OpenAPIHono<{ Bindings: Env; Variables: { user: any } }>();

// ============================================
// Error Logging Helper
// ============================================
interface ErrorLogContext {
  route: string;
  method?: string;
  userId?: string;
  requestData?: Record<string, unknown>;
}

function logError(error: unknown, context: ErrorLogContext): void {
  const errorObj = error instanceof Error ? error : new Error(String(error));
  const timestamp = new Date().toISOString();

  // Structured log for Cloudflare observability
  console.error(
    JSON.stringify({
      timestamp,
      level: "ERROR",
      route: context.route,
      method: context.method || "UNKNOWN",
      userId: context.userId || "anonymous",
      error: {
        name: errorObj.name,
        message: errorObj.message,
        stack: errorObj.stack?.split("\n").slice(0, 5).join("\n"), // First 5 lines of stack
      },
      requestData: context.requestData,
    })
  );

  // Also log in human-readable format for quick debugging
  console.error(`[${timestamp}] ERROR in ${context.route}:`, errorObj.message);
  if (errorObj.stack) {
    console.error("Stack trace:", errorObj.stack);
  }
}

// ============================================
// Global Error Handler
// ============================================
app.onError((err, c) => {
  const requestId =
    c.req.header("cf-ray") || c.req.header("x-request-id") || "unknown";
  const user = c.get("user");

  logError(err, {
    route: c.req.path,
    method: c.req.method,
    userId: user?.id,
    requestData: {
      requestId,
      url: c.req.url,
      headers: {
        "content-type": c.req.header("content-type"),
        "user-agent": c.req.header("user-agent"),
      },
    },
  });

  // Return a generic error response
  return c.json(
    {
      error: "Internal Server Error",
      message: err.message || "An unexpected error occurred",
      requestId,
    },
    500
  );
});

// ============================================
// CORS Middleware (Global)
// ============================================
app.use(
  "/*",
  cors({
    origin: (origin) => {
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

// Apply auth middleware to protected routes
app.use("/chat/*", authMiddleware);
app.use("/scene/*", authMiddleware);
app.use("/common/*", authMiddleware);
app.use("/tts/*", authMiddleware);
app.use("/speech/*", authMiddleware);

// ============================================
// Routes
// ============================================

// GET / - Root
app.get("/", (c) => {
  return c.json(
    {
      message: "TriTalk Backend Running on Cloudflare Workers with OpenAPIHono",
    },
    200
  );
});

// GET /health - Health check
const healthRoute = createRoute({
  method: "get",
  path: "/health",
  responses: {
    200: {
      content: {
        "application/json": { schema: z.object({ status: z.string() }) },
      },
      description: "Health status",
    },
  },
});
app.openapi(healthRoute, (c) => c.json({ status: "ok" }, 200));

// POST /chat/send
const chatSendRoute = createRoute({
  method: "post",
  path: "/chat/send",
  request: {
    body: {
      content: { "application/json": { schema: ChatRequestSchema } },
    },
  },
  responses: {
    200: {
      content: { "application/json": { schema: ChatResponseSchema } },
      description: "Chat response",
    },
    500: {
      content: { "application/json": { schema: ErrorSchema } },
      description: "Server error",
    },
  },
});
app.openapi(chatSendRoute, async (c) => {
  try {
    const body = c.req.valid("json");
    const env = c.env as Env;

    console.log("[/chat/send] Request received:", {
      message: body.message?.substring(0, 50),
      historyLength: body.history?.length || 0,
      sceneContext: body.scene_context?.substring(0, 30),
    });

    const nativeLang = body.native_language || "Chinese (Simplified)";
    const targetLang = body.target_language || "English";

    // Check if this is the initial message (empty history + simple greeting)
    const isInitialMessage =
      (!body.history || body.history.length === 0) &&
      body.message.trim().toLowerCase() === 'hi';

    if (isInitialMessage) {
      // For initial message, just generate AI's greeting without analysis
      const initialPrompt = `You are roleplaying in a language learning scenario.
      
SCENARIO CONTEXT: ${body.scene_context}

CRITICAL ROLE INSTRUCTIONS:
1. You MUST play the AI role specified in the scenario context.
2. This is the START of a new conversation.
3. Generate a natural, in-character greeting to begin the roleplay.
4. Stay in character and set the scene naturally.
5. Keep your greeting conversational and welcoming.

Generate ONLY a JSON response with this format:
{
    "reply": "Your in-character greeting to start the conversation"
}`;

      const messages = [{ role: "user", content: initialPrompt }];
      const content = await callOpenRouter(
        env.OPENROUTER_API_KEY,
        env.OPENROUTER_CHAT_MODEL,
        messages
      );
      const data = parseJSON(content);
      const replyText = sanitizeText(data.reply || "Hello! How can I help you today?");

      return c.json(
        {
          message: replyText,
          review_feedback: null, // No feedback for initial greeting
        },
        200
      );
    }

    // Normal message flow with analysis
    const systemPrompt = buildChatSystemPrompt(
      body.scene_context,
      nativeLang,
      targetLang
    );

    const messages = [{ role: "system", content: systemPrompt }];

    if (body.history && body.history.length > 0) {
      const recentHistory = body.history.slice(-10);
      messages.push(...recentHistory);
    }

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

    const feedback = {
      is_perfect: analysisData.is_perfect || false,
      corrected_text: sanitizeText(analysisData.corrected_text || body.message),
      native_expression: sanitizeText(analysisData.native_expression || ""),
      explanation: sanitizeText(analysisData.grammar_explanation || analysisData.explanation || ""), // Backward compatibility
      grammar_explanation: sanitizeText(analysisData.grammar_explanation || analysisData.explanation || ""),
      native_expression_reason: sanitizeText(analysisData.native_expression_reason || ""),
      example_answer: sanitizeText(analysisData.example_answer || ""),
      example_answer_reason: sanitizeText(analysisData.example_answer_reason || ""),
    };

    return c.json(
      {
        message: replyText,
        review_feedback: feedback,
      },
      200
    );
  } catch (error) {
    const user = c.get("user");
    logError(error, {
      route: "/chat/send",
      method: "POST",
      userId: user?.id,
    });
    return c.json(
      {
        message: "Sorry, I'm having trouble connecting to the AI right now.",
        debug_error: String(error),
      },
      500
    );
  }
});

// POST /chat/transcribe
const transcribeRoute = createRoute({
  method: "post",
  path: "/chat/transcribe",
  request: {
    body: {
      content: {
        "multipart/form-data": {
          schema: z.object({
            audio: z
              .instanceof(File)
              .openapi({ type: "string", format: "binary" }),
          }),
        },
      },
    },
  },
  responses: {
    200: {
      content: { "application/json": { schema: TranscribeResponseSchema } },
      description: "Transcription result",
    },
    500: {
      content: { "application/json": { schema: ErrorSchema } },
      description: "Server error",
    },
  },
});
app.openapi(transcribeRoute, async (c) => {
  try {
    const formData = await c.req.formData();
    const env = c.env as Env;
    const audioFile = formData.get("audio");

    if (!audioFile || typeof audioFile === "string") {
      throw new Error("No audio file uploaded");
    }

    const audioBlob = audioFile as File;
    const arrayBuffer = await audioBlob.arrayBuffer();
    const audioBase64 = arrayBufferToBase64(arrayBuffer);
    const fileName = audioBlob.name || "audio.wav";
    const audioFormat = detectAudioFormat(fileName);

    console.log(
      `[Transcribe] File: ${fileName}, Format: ${audioFormat}, Size: ${arrayBuffer.byteLength} bytes`
    );

    const transcribePrompt = buildTranscribePrompt();

    const content = await callOpenRouterMultimodal(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_TRANSCRIBE_MODEL,
      transcribePrompt,
      [
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
      ]
    );

    const parsedData = parseJSON(content);
    return c.json(
      {
        text: parsedData.optimized_text || "",
        raw_text: parsedData.raw_text || "",
      },
      200
    );
  } catch (error) {
    const user = c.get("user");
    logError(error, {
      route: "/chat/transcribe",
      method: "POST",
      userId: user?.id,
    });
    return c.json(
      { error: "Failed to transcribe audio", details: String(error) },
      500
    );
  }
});

// POST /chat/send-voice - Two-step process: transcribe then respond
app.post("/chat/send-voice", async (c) => {
  console.log("[/chat/send-voice] Request received");
  try {
    const formData = await c.req.formData();
    const env = c.env as Env;
    const audioFile = formData.get("audio");
    const sceneContext = (formData.get("scene_context") as string) || "";
    const historyStr = (formData.get("history") as string) || "[]";
    const nativeLang =
      (formData.get("native_language") as string) || "Chinese (Simplified)";
    const targetLang = (formData.get("target_language") as string) || "English";

    console.log("[/chat/send-voice] Parsed form data:", {
      hasAudio: !!audioFile,
      sceneContext: sceneContext?.substring(0, 30),
      historyLength: historyStr?.length,
    });

    let history: any[] = [];
    try {
      history = JSON.parse(historyStr);
    } catch (e) { }

    if (!audioFile || typeof audioFile === "string") {
      throw new Error("No audio file uploaded");
    }

    const audioBlob = audioFile as File;
    const arrayBuffer = await audioBlob.arrayBuffer();
    const audioBase64 = arrayBufferToBase64(arrayBuffer);
    const fileName = audioBlob.name || "audio.wav";
    const audioFormat = detectAudioFormat(fileName);

    console.log(
      `[Send Voice] File: ${fileName}, Format: ${audioFormat}, Size: ${arrayBuffer.byteLength} bytes`
    );

    // ============================================
    // STEP 1: Transcribe the audio
    // ============================================
    console.log("[Send Voice] Step 1: Transcribing audio...");
    const transcriptPrompt = buildTranscriptionPrompt();

    const transcriptResponse = await callOpenRouterMultimodal(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_TRANSCRIBE_MODEL,
      transcriptPrompt,
      [
        {
          type: "text",
          text: "Transcribe the following audio exactly as spoken:",
        },
        {
          type: "input_audio",
          input_audio: {
            data: audioBase64,
            format: audioFormat,
          },
        },
      ],
      false  // Plain text mode for transcription
    );

    const transcript = sanitizeText(transcriptResponse).trim();
    console.log("[Send Voice] Step 1 complete. Transcript:", transcript.substring(0, 50));

    // ============================================
    // STEP 2: Generate AI response based on transcript
    // ============================================
    console.log("[Send Voice] Step 2: Generating AI response...");
    const systemPrompt = buildChatSystemPrompt(
      sceneContext,
      nativeLang,
      targetLang
    );

    const messages = [{ role: "system", content: systemPrompt }];

    if (history && history.length > 0) {
      const recentHistory = history.slice(-5);
      messages.push(...recentHistory);
    }

    // Add the user's transcribed message
    messages.push({
      role: "user",
      content: `<<LATEST_USER_MESSAGE>>${transcript}<</LATEST_USER_MESSAGE>>`,
    });

    const response = await callOpenRouterStreaming(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_CHAT_MODEL,
      messages
    );

    c.header("Content-Type", "application/x-ndjson");
    c.header("Content-Encoding", "Identity");

    return stream(
      c,
      async (stream) => {
        stream.onAbort(() => {
          console.log("Stream aborted: /chat/send-voice");
        });

        let fullResponse = "";

        // Accumulate the full JSON response from Step 2
        for await (const line of iterateStreamLines(response)) {
          if (line === "data: [DONE]") continue;
          if (line.startsWith("data: ")) {
            try {
              const jsonStr = line.slice(6);
              const parsed = JSON.parse(jsonStr);
              const content = parsed.choices?.[0]?.delta?.content || "";
              if (content) {
                fullResponse += content;
              }
            } catch (e) {
              // Skip malformed JSON
            }
          }
        }

        // Parse the complete JSON response
        try {
          const data = parseJSON(fullResponse);
          const replyText = sanitizeText(data.reply || "");
          const analysisData = data.analysis || {};

          console.log("[Send Voice] Step 2 complete. Reply:", replyText.substring(0, 50));

          // Send combined metadata with transcript only
          // Note: Analysis is NOT included here - it's triggered on-demand when user clicks "Analyze"
          await stream.writeln(
            JSON.stringify({
              type: "metadata",
              data: {
                transcript,  // From Step 1
                translation: null, // TODO: Add translation step if needed
              },
            })
          );

          // Stream the reply text character by character for smooth UX
          // (simulate streaming even though we have the full text)
          for (let i = 0; i < replyText.length; i++) {
            await stream.writeln(
              JSON.stringify({ type: "token", content: replyText[i] })
            );
            // Small delay to simulate natural streaming (optional)
            // await new Promise(resolve => setTimeout(resolve, 10));
          }
        } catch (e) {
          console.error("[Send Voice] Failed to parse response:", e);
          console.error("[Send Voice] Raw response:", fullResponse.substring(0, 200));

          // Send error
          await stream.writeln(
            JSON.stringify({
              type: "error",
              error: "Failed to parse AI response",
            })
          );
        }

        await stream.writeln(JSON.stringify({ type: "done" }));
      },
      async (err, stream) => {
        console.error("Stream error in /chat/send-voice:", err);
        await stream.writeln(
          JSON.stringify({ type: "error", error: String(err) })
        );
      }
    );
  } catch (error) {
    const user = c.get("user");
    logError(error, {
      route: "/chat/send-voice",
      method: "POST",
      userId: user?.id,
    });
    return c.json(
      {
        message: "Sorry, I'm having trouble processing your voice message.",
        debug_error: String(error),
      },
      500
    );
  }
});

// POST /chat/hint
const hintRoute = createRoute({
  method: "post",
  path: "/chat/hint",
  request: {
    body: {
      content: { "application/json": { schema: HintRequestSchema } },
    },
  },
  responses: {
    200: {
      content: { "application/json": { schema: HintResponseSchema } },
      description: "Hints",
    },
    500: {
      content: { "application/json": { schema: ErrorSchema } },
      description: "Error",
    },
  },
});
app.openapi(hintRoute, async (c) => {
  try {
    const body = c.req.valid("json");
    const env = c.env as Env;
    const targetLang = body.target_language || "English";

    const hintPrompt = buildHintPrompt(body.scene_context, targetLang);
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

    return c.json({ hints }, 200);
  } catch (error) {
    const user = c.get("user");
    logError(error, {
      route: "/chat/hint",
      method: "POST",
      userId: user?.id,
    });
    return c.json(
      {
        hints: [
          "Could you help me?",
          "I don't understand.",
          "Please continue.",
        ],
      },
      200
    );
  }
});

// POST /chat/analyze - Streaming
app.post("/chat/analyze", async (c) => {
  try {
    const body = (await c.req.json()) as any;
    const env = c.env as Env;
    const nativeLang = body.native_language || "Chinese (Simplified)";

    const analyzePrompt = buildAnalyzePrompt(body.message, nativeLang);
    const messages = [{ role: "user", content: analyzePrompt }];

    const response = await callOpenRouterStreaming(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_CHAT_MODEL,
      messages
    );

    c.header("Content-Type", "application/x-ndjson");
    c.header("Content-Encoding", "Identity");

    return stream(
      c,
      async (stream) => {
        stream.onAbort(() => console.log("Stream aborted: /chat/analyze"));
        for await (const line of iterateStreamLines(response)) {
          if (line === "data: [DONE]") continue;
          if (line.startsWith("data: ")) {
            try {
              const jsonStr = line.slice(6);
              const parsed = JSON.parse(jsonStr);
              const content = parsed.choices?.[0]?.delta?.content || "";
              if (content) {
                if (content.includes("```")) continue;
                await stream.write(content);
              }
            } catch (e) { }
          }
        }
      },
      async (err, stream) => {
        console.error("Stream error in /chat/analyze:", err);
        await stream.write(JSON.stringify({ error: String(err) }));
      }
    );
  } catch (error) {
    const user = c.get("user");
    logError(error, {
      route: "/chat/analyze",
      method: "POST",
      userId: user?.id,
    });
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

// POST /scene/generate
const sceneGenerateRoute = createRoute({
  method: "post",
  path: "/scene/generate",
  request: {
    body: {
      content: { "application/json": { schema: SceneGenerationRequestSchema } },
    },
  },
  responses: {
    200: {
      content: {
        "application/json": { schema: SceneGenerationResponseSchema },
      },
      description: "Scene",
    },
    500: {
      content: {
        "application/json": { schema: SceneGenerationResponseSchema },
      },
      description: "Error fallback",
    },
  },
});
app.openapi(sceneGenerateRoute, async (c) => {
  let body: any;
  try {
    body = c.req.valid("json");
    const env = c.env as Env;
    const { description, tone } = body;
    const prompt = buildSceneGeneratePrompt(description, tone);
    const messages = [{ role: "user", content: prompt }];

    const content = await callOpenRouter(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_CHAT_MODEL,
      messages
    );
    let data = parseJSON(content);
    if (Array.isArray(data) && data.length > 0) data = data[0];

    return c.json(
      {
        title: data.title || "Custom Scene",
        ai_role: data.ai_role || "Assistant",
        user_role: data.user_role || "Learner",
        goal: data.goal || "Practice English",
        description: data.description || description,
        initial_message: data.initial_message || "Hello! Ready to practice?",
        emoji: data.emoji || "✨",
      },
      200
    );
  } catch (error) {
    const user = c.get("user");
    logError(error, {
      route: "/scene/generate",
      method: "POST",
      userId: user?.id,
      requestData: { description: body?.description?.substring(0, 50) },
    });
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

// POST /scene/polish
const scenePolishRoute = createRoute({
  method: "post",
  path: "/scene/polish",
  request: {
    body: {
      content: { "application/json": { schema: PolishRequestSchema } },
    },
  },
  responses: {
    200: {
      content: { "application/json": { schema: PolishResponseSchema } },
      description: "Polished text",
    },
    500: {
      content: { "application/json": { schema: PolishResponseSchema } },
      description: "Error",
    },
  },
});
app.openapi(scenePolishRoute, async (c) => {
  try {
    const body = c.req.valid("json");
    const env = c.env as Env;
    const prompt = buildScenePolishPrompt(body.description);
    const messages = [{ role: "user", content: prompt }];
    const content = await callOpenRouter(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_CHAT_MODEL,
      messages
    );
    const data = parseJSON(content);
    return c.json(
      { polished_text: data.polished_text || body.description },
      200
    );
  } catch (error) {
    const user = c.get("user");
    logError(error, {
      route: "/scene/polish",
      method: "POST",
      userId: user?.id,
    });
    return c.json(
      { polished_text: "Could not polish text at this time." },
      500
    );
  }
});

// POST /common/translate
const translateRoute = createRoute({
  method: "post",
  path: "/common/translate",
  request: {
    body: {
      content: { "application/json": { schema: TranslateRequestSchema } },
    },
  },
  responses: {
    200: {
      content: { "application/json": { schema: TranslateResponseSchema } },
      description: "Translation",
    },
    500: {
      content: { "application/json": { schema: TranslateResponseSchema } },
      description: "Error",
    },
  },
});
app.openapi(translateRoute, async (c) => {
  try {
    const body = c.req.valid("json");
    const env = c.env as Env;
    const prompt = buildTranslatePrompt(body.text, body.target_language);
    const messages = [{ role: "user", content: prompt }];
    const content = await callOpenRouter(
      env.OPENROUTER_API_KEY,
      env.OPENROUTER_CHAT_MODEL,
      messages
    );
    const data = parseJSON(content);
    return c.json({ translation: data.translation || body.text }, 200);
  } catch (error) {
    const user = c.get("user");
    logError(error, {
      route: "/common/translate",
      method: "POST",
      userId: user?.id,
    });
    return c.json({ translation: "Translation unavailable." }, 500);
  }
});

// POST /chat/shadow
const shadowRoute = createRoute({
  method: "post",
  path: "/chat/shadow",
  request: {
    body: {
      content: { "application/json": { schema: ShadowRequestSchema } },
    },
  },
  responses: {
    200: {
      content: { "application/json": { schema: ShadowResponseSchema } },
      description: "Shadow result",
    },
    500: {
      content: { "application/json": { schema: ShadowResponseSchema } },
      description: "Error",
    },
  },
});
app.openapi(shadowRoute, async (c) => {
  try {
    const body = c.req.valid("json");
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

    return c.json(
      {
        score,
        details: {
          intonation_score: Math.max(0, score - 10),
          pronunciation_score: score,
          feedback,
        },
      },
      200
    );
  } catch (error) {
    const user = c.get("user");
    logError(error, {
      route: "/chat/shadow",
      method: "POST",
      userId: user?.id,
    });
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

// POST /chat/optimize
const optimizeRoute = createRoute({
  method: "post",
  path: "/chat/optimize",
  request: {
    body: {
      content: { "application/json": { schema: OptimizeRequestSchema } },
    },
  },
  responses: {
    200: {
      content: { "application/json": { schema: OptimizeResponseSchema } },
      description: "Optimized text",
    },
    500: {
      content: { "application/json": { schema: OptimizeResponseSchema } },
      description: "Error",
    },
  },
});
app.openapi(optimizeRoute, async (c) => {
  try {
    const body = c.req.valid("json");
    const env = c.env as Env;
    const targetLang = body.target_language || "English";
    const prompt = buildOptimizePrompt(
      body.scene_context,
      body.message,
      targetLang
    );
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
    return c.json({ optimized_text: data.optimized_text || body.message }, 200);
  } catch (error) {
    const user = c.get("user");
    logError(error, {
      route: "/chat/optimize",
      method: "POST",
      userId: user?.id,
    });
    return c.json({ optimized_text: "Optimization unavailable." }, 500);
  }
});

// POST /tts/generate - Streaming
app.post("/tts/generate", async (c) => {
  try {
    const env = c.env as Env;
    if (!isTTSConfigured(env)) {
      return c.json({ error: "TTS service not configured." }, 503);
    }
    const body = (await c.req.json()) as any;
    if (!body.text || body.text.trim().length === 0) {
      return c.json({ error: "Text is required." }, 400);
    }
    const ttsConfig = getTTSConfig(env);
    const ttsResponse = await callMiniMaxTTS(ttsConfig, {
      text: body.text,
      voiceId: body.voice_id,
    });
    if (!ttsResponse.ok) {
      const errorText = await ttsResponse.text();
      console.error("MiniMax TTS API Error:", errorText);
      return c.json(
        { error: `TTS generation failed: ${ttsResponse.status}` },
        502
      );
    }

    c.header("Content-Type", "application/x-ndjson");
    c.header("Content-Encoding", "Identity");

    return stream(
      c,
      async (stream) => {
        stream.onAbort(() => console.log("Stream aborted: /tts/generate"));
        let chunkIndex = 0;
        for await (const line of iterateStreamLines(ttsResponse)) {
          console.log("MiniMax Raw Line:", line.substring(0, 200));
          if (!line.startsWith("data:")) continue;
          const jsonStr = line.slice(5).trim();
          if (!jsonStr || jsonStr === "[DONE]") continue;
          try {
            const chunkData = JSON.parse(jsonStr);
            if (chunkData.base_resp && chunkData.base_resp.status_code !== 0) {
              await stream.writeln(
                JSON.stringify({
                  type: "error",
                  error: chunkData.base_resp.status_msg,
                })
              );
              continue;
            }
            const audioHex = chunkData.data?.audio;
            if (audioHex) {
              const audioBase64 = hexToBase64(audioHex);
              await stream.writeln(
                JSON.stringify({
                  type: "audio_chunk",
                  chunk_index: chunkIndex++,
                  audio_base64: audioBase64,
                })
              );
            }
            if (chunkData.extra_info?.audio_length) {
              await stream.writeln(
                JSON.stringify({
                  type: "info",
                  duration_ms: chunkData.extra_info.audio_length,
                })
              );
            }
          } catch (e) {
            console.error("Error processing TTS chunk:", e);
          }
        }
        await stream.writeln(JSON.stringify({ type: "done" }));
      },
      async (err, stream) => {
        console.error("Stream error in /tts/generate:", err);
        await stream.writeln(
          JSON.stringify({ type: "error", error: String(err) })
        );
      }
    );
  } catch (error) {
    const user = c.get("user");
    logError(error, {
      route: "/tts/generate",
      method: "POST",
      userId: user?.id,
    });
    return c.json({ error: "TTS generation failed." }, 500);
  }
});

// DELETE /chat/messages
const deleteMessagesRoute = createRoute({
  method: "delete",
  path: "/chat/messages",
  request: {
    body: {
      content: {
        "application/json": {
          schema: z.object({
            scene_key: z.string(),
            message_ids: z.array(z.string()),
          }),
        },
      },
    },
  },
  responses: {
    200: {
      content: {
        "application/json": {
          schema: z.object({ success: z.boolean(), deleted_count: z.number() }),
        },
      },
      description: "Deleted",
    },
    400: {
      content: {
        "application/json": { schema: z.object({ error: z.string() }) },
      },
      description: "Bad Request",
    },
    500: {
      content: {
        "application/json": { schema: z.object({ error: z.string() }) },
      },
      description: "Error",
    },
  },
});
app.openapi(deleteMessagesRoute, async (c) => {
  try {
    const body = c.req.valid("json");
    const env = c.env as Env;
    const sceneKey = body.scene_key;
    const messageIds = body.message_ids;

    if (!sceneKey || !messageIds || messageIds.length === 0) {
      return c.json({ error: "Missing scene_key or message_ids" }, 400);
    }
    const user = c.get("user");
    const authHeader = c.req.header("Authorization");
    const token = extractToken(authHeader)!;
    const supabase = createSupabaseClient(env, token);

    const { data: chatHistory, error: fetchError } = await supabase
      .from("chat_history")
      .select("messages")
      .eq("user_id", user.id)
      .eq("scene_key", sceneKey)
      .maybeSingle();

    if (fetchError) {
      return c.json({ error: "Failed to fetch chat history" }, 500);
    }
    if (!chatHistory || !chatHistory.messages) {
      return c.json({ success: true, deleted_count: 0 }, 200);
    }
    const currentMessages = chatHistory.messages as any[];
    const filteredMessages = currentMessages.filter(
      (msg) => !messageIds.includes(msg.id)
    );
    const deletedCount = currentMessages.length - filteredMessages.length;

    const { error: updateError } = await supabase
      .from("chat_history")
      .update({
        messages: filteredMessages,
        updated_at: new Date().toISOString(),
      })
      .eq("user_id", user.id)
      .eq("scene_key", sceneKey);

    if (updateError) {
      return c.json({ error: "Failed to delete messages" }, 500);
    }
    return c.json({ success: true, deleted_count: deletedCount }, 200);
  } catch (error) {
    const user = c.get("user");
    logError(error, {
      route: "/chat/messages",
      method: "DELETE",
      userId: user?.id,
    });
    return c.json({ error: "Failed to delete messages" }, 500);
  }
});

// ============================================
// Speech API - Pronunciation Assessment
// ============================================

// POST /speech/assess - Pronunciation Assessment using Azure Speech
app.post("/speech/assess", async (c) => {
  try {
    const formData = await c.req.formData();
    const env = c.env as Env;

    // Check if Azure Speech is configured
    if (
      !isAzureSpeechConfigured(env.AZURE_SPEECH_KEY, env.AZURE_SPEECH_REGION)
    ) {
      return c.json({ error: "Azure Speech is not configured" }, 500);
    }

    const audioFile = formData.get("audio");
    const referenceText = formData.get("reference_text") as string;
    const language = (formData.get("language") as string) || "en-US";
    const enableProsody = formData.get("enable_prosody") !== "false";

    if (!audioFile || typeof audioFile === "string") {
      return c.json({ error: "No audio file uploaded" }, 400);
    }

    if (!referenceText) {
      return c.json({ error: "Reference text is required" }, 400);
    }

    const audioBlob = audioFile as File;
    const arrayBuffer = await audioBlob.arrayBuffer();

    // Debug: inspect audio header bytes
    const headerBytes = new Uint8Array(arrayBuffer.slice(0, 44));
    const headerStr = String.fromCharCode(...headerBytes.slice(0, 4));
    console.log(
      `[Speech/Assess] Reference: "${referenceText}", Language: ${language}`
    );
    console.log(
      `[Speech/Assess] File: ${audioBlob.name}, Size: ${arrayBuffer.byteLength} bytes, Header: "${headerStr}"`
    );
    console.log(
      `[Speech/Assess] First 12 header bytes:`,
      Array.from(headerBytes.slice(0, 12))
        .map((b) => b.toString(16).padStart(2, "0"))
        .join(" ")
    );

    // Call Azure Speech Pronunciation Assessment API
    const result = await callAzureSpeechAssessment(
      env.AZURE_SPEECH_KEY!,
      env.AZURE_SPEECH_REGION!,
      arrayBuffer,
      referenceText,
      language,
      enableProsody
    );

    // Process words for UI display (Traffic Light system)
    const wordFeedback = processWordsForUI(result.words);

    // Transform to snake_case for API response
    const response = {
      recognition_status: result.recognitionStatus,
      display_text: result.displayText,
      pronunciation_score: result.pronunciationScore,
      accuracy_score: result.accuracyScore,
      fluency_score: result.fluencyScore,
      completeness_score: result.completenessScore,
      prosody_score: result.prosodyScore,
      words: result.words.map((word) => ({
        word: word.word,
        accuracy_score: word.accuracyScore,
        error_type: word.errorType,
        phonemes: word.phonemes.map((phoneme) => ({
          phoneme: phoneme.phoneme,
          accuracy_score: phoneme.accuracyScore,
          offset: phoneme.offset,
          duration: phoneme.duration,
        })),
      })),
      word_feedback: wordFeedback.map((wf) => ({
        text: wf.text,
        score: wf.score,
        level: wf.level,
        error_type: wf.errorType,
        phonemes: wf.phonemes.map((phoneme) => ({
          phoneme: phoneme.phoneme,
          accuracy_score: phoneme.accuracyScore,
          offset: phoneme.offset,
          duration: phoneme.duration,
        })),
      })),
    };

    return c.json(response, 200);
  } catch (error) {
    const user = c.get("user");
    logError(error, {
      route: "/speech/assess",
      method: "POST",
      userId: user?.id,
    });
    return c.json(
      {
        error: "Failed to assess pronunciation",
        details: String(error),
      },
      500
    );
  }
});

// POST /user/sync
const userSyncRoute = createRoute({
  method: "post",
  path: "/user/sync",
  request: {
    body: {
      content: {
        "application/json": {
          schema: z.object({ id: z.string(), email: z.string().optional() }),
        },
      },
    },
  },
  responses: {
    200: {
      content: {
        "application/json": {
          schema: z.object({ status: z.string(), synced_at: z.string() }),
        },
      },
      description: "Synced",
    },
  },
});
app.openapi(userSyncRoute, async (c) => {
  const body = c.req.valid("json");
  console.log("Received user sync:", body.id, body.email);
  return c.json(
    { status: "success", synced_at: new Date().toISOString() },
    200
  );
});

// API Docs
app.doc("/doc", {
  openapi: "3.0.0",
  info: {
    version: "1.0.0",
    title: "TriTalk API",
  },
});

app.get("/ui", swaggerUI({ url: "/doc" }));

export default app;
