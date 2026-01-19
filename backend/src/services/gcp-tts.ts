/**
 * Google Cloud Platform Text-to-Speech via Vertex AI
 * Uses gemini-2.5-flash-tts model for high-quality TTS
 *
 * IMPORTANT: Audio Format Differences from MiniMax TTS:
 * - Gemini TTS outputs raw 16-bit PCM audio at 24kHz (no header)
 * - MiniMax TTS outputs MP3 format at 32kHz
 *
 * Documentation: https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/gemini
 */

import type { Env } from "../types";
import { getGCPAccessToken } from "../auth/gcp-auth";

/**
 * GCP TTS Audio Format Constants
 * Gemini TTS outputs raw 16-bit PCM at 24kHz
 */
export const GCP_TTS_AUDIO_FORMAT = {
  sampleRate: 24000,
  bitsPerSample: 16,
  numChannels: 1,
  mimeType: "audio/L16;rate=24000", // Raw PCM MIME type
} as const;

export interface GCPTTSRequestOptions {
  text: string;
  voiceName?: string; // e.g., "Kore", "Charon", "Fenrir", etc.
  languageCode?: string; // e.g., "en-US" (for reference, model auto-detects)
  speed?: number; // Speaking rate (if supported by model)
}

export interface GCPVertexAIConfig {
  projectId: string;
  clientEmail: string;
  privateKey: string;
  region: string;
  defaultVoiceName?: string;
}

interface VertexAITTSRequest {
  contents: Array<{
    role: string;
    parts: Array<{ text: string }>;
  }>;
  generationConfig: {
    responseModalities: string[];
    speechConfig?: {
      voiceConfig?: {
        prebuiltVoiceConfig?: {
          voiceName: string;
        };
      };
    };
  };
}

interface VertexAIStreamChunk {
  candidates?: Array<{
    content?: {
      parts?: Array<{
        inlineData?: {
          mimeType: string;
          data: string; // Base64-encoded audio chunk
        };
        text?: string;
      }>;
    };
    finishReason?: string;
  }>;
  usageMetadata?: {
    promptTokenCount?: number;
    candidatesTokenCount?: number;
    totalTokenCount?: number;
  };
  error?: {
    code: number;
    message: string;
    status: string;
  };
}

/**
 * Available voice names for gemini-2.5-flash-tts
 * Reference: https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/audio-understanding
 */
export const GEMINI_TTS_VOICES = [
  "Achernar",
  "Achird",
  "Algenib",
  "Algieba",
  "Alnilam",
  "Aoede",
  "Autonoe",
  "Callirrhoe",
  "Charon",
  "Despina",
  "Enceladus",
  "Erinome",
  "Fenrir",
  "Gacrux",
  "Iapetus",
  "Kore",
  "Laomedeia",
  "Leda",
  "Orus",
  "Pulcherrima",
  "Puck",
  "Rasalgethi",
  "Sadachbia",
  "Sadaltager",
  "Schedar",
  "Sulafat",
  "Umbriel",
  "Vindemiatrix",
  "Zephyr",
  "Zubenelgenubi",
] as const;

export type GeminiTTSVoice = (typeof GEMINI_TTS_VOICES)[number];

/**
 * Default voice mapping from language codes to Gemini TTS voices
 */
const LANGUAGE_TO_VOICE: Record<string, GeminiTTSVoice> = {
  "ar-EG": "Achernar", // Arabic (Egypt)
  "bn-BD": "Gacrux", // Bangla (Bangladesh)
  "nl-NL": "Algenib", // Dutch (Netherlands)
  "en-IN": "Kore", // English (India)
  "en-US": "Kore", // English (United States)
  "fr-FR": "Aoede", // French (France)
  "de-DE": "Orus", // German (Germany)
  "hi-IN": "Vindemiatrix", // Hindi (India)
  "id-ID": "Zephyr", // Indonesian (Indonesia)
  "it-IT": "Callirrhoe", // Italian (Italy)
  "ja-JP": "Puck", // Japanese (Japan)
  "ko-KR": "Fenrir", // Korean (South Korea)
  "mr-IN": "Leda", // Marathi (India)
  "pl-PL": "Sadachbia", // Polish (Poland)
  "pt-BR": "Despina", // Portuguese (Brazil)
  "ro-RO": "Erinome", // Romanian (Romania)
  "ru-RU": "Charon", // Russian (Russia)
  "es-ES": "Aoede", // Spanish (Spain)
  "ta-IN": "Laomedeia", // Tamil (India)
  "te-IN": "Sulafat", // Telugu (India)
  "th-TH": "Autonoe", // Thai (Thailand)
  "tr-TR": "Schedar", // Turkish (Turkey)
  "uk-UA": "Algieba", // Ukrainian (Ukraine)
  "vi-VN": "Sadaltager", // Vietnamese (Vietnam)
  "zh-CN": "Charon", // Chinese (Simplified)
  "zh-TW": "Charon", // Chinese (Traditional)
  "en-GB": "Kore", // English (UK)
  "es-MX": "Aoede", // Spanish (Mexico)
};
/**
 * Get Gemini TTS voice from language code
 */
