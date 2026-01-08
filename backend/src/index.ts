import { Hono } from "hono";
import { cors } from "hono/cors";
import { stream } from "hono/streaming";
import {
  ChatRequest,
  ChatResponse,
  HintRequest,
  HintResponse,
  SceneGenerationRequest,
  SceneGenerationResponse,
  AnalyzeRequest,
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

// Utils
import {
  parseJSON,
  sanitizeText,
  hexToBase64,
  arrayBufferToBase64,
  detectAudioFormat,
  ALLOWED_ORIGINS,
  iterateStreamLines,
} from "./utils";

// Services
import {
  callOpenRouter,
  callOpenRouterStreaming,
  callOpenRouterMultimodal,
  callMiniMaxTTS,
  isTTSConfigured,
  getTTSConfig,
  createSupabaseClient,
  extractToken,
  authMiddleware,
} from "./services";

// Prompts
import {
  buildChatSystemPrompt,
  buildVoiceChatSystemPrompt,
  buildHintPrompt,
  buildOptimizePrompt,
  buildAnalyzePrompt,
  buildSceneGeneratePrompt,
  buildScenePolishPrompt,
  buildTranscribePrompt,
  buildTranslatePrompt,
} from "./prompts";

// Initialize Hono app with Env bindings
const app = new Hono<{ Bindings: Env; Variables: { user: any } }>();

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

    const systemPrompt = buildChatSystemPrompt(
      body.scene_context,
      nativeLang,
      targetLang
    );

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

    if (!audioFile || typeof audioFile === "string") {
      throw new Error("No audio file uploaded");
    }

    // Convert audio file to base64 with improved binary handling
    const audioBlob = audioFile as File;
    const arrayBuffer = await audioBlob.arrayBuffer();
    const audioBase64 = arrayBufferToBase64(arrayBuffer);

    // Determine audio format from file extension
    const fileName = audioBlob.name || "audio.wav";
    const audioFormat = detectAudioFormat(fileName);

    console.log(
      `[Transcribe] File: ${fileName}, Format: ${audioFormat}, Size: ${arrayBuffer.byteLength} bytes`
    );

    // Build the multimodal prompt for Gemini
    const transcribePrompt = buildTranscribePrompt();

    // Call OpenRouter with multimodal content (audio + text)
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
    const systemPrompt = buildVoiceChatSystemPrompt(
      sceneContext,
      nativeLang,
      targetLang
    );

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
        stream.onAbort(() => {
          console.log("Stream aborted: /chat/analyze");
        });

        for await (const line of iterateStreamLines(response)) {
          if (line === "data: [DONE]") continue;
          if (line.startsWith("data: ")) {
            try {
              const jsonStr = line.slice(6);
              const parsed = JSON.parse(jsonStr);
              const content = parsed.choices?.[0]?.delta?.content || "";
              if (content) {
                if (content.includes("```")) {
                  continue;
                }
                await stream.write(content);
              }
            } catch (e) {
              // Ignore parse errors
            }
          }
        }
      },
      async (err, stream) => {
        console.error("Stream error in /chat/analyze:", err);
        await stream.write(JSON.stringify({ error: String(err) }));
      }
    );
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
    const prompt = buildSceneGeneratePrompt(description, tone);
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

    const prompt = buildScenePolishPrompt(body.description);
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

    const prompt = buildTranslatePrompt(body.text, body.target_language);
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
    if (!isTTSConfigured(env)) {
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

    const ttsConfig = getTTSConfig(env);
    const ttsResponse = await callMiniMaxTTS(ttsConfig, {
      text: body.text,
      voiceId: body.voice_id,
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

    // Create a streaming response
    c.header("Content-Type", "application/x-ndjson");
    c.header("Content-Encoding", "Identity");

    return stream(
      c,
      async (stream) => {
        stream.onAbort(() => {
          console.log("Stream aborted: /tts/generate");
        });

        let chunkIndex = 0;

        for await (const line of iterateStreamLines(ttsResponse)) {
          if (!line.startsWith("data:")) continue;

          const jsonStr = line.slice(5).trim();
          if (!jsonStr || jsonStr === "[DONE]") continue;

          try {
            const chunkData = JSON.parse(jsonStr);

            if (chunkData.base_resp && chunkData.base_resp.status_code !== 0) {
              const errorPayload = {
                type: "error",
                error:
                  chunkData.base_resp.status_msg || "TTS generation failed",
              };
              await stream.writeln(JSON.stringify(errorPayload));
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
              await stream.writeln(JSON.stringify(chunkResponse));
            }

            if (chunkData.extra_info?.audio_length) {
              const infoResponse = {
                type: "info",
                duration_ms: chunkData.extra_info.audio_length,
              };
              await stream.writeln(JSON.stringify(infoResponse));
            }
          } catch (e) {
            console.error("Error parsing TTS chunk:", e);
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
    const token = extractToken(authHeader)!;
    const supabase = createSupabaseClient(env, token);

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
