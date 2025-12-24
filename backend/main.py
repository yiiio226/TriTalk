from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
import time
import os
from openai import OpenAI
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure OpenRouter (via OpenAI client)
client = OpenAI(
  base_url="https://openrouter.ai/api/v1",
  api_key=os.getenv("OPENROUTER_API_KEY"),
)
model = os.getenv("OPENROUTER_MODEL", "google/gemini-2.0-flash-exp:free")

app = FastAPI()

class HintResponse(BaseModel):
    hints: List[str]

# Assuming ChatRequest is defined elsewhere or needs a placeholder
class ChatRequest(BaseModel):
    message: str
    history: List[dict] = []
    scene_context: str = ""

import json

class ReviewFeedback(BaseModel):
    is_perfect: bool
    corrected_text: str
    native_expression: str
    explanation: str # In Chinese
    example_answer: str = "" # How the AI would answer if it were the user

class ChatResponse(BaseModel):
    message: str
    translation: str = None
    review_feedback: ReviewFeedback = None

# Helper to parse JSON from LLM response which might be wrapped in markdown
def parse_json(content: str):
    content = content.strip()
    if content.startswith("```json"):
        content = content[7:]
    elif content.startswith("```"):
        content = content[3:]
    if content.endswith("```"):
        content = content[:-3]
    return json.loads(content.strip())

@app.post("/chat/send", response_model=ChatResponse)
async def chat_send(request: ChatRequest):
    # Construct messages with context
    system_prompt = f"""You are roleplaying in a language learning scenario. Key Scenario Context: {request.scene_context}.
    
    CRITICAL RULES:
    1. STAY IN CHARACTER at all times. Never break the fourth wall or mention that this is practice/learning.
    2. Respond naturally as your character would in this real-world situation.
    3. Keep responses conversational and realistic for the scenario.
    
    Analyze the user's message for grammar, naturalness, and appropriateness.
    
    IMPORTANT: Both "native_expression" and "example_answer" should show how the USER (learner) could better express THEIR OWN message. These are NOT your (AI character's) responses.
    
    Example:
    - User says: "I want coffee"
    - native_expression: "I'd like a coffee, please" (more polite way for USER to say it)
    - example_answer: "Could I get a coffee?" (alternative way for USER to say it)
    - reply: "Sure! What size would you like?" (this is YOUR response as the AI character)
    
    You MUST return your response in valid JSON format:
    {{
        "reply": "Your in-character conversational reply (stay in role, never mention practice/learning)",
        "analysis": {{
            "is_perfect": boolean,
            "corrected_text": "Grammatically correct version of what the USER said",
            "native_expression": "More natural/idiomatic way for the USER to express their message (NOT your AI response)",
            "explanation": "Explanation in Chinese (Simplified). If perfect, compliment in Chinese.",
            "example_answer": "Alternative way for the USER to express the same idea (NOT your AI response)"
        }}
    }}
    """


    messages = [
        {"role": "system", "content": system_prompt},
    ]
    # Add history
    # messages.extend(request.history) 
    
    messages.append({"role": "user", "content": request.message})

    try:
        completion = client.chat.completions.create(
            model=model,
            messages=messages,
            response_format={"type": "json_object"} # Ensure JSON output if supported by provider/model
        )
        content = completion.choices[0].message.content
        data = parse_json(content)
        
        reply_text = data.get("reply", "")
        analysis_data = data.get("analysis", {})
        
        feedback = ReviewFeedback(
            is_perfect=analysis_data.get("is_perfect", False),
            corrected_text=analysis_data.get("corrected_text", request.message),
            native_expression=analysis_data.get("native_expression", ""),
            explanation=analysis_data.get("explanation", ""),
            example_answer=analysis_data.get("example_answer", "")
        )

        return ChatResponse(
            message=reply_text,
            review_feedback=feedback
        )
    except Exception as e:
        print(f"Error calling LLM: {e}")
        # Fallback for error or non-JSON response
        return ChatResponse(message="Sorry, I'm having trouble connecting to the AI right now.")

@app.post("/chat/hint", response_model=HintResponse)
async def get_hints(request: ChatRequest):
    # Construct context for hints
    hint_prompt = f"""You are a helpful conversation tutor.
    Key Scenario Context: {request.scene_context}.
    
    Based on the conversation history, suggest 3 natural, diverse, and appropriate short responses for the user (learner) to say next.
    
    Guidelines:
    1. Keep them short (1 sentence).
    2. Vary the intent (e.g., one agreement, one question, one alternative).
    3. Output JSON format only: {{ "hints": ["Hint 1", "Hint 2", "Hint 3"] }}
    """

    messages = [
        {"role": "system", "content": hint_prompt},
    ]
    
    # Add recent history (last 5 messages to keep context but save tokens)
    # Ensure history is in correct format for OpenAI API
    if request.history:
        messages.extend(request.history[-5:])

    try:
        completion = client.chat.completions.create(
            model=model,
            messages=messages,
            response_format={"type": "json_object"}
        )
        content = completion.choices[0].message.content
        data = parse_json(content)
        hints = data.get("hints", [])
        
        # Fallback if empty
        if not hints:
            hints = ["Yes, please.", "No, thank you.", "Could you repeat that?"]
            
        return HintResponse(hints=hints)
    except Exception as e:
        print(f"Error generating hints: {e}")
        return HintResponse(hints=["Could you help me?", "I don't understand.", "Please continue."])

class SceneGenerationRequest(BaseModel):
    description: str
    tone: str = "Casual"

class SceneGenerationResponse(BaseModel):
    title: str
    ai_role: str
    user_role: str
    goal: str
    description: str
    initial_message: str
    emoji: str

@app.post("/scene/generate", response_model=SceneGenerationResponse)
async def generate_scene(request: SceneGenerationRequest):
    prompt = f"""Act as a creative educational scenario designer.
    User Request: "{request.description}"
    Tone: {request.tone}
    
    Create a roleplay scenario for learning English.
    Output JSON ONLY with these fields:
    - title: Short, catchy title (e.g. "Coffee Shop Chat")
    - ai_role: Who you (AI) will play (e.g. "Barista")
    - user_role: Who the user will play (e.g. "Customer")
    - goal: The user's objective (e.g. "Order a latte with oat milk")
    - description: A brief context setting (e.g. "You are at a busy cafe in London...")
    - initial_message: The first thing the AI says to start the conversation.
    - emoji: A single relevant emoji char.
    """
    
    try:
        completion = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": prompt}],
            response_format={"type": "json_object"}
        )
        content = completion.choices[0].message.content
        data = parse_json(content)
        # Handle list response (some models return [{}])
        if isinstance(data, list) and len(data) > 0:
            data = data[0]
            
        return SceneGenerationResponse(
            title=data.get("title", "Custom Scene"),
            ai_role=data.get("ai_role", "Assistant"),
            user_role=data.get("user_role", "Learner"),
            goal=data.get("goal", "Practice English"),
            description=data.get("description", request.description),
            initial_message=data.get("initial_message", "Hello! Ready to practice?"),
            emoji=data.get("emoji", "✨")
        )
    except Exception as e:
        print(f"Error generating scene: {e}")
        # Fallback
        return SceneGenerationResponse(
            title="Custom Scene",
            ai_role="Assistant",
            user_role="User",
            goal="Practice conversation",
            description=request.description,
            initial_message="Hi! Let's start expecting.",
            emoji="📝"
        )

@app.get("/")
def read_root():
    return {"message": "TriTalk Backend Running"}

@app.get("/health")
def health_check():
    return {"status": "ok"}
