import { z } from "@hono/zod-openapi";

// --- Chat Schemas ---

export const ChatRequestSchema = z.object({
  message: z.string().openapi({ example: "Hello, how are you?" }),
  history: z
    .array(
      z.object({
        role: z.string(),
        content: z.string(),
      }),
    )
    .optional()
    .openapi({ example: [{ role: "user", content: "Hi" }] }),
  scene_context: z.string().openapi({ example: "Coffee shop ordering" }),
  native_language: z
    .string()
    .optional()
    .openapi({ example: "Chinese (Simplified)" }),
  target_language: z.string().optional().openapi({ example: "English" }),
});

export const ReviewFeedbackSchema = z.object({
  is_perfect: z.boolean().openapi({ example: false }),
  corrected_text: z.string().openapi({ example: "Hello, how are you doing?" }),
  native_expression: z.string().openapi({ example: "Chinese expression" }),
  explanation: z
    .string()
    .openapi({ example: "Added 'doing' for continuous aspect." }),
  example_answer: z.string().openapi({ example: "I am doing well." }),
});

export const ChatResponseSchema = z.object({
  message: z.string().openapi({ example: "I am fine, thanks." }),
  translation: z.string().optional().openapi({ example: "我很好，谢谢。" }),
  review_feedback: ReviewFeedbackSchema.optional(),
});

// --- Hint Schemas ---

export const HintRequestSchema = z.object({
  message: z.string().optional().openapi({ example: "I want a coffee." }),
  history: z
    .array(
      z.object({
        role: z.string(),
        content: z.string(),
      }),
    )
    .optional(),
  scene_context: z.string().openapi({ example: "Ordering at a cafe" }),
  target_language: z.string().optional().openapi({ example: "English" }),
});

export const HintResponseSchema = z.object({
  hints: z
    .array(z.string())
    .openapi({ example: ["Could I have a latte?", "I would like a coffee."] }),
});

// --- Analyze Schemas ---

export const AnalyzeRequestSchema = z.object({
  message: z.string().openapi({ example: "I want coffee." }),
  native_language: z
    .string()
    .optional()
    .openapi({ example: "Chinese (Simplified)" }),
});

export const GrammarPointSchema = z.object({
  structure: z.string(),
  explanation: z.string(),
  example: z.string(),
});

export const VocabularyItemSchema = z.object({
  word: z.string(),
  definition: z.string(),
  example: z.string(),
  level: z.string().optional(),
  part_of_speech: z.string().optional(),
});

export const AnalyzeResponseSchema = z.object({
  grammar_points: z.array(GrammarPointSchema),
  vocabulary: z.array(VocabularyItemSchema),
  sentence_structure: z.string(),
  sentence_breakdown: z
    .array(z.object({ text: z.string(), tag: z.string() }))
    .optional(),
  overall_summary: z.string(),
  pragmatic_analysis: z.string().optional(),
  emotion_tags: z.array(z.string()).optional(),
  idioms_slang: z
    .array(
      z.object({
        text: z.string(),
        explanation: z.string(),
        type: z.enum(["Idiom", "Slang", "Common Phrase"]),
      }),
    )
    .optional(),
});

// --- Scene Schemas ---

export const SceneGenerationRequestSchema = z.object({
  description: z.string().openapi({ example: "Booking a flight ticket." }),
  tone: z.string().optional().openapi({ example: "Polite" }),
  target_language: z.string().optional().openapi({ example: "Spanish" }),
});

export const SceneGenerationResponseSchema = z.object({
  title: z.string(),
  ai_role: z.string(),
  user_role: z.string(),
  goal: z.string(),
  description: z.string(),
  initial_message: z.string(),
  emoji: z.string(),
});

export const PolishRequestSchema = z.object({
  description: z.string().openapi({ example: "ordering food" }),
});

export const PolishResponseSchema = z.object({
  polished_text: z
    .string()
    .openapi({ example: "Ordering food at a fine dining restaurant." }),
});

// --- Translate Schemas ---

export const TranslateRequestSchema = z.object({
  text: z.string().openapi({ example: "Hello" }),
  target_language: z.string().openapi({ example: "Spanish" }),
});

export const TranslateResponseSchema = z.object({
  translation: z.string().openapi({ example: "Hola" }),
});

// --- Shadow Schemas ---