export function getGeminiVoiceFromLanguage(language: string): GeminiTTSVoice {
  return LANGUAGE_TO_VOICE[language] || LANGUAGE_TO_VOICE["en-US"];
}

/**
 * Build the Vertex AI generateContent request body for TTS
 */
export function buildVertexAITTSRequest(
  text: string,
  voiceName?: string,
): VertexAITTSRequest {
  const request: VertexAITTSRequest = {
    contents: [
      {
        role: "user",
        parts: [{ text: `Please speak the following text naturally: ${text}` }],
      },
    ],
    generationConfig: {
      responseModalities: ["AUDIO"],
    },
  };

  // Add voice configuration if specified
  if (voiceName) {
    request.generationConfig.speechConfig = {
      voiceConfig: {
        prebuiltVoiceConfig: {
          voiceName: voiceName,
        },
      },
    };
  }

  return request;
}

/**
 * Create a WAV header for raw PCM audio data
 * Gemini TTS outputs raw 16-bit PCM at 24kHz, so we need to add a WAV header
 * for proper playback.
 *
 * @param dataLength - Length of the PCM audio data in bytes
 * @returns WAV header as Uint8Array (44 bytes)
 */
export function createWavHeader(dataLength: number): Uint8Array {
  const sampleRate = GCP_TTS_AUDIO_FORMAT.sampleRate;
  const bitsPerSample = GCP_TTS_AUDIO_FORMAT.bitsPerSample;
  const numChannels = GCP_TTS_AUDIO_FORMAT.numChannels;
  const byteRate = (sampleRate * numChannels * bitsPerSample) / 8;
  const blockAlign = (numChannels * bitsPerSample) / 8;

  const header = new ArrayBuffer(44);
  const view = new DataView(header);

  // RIFF header
  writeString(view, 0, "RIFF");
  view.setUint32(4, 36 + dataLength, true); // File size - 8
  writeString(view, 8, "WAVE");

  // fmt subchunk
  writeString(view, 12, "fmt ");
  view.setUint32(16, 16, true); // Subchunk1Size (16 for PCM)
  view.setUint16(20, 1, true); // AudioFormat (1 for PCM)
  view.setUint16(22, numChannels, true);
  view.setUint32(24, sampleRate, true);
  view.setUint32(28, byteRate, true);
  view.setUint16(32, blockAlign, true);
  view.setUint16(34, bitsPerSample, true);

  // data subchunk
  writeString(view, 36, "data");
  view.setUint32(40, dataLength, true);

  return new Uint8Array(header);
}

function writeString(view: DataView, offset: number, str: string): void {
  for (let i = 0; i < str.length; i++) {
    view.setUint8(offset + i, str.charCodeAt(i));
  }
}

/**
 * Call Vertex AI gemini-2.5-flash-tts for Text-to-Speech (Streaming)
 * Returns the raw Response object for stream processing.
 *
 * IMPORTANT: Gemini TTS outputs raw 16-bit PCM audio at 24kHz
 * The response contains base64-encoded PCM chunks that need to be:
 * 1. Decoded from base64
 * 2. Concatenated
 * 3. Wrapped with a WAV header for playback (use createWavHeader)
 *
 * @param config - GCP Vertex AI configuration
 * @param options - TTS request options
 * @returns Response object for streaming
 */
