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
