#!/bin/bash

# Deploy Solana Fellowship Server to Render
# This script helps prepare for Render deployment

set -e

echo "🚀 Preparing for Render Deployment"
echo "=================================="

# Check if we have render.yaml
if [ ! -f "render.yaml" ]; then
    echo "❌ render.yaml not found!"
    exit 1
fi

echo "✅ render.yaml found"

# Check if git repo is up to date
if git status --porcelain | grep -q .; then
    echo "📝 Uncommitted changes found. Committing..."
    git add .
    git commit -m "Prepare for Render deployment"
fi

# Push to GitHub
echo "📤 Pushing to GitHub..."
if git remote get-url origin &> /dev/null; then
    git push origin main
    echo "✅ Code pushed to GitHub"
else
    echo "❌ No GitHub remote found. Please add your GitHub repository:"
    echo "git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
    echo "git push -u origin main"
    exit 1
fi

echo ""
echo "🌐 Next steps for Render deployment:"
echo "1. Go to https://render.com"
echo "2. Click 'New +' -> 'Web Service'"
echo "3. Connect your GitHub repository"
echo "4. Select this repository"
echo "5. Render will automatically detect the render.yaml file"
echo "6. Click 'Create Web Service'"
echo ""
echo "Your service will be available at: https://YOUR-SERVICE-NAME.onrender.com"
echo ""
echo "🧪 Test your deployment with:"
echo "export BASE_URL=\"https://YOUR-SERVICE-NAME.onrender.com\""
echo "./test_fellowship.sh"
