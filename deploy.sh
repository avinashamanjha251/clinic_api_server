#!/bin/bash

# Clinic API Server Deployment Script
# Usage: ./deploy.sh [environment]

set -e

ENVIRONMENT=${1:-production}
DOCKER_IMAGE="clinic-api-server"
CONTAINER_NAME="clinic_api_server"
AWS_IP="3.6.173.209"

echo "🚀 Starting deployment for environment: $ENVIRONMENT"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found. Please create it with all required environment variables."
    exit 1
fi

# Source environment variables
source .env

echo "📋 Environment variables loaded"

# Stop and remove existing containers
echo "🛑 Stopping existing containers..."
docker compose down --remove-orphans || true

# Build new image
echo "🔨 Building Docker image..."
docker build -t $DOCKER_IMAGE .

# Start services
echo "🚀 Starting services..."
docker compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to start..."
sleep 30

# Health check
echo "🔍 Running health checks..."
if curl -f http://localhost:8080/api/v1/health; then
    echo "✅ API server is healthy!"
else
    echo "❌ Health check failed"
    docker compose logs clinic-api
    exit 1
fi

echo "🎉 Deployment completed successfully!"
echo "📡 API accessible at: http://$AWS_IP:8080"
echo "📊 Check logs with: docker compose logs -f clinic-api"
echo "🔧 Stop services with: docker compose down"

# Display running containers
docker compose ps