import jwt
import time
import sys
import os

def generate_client_secret(team_id, key_id, client_id, private_key_path):
    # Validity period: 180 days (max allowed by Apple)
    validity_days = 180
    current_time = int(time.time())
    expiration_time = current_time + (86400 * validity_days)

    try:
        with open(private_key_path, 'r') as f:
            private_key = f.read()
    except FileNotFoundError:
        print(f"Error: Private key file not found at {private_key_path}")
        return None

    headers = {
        'kid': key_id,
        'alg': 'ES256'
    }

    payload = {
        'iss': team_id,
        'iat': current_time,
        'exp': expiration_time,
        'aud': 'https://appleid.apple.com',
        'sub': client_id,
    }

    try:
        client_secret = jwt.encode(
            payload, 
            private_key, 
            algorithm='ES256', 
            headers=headers
        )
        return client_secret
    except Exception as e:
        print(f"Error generating token: {e}")
        return None

if __name__ == "__main__":
    print("\n--- Apple Client Secret Generator ---\n")
    
    # You can hardcode these for convenience if running multiple times
    team_id = input("Enter your Team ID (10 chars, e.g., KAZ9QWTLUS): ").strip()
    key_id = input("Enter your Key ID (10 chars, e.g., 47432423): ").strip()
    client_id = "com.trista.tritalk.service" 
    print(f"Using Client ID (Service ID): {client_id}")
    
    p8_path = input("Enter path to your .p8 file (drag and drop file here): ").strip().replace("'", "").rstrip()
    
    if not os.path.exists(p8_path):
        print("File does not exist. Please check the path.")
        sys.exit(1)

    print("\nGenerating secret...")
    secret = generate_client_secret(team_id, key_id, client_id, p8_path)
    
    if secret:
        print("\n" + "="*60)
        print("SUCCESS! Here is your Client Secret (valid for 6 months):")
        print("="*60 + "\n")
        print(secret)
        print("\n" + "="*60)
        print("Copy the string above and paste it into the Supabase 'Secret Key' field.")
    else:
        print("Failed to generate secret.")
