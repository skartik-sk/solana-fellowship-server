#!/bin/bash

# 🚀 SOLANA FELLOWSHIP SERVER - SMART DEPLOYMENT SCRIPT
# This script helps you deploy to the best available platform

set -e

echo "🚀 Solana Fellowship Server - Smart Deployment"
echo "=============================================="
echo ""
echo "Choose your deployment platform:"
echo ""
echo "1) 🌟 Railway (Fastest - 3 minutes)"
echo "2) 🐋 Render (Free forever)"  
echo "3) ✈️  Fly.io (Most reliable)"
echo "4) 🌊 DigitalOcean (Professional)"
echo "5) 📊 Show all options"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        echo "🚂 Deploying to Railway..."
        if ! command -v railway &> /dev/null; then
            echo "📦 Installing Railway CLI..."
            npm install -g @railway/cli
        fi
        
        echo "🔐 Logging in to Railway..."
        railway login
        
        echo "🆕 Creating new Railway project..."
        railway new
        
        echo "🚀 Deploying to Railway..."
        railway up
        
        echo "✅ Deployment complete! Getting URL..."
        railway status
        
        echo ""
        echo "🧪 Test your deployment:"
        echo "export BASE_URL=\"https://\$(railway status --json | jq -r '.deployments[0].url')\""
        echo "./test_fellowship.sh"
        ;;
        
    2)
        echo "🎨 Deploying to Render..."
        echo ""
        echo "📝 Next steps:"
        echo "1. Push your code to GitHub: git push origin main"
        echo "2. Go to https://render.com"
        echo "3. Click 'New +' → 'Web Service'"
        echo "4. Connect your GitHub repository"
        echo "5. Render will auto-detect render.yaml"
        echo "6. Click 'Create Web Service'"
        echo ""
        echo "💡 Your service will be at: https://solana-fellowship-server.onrender.com"
        echo ""
        
        if git remote get-url origin &> /dev/null; then
            echo "📤 Pushing to GitHub..."
            git push origin main
            echo "✅ Code pushed! Now go to render.com to deploy."
        else
            echo "❌ No GitHub remote found. Add one first:"
            echo "git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
            echo "git push -u origin main"
        fi
        ;;
        
    3)
        echo "✈️ Deploying to Fly.io..."
        ./deploy-fly.sh
        ;;
        
    4)
        echo "🌊 DigitalOcean App Platform deployment:"
        echo ""
        echo "📝 Next steps:"
        echo "1. Go to https://cloud.digitalocean.com/apps"
        echo "2. Click 'Create App'"
        echo "3. Connect your GitHub repository"
        echo "4. Select 'Docker' as build pack"
        echo "5. Set HTTP port to 10000"
        echo "6. Deploy on Basic plan"
        echo ""
        echo "💡 Free trial includes $200 credit!"
        ;;
        
    5)
        echo "📋 All deployment options:"
        echo ""
        echo "🚂 Railway: ./deploy.sh and choose option 1"
        echo "🎨 Render: ./deploy.sh and choose option 2"  
        echo "✈️ Fly.io: ./deploy-fly.sh"
        echo "🌊 DigitalOcean: ./deploy.sh and choose option 4"
        echo "⚡ Koyeb: Check DEPLOYMENT_OPTIONS.md"
        echo "🚀 Vercel: Check DEPLOYMENT_OPTIONS.md"
        echo ""
        echo "📚 Detailed guides:"
        echo "- RENDER_DEPLOYMENT_GUIDE.md"
        echo "- DEPLOYMENT_OPTIONS.md"
        echo "- DEPLOYMENT_READY.md"
        ;;
        
    *)
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "🎉 Happy deploying! Your Solana Fellowship server will be live soon!"
