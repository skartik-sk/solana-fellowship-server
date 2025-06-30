# 🚀 Render Deployment Steps for Solana Fellowship Assignment

## Step 1: Push to GitHub
```bash
# If you don't have a GitHub repo yet:
# 1. Go to https://github.com and create a new repository
# 2. Name it: solana-fellowship-server
# 3. Don't initialize with README (since we already have files)
# 4. Copy the repository URL

# Then run these commands:
git remote add origin https://github.com/YOUR_USERNAME/solana-fellowship-server.git
git branch -M main
git push -u origin main
```

## Step 2: Deploy on Render

### 🌐 **Web UI Method (Updated Steps)**
1. Go to **https://render.com**
2. Click **"Get Started for Free"**
3. Sign up with GitHub
4. Click **"New +"** → **"Web Service"**
5. Connect your GitHub repository: `solana-fellowship-server`
6. Configure:
   - **Name**: `solana-fellowship-server`
   - **Region**: `Oregon (US West)`
   - **Branch**: `main`
   - **Root Directory**: `.` (leave empty)
   - **Environment**: `Native` (NOT Docker)
   - **Build Command**: `cargo build --release`
   - **Start Command**: `./target/release/sol-fn`
   - **Plan**: `Free`

7. **Environment Variables** (click "Advanced"):
   ```
   PORT=10000
   RUST_LOG=info
   ```

8. Click **"Create Web Service"**

### 🔧 **Alternative: If Native Environment Doesn't Work**

#### Option A: Manual Configuration (No render.yaml)
1. Don't use render.yaml file
2. Configure everything manually in the Render dashboard:
   - **Runtime**: `Rust`
   - **Build Command**: `cargo build --release`
   - **Start Command**: `./target/release/sol-fn`

#### Option B: Use Buildpacks
1. In Render dashboard, choose:
   - **Environment**: `Native`
   - **Auto-Deploy**: `Yes`
   - Render will auto-detect it's a Rust project

#### Option C: Force Docker (If Available)
1. If Docker option appears later, use:
   - **Environment**: `Docker`
   - **Dockerfile Path**: `./Dockerfile`
   - Leave build/start commands empty

### 📋 **Your Service Will Be Available At:**
```
https://solana-fellowship-server.onrender.com
```

## Step 3: Test Your Deployed API

Once deployed, test with:

```bash
# Health check
curl https://solana-fellowship-server.onrender.com/health

# Generate keypair
curl -X POST https://solana-fellowship-server.onrender.com/keypair

# Test all endpoints
./test_fellowship.sh
# (Replace localhost:3000 with your Render URL)
```

## 🎯 **Expected Deployment Time**
- First deployment: 5-10 minutes
- Subsequent deployments: 2-5 minutes

## 🆓 **Free Tier Limits**
- 750 hours/month (always free)
- Sleeps after 15 minutes of inactivity
- Wakes up automatically on first request
- No credit card required

## 🔧 **Auto-Deploy**
- Automatically redeploys on every `git push` to main branch
- Build logs available in Render dashboard
- Zero-downtime deployments

## 🌟 **Your Fellowship Assignment Endpoints**
Once deployed, your server will have these endpoints:

- `POST /keypair` - Generate keypair
- `POST /token/create` - Create token
- `POST /token/mint` - Mint token  
- `POST /message/sign` - Sign message
- `POST /message/verify` - Verify message
- `POST /send/sol` - Send SOL
- `POST /send/token` - Send token

## 🎉 **You're Done!**
Your Solana Fellowship Assignment HTTP server is now live and accessible worldwide!
