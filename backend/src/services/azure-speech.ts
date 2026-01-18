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

// Break info from Azure Prosody assessment
// BreakLength is in 100-nanosecond units (10,000 = 1ms)
export interface BreakInfo {
  errorType:
    | "None"
    | "UnexpectedBreak"
    | "MissingBreak"
    | "BreakTooLong"
    | "BreakTooShort";
  breakLength: number; // In 100-nanosecond units (3000000 = 300ms)
}

// Word-level assessment result
export interface WordAssessment {
  word: string;
  offset: number;
  duration: number;
  accuracyScore: number;
  errorType: "None" | "Omission" | "Insertion" | "Mispronunciation";
  phonemes: PhonemeAssessment[];
  break?: BreakInfo; // Break info after this word (from Prosody assessment)
}

// Smart segment for UI display
// Represents a portion of text that should be practiced together
export interface SmartSegment {
  text: string; // The text content of this segment
  startIndex: number; // Start word index (inclusive)
  endIndex: number; // End word index (inclusive)
  score: number; // Average pronunciation score for this segment
  hasError: boolean; // If segment contains any red/yellow words (score < 80)
  wordCount: number; // Number of words in segment
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
  segments: SmartSegment[]; // Smart segments based on natural pauses
}

/**
 * Check if Azure Speech is configured
 */
export function isAzureSpeechConfigured(
  azureKey?: string,
  azureRegion?: string,
): boolean {
  return Boolean(azureKey && azureRegion);
}

/**
 * Get Azure Speech configuration
 */
export function getAzureSpeechConfig(
  azureKey?: string,
  azureRegion?: string,
  language?: string,
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
  config: PronunciationAssessmentConfig,
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
    String.fromCharCode(byte),
  ).join("");
  return btoa(binaryString);
}

/**
 * Transform Azure API response to our structured format
 */
function transformAssessmentResult(
  azureResponse: any,
): PronunciationAssessmentResult {
  const nBest = azureResponse.NBest?.[0];
  if (!nBest) {
    throw new Error("No recognition results found in Azure response");
  }

  // Azure returns scores in two possible locations depending on the API version:
  // 1. Directly on nBest (current API behavior)
  // 2. Nested under nBest.PronunciationAssessment (legacy/SDK behavior)
  // We check both locations for compatibility
  const assessment = nBest.PronunciationAssessment || nBest;

  const words: WordAssessment[] = (nBest.Words || []).map((word: any) => {
    // Extract Break info from Feedback.Prosody.Break if available
    // Azure returns Break in Feedback object when prosody assessment is enabled
    const breakInfo = word.Feedback?.Prosody?.Break;

    return {
      word: word.Word,
      offset: word.Offset || 0,
      duration: word.Duration || 0,
      // Word-level scores are directly on the word object, not nested
      accuracyScore:
        word.AccuracyScore ?? word.PronunciationAssessment?.AccuracyScore ?? 0,
      errorType:
        word.ErrorType ?? word.PronunciationAssessment?.ErrorType ?? "None",
      phonemes: (word.Phonemes || []).map((phoneme: any) => ({
        phoneme: phoneme.Phoneme,
        // Phoneme-level scores are also directly on the phoneme object
        accuracyScore:
          phoneme.AccuracyScore ??
          phoneme.PronunciationAssessment?.AccuracyScore ??
          0,
        offset: phoneme.Offset || 0,
        duration: phoneme.Duration || 0,
      })),
      // Include break info if available
      break: breakInfo
        ? {
            errorType: breakInfo.ErrorType || "None",
            breakLength: breakInfo.BreakLength || 0,
          }
        : undefined,
    };
  });

  // Calculate smart segments based on natural breaks
  const segments = calculateSmartSegments(words);

  return {
    recognitionStatus: azureResponse.RecognitionStatus,
    displayText: azureResponse.DisplayText || nBest.Display || "",
    // Use PronScore for overall pronunciation score (Azure naming convention)
    pronunciationScore:
      assessment?.PronScore ?? assessment?.PronunciationScore ?? 0,
    accuracyScore: assessment?.AccuracyScore ?? 0,
    fluencyScore: assessment?.FluencyScore ?? 0,
    completenessScore: assessment?.CompletenessScore ?? 0,
    prosodyScore: assessment?.ProsodyScore,
    words,
    segments,
  };
}

/**
 * Calculate smart segments based on natural pauses from Azure Break data
 *
 * Algorithm:
 * 1. Find words with BreakLength > 300ms (3000000 units) as potential breaks
 * 2. Ensure each segment has at least 3 words (merge if too short)
 * 3. Limit to max 5 segments (prioritize largest breaks)
 * 4. Fallback to single segment if no valid breaks found
 *
 * @param words - Array of WordAssessment with optional break data
 * @returns Array of SmartSegment
 */