export async function callGCPTTSStreaming(
  config: GCPVertexAIConfig,
  options: GCPTTSRequestOptions,
): Promise<Response> {
  const startTime = Date.now();
  console.log("[GCP TTS Streaming] Starting streaming TTS request", {
    textLength: options.text.length,
    textPreview:
      options.text.substring(0, 100) + (options.text.length > 100 ? "..." : ""),
    voiceName: options.voiceName,
    languageCode: options.languageCode,
    region: config.region,
    projectId: config.projectId,
  });

  // Get access token using service account credentials
  console.log("[GCP TTS Streaming] Fetching GCP access token...");
  const tokenStartTime = Date.now();
  const accessToken = await getGCPAccessToken(
    config.clientEmail,
    config.privateKey,
    "https://www.googleapis.com/auth/cloud-platform",
  );
  console.log(
    `[GCP TTS Streaming] Access token obtained in ${Date.now() - tokenStartTime}ms`,
  );

  // Determine voice name
  const voiceName =
    options.voiceName ||
    config.defaultVoiceName ||
    (options.languageCode
      ? getGeminiVoiceFromLanguage(options.languageCode)
      : "Kore");
  console.log(`[GCP TTS Streaming] Using voice: ${voiceName}`);

  // Build request
  const requestBody = buildVertexAITTSRequest(options.text, voiceName);
  console.log(
    "[GCP TTS Streaming] Request body:",
    JSON.stringify(requestBody, null, 2),
  );

  // Vertex AI streaming endpoint for gemini-2.5-flash-tts
  // Using streamGenerateContent for real-time audio streaming
  const endpoint = `https://${config.region}-aiplatform.googleapis.com/v1beta1/projects/${config.projectId}/locations/${config.region}/publishers/google/models/gemini-2.5-flash-preview-tts:streamGenerateContent?alt=sse`;
  console.log(`[GCP TTS Streaming] Calling Vertex AI endpoint: ${endpoint}`);

  const apiStartTime = Date.now();
  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(requestBody),
  });
  console.log(
    `[GCP TTS Streaming] Vertex AI API responded in ${Date.now() - apiStartTime}ms with status ${response.status}`,
  );

  if (!response.ok) {
    const errorText = await response.text();
    console.error("[GCP TTS Streaming] API error response:", {
      status: response.status,
      statusText: response.statusText,
      errorBody: errorText,
    });
    throw new Error(
      `Vertex AI TTS Streaming error: ${response.status} ${response.statusText} - ${errorText}`,
    );
  }

  console.log("[GCP TTS Streaming] Stream started successfully", {
    totalSetupTimeMs: Date.now() - startTime,
    contentType: response.headers.get("content-type"),
  });

  return response;
}

/**
 * Call Vertex AI gemini-2.5-flash-tts for Text-to-Speech (Non-Streaming)
 * Returns audio data as base64 string with WAV format.
 *
 * Use this for short text like single words where streaming is not needed.
 *
 * @param config - GCP Vertex AI configuration
 * @param options - TTS request options
 * @returns Object containing base64-encoded WAV audio and MIME type
 */
export async function callGCPTTS(
  config: GCPVertexAIConfig,
  options: GCPTTSRequestOptions,
): Promise<{ audioBase64: string; mimeType: string }> {
  const startTime = Date.now();
  console.log("[GCP TTS] Starting non-streaming TTS request", {
    textLength: options.text.length,
    textPreview:
      options.text.substring(0, 100) + (options.text.length > 100 ? "..." : ""),
    voiceName: options.voiceName,
    languageCode: options.languageCode,
    region: config.region,
    projectId: config.projectId,
  });

  // Get access token using service account credentials
  console.log("[GCP TTS] Fetching GCP access token...");
  const tokenStartTime = Date.now();
  const accessToken = await getGCPAccessToken(
    config.clientEmail,
    config.privateKey,
    "https://www.googleapis.com/auth/cloud-platform",
  );
  console.log(
    `[GCP TTS] Access token obtained in ${Date.now() - tokenStartTime}ms`,
  );

  // Determine voice name
  const voiceName =
    options.voiceName ||
    config.defaultVoiceName ||
    (options.languageCode
      ? getGeminiVoiceFromLanguage(options.languageCode)
      : "Kore");
  console.log(`[GCP TTS] Using voice: ${voiceName}`);

  // Build request
  const requestBody = buildVertexAITTSRequest(options.text, voiceName);
  console.log("[GCP TTS] Request body:", JSON.stringify(requestBody, null, 2));

  // Vertex AI endpoint for gemini-2.5-flash-tts (non-streaming)
  const endpoint = `https://${config.region}-aiplatform.googleapis.com/v1beta1/projects/${config.projectId}/locations/${config.region}/publishers/google/models/gemini-2.5-flash-preview-tts:generateContent`;
  console.log(`[GCP TTS] Calling Vertex AI endpoint: ${endpoint}`);

  const apiStartTime = Date.now();
  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(requestBody),
  });
  console.log(
    `[GCP TTS] Vertex AI API responded in ${Date.now() - apiStartTime}ms with status ${response.status}`,
  );

  if (!response.ok) {
    const errorText = await response.text();
    console.error("[GCP TTS] API error response:", {
      status: response.status,
      statusText: response.statusText,
      errorBody: errorText,
    });
    throw new Error(
      `Vertex AI TTS error: ${response.status} ${response.statusText} - ${errorText}`,
    );
  }

  const data = (await response.json()) as VertexAIStreamChunk;
  console.log("[GCP TTS] Response structure:", {
    hasCandidates: !!data.candidates,
    candidatesCount: data.candidates?.length,
    hasError: !!data.error,
  });

  // Check for API error in response
  if (data.error) {
    console.error("[GCP TTS] API error in response:", data.error);
    throw new Error(
      `Vertex AI TTS API error: ${data.error.code} ${data.error.status} - ${data.error.message}`,
    );
  }

  // Extract audio from response
  const audioData = data.candidates?.[0]?.content?.parts?.find(
    (part) => part.inlineData?.data,
  )?.inlineData;

  if (!audioData?.data) {
    console.error("[GCP TTS] No audio content found in response", {
      candidates: data.candidates,
      rawResponse: JSON.stringify(data).substring(0, 500),
    });
    throw new Error("No audio content in Vertex AI TTS response");
  }

  // Decode the raw PCM audio from base64
  const pcmBase64 = audioData.data;
  const pcmBinary = atob(pcmBase64);
  const pcmBytes = new Uint8Array(pcmBinary.length);
  for (let i = 0; i < pcmBinary.length; i++) {
    pcmBytes[i] = pcmBinary.charCodeAt(i);
  }

  console.log("[GCP TTS] PCM audio data:", {
    originalMimeType: audioData.mimeType,
    pcmSizeBytes: pcmBytes.length,
  });

  // Create WAV with header for proper playback
  const wavHeader = createWavHeader(pcmBytes.length);
  const wavData = new Uint8Array(wavHeader.length + pcmBytes.length);
  wavData.set(wavHeader, 0);
  wavData.set(pcmBytes, wavHeader.length);

  // Convert WAV to base64
  let wavBinary = "";
  wavData.forEach((byte) => {
    wavBinary += String.fromCharCode(byte);
  });
  const wavBase64 = btoa(wavBinary);

  const totalTime = Date.now() - startTime;
  console.log("[GCP TTS] TTS request completed successfully", {
    originalFormat: audioData.mimeType,
    outputFormat: "audio/wav",
    wavSizeBytes: wavData.length,
    totalTimeMs: totalTime,
  });

  return {
    audioBase64: wavBase64,
    mimeType: "audio/wav",
  };
}

