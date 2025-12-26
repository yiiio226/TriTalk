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
    overall_summary: string;
    // L-02 Context & Emotion
    pragmatic_analysis?: string; // "Why" they said it (e.g. "To be polite request")
    emotion_tags?: string[];     // ["Polite", "Formal", "Sarcastic"]
    // L-02 Idioms
    idioms_slang?: Array<{
        text: string;
        explanation: string;
        type: 'Idiom' | 'Slang' | 'Common Phrase';
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
