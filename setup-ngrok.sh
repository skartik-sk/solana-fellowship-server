#!/bin/bash

# Quick ngrok setup for Solana HTTP Server
# One-command deployment to share your server publicly

echo "🚀 Quick Ngrok Setup"
echo "==================="

# Install ngrok if not present (macOS)
if ! command -v ngrok &> /dev/null; then
    echo "📦 Installing ngrok..."
    if command -v brew &> /dev/null; then
        brew install ngrok/ngrok/ngrok
    else
        echo "❌ Please install Homebrew first or install ngrok manually"
        echo "🌐 Download from: https://ngrok.com/download"
        exit 1
    fi
fi

echo "🔐 Setup Steps:"
echo "1. Sign up at https://ngrok.com (free)"
echo "2. Get your authtoken from https://dashboard.ngrok.com/get-started/your-authtoken"
echo "3. Run: ngrok config add-authtoken YOUR_TOKEN"
echo ""
echo "Then run: ./deploy-ngrok.sh"
echo ""
echo "💡 Quick test (if already authenticated):"
echo "   cargo run &"
echo "   ngrok http 3000"
