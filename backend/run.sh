#!/bin/bash

# Change to the directory where the script is located
cd "$(dirname "$0")"

# Unset proxy variables that might cause connection issues
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY

# Define virtual environment directory
VENV_DIR="venv"

# Check if venv exists
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python3 -m venv $VENV_DIR
fi

# Activate venv (use . for sh compatibility)
. "$VENV_DIR/bin/activate"

# Install dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
    # Simple check to see if we need to install (checks if uvicorn is missing)
    if ! command -v uvicorn &> /dev/null; then
        echo "Installing dependencies..."
        pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r requirements.txt
    fi
else
    echo "Error: requirements.txt not found in $(pwd)"
    exit 1
fi

# Run the server
echo "Starting backend server..."
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
