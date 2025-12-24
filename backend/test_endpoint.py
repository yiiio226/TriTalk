import requests
import json

url = "http://127.0.0.1:8000/scene/generate"
data = {
    "description": "I want to return a shirt",
    "tone": "Casual"
}

try:
    print(f"Sending POST request to {url}...")
    response = requests.post(url, json=data)
    print(f"Status Code: {response.status_code}")
    print("Response Body:")
    print(json.dumps(response.json(), indent=2))
except Exception as e:
    print(f"Error: {e}")
    if 'response' in locals():
        print(f"Response Text: {response.text}")
