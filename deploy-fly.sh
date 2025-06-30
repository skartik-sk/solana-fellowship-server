#!/bin/bash

# Deploy Solana Fellowship Server to Fly.io
# This script automates the deployment process

set -e

echo "🚀 Deploying Solana Fellowship Server to Fly.io"
echo "================================================="

# Check if fly CLI is installed
if ! command -v fly &> /dev/null; then
    echo "❌ Fly CLI not found. Installing..."
    curl -L https://fly.io/install.sh | sh
    export PATH="$HOME/.fly/bin:$PATH"
fi

# Check if user is logged in
echo "🔐 Checking Fly.io authentication..."
if ! fly auth whoami &> /dev/null; then
    echo "🔑 Please log in to Fly.io:"
    fly auth login
fi

# Initialize or update fly.toml if needed
echo "📝 Setting up Fly.io configuration..."
if [ ! -f "fly.toml" ]; then
    fly launch --no-deploy --name solana-fellowship-server
else
    echo "✅ fly.toml already exists"
fi

# Deploy the application
echo "🌍 Deploying to Fly.io..."
fly deploy --ha=false

# Get the deployment URL
echo "🎉 Deployment complete!"
echo "Your Solana Fellowship Server is available at:"
fly status --json | jq -r '.hostname' | xargs -I {} echo "https://{}"

echo ""
echo "🧪 Test your deployment with:"
echo "export BASE_URL=\"https://\$(fly status --json | jq -r '.hostname')\""
echo "./test_fellowship.sh"

echo ""
echo "✅ Deployment successful! Your server is ready to use."
