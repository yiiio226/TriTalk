/**
 * Azure AI Speech Pronunciation Assessment API client
 *
 * This service integrates with Azure Cognitive Services Speech API
 * for pronunciation assessment with phoneme-level analysis.
 *
 * @see https://learn.microsoft.com/en-us/azure/ai-services/speech-service/rest-speech-to-text-short
 */

// Configuration for pronunciation assessment
export interface PronunciationAssessmentConfig {
  referenceText: string;
  gradingSystem: "HundredMark" | "FivePoint";
  granularity: "Phoneme" | "Word" | "FullText";
  phonemeAlphabet: "IPA" | "SAPI";
  enableProsodyAssessment: boolean;
}

// Phoneme-level assessment result
export interface PhonemeAssessment {
  phoneme: string;
  accuracyScore: number;
  offset: number;
  duration: number;
}

// Word-level assessment result
export interface WordAssessment {
  word: string;
  offset: number;
  duration: number;
  accuracyScore: number;
  errorType: "None" | "Omission" | "Insertion" | "Mispronunciation";
  phonemes: PhonemeAssessment[];
}

// Prosody (intonation/rhythm) assessment result
export interface ProsodyAssessment {
  prosodyScore: number;
}

// Overall pronunciation assessment result
export interface PronunciationAssessmentResult {
  recognitionStatus: string;
  displayText: string;
  pronunciationScore: number;
  accuracyScore: number;
  fluencyScore: number;
  completenessScore: number;
  prosodyScore?: number;
  words: WordAssessment[];
}

/**
 * Check if Azure Speech is configured
 */
export function isAzureSpeechConfigured(
  azureKey?: string,
  azureRegion?: string
): boolean {
  return Boolean(azureKey && azureRegion);
}

/**
 * Get Azure Speech configuration
 */
export function getAzureSpeechConfig(
  azureKey?: string,
  azureRegion?: string,
  language?: string
): { key: string; region: string; language: string } | null {
  if (!isAzureSpeechConfigured(azureKey, azureRegion)) {
    return null;
  }
  return {
    key: azureKey!,
    region: azureRegion!,
    language: language || "en-US",
  };
}

/**
 * Build the pronunciation assessment configuration header
 */
function buildPronunciationAssessmentHeader(
  config: PronunciationAssessmentConfig
): string {
  // IMPORTANT: Azure expects string values "True"/"False" for boolean parameters
  // Using JavaScript boolean values (true/false) will cause the assessment to fail
  // with all scores returning 0.
  // See: https://learn.microsoft.com/en-us/azure/ai-services/speech-service/rest-speech-to-text-short
  const assessmentConfig = {
    ReferenceText: config.referenceText,
    GradingSystem: config.gradingSystem,
    Granularity: config.granularity,
    Dimension: "Comprehensive",
    // Azure requires string "True" or "False", not boolean true/false
    EnableMiscue: "False",
    EnableProsodyAssessment: config.enableProsodyAssessment ? "True" : "False",
    // PhonemeAlphabet is optional - only add if using Phoneme granularity
    ...(config.granularity === "Phoneme" && {
      PhonemeAlphabet: config.phonemeAlphabet,
    }),
  };

  // Base64 encode the JSON config (Unicode-safe)
  // btoa() only handles Latin1, so we need to encode UTF-8 first
  const jsonString = JSON.stringify(assessmentConfig);
  console.log(`[Azure Speech] Assessment Config JSON: ${jsonString}`);

  const bytes = new TextEncoder().encode(jsonString);
  const binaryString = Array.from(bytes, (byte) =>
    String.fromCharCode(byte)
  ).join("");
  return btoa(binaryString);
}

/**
 * Transform Azure API response to our structured format
 */