export const ShadowRequestSchema = z.object({
  target_text: z.string().openapi({ example: "Hello World" }),
  user_audio_text: z.string().openapi({ example: "Hello Ward" }),
});

export const ShadowResponseSchema = z.object({
  score: z.number().openapi({ example: 85 }),
  details: z.object({
    intonation_score: z.number(),
    pronunciation_score: z.number(),
    feedback: z.string(),
  }),
});

// --- Optimize Schemas ---

export const OptimizeRequestSchema = z.object({
  message: z.string(),
  scene_context: z.string(),
  history: z
    .array(z.object({ role: z.string(), content: z.string() }))
    .optional(),
  target_language: z.string().optional(),
});

export const OptimizeResponseSchema = z.object({
  optimized_text: z.string(),
});

// --- TTS Schemas ---

export const TTSRequestSchema = z.object({
  text: z.string().openapi({ example: "Hello world" }),
  message_id: z.string().optional(),
  voice_id: z.string().optional(),
});

export const TTSResponseSchema = z.object({
  audio_url: z.string().optional(),
  audio_base64: z.string().optional(),
  duration_ms: z.number().optional(),
  error: z.string().optional(),
});

// --- Transcribe Schemas ---

export const TranscribeResponseSchema = z.object({
  text: z.string().openapi({ example: "Hello world" }),
  raw_text: z.string().optional(),
});

// --- Pronunciation Assessment Schemas ---

export const PronunciationAssessmentRequestSchema = z.object({
  reference_text: z
    .string()
    .openapi({ example: "The quick brown fox jumps over the lazy dog" }),
  language: z.string().optional().openapi({ example: "en-US" }),
  enable_prosody: z.boolean().optional().openapi({ example: true }),
});

export const PhonemeAssessmentSchema = z.object({
  phoneme: z.string().openapi({ example: "ð" }),
  accuracy_score: z.number().openapi({ example: 85.5 }),
  offset: z.number().optional(),
  duration: z.number().optional(),
});

export const WordAssessmentSchema = z.object({
  word: z.string().openapi({ example: "the" }),
  accuracy_score: z.number().openapi({ example: 92.3 }),
  error_type: z
    .enum(["None", "Omission", "Insertion", "Mispronunciation"])
    .openapi({ example: "None" }),
  phonemes: z.array(PhonemeAssessmentSchema),
});

export const WordFeedbackSchema = z.object({
  text: z.string().openapi({ example: "the" }),
  score: z.number().openapi({ example: 92.3 }),
  level: z
    .enum(["perfect", "warning", "error", "missing"])
    .openapi({ example: "perfect" }),
  error_type: z.string().openapi({ example: "None" }),
  phonemes: z.array(PhonemeAssessmentSchema),
});

// Smart segment for targeted practice - represents a portion of text with natural break points
export const SmartSegmentSchema = z.object({
  text: z.string().openapi({ example: "The quick brown" }),
  start_index: z.number().openapi({ example: 0 }),
  end_index: z.number().openapi({ example: 2 }),
  score: z.number().openapi({ example: 85.5 }),
  has_error: z.boolean().openapi({ example: false }),
  word_count: z.number().openapi({ example: 3 }),
});

export const PronunciationAssessmentResponseSchema = z.object({
  recognition_status: z.string().openapi({ example: "Success" }),
  display_text: z.string().openapi({ example: "The quick brown fox" }),
  pronunciation_score: z.number().openapi({ example: 87.5 }),
  accuracy_score: z.number().openapi({ example: 89.2 }),
  fluency_score: z.number().openapi({ example: 85.0 }),
  completeness_score: z.number().openapi({ example: 100.0 }),
  prosody_score: z.number().optional().openapi({ example: 82.5 }),
  words: z.array(WordAssessmentSchema),
  word_feedback: z.array(WordFeedbackSchema).optional(),
  segments: z.array(SmartSegmentSchema).openapi({
    description: "Smart segments based on natural pauses for targeted practice",
  }),
});

// --- Error Schema ---
export const ErrorSchema = z.object({
  error: z.string().optional(),
  message: z.string().optional(),
  debug_error: z.string().optional(),
  details: z.string().optional(),
});

// --- Shadowing Practice Schemas ---

