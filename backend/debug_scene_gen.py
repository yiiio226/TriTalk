import os
from openai import OpenAI
from dotenv import load_dotenv
import json

load_dotenv()

client = OpenAI(
  base_url="https://openrouter.ai/api/v1",
  api_key=os.getenv("OPENROUTER_API_KEY"),
)
model = os.getenv("OPENROUTER_MODEL", "google/gemini-2.0-flash-exp:free")

prompt = """Act as a creative educational scenario designer.
User Request: "I want to return a shirt"
Tone: Casual

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
    print(f"Sending request to model: {model}")
    completion = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        # response_format={"type": "json_object"} # Commenting out to see if this is the cause
    )
    content = completion.choices[0].message.content
    print("Raw Content:", content)
    data = json.loads(content)
    print("Parsed JSON:", data)
except Exception as e:
    print(f"Error: {e}")
