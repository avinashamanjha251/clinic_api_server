# AWS Lightsail Deployment Guide - Local Compilation (512MB RAM Server)

This guide deploys your Clinic API Server to AWS Lightsail using **local compilation** strategy optimized for low-memory servers.

## 📋 Prerequisites

- ✅ AWS Lightsail instance with Ubuntu 22.04
- ✅ Static IP: `3.7.95.138` assigned to your instance
- ✅ SSH access to your server
- ✅ Local machine with Docker installed (for compilation)
- ✅ 512MB+ RAM server (compilation happens locally)

---

## 🚀 Step 1: Prepare Local Environment

### 1.1 Verify Local Docker Installation
```bash
docker --version
docker compose --version
```

### 1.2 Test Local Build (Recommended)
```bash
cd /Volumes/Project/Clinic/Server/clinic_api_server

# Test local compilation first
docker build -t clinic-api-server .

# Verify image was created
docker images | grep clinic-api-server
```

---

## 📤 Step 2: Setup Minimal Server (One-time)

### 2.1 Upload Server Setup Script
```bash
# Upload setup script to server
scp setup-minimal-server.sh ubuntu@3.7.95.138:~/
```

### 2.2 Run Server Setup
```bash
# SSH to server
ssh ubuntu@3.7.95.138

# Run minimal setup (optimized for 512MB RAM)
chmod +x setup-minimal-server.sh
./setup-minimal-server.sh
```

**What this setup does:**
- ✅ Installs Docker (minimal configuration)
- ✅ Creates 1GB swap file (helps with low memory)
- ✅ Configures firewall (ports 22, 80, 443, 8080)
- ✅ Sets up auto-restart systemd service
- ✅ Optimizes Docker for low memory usage
- ✅ Creates project directory `/opt/clinic-api`

---

## 🏗️ Step 3: Deploy with Local Compilation

### 3.1 Deploy from Local Machine
```bash
# From your local machine (NOT the server)
cd /Volumes/Project/Clinic/Server/clinic_api_server
./deploy-local-build.sh
```

