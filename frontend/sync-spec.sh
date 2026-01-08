#!/bin/bash

# Configuration
# ⚠️ IMPORTANT: Replace this with your actual R2 Public Bucket URL ⚠️
# Go to Cloudflare Dashboard -> R2 -> [Your Bucket] -> Settings -> Public Access -> Public Bucket URL
BASE_URL="https://pub-03509941dd4b4ed88f51359c04c694b2.r2.dev/tritalk"
TARGET_DIR="swagger"
TARGET_FILE="$TARGET_DIR/swagger.json"

# Ensure target directory exists
if [ ! -d "$TARGET_DIR" ]; then
  mkdir -p "$TARGET_DIR"
fi

VERSION=$1

if [ -z "$VERSION" ]; then
  # Default to latest
  URL="$BASE_URL/latest/swagger.json"
  echo "📥 Fetching LATEST schema from: $URL"
else
  # Fetch specific version
  URL="$BASE_URL/v$VERSION/swagger.json"
  echo "📥 Fetching version $VERSION schema from: $URL"
fi

# Download file
# -s: Silent mode
# -f: Fail silently on HTTP errors (useful to detect 404)
# -L: Follow redirects
HTTP_STATUS=$(curl -s -o "$TARGET_FILE" -w "%{http_code}" "$URL")

if [ "$HTTP_STATUS" -eq 200 ]; then
  echo "✅ Successfully updated $TARGET_FILE"
  echo "🚀 Running client code generation..."
  ./generate-client.sh
else
  echo "❌ Failed to download schema (HTTP $HTTP_STATUS)."
  echo "   Please check:"
  echo "   1. The R2 Public Access is enabled"
  echo "   2. The BASE_URL in this script is correct"
  echo "   3. The version exists"
  rm -f "$TARGET_FILE" # Remove partial/error file
  exit 1
fi
