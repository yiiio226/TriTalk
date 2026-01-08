/**
 * Services barrel export
 */

export {
  callOpenRouter,
  callOpenRouterStreaming,
  callOpenRouterMultimodal,
  type OpenRouterMessage,
} from "./openrouter";

export {
  callMiniMaxTTS,
  buildTTSRequestBody,
  isTTSConfigured,
  getTTSConfig,
  type TTSRequestOptions,
  type TTSConfig,
} from "./minimax";

export { createSupabaseClient, extractToken } from "./supabase";

export { authenticateUser, authMiddleware } from "./auth";
