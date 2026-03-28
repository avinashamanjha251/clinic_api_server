#!/bin/bash

# Local Build and Deploy Script
# Compiles locally and deploys to low-memory server (512MB RAM)

set -e

AWS_IP="3.7.95.138"
AWS_USER="ubuntu"
DOCKER_IMAGE="clinic-api-server"
PROJECT_DIR="/opt/clinic-api"
SSH_KEY="clinic_ssh_key.pem"

echo "🏗️  Local Build and Deploy to AWS Lightsail"
echo "============================================="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found. Please create it with all required environment variables."
    exit 1
fi

# Check if SSH key exists
if [ ! -f $SSH_KEY ]; then
    echo "❌ SSH key file '$SSH_KEY' not found. Please ensure it's in the current directory."
    exit 1
fi

# Set correct permissions for SSH key
chmod 600 $SSH_KEY

echo "🔨 Step 1: Building Docker image locally..."
/Applications/Docker.app/Contents/Resources/bin/docker build -t $DOCKER_IMAGE .

echo "📦 Step 2: Saving Docker image to file..."
/Applications/Docker.app/Contents/Resources/bin/docker save $DOCKER_IMAGE:latest | gzip > clinic-api-image.tar.gz

echo "📤 Step 3: Uploading image to server..."
echo "   This may take a few minutes depending on your internet speed..."
scp -i $SSH_KEY clinic-api-image.tar.gz $AWS_USER@$AWS_IP:/tmp/

echo "📤 Step 4: Uploading configuration files..."
# Create project directory first
ssh -i $SSH_KEY $AWS_USER@$AWS_IP "sudo mkdir -p $PROJECT_DIR && sudo chown $AWS_USER:$AWS_USER $PROJECT_DIR"
scp -i $SSH_KEY docker-compose-production.yml nginx.conf .env $AWS_USER@$AWS_IP:$PROJECT_DIR/

echo "🚀 Step 5: Deploying on server..."
ssh -i $SSH_KEY $AWS_USER@$AWS_IP << EOF
    cd $PROJECT_DIR
    
    echo "📦 Loading Docker image..."
    docker load < /tmp/clinic-api-image.tar.gz
    
    echo "🧹 Removing old images to save space..."
    docker image prune -f
    docker system prune -f --volumes
    
    echo "🛑 Stopping existing services..."
    docker compose -f docker-compose-production.yml down || true
    
    echo "⚙️ Fixing environment for HTTP access..."
    sed -i 's/VAPOR_ENV="prod"/VAPOR_ENV="development"/' .env
    
    echo "🚀 Starting services..."
    docker compose -f docker-compose-production.yml up -d
    
    echo "⏳ Waiting for services to start..."
    sleep 20
    
    echo "🔍 Testing health endpoint..."
    curl -f http://localhost:8080/api/v1/health || echo "❌ Health check failed"
    
    echo "🧪 Testing API endpoint..."
    curl -f http://localhost/api/v1/home || echo "⚠️ API endpoint test failed"
    
    echo "🧹 Cleaning up..."
    rm -f /tmp/clinic-api-image.tar.gz
    
    echo "📊 Service status:"
    docker compose -f docker-compose-production.yml ps
EOF

echo ""
echo "🎉 Deployment completed!"
echo "======================"
echo "📡 API Health Check: http://$AWS_IP/api/v1/health"
echo "🏠 API Home: http://$AWS_IP/api/v1/home"
echo "📊 Check status: ssh -i $SSH_KEY $AWS_USER@$AWS_IP 'cd $PROJECT_DIR && docker compose -f docker-compose-production.yml ps'"
echo "📋 View logs: ssh -i $SSH_KEY $AWS_USER@$AWS_IP 'cd $PROJECT_DIR && docker compose -f docker-compose-production.yml logs clinic-api'"
echo "🔧 MongoDB Fix: Add IP $AWS_IP to MongoDB Atlas whitelist"

# Clean up local file
rm -f clinic-api-image.tar.gz
echo "🧹 Local cleanup completed"