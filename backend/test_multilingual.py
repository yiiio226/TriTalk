import requests
import json
import sys

BASE_URL = "http://127.0.0.1:8787"

def test_chat_multilingual(native, target):
    print(f"\n--- Testing Chat with Native={native}, Target={target} ---")
    payload = {
        "message": "Hello, how are you?",
        "history": [],
        "scene_context": "Meeting a new friend at a park.",
        "native_language": native,
        "target_language": target
    }
    
    try:
        response = requests.post(f"{BASE_URL}/chat/send", json=payload)
        response.raise_for_status()
        data = response.json()
        
        reply = data.get('message')
        feedback = data.get('review_feedback')
        
        print(f"Reply: {reply}")
        if feedback:
            print(f"Native Expression: {feedback.get('native_expression')}")
            print(f"Explanation: {feedback.get('explanation')}")
            print(f"Example Answer: {feedback.get('example_answer')}")
            
        return True
    except Exception as e:
        print(f"Failed: {e}")
        return False

def test_hints_multilingual(native, target):
    print(f"\n--- Testing Hints with Native={native}, Target={target} ---")
    payload = {
        "message": "",
        "history": [],
        "scene_context": "Ordering food.",
        "native_language": native,
        "target_language": target
    }
    
    try:
        response = requests.post(f"{BASE_URL}/chat/hint", json=payload)
        response.raise_for_status()
        data = response.json()
        hints = data.get('hints')
        print(f"Hints: {hints}")
        return True
    except Exception as e:
        print(f"Failed: {e}")
        return False

if __name__ == "__main__":
    # Test 1: Chinese Native, English Target (Default)
    test_chat_multilingual("Chinese (Simplified)", "English")
    
    # Test 2: Spanish Native, English Target
    test_chat_multilingual("Spanish", "English")
    
    # Test 3: Hints
    test_hints_multilingual("Japanese", "English")
