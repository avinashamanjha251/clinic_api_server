#!/bin/bash

# AWS Lightsail Deployment Script for Clinic API Server
# This script should be run on the AWS Lightsail instance

set -e

echo "🌐 AWS Lightsail Clinic API Deployment"
echo "========================================"

# Variables
PROJECT_DIR="/opt/clinic-api"
REPO_URL="your-git-repository-url"  # Replace with actual repository URL
AWS_IP="3.7.95.138"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "❌ This script should not be run as root for security reasons"
   exit 1
fi

# Update system packages
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    echo "🐳 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create project directory
echo "📁 Creating project directory..."
sudo mkdir -p $PROJECT_DIR
sudo chown $USER:$USER $PROJECT_DIR

# Clone or update repository
if [ -d "$PROJECT_DIR/.git" ]; then
    echo "🔄 Updating existing repository..."
    cd $PROJECT_DIR
    git pull origin main
else
    echo "📥 Cloning repository..."
    # For now, we'll create the necessary files manually since we don't have the repo URL
    cd $PROJECT_DIR
    
    # Copy files from current location (adjust path as needed)
    # git clone $REPO_URL .
    echo "⚠️  Please manually copy your project files to $PROJECT_DIR"
    echo "   Or update REPO_URL variable with your actual repository URL"
fi

# Navigate to project directory
cd $PROJECT_DIR

# Check if required files exist
if [ ! -f "Dockerfile" ] || [ ! -f "docker-compose.yml" ]; then
    echo "❌ Required Docker files not found in $PROJECT_DIR"
    echo "   Please ensure Dockerfile and docker-compose.yml are present"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    if [ -f ".env.template" ]; then
        echo "📝 Creating .env from template..."
        cp .env.template .env
        echo "⚠️  Please edit .env file with your actual environment variables"
        echo "   nano .env"
        read -p "Press Enter after editing .env file..."
    else
        echo "❌ No .env or .env.template file found"
        exit 1
    fi
fi

# Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 8080/tcp  # API direct access
sudo ufw --force enable

# Deploy application
echo "🚀 Deploying application..."
./deploy.sh production

# Configure systemd service for auto-restart
echo "⚙️  Creating systemd service..."
sudo tee /etc/systemd/system/clinic-api.service > /dev/null <<EOF
[Unit]
Description=Clinic API Server
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable clinic-api.service
sudo systemctl start clinic-api.service

# Set up automatic updates (optional)
echo "🔄 Setting up automatic updates..."
(crontab -l 2>/dev/null; echo "0 2 * * 1 cd $PROJECT_DIR && git pull && ./deploy.sh production") | crontab -

# Final checks
echo "🔍 Running final checks..."
sleep 30

# Test health endpoint
if curl -f http://localhost:8080/api/v1/health > /dev/null 2>&1; then
    echo "✅ Local health check passed"
else
    echo "❌ Local health check failed"
    sudo systemctl status clinic-api.service
    docker compose logs clinic-api
fi

# Test external access
if curl -f http://$AWS_IP:8080/api/v1/health > /dev/null 2>&1; then
    echo "✅ External health check passed"
else
    echo "⚠️  External health check failed - check firewall and security groups"
fi

echo ""
echo "🎉 Deployment completed!"
echo "========================================"
echo "📡 API URL: http://$AWS_IP:8080"
echo "🔍 Health Check: http://3.6.173.209:8080/api/v1/health"
echo ""
echo "📊 Useful commands:"
echo "   Check status: sudo systemctl status clinic-api"
echo "   View logs: docker-compose logs -f clinic-api"
echo "   Restart: sudo systemctl restart clinic-api"
echo "   Update: cd $PROJECT_DIR && git pull && ./deploy.sh production"
echo ""
echo "⚠️  Remember to:"
echo "   1. Configure AWS Lightsail firewall (ports 22, 80, 443, 8080)"
echo "   2. Set up SSL certificates for HTTPS"
echo "   3. Configure domain name (if applicable)"
echo "   4. Set up monitoring and backups"