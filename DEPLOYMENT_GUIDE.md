# 🚀 Deployment Guide for Solana HTTP Server

This guide covers multiple deployment options for your Axum-based Solana HTTP server.

## 📋 Quick Deployment Options

### 1. **Local Docker (Fastest for Testing)**
```bash
# Build and run with Docker
docker build -t solana-http-server .
docker run -d -p 3000:3000 --name solana-server solana-http-server

# Or use Docker Compose
docker-compose up -d
```

### 2. **Automated Deployment Script**
```bash
./deploy.sh
# Choose from: Docker, Docker Compose, Release Binary, or Systemd Service
```

### 3. **🌐 Instant Public Access with Ngrok**
```bash
# Quick setup (one-time)
./setup-ngrok.sh

# Deploy and share publicly
./deploy-ngrok.sh
# Choose: Local server + ngrok OR Docker + ngrok
```

**Perfect for**: Instant sharing, demos, testing with others

## ☁️ Cloud Platform Deployments

### 🌐 **Ngrok** (Instant Public Access)
**Pros**: Instant setup, free tier, perfect for demos/testing
**Cost**: Free tier (2 hours sessions), $8/month for persistent URLs

```bash
# One-time setup
brew install ngrok/ngrok/ngrok  # macOS
# OR download from https://ngrok.com/download

# Get free authtoken from https://ngrok.com
ngrok config add-authtoken YOUR_TOKEN

# Deploy instantly
./deploy-ngrok.sh
# Your server will be publicly accessible immediately!
```

### 🪁 **Fly.io** (Recommended for Production)
**Pros**: Fast global CDN, automatic scaling, Docker-based
**Cost**: Free tier available, ~$5-10/month for production

```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Login and deploy
fly auth login
fly launch --copy-config --dockerfile
fly deploy
```

### 🚂 **Railway**
**Pros**: Simple Git-based deployment, automatic builds
**Cost**: Free tier available, pay-per-use

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and deploy
railway login
railway init
railway up
```

### 🎯 **Render**
**Pros**: Easy setup, free tier, automatic SSL
**Cost**: Free tier available, $7/month for production

1. Connect your GitHub repository
2. Use the `render.yaml` configuration file
3. Deploy automatically from Git pushes

### 🔺 **Vercel** (Limited Rust Support)
**Note**: Primarily for Node.js, but can work with containerized apps
```bash
npm i -g vercel
vercel --docker
```

### ☁️ **AWS/GCP/Azure**

#### **AWS ECS with Fargate**
```bash
# Build and push to ECR
aws ecr create-repository --repository-name solana-http-server
docker tag solana-http-server:latest $AWS_ACCOUNT.dkr.ecr.$REGION.amazonaws.com/solana-http-server:latest
docker push $AWS_ACCOUNT.dkr.ecr.$REGION.amazonaws.com/solana-http-server:latest

# Deploy with ECS (use AWS Console or Terraform)
```

#### **Google Cloud Run**
```bash
# Build and deploy
gcloud builds submit --tag gcr.io/$PROJECT_ID/solana-http-server
gcloud run deploy --image gcr.io/$PROJECT_ID/solana-http-server --platform managed
```

#### **Azure Container Instances**
```bash
# Create resource group and deploy
az group create --name solana-rg --location eastus
az container create --resource-group solana-rg --name solana-server \
  --image solana-http-server --ports 3000
```

### 🐙 **DigitalOcean App Platform**
1. Connect GitHub repository
2. Use Dockerfile for deployment
3. Set environment variables

## 🖥️ VPS/Dedicated Server Deployment

### **Using Systemd (Linux)**
```bash
# Run the deployment script
./deploy.sh
# Choose option 4 for systemd service

# Manual commands:
cargo build --release
sudo cp target/release/sol-fn /usr/local/bin/
sudo systemctl enable solana-http-server
sudo systemctl start solana-http-server
```

### **Using PM2 (Alternative Process Manager)**
```bash
# Build release
cargo build --release

# Install PM2
npm install -g pm2

# Create ecosystem file
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'solana-http-server',
    script: './target/release/sol-fn',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      PORT: 3000,
      RUST_LOG: 'info'
    }
  }]
}
EOF

# Start with PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### **Nginx Reverse Proxy Setup**
```bash
# Install Nginx
sudo apt update && sudo apt install nginx

# Copy our nginx.conf or create custom config
sudo cp nginx.conf /etc/nginx/sites-available/solana-server
sudo ln -s /etc/nginx/sites-available/solana-server /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

## 🌐 Domain and SSL Setup

### **Free SSL with Let's Encrypt**
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d yourdomain.com
```

### **Cloudflare Setup**
1. Add your domain to Cloudflare
2. Update DNS records to point to your server
3. Enable SSL/TLS in Cloudflare dashboard

## 📊 Monitoring and Logging

### **Basic Health Monitoring**
```bash
# Create simple health check script
cat > health_check.sh << 'EOF'
#!/bin/bash
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health)
if [ $response != "200" ]; then
    echo "Server is down! Response: $response"
    # Add restart logic or alerts here
fi
EOF

# Add to crontab for regular checks
echo "*/5 * * * * /path/to/health_check.sh" | crontab -
```

### **Log Management**
```bash
# View logs (systemd)
sudo journalctl -u solana-http-server -f

# View logs (PM2)
pm2 logs solana-http-server

# View logs (Docker)
docker logs -f solana-server
```

## 🔒 Security Considerations

1. **Firewall Setup**
   ```bash
   sudo ufw allow 22   # SSH
   sudo ufw allow 80   # HTTP
   sudo ufw allow 443  # HTTPS
   sudo ufw enable
   ```

2. **Rate Limiting**: Use nginx or Cloudflare
3. **Environment Variables**: Never commit secrets
4. **Regular Updates**: Keep dependencies updated

## 💰 Cost Comparison

| Platform | Free Tier | Paid Plans | Best For |
|----------|-----------|------------|----------|
| Fly.io | 2 shared-cpu-1x, 160MB | ~$5-10/month | Production apps |
| Railway | $5 credit | $5/month + usage | Hobby projects |
| Render | Free tier | $7/month | Static + API |
| DigitalOcean | $100 credit | $5/month droplet | Full control |
| AWS | 12 months free | Pay per use | Enterprise |
| VPS | - | $5-20/month | Custom setups |

## 🎯 Recommended Setup

**For Development**: Docker or local cargo run
**For Staging**: Railway or Render (free tier)
**For Production**: Fly.io or DigitalOcean VPS with nginx

Choose based on your needs:
- **Simplicity**: Railway/Render
- **Performance**: Fly.io/DigitalOcean
- **Cost**: VPS or free tiers
- **Scale**: AWS/GCP/Azure
