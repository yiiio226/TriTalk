// Type definitions for API requests and responses

export interface ChatRequest {
  message: string;
  history?: Array<{ role: string; content: string }>;
  scene_context: string;
  native_language?: string;
  target_language?: string;
}

export interface ReviewFeedback {
  is_perfect: boolean;
  corrected_text: string;
  native_expression: string;
  explanation: string;
  example_answer: string;
}

export interface ChatResponse {
  message: string;
  translation?: string;
  review_feedback?: ReviewFeedback;
}

export interface HintRequest {
  message?: string;
  history?: Array<{ role: string; content: string }>;
  scene_context: string;
  target_language?: string;
}

export interface HintResponse {
  hints: string[];
}

export interface SceneGenerationRequest {
  description: string;
  tone?: string;
}

export interface GrammarPoint {
  structure: string;
  explanation: string;
  example: string;
}

export interface VocabularyItem {
  word: string;
  definition: string;
  example: string;
  level?: string;
  part_of_speech?: string;
}

export interface AnalyzeRequest {
  message: string;
  native_language?: string;
}

export interface AnalyzeResponse {
  grammar_points: GrammarPoint[];
  vocabulary: VocabularyItem[];
  sentence_structure: string;
  sentence_breakdown?: Array<{ text: string; tag: string }>; // For visualization
  overall_summary: string;
  // L-02 Context & Emotion
  pragmatic_analysis?: string; // "Why" they said it (e.g. "To be polite request")
  emotion_tags?: string[]; // ["Polite", "Formal", "Sarcastic"]
  // L-02 Idioms
  idioms_slang?: Array<{
    text: string;
    explanation: string;
    type: "Idiom" | "Slang" | "Common Phrase";
  }>;
}

// L-03 Shadowing
export interface ShadowRequest {
  target_text: string;
  user_audio_text: string; // Simulated for now (STT result)
  // In future: user_audio_base64: string;
}

export interface ShadowResponse {
  score: number; // 0-100
  details: {
    intonation_score: number;
    pronunciation_score: number;
    feedback: string; // Specific advice
  };
}

export interface SceneGenerationResponse {
  title: string;
  ai_role: string;
  user_role: string;
  goal: string;
  description: string;
  initial_message: string;
  emoji: string;
}

export interface Env {
  OPENROUTER_API_KEY: string;
  OPENROUTER_CHAT_MODEL: string; // Model for chat, hint, analyze, etc.
  OPENROUTER_TRANSCRIBE_MODEL: string; // Model for audio transcription (multimodal)
  // Removed TRITALK_API_KEY as we are moving to Supabase Auth
  // TRITALK_API_KEY: string;
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
  // Service role key for backend operations (bypasses RLS)
  SUPABASE_SERVICE_ROLE_KEY?: string;
  // Database schema (default: public, dev: tritalk_schema)
  SUPABASE_SCHEMA?: string;

  // Azure Speech API credentials for Pronunciation Assessment
  AZURE_SPEECH_KEY?: string;
  AZURE_SPEECH_REGION?: string;
  // GCP Vertex AI TTS credentials (Service Account)
  GCP_PROJECT_ID?: string;
  GCP_CLIENT_EMAIL?: string;
  GCP_PRIVATE_KEY?: string;
  GCP_REGION?: string;
  GCP_TTS_DEFAULT_VOICE_NAME?: string;

  // RevenueCat Webhook
  REVENUECAT_WEBHOOK_SECRET?: string;

  // Admin API Key for protected admin endpoints
  ADMIN_API_KEY?: string;
}

export interface PolishRequest {
  description: string;
}

export interface PolishResponse {
  polished_text: string;
}

export interface TranslateRequest {
  text: string;
  target_language: string;
}

export interface TranslateResponse {
  translation: string;
}

export interface OptimizeRequest {
  message: string;
  scene_context: string;
  history?: Array<{ role: string; content: string }>;
  target_language?: string;
}

export interface OptimizeResponse {
  optimized_text: string;
}

// TTS (Text-to-Speech) Types
export interface TTSRequest {
  text: string;
  message_id?: string; // Optional: for caching purposes
  voice_id?: string; // Optional: specific voice to use
}

export interface TTSResponse {
  audio_url?: string; // URL to the audio file (if using R2 storage)
  audio_base64?: string; // Base64 encoded audio data
  duration_ms?: number; // Audio duration in milliseconds
  error?: string;
}

// Smart Voice Input (Transcribe + Optimize) Types
// Uses Gemini 2.0 Flash Lite multimodal for direct audio-to-text transcription and optimization
export interface TranscribeResponse {
  text: string; // The optimized/refined transcription
  raw_text?: string; // The original transcription
}

// Pronunciation Assessment Types (Azure Speech)
export interface PronunciationAssessmentRequest {
  reference_text: string; // The expected text user should say
  language?: string; // Language code (e.g., "en-US")
  enable_prosody?: boolean; // Enable prosody/intonation assessment
}

export interface PhonemeResult {
  phoneme: string; // IPA phoneme symbol
  accuracy_score: number; // 0-100 accuracy score
  offset?: number;
  duration?: number;
}

export interface WordResult {
  word: string;
  accuracy_score: number;
  error_type: "None" | "Omission" | "Insertion" | "Mispronunciation";
  phonemes: PhonemeResult[];
}

export interface WordFeedback {
  text: string;
  score: number;
  level: "perfect" | "warning" | "error" | "missing"; // Traffic light system
  error_type: string;
  phonemes: PhonemeResult[];
}

export interface PronunciationAssessmentResponse {
  recognition_status: string;
  display_text: string;
  pronunciation_score: number; // Overall score (0-100)
  accuracy_score: number;
  fluency_score: number;
  completeness_score: number;
  prosody_score?: number; // Only if enableProsody is true
  words: WordResult[];
  word_feedback?: WordFeedback[]; // UI-ready word feedback
}
