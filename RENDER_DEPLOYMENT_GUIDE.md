# 🚀 RENDER DEPLOYMENT - COMPREHENSIVE GUIDE

This guide provides multiple tested approaches to deploy your Solana Fellowship server on Render.

## 🎯 Quick Deploy Options

### Option 1: Docker Deployment (Recommended)
Use the main `render.yaml` with Docker environment:

1. **Ensure your `render.yaml` is set to Docker:**
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

2. **Deploy:**
   - Push code to GitHub
   - Connect repo to Render
   - Deploy automatically

### Option 2: Native Environment 
Use `render-native.yaml` for native builds:

1. **Rename the config:**
   ```bash
   mv render-native.yaml render.yaml
   ```

2. **Deploy as above**

## 🔧 Troubleshooting Common Issues

### Issue 1: Cargo.lock Version Error
**Solution:** Use the native environment with fresh Rust installation
- File: `render-native.yaml`
- This installs Rust 1.83 fresh on the build server

### Issue 2: Rust Version Compatibility
**Error:** `rustc 1.82.0 is not supported`
**Solution:** Updated Dockerfile to use Rust 1.83

### Issue 3: Build Timeout
**Solution:** Optimize dependencies by:
- Using native environment instead of Docker
- Or use the dependency pre-build optimization in Dockerfile

## 📋 Pre-Deployment Checklist

- [ ] Code pushed to GitHub
- [ ] `render.yaml` configured correctly
- [ ] Health endpoint `/health` exists
- [ ] PORT environment variable used in code
- [ ] Repository is public or connected to Render

## 🌐 Alternative Quick Deploy

### Railway (Fastest Option)
```bash
npm install -g @railway/cli
railway login
railway new
railway up
```

### Fly.io (Most Reliable)
```bash
./deploy-fly.sh
```

## 📝 Render Deployment Steps

1. **Go to render.com**
2. **Click "New +" → "Web Service"**
3. **Connect GitHub repository**
4. **Render auto-detects render.yaml**
5. **Click "Create Web Service"**
6. **Wait for deployment (5-10 minutes)**
7. **Test endpoints at your-service.onrender.com**

## 🧪 Test Your Deployment

```bash
export BASE_URL="https://your-service-name.onrender.com"
./test_fellowship.sh
```

## 🔍 Debugging Failed Builds

1. **Check Render build logs** for specific errors
2. **Try native environment** if Docker fails
3. **Use Railway or Fly.io** as backup options
4. **Ensure Rust 1.83+** is being used

## 💡 Pro Tips

- **Native builds are often more reliable** than Docker on Render
- **First deploy takes longer** (dependencies download)
- **Subsequent deploys are faster** (cached dependencies)
- **Free tier services sleep** after 15 minutes of inactivity

## 🆘 If All Else Fails

Use this Railway one-liner:
```bash
npx @railway/cli login && npx @railway/cli new && npx @railway/cli up
```

Your server will be live in 3-5 minutes! 🎉
