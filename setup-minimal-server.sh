#!/bin/bash

# Minimal Server Setup for Pre-compiled Deployment
# For 512MB RAM servers - no compilation needed

set -e

AWS_IP="3.7.95.138"
PROJECT_DIR="/opt/clinic-api"

echo "⚙️  Minimal AWS Lightsail Setup (512MB RAM)"
echo "==========================================="

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
    
    # Start Docker
    sudo systemctl enable docker
    sudo systemctl start docker
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    echo "🐳 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Create symlink for 'docker compose' command
    sudo ln -sf /usr/local/bin/docker-compose /usr/local/bin/docker
fi

# Create project directory
echo "📁 Creating project directory..."
sudo mkdir -p $PROJECT_DIR
sudo chown $USER:$USER $PROJECT_DIR

# Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 8080/tcp  # API direct access
sudo ufw --force enable

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
User=$USER
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/local/bin/docker-compose -f docker-compose-production.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose-production.yml down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Enable service
sudo systemctl daemon-reload
sudo systemctl enable clinic-api.service

# Optimize for low memory
echo "🔧 Optimizing for low memory (512MB RAM)..."

# Set Docker to use less memory
sudo mkdir -p /etc/docker
echo '{"storage-driver": "overlay2", "log-driver": "json-file", "log-opts": {"max-size": "10m", "max-file": "3"}}' | sudo tee /etc/docker/daemon.json

# Restart Docker with new settings
sudo systemctl restart docker

# Set swap if not exists (helps with low memory)
if [ ! -f /swapfile ]; then
    echo "💾 Creating swap file for low memory server..."
    sudo fallocate -l 1G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

echo ""
echo "✅ Server setup completed!"
echo "========================="
echo "📡 Server IP: $AWS_IP"
echo "📁 Project Directory: $PROJECT_DIR"
echo ""
echo "🚀 Next steps:"
echo "   1. Run 'deploy-local-build.sh' from your local machine"
echo "   2. This will compile locally and deploy to the server"
echo ""
echo "📊 Server resources optimized for:"
echo "   - 512MB RAM with 1GB swap"
echo "   - Docker log rotation (max 30MB)"
echo "   - Auto-restart on boot"
echo ""
echo "⚠️  Remember to:"
echo "   - Configure AWS Lightsail firewall (ports 22, 80, 443, 8080)"
echo "   - Test deployment with: deploy-local-build.sh"