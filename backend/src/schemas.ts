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

export const ShadowingPracticeSaveSchema = z.object({
  target_text: z.string(),
  source_type: z.enum([
    "ai_message",
    "native_expression",
    "reference_answer",
    "custom",
  ]),
  source_id: z.string().optional(),
  scene_key: z.string().nullable(),
  pronunciation_score: z.number(),
  accuracy_score: z.number().optional(),
  fluency_score: z.number().optional(),
  completeness_score: z.number().optional(),
  prosody_score: z.number().optional(),
  word_feedback: z.array(WordFeedbackSchema).optional(),
  feedback_text: z.string().optional(),
  audio_path: z.string().optional(),
  // Smart segments based on natural pauses (optional for backward compatibility)
  segments: z.array(SmartSegmentSchema).optional(),
});

export const ShadowingPracticeResponseSchema = z.object({
  success: z.boolean(),
  data: z.object({
    id: z.string(),
    practiced_at: z.string(),
  }),
});

export const ShadowingHistoryResponseSchema = z.object({
  success: z.boolean(),
  data: z.object({
    practices: z.array(
      z.object({
        id: z.string(),
        target_text: z.string(),
        source_type: z.string(),
        source_id: z.string().nullable(),
        pronunciation_score: z.number(),
        accuracy_score: z.number().nullable(),
        fluency_score: z.number().nullable(),
        completeness_score: z.number().nullable(),
        prosody_score: z.number().nullable(),
        word_feedback: z.array(WordFeedbackSchema).nullable(),
        feedback_text: z.string().nullable(),
        audio_path: z.string().nullable(),
        segments: z.array(SmartSegmentSchema).nullable(), // Smart segments (null for historical data)
        practiced_at: z.string(),
      }),
    ),
    total: z.number(),
  }),
});