// New: Upsert schema for PUT /shadowing/upsert
// - source_id is now required (no longer optional)
// - removed 'custom' source_type
// - removed audio_path (local path meaningless in cloud)
export const ShadowingUpsertSchema = z.object({
  target_text: z.string(),
  source_type: z.enum(["ai_message", "native_expression", "reference_answer"]),
  source_id: z.string(), // Required for unique key
  scene_key: z.string().nullable(),
  pronunciation_score: z.number(),
  accuracy_score: z.number().optional(),
  fluency_score: z.number().optional(),
  completeness_score: z.number().optional(),
  prosody_score: z.number().nullable().optional(),
  word_feedback: z.array(WordFeedbackSchema).optional(),
  feedback_text: z.string().optional(),
  segments: z.array(SmartSegmentSchema).optional(),
});

// Response schema for upsert operation
export const ShadowingPracticeResponseSchema = z.object({
  success: z.boolean(),
  data: z.object({
    id: z.string(),
    practiced_at: z.string(),
  }),
});

// New: Query params schema for GET /shadowing/get
export const ShadowingGetQuerySchema = z.object({
  source_type: z.enum(["ai_message", "native_expression", "reference_answer"]),
  source_id: z.string(),
});

// New: Response schema for GET /shadowing/get
// Returns single record or null (not an array)
export const ShadowingGetResponseSchema = z.object({
  success: z.boolean(),
  data: z
    .object({
      id: z.string(),
      source_type: z.string(),
      source_id: z.string(),
      target_text: z.string(),
      scene_key: z.string().nullable(),
      pronunciation_score: z.number(),
      accuracy_score: z.number().nullable(),
      fluency_score: z.number().nullable(),
      completeness_score: z.number().nullable(),
      prosody_score: z.number().nullable(),
      word_feedback: z.array(WordFeedbackSchema).nullable(),
      feedback_text: z.string().nullable(),
      segments: z.array(SmartSegmentSchema).nullable(),
      practiced_at: z.string(),
    })
    .nullable(), // Returns single record or null
});

// --- Admin Standard Scenes Schemas ---

export const StandardSceneSchema = z.object({
  id: z
    .string()
    .uuid()
    .optional()
    .openapi({ example: "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11" }),
  title: z.string().openapi({ example: "Order Coffee" }),
  description: z.string().openapi({ example: "Order a coffee at a cafe" }),
  ai_role: z.string().openapi({ example: "Barista" }),
  user_role: z.string().openapi({ example: "Customer" }),
  initial_message: z
    .string()
    .openapi({ example: "Hi! What can I get for you today?" }),
  goal: z.string().openapi({ example: "Order a coffee" }),
  emoji: z.string().default("🎭").openapi({ example: "☕" }),
  category: z.string().openapi({ example: "Daily Life" }),
  difficulty: z.enum(["Easy", "Medium", "Hard"]).openapi({ example: "Easy" }),
  icon_path: z
    .string()
    .nullable()
    .optional()
    .openapi({ example: "assets/images/scenes/coffee_3d.png" }),
  color: z.number().openapi({ example: 4292932337 }),
  target_language: z.string().default("en-US").openapi({ example: "en-US" }),
});

// Request schema for creating/updating scenes (supports batch)
export const AdminCreateScenesRequestSchema = z.object({
  scenes: z.array(StandardSceneSchema).min(1).openapi({
    description: "Array of scenes to create. At least one scene is required.",
  }),
});

// Response schema for batch create
export const AdminCreateScenesResponseSchema = z.object({
  success: z.boolean(),
  created_count: z.number().openapi({ example: 3 }),
  scenes: z.array(
    z.object({
      id: z.string().uuid(),
      title: z.string(),
    }),
  ),
});

// Response schema for list
export const AdminListScenesResponseSchema = z.object({
  success: z.boolean(),
  count: z.number(),
  scenes: z.array(
    StandardSceneSchema.extend({
      id: z.string().uuid(),
      created_at: z.string().optional(),
    }),
  ),
});

// Response schema for delete
export const AdminDeleteScenesResponseSchema = z.object({
  success: z.boolean(),
  deleted_count: z.number(),
});

// --- Delete Account Schemas ---

// Request: Empty Body (账号删除不需要请求体)
export const DeleteAccountRequestSchema = z.object({});

// Response
export const DeleteAccountResponseSchema = z.object({
  success: z.boolean(),
  message: z.string().openapi({ example: "Account permanently deleted" }),
});
