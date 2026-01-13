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
  const assessmentConfig = {
    ReferenceText: config.referenceText,
    GradingSystem: config.gradingSystem,
    Granularity: config.granularity,
    PhonemeAlphabet: config.phonemeAlphabet,
    EnableProsodyAssessment: config.enableProsodyAssessment,
    Dimension: "Comprehensive",
  };

  // Base64 encode the JSON config
  const jsonString = JSON.stringify(assessmentConfig);
  return btoa(jsonString);
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
  // Build pronunciation assessment config
  const assessmentConfig: PronunciationAssessmentConfig = {
    referenceText,
    gradingSystem: "HundredMark",
    granularity: "Phoneme",
    phonemeAlphabet: "IPA",
    enableProsodyAssessment: enableProsody,
  };

  const configHeader = buildPronunciationAssessmentHeader(assessmentConfig);

  // Construct the Azure Speech API URL
  const endpoint = `https://${azureRegion}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1`;
  const url = new URL(endpoint);
  url.searchParams.set("language", language);
  url.searchParams.set("format", "detailed");

  // Make the API request
  const response = await fetch(url.toString(), {
    method: "POST",
    headers: {
      "Ocp-Apim-Subscription-Key": azureKey,
      "Content-Type": "audio/wav; codecs=audio/pcm; samplerate=16000",
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
