from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import time

app = FastAPI()

class ChatMessage(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    message: str
    history: List[ChatMessage]
    scene_context: str

class ReviewFeedback(BaseModel):
    is_perfect: bool
    score: int
    optimized_text: str
    explanation: str
    highlight_indices: List[int]

class ChatResponse(BaseModel):
    message: str
    review_feedback: Optional[ReviewFeedback] = None

@app.post("/chat/send", response_model=ChatResponse)
async def send_chat(request: ChatRequest):
    # Mock latency
    time.sleep(1)
    
    # TODO: Integrate real LLM here
    # Mock logic for MVP
    user_msg = request.message.lower()
    
    ai_reply = "That's interesting! Tell me more."
    feedback = None
    
    if "can i" in user_msg and "check in" in user_msg:
         ai_reply = "Sure, what time were you thinking?"
         feedback = ReviewFeedback(
             is_perfect=False,
             score=85,
             optimized_text="Would it be possible to check in early?",
             explanation="Using 'Would it be possible' is more polite when asking a landlord.",
             highlight_indices=[0, 5] # 'Can I'
         )
    
    return ChatResponse(message=ai_reply, review_feedback=feedback)

@app.get("/")
def read_root():
    return {"message": "SpeakScene Backend Running"}
