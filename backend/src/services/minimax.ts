/**
 * MiniMax TTS API client
 */

import type { Env } from "../types";

export interface TTSRequestOptions {
  text: string;
  voiceId?: string;
  speed?: number;
  vol?: number;
  pitch?: number;
}

export interface TTSConfig {
  apiKey: string;
  groupId: string;
}

/**
 * Build TTS request body for MiniMax API.
 */
export function buildTTSRequestBody(options: TTSRequestOptions) {
  return {
    model: "speech-2.6-turbo",
    text: options.text.slice(0, 2000), // Max 2000 chars
    stream: true,
    stream_options: {
      exclude_aggregated_audio: true,
    },
    voice_setting: {
      voice_id: options.voiceId || "English_Trustworthy_Man",
      speed: options.speed || 1.0,
      vol: options.vol || 1.0,
      pitch: options.pitch || 0,
    },
    audio_setting: {
      sample_rate: 32000,
      bitrate: 128000,
      format: "mp3",
      channel: 1,
    },
  };
}

/**
 * Call MiniMax TTS API.
 * Returns the raw Response object for stream processing.
 */
export async function callMiniMaxTTS(
  config: TTSConfig,
  options: TTSRequestOptions
): Promise<Response> {
  const apiUrl = `https://api.minimax.chat/v1/t2a_v2?GroupId=${config.groupId}`;
  const requestBody = buildTTSRequestBody(options);

  const response = await fetch(apiUrl, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${config.apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(requestBody),
  });

  return response;
}

/**
 * Check if MiniMax TTS is configured in the environment.
 */
export function isTTSConfigured(env: Env): boolean {
  return Boolean(env.MINIMAX_API_KEY && env.MINIMAX_GROUP_ID);
}

/**
 * Get TTS config from environment.
 * Should only be called after isTTSConfigured returns true.
 */
export function getTTSConfig(env: Env): TTSConfig {
  return {
    apiKey: env.MINIMAX_API_KEY!,
    groupId: env.MINIMAX_GROUP_ID!,
  };
}
