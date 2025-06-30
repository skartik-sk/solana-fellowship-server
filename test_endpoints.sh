#!/bin/bash

# Solana HTTP Server Test Script
# This script demonstrates all available endpoints

echo "🔧 Testing Solana HTTP Server Endpoints"
echo "========================================"

BASE_URL="http://localhost:3000"

# Test health endpoint
echo "1. Health Check:"
curl -s "$BASE_URL/health" | jq
echo ""

# Generate a keypair
echo "2. Generate Keypair:"
KEYPAIR_RESPONSE=$(curl -s -X POST "$BASE_URL/keypair/generate")
echo "$KEYPAIR_RESPONSE" | jq
echo ""

# Extract keys for further tests
PUBLIC_KEY=$(echo "$KEYPAIR_RESPONSE" | jq -r '.data.public_key')
SECRET_KEY=$(echo "$KEYPAIR_RESPONSE" | jq -r '.data.secret_key')

# Test get public key from secret key
echo "3. Get Public Key from Secret Key:"
curl -s "$BASE_URL/keypair/public/$SECRET_KEY" | jq
echo ""

# Test message signing
echo "4. Sign Message:"
SIGN_RESPONSE=$(curl -s -X POST "$BASE_URL/message/sign" \
  -H "Content-Type: application/json" \
  -d "{
    \"message\": \"Hello Solana!\",
    \"secret_key\": \"$SECRET_KEY\"
  }")
echo "$SIGN_RESPONSE" | jq
echo ""

# Extract signature for verification
SIGNATURE=$(echo "$SIGN_RESPONSE" | jq -r '.data.signature')

# Test message verification
echo "5. Verify Message:"
curl -s -X POST "$BASE_URL/message/verify" \
  -H "Content-Type: application/json" \
  -d "{
    \"message\": \"Hello Solana!\",
    \"signature\": \"$SIGNATURE\",
    \"public_key\": \"$PUBLIC_KEY\"
  }" | jq
echo ""

# Test get token account address
echo "6. Get Token Account Address:"
MINT_ADDRESS="Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"  # USDT mint
curl -s "$BASE_URL/token/account/address/$PUBLIC_KEY/$MINT_ADDRESS" | jq
echo ""

# Test create associated token account
echo "7. Create Associated Token Account:"
curl -s -X POST "$BASE_URL/token/account/create" \
  -H "Content-Type: application/json" \
  -d "{
    \"owner_pubkey\": \"$PUBLIC_KEY\",
    \"mint_pubkey\": \"$MINT_ADDRESS\",
    \"payer_pubkey\": \"$PUBLIC_KEY\"
  }" | jq
echo ""

# Test create SOL transfer instruction
echo "8. Create SOL Transfer Instruction:"
curl -s -X POST "$BASE_URL/sol/transfer" \
  -H "Content-Type: application/json" \
  -d "{
    \"from_pubkey\": \"$PUBLIC_KEY\",
    \"to_pubkey\": \"11111111111111111111111111111113\",
    \"lamports\": 1000000000
  }" | jq
echo ""

# Test create token transfer instruction
echo "9. Create Token Transfer Instruction:"
TOKEN_ACCOUNT1=$(curl -s "$BASE_URL/token/account/address/$PUBLIC_KEY/$MINT_ADDRESS" | jq -r '.data')
TOKEN_ACCOUNT2="11111111111111111111111111111113"  # Dummy destination

curl -s -X POST "$BASE_URL/token/transfer" \
  -H "Content-Type: application/json" \
  -d "{
    \"source\": \"$TOKEN_ACCOUNT1\",
    \"destination\": \"$TOKEN_ACCOUNT2\",
    \"owner\": \"$PUBLIC_KEY\",
    \"amount\": 1000000
  }" | jq
echo ""

echo "✅ All tests completed!"
