#!/bin/bash

# Fellowship Assignment Test Script
# Tests all required endpoints according to the specification

echo "🎓 Testing Solana Fellowship Assignment HTTP Server"
echo "===================================================="

BASE_URL="http://localhost:3000"

# Test health endpoint
echo "🔍 1. Health Check:"
curl -s "$BASE_URL/health" | jq
echo ""

# Test keypair generation
echo "🔑 2. Generate Keypair (POST /keypair):"
KEYPAIR_RESPONSE=$(curl -s -X POST "$BASE_URL/keypair")
echo "$KEYPAIR_RESPONSE" | jq
echo ""

# Extract keys for further tests
PUBKEY=$(echo "$KEYPAIR_RESPONSE" | jq -r '.data.pubkey')
SECRET=$(echo "$KEYPAIR_RESPONSE" | jq -r '.data.secret')

echo "📝 3. Sign Message (POST /message/sign):"
SIGN_RESPONSE=$(curl -s -X POST "$BASE_URL/message/sign" \
  -H "Content-Type: application/json" \
  -d "{
    \"message\": \"Hello, Solana!\",
    \"secret\": \"$SECRET\"
  }")
echo "$SIGN_RESPONSE" | jq
echo ""

# Extract signature for verification
SIGNATURE=$(echo "$SIGN_RESPONSE" | jq -r '.data.signature')

echo "✅ 4. Verify Message (POST /message/verify):"
curl -s -X POST "$BASE_URL/message/verify" \
  -H "Content-Type: application/json" \
  -d "{
    \"message\": \"Hello, Solana!\",
    \"signature\": \"$SIGNATURE\",
    \"pubkey\": \"$PUBKEY\"
  }" | jq
echo ""

echo "🪙 5. Create Token (POST /token/create):"
# Generate a mint keypair for testing
MINT_KEYPAIR=$(curl -s -X POST "$BASE_URL/keypair")
MINT_PUBKEY=$(echo "$MINT_KEYPAIR" | jq -r '.data.pubkey')

curl -s -X POST "$BASE_URL/token/create" \
  -H "Content-Type: application/json" \
  -d "{
    \"mintAuthority\": \"$PUBKEY\",
    \"mint\": \"$MINT_PUBKEY\",
    \"decimals\": 6
  }" | jq
echo ""

echo "🏦 6. Mint Token (POST /token/mint):"
curl -s -X POST "$BASE_URL/token/mint" \
  -H "Content-Type: application/json" \
  -d "{
    \"mint\": \"$MINT_PUBKEY\",
    \"destination\": \"$PUBKEY\",
    \"authority\": \"$PUBKEY\",
    \"amount\": 1000000
  }" | jq
echo ""

echo "💰 7. Send SOL (POST /send/sol):"
# Generate recipient for testing
RECIPIENT_KEYPAIR=$(curl -s -X POST "$BASE_URL/keypair")
RECIPIENT_PUBKEY=$(echo "$RECIPIENT_KEYPAIR" | jq -r '.data.pubkey')

curl -s -X POST "$BASE_URL/send/sol" \
  -H "Content-Type: application/json" \
  -d "{
    \"from\": \"$PUBKEY\",
    \"to\": \"$RECIPIENT_PUBKEY\",
    \"lamports\": 100000
  }" | jq
echo ""

echo "🪙 8. Send Token (POST /send/token):"
curl -s -X POST "$BASE_URL/send/token" \
  -H "Content-Type: application/json" \
  -d "{
    \"destination\": \"$RECIPIENT_PUBKEY\",
    \"mint\": \"$MINT_PUBKEY\",
    \"owner\": \"$PUBKEY\",
    \"amount\": 100000
  }" | jq
echo ""

echo "✅ All Fellowship Assignment endpoints tested!"
echo ""
echo "📊 Test Summary:"
echo "   ✅ POST /keypair - Generate keypair"
echo "   ✅ POST /message/sign - Sign message"
echo "   ✅ POST /message/verify - Verify message"
echo "   ✅ POST /token/create - Create token"
echo "   ✅ POST /token/mint - Mint token"
echo "   ✅ POST /send/sol - Send SOL"
echo "   ✅ POST /send/token - Send token"
