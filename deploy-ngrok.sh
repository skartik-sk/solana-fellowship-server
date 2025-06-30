#!/bin/bash

# Ngrok deployment script for Solana HTTP Server
# This script will start your server and expose it publicly via ngrok

set -e

echo "🌐 Ngrok Deployment for Solana HTTP Server"
echo "=========================================="

# Check if ngrok is installed
if ! command -v ngrok &> /dev/null; then
    echo "📦 Installing ngrok..."
    
    # Detect OS and install ngrok
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install ngrok/ngrok/ngrok
        else
            echo "Please install Homebrew first: https://brew.sh"
            echo "Or download ngrok manually from: https://ngrok.com/download"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
        echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
        sudo apt update && sudo apt install ngrok
    else
        echo "Please install ngrok manually from: https://ngrok.com/download"
        exit 1
    fi
fi

# Check if user is authenticated with ngrok
if ! ngrok config check &> /dev/null; then
    echo "🔐 Please authenticate with ngrok first:"
    echo "1. Sign up at https://ngrok.com"
    echo "2. Get your authtoken from https://dashboard.ngrok.com/get-started/your-authtoken"
    echo "3. Run: ngrok config add-authtoken YOUR_TOKEN"
    exit 1
fi

# Function to start server and ngrok
start_local_server() {
    echo "🚀 Starting Solana HTTP server locally..."
    
    # Kill any existing processes on port 3000
    lsof -ti:3000 | xargs kill -9 2>/dev/null || true
    
    # Start the server in the background
    cargo run &
    SERVER_PID=$!
    
    # Wait for server to start
    echo "⏳ Waiting for server to start..."
    sleep 5
    
    # Check if server is running
    if curl -s http://localhost:3000/health > /dev/null; then
        echo "✅ Server started successfully!"
    else
        echo "❌ Server failed to start"
        kill $SERVER_PID 2>/dev/null || true
        exit 1
    fi
    
    # Start ngrok tunnel
    echo "🌐 Starting ngrok tunnel..."
    ngrok http 3000 --log=stdout > ngrok.log &
    NGROK_PID=$!
    
    # Wait for ngrok to start
    sleep 3
    
    # Get the public URL
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' 2>/dev/null || echo "")
    
    if [ -z "$NGROK_URL" ]; then
        echo "❌ Failed to get ngrok URL. Checking logs..."
        cat ngrok.log
        kill $SERVER_PID $NGROK_PID 2>/dev/null || true
        exit 1
    fi
    
    echo ""
    echo "🎉 Your Solana HTTP Server is now publicly accessible!"
    echo "================================================="
    echo "🌐 Public URL: $NGROK_URL"
    echo "🏠 Local URL:  http://localhost:3000"
    echo ""
    echo "📋 Test endpoints:"
    echo "   Health Check: $NGROK_URL/health"
    echo "   Generate Key: $NGROK_URL/keypair/generate"
    echo ""
    echo "📊 Ngrok Dashboard: http://localhost:4040"
    echo ""
    echo "Press Ctrl+C to stop both server and ngrok tunnel"
    echo "================================================="
    
    # Wait for user to stop
    trap 'echo "🛑 Stopping server and ngrok..."; kill $SERVER_PID $NGROK_PID 2>/dev/null || true; exit 0' INT
    wait
}

# Function to start with Docker and ngrok
start_docker_server() {
    echo "🐳 Starting with Docker..."
    
    # Kill any existing container
    docker stop solana-server 2>/dev/null || true
    docker rm solana-server 2>/dev/null || true
    
    # Build Docker image
    echo "🔨 Building Docker image..."
    docker build -t solana-http-server .
    
    # Run Docker container
    echo "🚀 Starting Docker container..."
    docker run -d -p 3000:3000 --name solana-server solana-http-server
    
    # Wait for container to start
    echo "⏳ Waiting for container to start..."
    sleep 10
    
    # Check if server is running
    if curl -s http://localhost:3000/health > /dev/null; then
        echo "✅ Docker container started successfully!"
    else
        echo "❌ Docker container failed to start"
        docker logs solana-server
        exit 1
    fi
    
    # Start ngrok tunnel
    echo "🌐 Starting ngrok tunnel..."
    ngrok http 3000 --log=stdout > ngrok.log &
    NGROK_PID=$!
    
    # Wait for ngrok to start
    sleep 3
    
    # Get the public URL
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' 2>/dev/null || echo "")
    
    if [ -z "$NGROK_URL" ]; then
        echo "❌ Failed to get ngrok URL. Checking logs..."
        cat ngrok.log
        docker stop solana-server
        kill $NGROK_PID 2>/dev/null || true
        exit 1
    fi
    
    echo ""
    echo "🎉 Your Solana HTTP Server is now publicly accessible!"
    echo "================================================="
    echo "🌐 Public URL: $NGROK_URL"
    echo "🏠 Local URL:  http://localhost:3000"
    echo "🐳 Docker Container: solana-server"
    echo ""
    echo "📋 Test endpoints:"
    echo "   Health Check: $NGROK_URL/health"
    echo "   Generate Key: $NGROK_URL/keypair/generate"
    echo ""
    echo "📊 Ngrok Dashboard: http://localhost:4040"
    echo "📊 Docker Logs: docker logs -f solana-server"
    echo ""
    echo "Press Ctrl+C to stop ngrok tunnel (Docker container will keep running)"
    echo "To stop Docker: docker stop solana-server"
    echo "================================================="
    
    # Wait for user to stop
    trap 'echo "🛑 Stopping ngrok..."; kill $NGROK_PID 2>/dev/null || true; echo "Docker container still running. Stop with: docker stop solana-server"; exit 0' INT
    wait
}

# Main menu
echo "Choose deployment method:"
echo "1) Local server + ngrok"
echo "2) Docker + ngrok"
echo "3) Exit"

read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        start_local_server
        ;;
    2)
        start_docker_server
        ;;
    3)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice!"
        exit 1
        ;;
esac