function transformAssessmentResult(
  azureResponse: any
): PronunciationAssessmentResult {
  const nBest = azureResponse.NBest?.[0];
  if (!nBest) {
    throw new Error("No recognition results found in Azure response");
  }

  const assessment = nBest.PronunciationAssessment;
  const words: WordAssessment[] = (nBest.Words || []).map((word: any) => ({
    word: word.Word,
    offset: word.Offset || 0,
    duration: word.Duration || 0,
    accuracyScore: word.PronunciationAssessment?.AccuracyScore || 0,
    errorType: word.PronunciationAssessment?.ErrorType || "None",
    phonemes: (word.Phonemes || []).map((phoneme: any) => ({
      phoneme: phoneme.Phoneme,
      accuracyScore: phoneme.PronunciationAssessment?.AccuracyScore || 0,
      offset: phoneme.Offset || 0,
      duration: phoneme.Duration || 0,
    })),
  }));

  return {
    recognitionStatus: azureResponse.RecognitionStatus,
    displayText: azureResponse.DisplayText || nBest.Display || "",
    pronunciationScore: assessment?.PronScore || 0,
    accuracyScore: assessment?.AccuracyScore || 0,
    fluencyScore: assessment?.FluencyScore || 0,
    completenessScore: assessment?.CompletenessScore || 0,
    prosodyScore: assessment?.ProsodyScore,
    words,
  };
}

/**
 * Parse WAV header to extract audio format information
 */
function parseWavHeader(audioData: ArrayBuffer): {
  sampleRate: number;
  bitsPerSample: number;
  numChannels: number;
  isValid: boolean;
} {
  const view = new DataView(audioData);

  // Check RIFF header
  const riff = String.fromCharCode(
    view.getUint8(0),
    view.getUint8(1),
    view.getUint8(2),
    view.getUint8(3)
  );
  const wave = String.fromCharCode(
    view.getUint8(8),
    view.getUint8(9),
    view.getUint8(10),
    view.getUint8(11)
  );

  if (riff !== "RIFF" || wave !== "WAVE") {
    return {
      sampleRate: 16000,
      bitsPerSample: 16,
      numChannels: 1,
      isValid: false,
    };
  }

  // Parse fmt chunk - search for "fmt " marker
  let offset = 12;
  while (offset < Math.min(audioData.byteLength, 100)) {
    const chunkId = String.fromCharCode(
      view.getUint8(offset),
      view.getUint8(offset + 1),
      view.getUint8(offset + 2),
      view.getUint8(offset + 3)
    );
    const chunkSize = view.getUint32(offset + 4, true);

    if (chunkId === "fmt ") {
      const numChannels = view.getUint16(offset + 10, true);
      const sampleRate = view.getUint32(offset + 12, true);
      const bitsPerSample = view.getUint16(offset + 22, true);

      return { sampleRate, bitsPerSample, numChannels, isValid: true };
    }

    offset += 8 + chunkSize;
  }

  return {
    sampleRate: 16000,
    bitsPerSample: 16,
    numChannels: 1,
    isValid: false,
  };
}

/**
 * Call Azure Speech Pronunciation Assessment API
 *
 * @param azureKey - Azure Cognitive Services subscription key
 * @param azureRegion - Azure region (e.g., "eastus", "westus2")
 * @param audioData - Audio data as ArrayBuffer (PCM 16bit, 16kHz, Mono recommended)
 * @param referenceText - The expected text the user should say
 * @param language - Recognition language (default: "en-US")
 * @param enableProsody - Enable prosody (intonation) assessment (default: true)
 * @returns Pronunciation assessment result with phoneme-level details
 */
