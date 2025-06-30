#!/bin/bash

# Deploy script for various platforms

set -e

echo "🚀 Solana HTTP Server Deployment Script"
echo "======================================="

# Function to deploy with Docker
deploy_docker() {
    echo "📦 Building Docker image..."
    docker build -t solana-http-server .
    
    echo "🏃 Running container..."
    docker run -d \
        --name solana-server \
        --restart unless-stopped \
        -p 3000:3000 \
        -e RUST_LOG=info \
        solana-http-server
    
    echo "✅ Docker deployment complete!"
    echo "🌐 Server available at: http://localhost:3000"
}

# Function to deploy with Docker Compose
deploy_compose() {
    echo "📦 Deploying with Docker Compose..."
    docker-compose up -d --build
    
    echo "✅ Docker Compose deployment complete!"
    echo "🌐 Server available at: http://localhost:3000"
}

# Function to build for production
build_release() {
    echo "🔨 Building release binary..."
    cargo build --release
    
    echo "✅ Release build complete!"
    echo "📁 Binary location: ./target/release/sol-fn"
    echo "🏃 Run with: ./target/release/sol-fn"
}

# Function to create systemd service
create_systemd_service() {
    echo "⚙️ Creating systemd service..."
    
    # Build release first
    cargo build --release
    
    # Get current directory
    CURRENT_DIR=$(pwd)
    BINARY_PATH="$CURRENT_DIR/target/release/sol-fn"
    
    # Create systemd service file
    sudo tee /etc/systemd/system/solana-http-server.service > /dev/null <<EOF
[Unit]
Description=Solana HTTP Server
After=network.target

[Service]
Type=simple
User=\$USER
WorkingDirectory=$CURRENT_DIR
ExecStart=$BINARY_PATH
Restart=always
RestartSec=3
Environment=PORT=3000
Environment=RUST_LOG=info

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and enable service
    sudo systemctl daemon-reload
    sudo systemctl enable solana-http-server
    sudo systemctl start solana-http-server
    
    echo "✅ Systemd service created and started!"
    echo "📊 Check status: sudo systemctl status solana-http-server"
    echo "📝 View logs: sudo journalctl -u solana-http-server -f"
}

# Main menu
echo "Choose deployment method:"
echo "1) Docker"
echo "2) Docker Compose"
echo "3) Build Release Binary"
echo "4) Create Systemd Service (Linux)"
echo "5) Exit"

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        deploy_docker
        ;;
    2)
        deploy_compose
        ;;
    3)
        build_release
        ;;
    4)
        create_systemd_service
        ;;
    5)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice!"
        exit 1
        ;;
esac
