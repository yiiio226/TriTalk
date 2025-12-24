from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
import time

app = FastAPI()

class HintResponse(BaseModel):
    hints: List[str]

# Assuming ChatRequest is defined elsewhere or needs a placeholder
class ChatRequest(BaseModel):
    # Add fields relevant to your chat request here, e.g.:
    # message: str
    pass

@app.post("/chat/hint", response_model=HintResponse)
async def get_hints(request: ChatRequest):
    time.sleep(1)
    # Mock hints based on context
    return HintResponse(hints=[
        "Could you tell me more about that?",
        "I'm not sure I understand, can you explain?",
        "That sounds great, I'd love to hear more."
    ])

@app.get("/")
def read_root():
    return {"message": "SpeakScene Backend Running"}

@app.get("/health")
def health_check():
    return {"status": "ok"}
