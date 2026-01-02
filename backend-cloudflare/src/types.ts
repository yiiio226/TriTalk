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
  OPENROUTER_MODEL: string;
  // TTS - MiniMax API
  MINIMAX_API_KEY: string;
  MINIMAX_GROUP_ID: string;
  // R2 Storage for audio files
  AUDIO_BUCKET: R2Bucket;
  // R2 Public URL for serving audio (optional, defaults to placeholder)
  R2_PUBLIC_DOMAIN?: string;
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

// ========== TTS Types ==========

export interface TTSRequest {
  message_id: string; // Unique ID for caching
  text: string; // Text to synthesize
  voice_id?: string; // MiniMax voice ID (optional, defaults to "female-tianmei")
}

export interface TTSResponse {
  audio_url: string; // R2 public URL or signed URL
  cached: boolean; // Whether the audio was served from cache
}

export interface MiniMaxTTSResponse {
  audio_file: string; // Base64 encoded audio
  subtitle_file?: string;
  extra_info?: {
    audio_length: number;
    audio_sample_rate: number;
    audio_size: number;
    bitrate: number;
    word_count: number;
    invisible_character_ratio: number;
    usage_characters: number;
  };
  base_resp?: {
    status_code: number;
    status_msg: string;
  };
}
