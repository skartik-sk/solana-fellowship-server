# 🚀 Deployment Checklist

## Pre-Deployment Setup
- [ ] Code is tested and working locally
- [ ] All dependencies are properly configured in Cargo.toml
- [ ] Environment variables are properly set
- [ ] Health endpoint is responding correctly

## Quick Deploy Options (Choose One)

### 🐳 **Option 1: Docker (Recommended)**
```bash
# 1. Make sure Docker is running
docker --version

# 2. Build and run
docker build -t solana-http-server .
docker run -d -p 3000:3000 --name solana-server solana-http-server

# 3. Test
curl http://localhost:3000/health
```

### ☁️ **Option 2: Fly.io (Cloud Deployment)**
```bash
# 1. Install Fly CLI
curl -L https://fly.io/install.sh | sh

# 2. Login and deploy
fly auth login
fly launch --copy-config
fly deploy

# 3. Your app will be live at: https://your-app-name.fly.dev
```

### 🚂 **Option 3: Railway (Git-based)**
```bash
# 1. Install Railway CLI
npm install -g @railway/cli

# 2. Login and deploy
railway login
railway init
railway up

# 3. Connect to GitHub for auto-deployment
```

### 🎯 **Option 4: Render (Web UI)**
1. Go to https://render.com
2. Connect your GitHub repository
3. Choose "Web Service"
4. Use Docker environment
5. Deploy automatically

### 🖥️ **Option 5: VPS/Linux Server**
```bash
# 1. Copy files to your server
scp -r . user@your-server:/path/to/app

# 2. Run deployment script
./deploy.sh
# Choose option 4 for systemd service

# 3. Setup nginx (optional)
sudo apt install nginx
sudo cp nginx.conf /etc/nginx/sites-available/solana-server
```

## Post-Deployment Verification

### ✅ Test All Endpoints
```bash
# Replace YOUR_DOMAIN with your actual domain/IP
BASE_URL="http://YOUR_DOMAIN:3000"

# Health check
curl "$BASE_URL/health"

# Generate keypair
curl -X POST "$BASE_URL/keypair/generate"

# Test other endpoints with the test script
./test_endpoints.sh
```

### 📊 Monitor Your Deployment
- Check server logs regularly
- Monitor resource usage (CPU, memory)
- Set up uptime monitoring (UptimeRobot, Pingdom)
- Configure alerts for downtime

### 🔒 Security Setup (Production)
- [ ] Enable HTTPS/SSL certificate
- [ ] Set up firewall rules
- [ ] Configure rate limiting
- [ ] Use environment variables for sensitive data
- [ ] Regular security updates

## Troubleshooting

### Common Issues
1. **Port already in use**: Change PORT environment variable
2. **Memory issues**: Increase server resources or optimize build
3. **CORS errors**: Check CorsLayer configuration
4. **Build failures**: Ensure all dependencies are available

### Logs and Debugging
```bash
# Docker logs
docker logs solana-server

# Systemd logs
sudo journalctl -u solana-http-server -f

# Direct binary logs
RUST_LOG=debug ./target/release/sol-fn
```

## 🎉 You're Ready to Deploy!

Choose your preferred deployment method above and follow the steps. Your Solana HTTP server will be live and ready to share with others!
