/**
 * MiniMax TTS API client
 */

import type { Env } from "../types";

// ... (imports remain the same)

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
  defaultVoiceId?: string;
}

/**
 * Build TTS request body for MiniMax API.
 */
export function buildTTSRequestBody(
  options: TTSRequestOptions,
  defaultVoiceId: string = "English_Trustworthy_Man"
) {
  if (options.text.length > 2000) {
    throw new Error("TTS text exceeds 2000 characters");
  }

  return {
    model: "speech-2.6-turbo",
    text: options.text,
    stream: true,
    stream_options: {
      exclude_aggregated_audio: true,
    },
    voice_setting: {
      voice_id: options.voiceId || defaultVoiceId,
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
  const requestBody = buildTTSRequestBody(options, config.defaultVoiceId);

  const response = await fetch(apiUrl, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${config.apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(requestBody),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(
      `MiniMax API error: ${response.status} ${response.statusText} - ${errorText}`
    );
  }

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
    defaultVoiceId: env.MINIMAX_DEFAULT_VOICE_ID,
  };
}

/**
 * Build non-streaming TTS request body for MiniMax API.
 * Used for short text like single words.
 */
export function buildTTSRequestBodyNonStreaming(
  options: TTSRequestOptions,
  defaultVoiceId: string = "English_Trustworthy_Man"
) {
  if (options.text.length > 2000) {
    throw new Error("TTS text exceeds 2000 characters");
  }

  return {
    model: "speech-2.6-turbo",
    text: options.text,
    stream: false,
    voice_setting: {
      voice_id: options.voiceId || defaultVoiceId,
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
 * Call MiniMax TTS API in non-streaming mode.
 * Returns audio data as base64 string.
 */
export async function callMiniMaxTTSNonStreaming(
  config: TTSConfig,
  options: TTSRequestOptions
): Promise<{ audioBase64: string; durationMs?: number }> {
  const apiUrl = `https://api.minimax.chat/v1/t2a_v2?GroupId=${config.groupId}`;
  const requestBody = buildTTSRequestBodyNonStreaming(
    options,
    config.defaultVoiceId
  );

  const response = await fetch(apiUrl, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${config.apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(requestBody),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(
      `MiniMax API error: ${response.status} ${response.statusText} - ${errorText}`
    );
  }

  const data = (await response.json()) as {
    base_resp?: { status_code: number; status_msg: string };
    data?: { audio: string };
    extra_info?: { audio_length: number };
  };

  // Check for API error in response
  if (data.base_resp && data.base_resp.status_code !== 0) {
    throw new Error(`MiniMax TTS error: ${data.base_resp.status_msg}`);
  }

  // Get audio data (hex encoded)
  const audioHex = data.data?.audio;
  if (!audioHex) {
    throw new Error("No audio data in MiniMax response");
  }

  // Convert hex to base64
  const audioBase64 = hexToBase64(audioHex);

  return {
    audioBase64,
    durationMs: data.extra_info?.audio_length,
  };
}

/**
 * Convert hex string to base64.
 */
function hexToBase64(hexString: string): string {
  const bytes = new Uint8Array(
    hexString.match(/.{1,2}/g)!.map((byte) => parseInt(byte, 16))
  );
  let binary = "";
  bytes.forEach((byte) => {
    binary += String.fromCharCode(byte);
  });
  return btoa(binary);
}
