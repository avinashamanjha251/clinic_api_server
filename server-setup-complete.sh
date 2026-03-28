#!/bin/bash

# Complete Server Setup - Copy and paste this entire script in AWS Lightsail browser SSH

set -e

echo "⚙️  Setting up AWS Lightsail Server for Clinic API (512MB RAM)"
echo "============================================================="

# Update system packages
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
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

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "🐳 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create project directory
echo "📁 Creating project directory..."
sudo mkdir -p /opt/clinic-api
sudo chown $USER:$USER /opt/clinic-api

# Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 8080/tcp  # API direct access
sudo ufw --force enable

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

# Configure systemd service
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
WorkingDirectory=/opt/clinic-api
ExecStart=/usr/local/bin/docker-compose -f docker-compose-production.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose-production.yml down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Enable service
sudo systemctl daemon-reload
sudo systemctl enable clinic-api.service

echo ""
echo "✅ Server setup completed!"
echo "========================="
echo "📡 Server IP: 3.7.95.138"
echo "📁 Project Directory: /opt/clinic-api"
echo "💾 Memory: $(free -h | grep Mem: | awk '{print $2}') + $(free -h | grep Swap: | awk '{print $2}') swap"
echo ""
echo "🚀 Server is ready for deployment!"
echo "   Run the deployment from your local machine"

# Test Docker
echo "🧪 Testing Docker installation..."
docker --version
docker-compose --version

# Show system status
echo "📊 System Status:"
free -h
df -h /