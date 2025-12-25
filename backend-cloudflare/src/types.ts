// Type definitions for API requests and responses

export interface ChatRequest {
    message: string;
    history?: Array<{ role: string; content: string }>;
    scene_context: string;
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
}

export interface AnalyzeResponse {
    grammar_points: GrammarPoint[];
    vocabulary: VocabularyItem[];
    sentence_structure: string;
    overall_summary: string;
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