**Deployment Process:**
1. 🔨 **Builds Docker image locally** (uses your machine's RAM)
2. 📦 **Saves image to file** (~100-200MB compressed)
3. 📤 **Uploads image to server** via SCP
4. 🚀 **Loads and runs on server** (no compilation needed!)

### 3.2 Expected Output
```bash
🏗️  Local Build and Deploy to AWS Lightsail
=============================================
🔨 Step 1: Building Docker image locally...
📦 Step 2: Saving Docker image to file...
📤 Step 3: Uploading image to server...
📤 Step 4: Uploading configuration files...
🚀 Step 5: Deploying on server...
📦 Loading Docker image...
🛑 Stopping existing services...
🚀 Starting services...
⏳ Waiting for services to start...
🔍 Testing health endpoint...
🎉 Deployment completed!
```

---

## 🔥 Step 4: Configure AWS Lightsail Firewall

### 4.1 In AWS Lightsail Console
1. Go to **AWS Lightsail Console**
2. Select your **instance**  
3. Click **Networking** tab
4. **Add firewall rules**:

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22   | TCP      | Your IP only | SSH access |
| 80   | TCP      | Anywhere (0.0.0.0/0) | HTTP |
| 443  | TCP      | Anywhere (0.0.0.0/0) | HTTPS |
| 8080 | TCP      | Anywhere (0.0.0.0/0) | Direct API |

---

## ✅ Step 5: Verify Deployment

### 5.1 Test API Endpoints
```bash
# Test health endpoint
curl http://3.7.95.138:8080/api/v1/health

# Expected response:
{
  "success": true,
  "message": "success", 
  "code": 200,
  "data": {
    "status": "ok"
  }
}
```

### 5.2 Check Service Status
```bash
# SSH to server and check
ssh ubuntu@3.7.95.138
cd /opt/clinic-api

# Check container status
docker compose -f docker-compose-production.yml ps

# View logs if needed
docker compose -f docker-compose-production.yml logs clinic-api

# Check system service
sudo systemctl status clinic-api
```

---

## 📱 Step 6: Update Mobile/Web Apps

### 6.1 Update API Base URL in Your Apps
```javascript
// Update your mobile/web app configuration
const API_BASE_URL = 'http://3.7.95.138:8080';

// Example API call
const response = await fetch(`${API_BASE_URL}/api/v1/health`, {
  method: 'GET',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer your-jwt-token',
    'X-User-Id': 'user-id-here'
  }
});
```

### 6.2 Test from Your Apps
- **Health Check**: `http://3.7.95.138:8080/api/v1/health`
- **CORS**: Enabled for all origins
- **Headers**: Supports custom headers (X-User-Id, X-Admin-Token, etc.)

---

## 🔒 Step 7: Enable HTTPS (Optional)

### Option A: Self-Signed SSL (Quick Setup)
```bash
# SSH to server
ssh ubuntu@3.7.95.138
cd /opt/clinic-api

# Generate SSL certificate
./setup-self-signed-ssl.sh

# Restart with HTTPS
docker compose -f docker-compose-production.yml up -d

# Test HTTPS (will show browser warning)
curl -k https://3.7.95.138/api/v1/health
```

### Option B: Domain + Trusted SSL (Production)
```bash
# If you have a domain, update the script first
nano hostinger-ssl-setup.sh  # Update domain name

# Run SSL setup
./hostinger-ssl-setup.sh
```

---

## 🔧 Step 8: Management Commands

### 8.1 Update Deployment
```bash
# From your local machine
./deploy-local-build.sh
```

### 8.2 Server Management
```bash
# SSH to server
ssh ubuntu@3.7.95.138
cd /opt/clinic-api

# Restart services
sudo systemctl restart clinic-api

# View logs
docker compose -f docker-compose-production.yml logs -f clinic-api

# Stop services
docker compose -f docker-compose-production.yml down

# Start services
docker compose -f docker-compose-production.yml up -d

# Check resource usage
docker stats
free -h  # Check memory usage
```

---

## 🆘 Troubleshooting

### Common Issues

#### 1. Deployment Fails
```bash
# Check if server is accessible
ssh ubuntu@3.7.95.138

# Check Docker status on server
sudo systemctl status docker

# Check available space
df -h
```

#### 2. API Not Responding
```bash
# Check if containers are running
docker compose -f docker-compose-production.yml ps

# Check logs for errors
docker compose -f docker-compose-production.yml logs clinic-api

# Test direct container access
docker exec -it clinic_api_server curl http://localhost:8080/api/v1/health
```

#### 3. Memory Issues
```bash
# Check memory usage
free -h
docker stats

# If memory full, restart Docker
sudo systemctl restart docker
```

#### 4. Port Access Issues
```bash
# Check if ports are listening
netstat -tlnp | grep :8080
netstat -tlnp | grep :80

# Test from outside
nmap -p 8080 3.7.95.138
```

---

## 📊 Resource Usage (512MB RAM Server)

### Normal Operation:
- **Memory Usage**: ~150-200MB
- **Swap Usage**: ~50-100MB  
- **Disk Usage**: ~500MB for images
- **CPU Usage**: <10% when idle

### During Deployment:
- **Memory Usage**: ~300-400MB (brief spike)
- **Network**: ~100-200MB download
- **Time**: 30-60 seconds

---

## 🎉 Deployment Complete!

Your Clinic API Server is now deployed and accessible:

### 📡 **API Endpoints:**
- **HTTP**: `http://3.7.95.138:8080/api/v1/health`
- **HTTPS**: `https://3.7.95.138/api/v1/health` (after SSL setup)

### 🔄 **Benefits of This Setup:**
- ✅ **Low Memory Usage**: Optimized for 512MB RAM servers
- ✅ **Fast Deployments**: 30 seconds vs 10+ minutes
- ✅ **Reliable**: No compilation failures on server
- ✅ **Cost Effective**: Works with cheapest Lightsail tier
- ✅ **Auto-Restart**: Survives server reboots
- ✅ **Production Ready**: CORS, security headers, rate limiting

### 📱 **Mobile/Web App Integration:**
```javascript
const API_BASE_URL = 'http://3.7.95.138:8080';
// All your existing API calls will work with this base URL
```

Your deployment is complete and ready for production use! 🚀