/**
 * Parse a streaming response chunk from Vertex AI
 * Returns audio data if present in the chunk
 */
export function parseGCPTTSStreamChunk(jsonStr: string): {
  audioBase64?: string;
  mimeType?: string;
  isComplete: boolean;
  error?: string;
} {
  try {
    const chunk = JSON.parse(jsonStr) as VertexAIStreamChunk;

    if (chunk.error) {
      console.error("[GCP TTS] Stream chunk error:", chunk.error);
      return {
        isComplete: true,
        error: `${chunk.error.code} ${chunk.error.status}: ${chunk.error.message}`,
      };
    }

    const audioData = chunk.candidates?.[0]?.content?.parts?.find(
      (part) => part.inlineData?.data,
    )?.inlineData;

    const isComplete = chunk.candidates?.[0]?.finishReason === "STOP";

    if (audioData?.data) {
      console.log("[GCP TTS] Stream chunk received:", {
        mimeType: audioData.mimeType,
        dataLength: audioData.data.length,
        isComplete,
      });
      return {
        audioBase64: audioData.data,
        mimeType: audioData.mimeType || GCP_TTS_AUDIO_FORMAT.mimeType,
        isComplete,
      };
    }

    return { isComplete };
  } catch (e) {
    console.error(
      "[GCP TTS] Failed to parse stream chunk:",
      e,
      jsonStr.substring(0, 200),
    );
    return { isComplete: false };
  }
}

/**
 * Check if GCP Vertex AI TTS is configured in the environment
 */
export function isGCPTTSConfigured(env: Env): boolean {
  const isConfigured = Boolean(
    env.GCP_PROJECT_ID &&
    env.GCP_CLIENT_EMAIL &&
    env.GCP_PRIVATE_KEY &&
    env.GCP_REGION,
  );
  console.log("[GCP TTS] Configuration check:", {
    isConfigured,
    hasProjectId: !!env.GCP_PROJECT_ID,
    hasClientEmail: !!env.GCP_CLIENT_EMAIL,
    hasPrivateKey: !!env.GCP_PRIVATE_KEY,
    hasRegion: !!env.GCP_REGION,
  });
  return isConfigured;
}

/**
 * Get GCP Vertex AI TTS config from environment
 * Should only be called after isGCPTTSConfigured returns true
 */
export function getGCPTTSConfig(env: Env): GCPVertexAIConfig {
  return {
    projectId: env.GCP_PROJECT_ID!,
    clientEmail: env.GCP_CLIENT_EMAIL!,
    privateKey: env.GCP_PRIVATE_KEY!,
    region: env.GCP_REGION || "us-central1",
    defaultVoiceName: env.GCP_TTS_DEFAULT_VOICE_NAME,
  };
}
