#!/bin/bash

# CORS Testing Script for Hono Migration
# This script tests CORS headers on all endpoints

echo "🧪 Testing CORS Headers for Hono Migration"
echo "=========================================="
echo ""

BASE_URL="http://127.0.0.1:8787"
ORIGIN="http://localhost:3000"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test function
test_cors() {
    local endpoint=$1
    local method=$2
    local description=$3
    
    echo -n "Testing $method $endpoint ... "
    
    response=$(curl --noproxy "*" -s -o /dev/null -w "%{http_code}" \
        -H "Origin: $ORIGIN" \
        -X $method \
        "$BASE_URL$endpoint")
    
    if [ $response -eq 200 ] || [ $response -eq 401 ]; then
        echo -e "${GREEN}✓${NC} HTTP $response"
    else
        echo -e "${RED}✗${NC} HTTP $response"
    fi
}

echo "1. Testing Basic Endpoints"
echo "-------------------------"
test_cors "/" "GET" "Root endpoint"
test_cors "/health" "GET" "Health check"
echo ""

echo "2. Testing Protected Endpoints (should return 401 without auth)"
echo "----------------------------------------------------------------"
test_cors "/chat/send" "POST" "Chat send"
test_cors "/chat/hint" "POST" "Chat hint"
test_cors "/scene/generate" "POST" "Scene generate"
echo ""

echo "3. Testing CORS Preflight (OPTIONS)"
echo "-----------------------------------"
echo -n "Testing OPTIONS /chat/send ... "
response=$(curl --noproxy "*" -s -o /dev/null -w "%{http_code}" \
    -H "Origin: $ORIGIN" \
    -H "Access-Control-Request-Method: POST" \
    -H "Access-Control-Request-Headers: Content-Type, Authorization" \
    -X OPTIONS \
    "$BASE_URL/chat/send")

if [ $response -eq 204 ] || [ $response -eq 200 ]; then
    echo -e "${GREEN}✓${NC} HTTP $response"
else
    echo -e "${RED}✗${NC} HTTP $response"
fi
echo ""

echo "4. Checking CORS Headers"
echo "------------------------"
echo "Testing GET /health with Origin header:"
curl --noproxy "*" -s -i -H "Origin: $ORIGIN" "$BASE_URL/health" | grep -i "access-control"
echo ""

echo "5. Testing with Different Origins"
echo "---------------------------------"
ORIGINS=("http://localhost:8080" "http://127.0.0.1:3000" "https://evil.com")
for origin in "${ORIGINS[@]}"; do
    echo -n "Testing with origin $origin ... "
    cors_header=$(curl --noproxy "*" -s -i -H "Origin: $origin" "$BASE_URL/health" | grep -i "access-control-allow-origin" | cut -d ' ' -f2 | tr -d '\r')
    
    if [[ "$origin" == http://localhost:* ]] || [[ "$origin" == http://127.0.0.1:* ]]; then
        if [ "$cors_header" == "$origin" ]; then
            echo -e "${GREEN}✓${NC} Allowed ($cors_header)"
        else
            echo -e "${RED}✗${NC} Should be allowed but got: $cors_header"
        fi
    else
        if [ "$cors_header" == "null" ]; then
            echo -e "${GREEN}✓${NC} Blocked (returned: null)"
        else
            echo -e "${YELLOW}!${NC} Unexpected: $cors_header"
        fi
    fi
done
echo ""

echo "=========================================="
echo "✅ CORS Testing Complete!"
echo ""
echo "Note: Streaming endpoints (/chat/analyze, /tts/generate) require"
echo "      authentication and will be tested separately with real tokens."
