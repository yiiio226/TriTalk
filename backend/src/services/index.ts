/**
 * Services barrel export
 */

export {
  callOpenRouter,
  callOpenRouterStreaming,
  callOpenRouterMultimodal,
  type OpenRouterMessage,
} from "./openrouter";

export { createSupabaseClient, extractToken } from "./supabase";

export { authenticateUser, authMiddleware } from "./auth";

export {
  callAzureSpeechAssessment,
  processWordsForUI,
  isAzureSpeechConfigured,
  getAzureSpeechConfig,
  type PronunciationAssessmentConfig,
  type PronunciationAssessmentResult,
  type WordAssessment,
  type PhonemeAssessment,
  type WordFeedback,
} from "./azure-speech";

export {
  callGCPTTS,
  callGCPTTSStreaming,
  parseGCPTTSStreamChunk,
  buildVertexAITTSRequest,
  createWavHeader,
  isGCPTTSConfigured,
  getGCPTTSConfig,
  getGeminiVoiceFromLanguage,
  GEMINI_TTS_VOICES,
  GCP_TTS_AUDIO_FORMAT,
  type GCPTTSRequestOptions,
  type GCPVertexAIConfig,
  type GeminiTTSVoice,
} from "./gcp-tts";

export {
  handleRevenueCatWebhook,
  getUserSubscription,
  cleanupExpiredSubscriptions,
  extractBaseProductId,
  getTierFromProductId,
  getPlatformFromStore,
  PRODUCT_TO_TIER,
  type RevenueCatEventType,
  type RevenueCatWebhookEvent,
  type SubscriptionTier,
  type SubscriptionStatus,
  type SubscriptionData,
  type UserSubscription,
  type Platform,
  type EntitlementId,
  type Environment,
} from "./subscription";
