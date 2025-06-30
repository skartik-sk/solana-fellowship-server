# Deployment Options for Solana Fellowship Server

This document provides multiple deployment options for the Solana Fellowship HTTP server.

## Option 1: Render (Docker) - Recommended

1. **Update render.yaml for Docker**:
   ```yaml
   services:
     - type: web
       name: solana-fellowship-server
       env: docker
       dockerfilePath: ./Dockerfile
       region: oregon
       plan: free
       healthCheckPath: /health
       envVars:
         - key: PORT
           value: 10000
         - key: RUST_LOG
           value: info
   ```

2. **Deploy**:
   - Push your code to GitHub
   - Connect your GitHub repo to Render
   - Deploy using the Docker environment

## Option 2: Fly.io (Free Tier Available)

1. **Install Fly CLI**:
   ```bash
   curl -L https://fly.io/install.sh | sh
   ```

2. **Login and Deploy**:
   ```bash
   fly auth login
   fly launch --no-deploy
   fly deploy
   ```

3. **Get your URL**:
   ```bash
   fly status
   ```

## Option 3: Railway

1. **Install Railway CLI**:
   ```bash
   npm install -g @railway/cli
   ```

2. **Deploy**:
   ```bash
   railway login
   railway new
   railway up
   ```

## Option 4: Koyeb (Free Tier)

1. **Create a Koyeb account** at https://www.koyeb.com
2. **Connect your GitHub repository**
3. **Deploy with Docker**:
   - Select your repository
   - Choose Docker as build pack
   - Set port to 10000
   - Deploy

## Option 5: DigitalOcean App Platform

1. **Create account** at https://cloud.digitalocean.com
2. **Create new app**:
   - Connect GitHub repository
   - Choose Docker
   - Set port to 10000
   - Deploy on basic plan (free trial available)

## Option 6: Heroku (If you have credits)

1. **Install Heroku CLI**
2. **Deploy**:
   ```bash
   heroku create your-app-name
   heroku container:push web
   heroku container:release web
   ```

## Testing Your Deployment

Once deployed, test your endpoints using the provided test script:

```bash
# Update the BASE_URL in test_fellowship.sh to your deployed URL
export BASE_URL="https://your-deployed-app.com"
./test_fellowship.sh
```

## Common Issues and Solutions

### Cargo.lock Version Issues
- Use Rust 1.70+ (our Dockerfile uses 1.80)
- Delete Cargo.lock and regenerate with `cargo build`

### Port Configuration
- Ensure your app listens on `0.0.0.0:$PORT`
- Most platforms set PORT environment variable automatically

### Docker Issues
- Ensure Dockerfile uses multi-stage build for smaller image
- Include all necessary dependencies in the runtime image

### Memory Limits
- Free tiers typically have 512MB-1GB RAM limits
- Our app should work fine within these limits

## Recommended: Fly.io

For the most reliable free deployment, we recommend Fly.io:
- Generous free tier
- Excellent Rust support
- Easy deployment process
- Good performance

Deploy with:
```bash
fly launch --no-deploy
fly deploy
```