function calculateSmartSegments(words: WordAssessment[]): SmartSegment[] {
  if (words.length === 0) {
    return [];
  }

  // Constants for segmentation
  const BREAK_THRESHOLD = 3000000; // 300ms in 100-nanosecond units
  const MIN_WORDS_PER_SEGMENT = 3;
  const MAX_SEGMENTS = 5;

  // If text is too short, return as single segment
  if (words.length < MIN_WORDS_PER_SEGMENT * 2) {
    return [createSegment(words, 0, words.length - 1)];
  }

  // Find potential break points (word indices after which there's a significant pause)
  const breakPoints: { index: number; breakLength: number }[] = [];

  for (let i = 0; i < words.length; i++) {
    const word = words[i];
    if (word.break && word.break.breakLength >= BREAK_THRESHOLD) {
      breakPoints.push({ index: i, breakLength: word.break.breakLength });
    }
  }

  // Sort by break length (descending) to prioritize largest breaks
  breakPoints.sort((a, b) => b.breakLength - a.breakLength);

  // Build segments from break points, respecting constraints
  const validBreakIndices: number[] = [];

  for (const bp of breakPoints) {
    if (validBreakIndices.length >= MAX_SEGMENTS - 1) {
      break; // Already have enough segments
    }

    // Check if this break would create valid segments
    const allBreaks = [...validBreakIndices, bp.index].sort((a, b) => a - b);

    if (isValidSegmentation(allBreaks, words.length, MIN_WORDS_PER_SEGMENT)) {
      validBreakIndices.push(bp.index);
    }
  }

  // Sort break indices in order of appearance
  validBreakIndices.sort((a, b) => a - b);

  // If no valid breaks, return single segment
  if (validBreakIndices.length === 0) {
    return [createSegment(words, 0, words.length - 1)];
  }

  // Create segments from break indices
  const segments: SmartSegment[] = [];
  let startIndex = 0;

  for (const breakIndex of validBreakIndices) {
    segments.push(createSegment(words, startIndex, breakIndex));
    startIndex = breakIndex + 1;
  }

  // Add final segment
  if (startIndex < words.length) {
    segments.push(createSegment(words, startIndex, words.length - 1));
  }

  // Final merge pass: merge any segments that are too short
  return mergeShortSegments(segments, words, MIN_WORDS_PER_SEGMENT);
}

/**
 * Check if a set of break indices creates valid segments
 */
function isValidSegmentation(
  breakIndices: number[],
  totalWords: number,
  minWords: number,
): boolean {
  let startIndex = 0;

  for (const breakIndex of breakIndices) {
    const segmentLength = breakIndex - startIndex + 1;
    if (segmentLength < minWords) {
      return false;
    }
    startIndex = breakIndex + 1;
  }

  // Check last segment
  const lastSegmentLength = totalWords - startIndex;
  return lastSegmentLength >= minWords;
}

/**
 * Create a SmartSegment from word array and indices
 */
function createSegment(
  words: WordAssessment[],
  startIndex: number,
  endIndex: number,
): SmartSegment {
  const segmentWords = words.slice(startIndex, endIndex + 1);
  const text = segmentWords.map((w) => w.word).join(" ");

  // Calculate average score (exclude omitted words from average)
  const scoredWords = segmentWords.filter((w) => w.errorType !== "Omission");
  const avgScore =
    scoredWords.length > 0
      ? scoredWords.reduce((sum, w) => sum + w.accuracyScore, 0) /
        scoredWords.length
      : 0;

  // Check if any word has error (score < 80 or has error type)
  const hasError = segmentWords.some(
    (w) =>
      w.accuracyScore < 80 ||
      (w.errorType !== "None" && w.errorType !== "Insertion"),
  );

  return {
    text,
    startIndex,
    endIndex,
    score: Math.round(avgScore * 10) / 10, // Round to 1 decimal
    hasError,
    wordCount: segmentWords.length,
  };
}

/**
 * Merge segments that are too short with their neighbors
 */
function mergeShortSegments(
  segments: SmartSegment[],
  words: WordAssessment[],
  minWords: number,
): SmartSegment[] {
  if (segments.length <= 1) {
    return segments;
  }

  const result: SmartSegment[] = [];
  let i = 0;

  while (i < segments.length) {
    const current = segments[i];

    if (current.wordCount < minWords && result.length > 0) {
      // Merge with previous segment
      const prev = result[result.length - 1];
      result[result.length - 1] = createSegment(
        words,
        prev.startIndex,
        current.endIndex,
      );
    } else if (current.wordCount < minWords && i < segments.length - 1) {
      // Merge with next segment
      const next = segments[i + 1];
      result.push(createSegment(words, current.startIndex, next.endIndex));
      i++; // Skip next as it's merged
    } else {
      result.push(current);
    }
    i++;
  }

  return result;
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
    view.getUint8(3),
  );
  const wave = String.fromCharCode(
    view.getUint8(8),
    view.getUint8(9),
    view.getUint8(10),
    view.getUint8(11),
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
      view.getUint8(offset + 3),
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
  enableProsody: boolean = true,
): Promise<PronunciationAssessmentResult> {
  // Parse WAV header to get actual audio format
  const wavInfo = parseWavHeader(audioData);
  console.log(
    `[Azure Speech] WAV Info: sampleRate=${wavInfo.sampleRate}, bits=${wavInfo.bitsPerSample}, channels=${wavInfo.numChannels}, valid=${wavInfo.isValid}`,
  );

  // IMPORTANT: Azure Pronunciation Assessment requires 16kHz audio
  // If the audio is not 16kHz, the assessment scores will be 0
  if (wavInfo.isValid && wavInfo.sampleRate !== 16000) {
    console.warn(
      `[Azure Speech] ⚠️ WARNING: Audio sample rate is ${wavInfo.sampleRate}Hz, but Azure requires 16000Hz for pronunciation assessment!`,
    );
    console.warn(
      `[Azure Speech] This may cause all pronunciation scores to be 0.`,
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
    })}`,
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
      `Azure Speech API error: ${response.status} ${response.statusText} - ${errorText}`,
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
      JSON.stringify(nBest.PronunciationAssessment),
    );
    console.log(
      "[Azure Speech] NBest[0].Words count:",
      nBest.Words?.length || 0,
    );
    if (nBest.Words?.[0]) {
      console.log(
        "[Azure Speech] First word sample:",
        JSON.stringify(nBest.Words[0]),
      );
    }
  }

  // Check recognition status
  if (result.RecognitionStatus !== "Success") {
    throw new Error(
      `Azure Speech recognition failed: ${result.RecognitionStatus}`,
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