export async function callAzureSpeechAssessment(
  azureKey: string,
  azureRegion: string,
  audioData: ArrayBuffer,
  referenceText: string,
  language: string = "en-US",
  enableProsody: boolean = true
): Promise<PronunciationAssessmentResult> {
  // Parse WAV header to get actual audio format
  const wavInfo = parseWavHeader(audioData);
  console.log(
    `[Azure Speech] WAV Info: sampleRate=${wavInfo.sampleRate}, bits=${wavInfo.bitsPerSample}, channels=${wavInfo.numChannels}, valid=${wavInfo.isValid}`
  );

  // IMPORTANT: Azure Pronunciation Assessment requires 16kHz audio
  // If the audio is not 16kHz, the assessment scores will be 0
  if (wavInfo.isValid && wavInfo.sampleRate !== 16000) {
    console.warn(
      `[Azure Speech] ⚠️ WARNING: Audio sample rate is ${wavInfo.sampleRate}Hz, but Azure requires 16000Hz for pronunciation assessment!`
    );
    console.warn(
      `[Azure Speech] This may cause all pronunciation scores to be 0.`
    );
  }

  // Build pronunciation assessment config
  const assessmentConfig: PronunciationAssessmentConfig = {
    referenceText,
    gradingSystem: "HundredMark",
    granularity: "Phoneme",
    phonemeAlphabet: "IPA",
    enableProsodyAssessment: enableProsody,
  };

  const configHeader = buildPronunciationAssessmentHeader(assessmentConfig);
  console.log(
    `[Azure Speech] Assessment Config (decoded): ${JSON.stringify({
      referenceText:
        referenceText.substring(0, 50) +
        (referenceText.length > 50 ? "..." : ""),
      gradingSystem: "HundredMark",
      granularity: "Phoneme",
      enableProsody,
    })}`
  );

  // Construct the Azure Speech API URL
  const endpoint = `https://${azureRegion}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1`;
  const url = new URL(endpoint);
  url.searchParams.set("language", language);
  url.searchParams.set("format", "detailed");

  // Use the actual sample rate from the WAV header in Content-Type
  const actualSampleRate = wavInfo.isValid ? wavInfo.sampleRate : 16000;
  const contentType = `audio/wav; codecs=audio/pcm; samplerate=${actualSampleRate}`;
  console.log(`[Azure Speech] Using Content-Type: ${contentType}`);

  // Make the API request
  const response = await fetch(url.toString(), {
    method: "POST",
    headers: {
      "Ocp-Apim-Subscription-Key": azureKey,
      "Content-Type": contentType,
      "Pronunciation-Assessment": configHeader,
      Accept: "application/json",
    },
    body: audioData,
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error("Azure Speech API error:", errorText);
    throw new Error(
      `Azure Speech API error: ${response.status} ${response.statusText} - ${errorText}`
    );
  }

  const result = (await response.json()) as {
    RecognitionStatus: string;
    DisplayText?: string;
    NBest?: any[];
  };

  // Debug logging - log the raw Azure response
  console.log("[Azure Speech] Raw response:", JSON.stringify(result, null, 2));
  console.log("[Azure Speech] RecognitionStatus:", result.RecognitionStatus);
  console.log("[Azure Speech] DisplayText:", result.DisplayText);
  if (result.NBest?.[0]) {
    const nBest = result.NBest[0];
    console.log("[Azure Speech] NBest[0].Display:", nBest.Display);
    console.log(
      "[Azure Speech] NBest[0].PronunciationAssessment:",
      JSON.stringify(nBest.PronunciationAssessment)
    );
    console.log(
      "[Azure Speech] NBest[0].Words count:",
      nBest.Words?.length || 0
    );
    if (nBest.Words?.[0]) {
      console.log(
        "[Azure Speech] First word sample:",
        JSON.stringify(nBest.Words[0])
      );
    }
  }

  // Check recognition status
  if (result.RecognitionStatus !== "Success") {
    throw new Error(
      `Azure Speech recognition failed: ${result.RecognitionStatus}`
    );
  }

  return transformAssessmentResult(result);
}

/**
 * Process word results for UI display (Traffic Light system)
 */
export interface WordFeedback {
  text: string;
  score: number;
  level: "perfect" | "warning" | "error" | "missing";
  errorType: string;
  phonemes: PhonemeAssessment[];
}

export function processWordsForUI(words: WordAssessment[]): WordFeedback[] {
  return words.map((word) => {
    let level: WordFeedback["level"];

    if (word.errorType === "Omission") {
      level = "missing";
    } else if (word.accuracyScore > 80) {
      level = "perfect";
    } else if (word.accuracyScore >= 60) {
      level = "warning";
    } else {
      level = "error";
    }

    return {
      text: word.word,
      score: word.accuracyScore,
      level,
      errorType: word.errorType,
      phonemes: word.phonemes,
    };
  });
}
