# 🚀 Render Deployment - Step by Step (Native Environment)

## Problem: Can't Set Environment to Docker?
**Solution**: Use Native environment instead!

## 📋 **Exact Steps for Render Native Deployment**

### Step 1: Push Your Code to GitHub
```bash
# If you haven't created a GitHub repo yet:
# 1. Go to https://github.com/new
# 2. Repository name: solana-fellowship-server
# 3. Make it Public
# 4. Don't initialize with README
# 5. Click "Create repository"

# Then add remote and push:
git remote add origin https://github.com/YOUR_USERNAME/solana-fellowship-server.git
git branch -M main
git push -u origin main
```

### Step 2: Deploy on Render (Native Environment)

1. **Go to https://render.com**
2. **Click "Get Started for Free"**
3. **Sign up with GitHub** (connect your GitHub account)
4. **Click "New +"** → **"Web Service"**
5. **Connect Repository**: Select `solana-fellowship-server`

### Step 3: Configure Service Settings

Fill in these **EXACT** settings:

```
Name: solana-fellowship-server
Region: Oregon (US West)
Branch: main
Root Directory: [LEAVE EMPTY]
Environment: Native
Build Command: cargo build --release
Start Command: ./target/release/sol-fn
Plan: Free
```

### Step 4: Environment Variables (Advanced Section)

Click **"Advanced"** and add:
```
PORT = 10000
RUST_LOG = info
```

### Step 5: Deploy

Click **"Create Web Service"**

## 🎯 **What Happens Next**

1. **Build Time**: 5-15 minutes (Rust compilation)
2. **Deploy**: Automatic after build succeeds
3. **URL**: `https://solana-fellowship-server.onrender.com`

## 🔧 **If Native Environment Fails**

### Alternative Method: Let Render Auto-Detect

1. **Skip render.yaml file completely**
2. **Just set**:
   - Environment: `Native`
   - Build Command: `cargo build --release`
   - Start Command: `./target/release/sol-fn`
3. **Render will auto-detect Rust project**

### Check Build Logs

1. Go to your service dashboard
2. Click **"Logs"** tab
3. Watch the build process
4. Look for errors if build fails

## ✅ **Test Your Deployment**

Once live, test with:
```bash
# Health check
curl https://solana-fellowship-server.onrender.com/health

# Generate keypair
curl -X POST https://solana-fellowship-server.onrender.com/keypair
```

## 🆘 **Common Issues & Solutions**

### Issue: "Docker not available"
**Solution**: Use Native environment (instructions above)

### Issue: "Build failed"
**Solution**: Check if Cargo.toml is in root directory

### Issue: "Start command failed"
**Solution**: Use `./target/release/sol-fn` (not just `sol-fn`)

### Issue: "Port binding error"
**Solution**: Make sure PORT environment variable is set to 10000

## 🎉 **Success!**

Your Fellowship Assignment server will be live at:
**https://solana-fellowship-server.onrender.com**

All endpoints will work:
- `POST /keypair`
- `POST /token/create`
- `POST /token/mint`
- `POST /message/sign`
- `POST /message/verify`
- `POST /send/sol`
- `POST /send/token`
