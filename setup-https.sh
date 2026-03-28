#!/bin/bash

# SSL Setup Script for AWS Lightsail
# This script sets up Let's Encrypt SSL certificates for HTTPS

set -e

AWS_IP="3.7.95.138"
DOMAIN_NAME="3.6.173.209"
EMAIL="monalishadentalcareandopgcentr@gmail.com"  # For Let's Encrypt notifications

echo "🔒 Setting up HTTPS/SSL for Clinic API"
echo "========================================"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "❌ This script should not be run as root for security reasons"
   exit 1
fi

echo "⚠️  IMPORTANT: Before running this script:"
echo "   1. Point your domain ($DOMAIN_NAME) to your server IP ($AWS_IP)"
echo "   2. Ensure DNS propagation is complete"
echo "   3. Update DOMAIN_NAME variable in this script with your actual domain"
echo ""
read -p "Have you completed the above steps? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please complete the setup and run this script again."
    exit 1
fi

# Install Certbot for Let's Encrypt
echo "📦 Installing Certbot..."
sudo apt update
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -sf /snap/bin/certbot /usr/bin/certbot

# Stop nginx to free up port 80 for certificate validation
echo "🛑 Temporarily stopping nginx..."
sudo systemctl stop nginx || docker compose stop nginx || true

# Generate SSL certificate
echo "🔐 Generating SSL certificate for $DOMAIN_NAME..."
sudo certbot certonly --standalone \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --domains $DOMAIN_NAME \
    --non-interactive

# Create SSL directory and copy certificates
echo "📋 Setting up SSL certificates..."
sudo mkdir -p /opt/clinic-api/ssl
sudo cp /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem /opt/clinic-api/ssl/cert.pem
sudo cp /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem /opt/clinic-api/ssl/key.pem
sudo chown -R $USER:$USER /opt/clinic-api/ssl
sudo chmod 600 /opt/clinic-api/ssl/key.pem
sudo chmod 644 /opt/clinic-api/ssl/cert.pem

# Update nginx configuration for HTTPS
echo "⚙️  Updating nginx configuration..."
cd /opt/clinic-api

# Backup original nginx.conf
cp nginx.conf nginx.conf.backup

# Create HTTPS-enabled nginx configuration
cat > nginx-https.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream clinic_api {
        server clinic-api:8080;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

    # Redirect HTTP to HTTPS
    server {
        listen 80;
        server_name DOMAIN_PLACEHOLDER;
        return 301 https://$server_name$request_uri;
    }

    # HTTPS server
    server {
        listen 443 ssl http2;
        server_name DOMAIN_PLACEHOLDER;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout 10m;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;
        ssl_stapling on;
        ssl_stapling_verify on;

        # Security headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;

        # CORS headers for mobile and web apps
        add_header Access-Control-Allow-Origin "*" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH" always;
        add_header Access-Control-Allow-Headers "Accept, Authorization, Content-Type, Origin, X-Requested-With, User-Agent, Access-Control-Allow-Origin, X-User-Id, X-Admin-Token" always;
        add_header Access-Control-Max-Age 3600 always;

        # Handle preflight OPTIONS requests
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin "*";
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH";
            add_header Access-Control-Allow-Headers "Accept, Authorization, Content-Type, Origin, X-Requested-With, User-Agent, Access-Control-Allow-Origin, X-User-Id, X-Admin-Token";
            add_header Access-Control-Max-Age 3600;
            add_header Content-Length 0;
            add_header Content-Type text/plain;
            return 204;
        }

        # Apply rate limiting
        limit_req zone=api burst=20 nodelay;

        # Proxy to API server
        location / {
            proxy_pass http://clinic_api;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        # Health check endpoint
        location /api/v1/health {
            access_log off;
            proxy_pass http://clinic_api;
        }
    }
}
EOF

# Replace placeholder with actual domain
sed "s/DOMAIN_PLACEHOLDER/$DOMAIN_NAME/g" nginx-https.conf > nginx.conf

# Update docker-compose to mount SSL certificates
echo "🐳 Updating Docker Compose configuration..."
cp docker-compose.yml docker-compose.yml.backup

# Add SSL volume mount to nginx service
cat > docker-compose-https.yml << 'EOF'
version: '3.8'

services:
  clinic-api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: clinic_api_server
    restart: unless-stopped
    ports:
      - "8080:8080"
    environment:
      # Database Configuration
      - MONGODB_URI_PROD=${MONGODB_URI_PROD}
      - MONGODB_URI_DEV=${MONGODB_URI_DEV}
      - MONGO_DB_NAME_PROD=${MONGO_DB_NAME_PROD}
      - MONGO_DB_NAME_DEV=${MONGO_DB_NAME_DEV}
      
      # Authentication Configuration
      - BASIC_AUTH_USERNAME=${BASIC_AUTH_USERNAME}
      - BASIC_AUTH_PASSWORD=${BASIC_AUTH_PASSWORD}
      - BASIC_AUTH_ADMIN_USERNAME=${BASIC_AUTH_ADMIN_USERNAME}
      - BASIC_AUTH_ADMIN_PASSWORD=${BASIC_AUTH_ADMIN_PASSWORD}
      - JWT_SECRET=${JWT_SECRET}
      
      # Email Configuration
      - SMTP_HOSTNAME=${SMTP_HOSTNAME}
      - SMTP_PORT=${SMTP_PORT}
      - SMTP_USERNAME=${SMTP_USERNAME}
      - SMTP_PASSWORD=${SMTP_PASSWORD}
      
      # Security Configuration
      - ENCRYPTION_KEY=${ENCRYPTION_KEY}
      
      # Application Configuration
      - VAPOR_ENV=production
      - API_BASE_URL=https://DOMAIN_PLACEHOLDER
      
    env_file:
      - .env
    networks:
      - clinic-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/v1/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  nginx:
    image: nginx:alpine
    container_name: clinic_nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - clinic-api
    networks:
      - clinic-network

networks:
  clinic-network:
    driver: bridge

volumes:
  clinic-data:
    driver: local
EOF

# Replace placeholder with actual domain
sed "s/DOMAIN_PLACEHOLDER/$DOMAIN_NAME/g" docker-compose-https.yml > docker-compose.yml

# Update environment variables
echo "📝 Updating environment variables..."
sed -i.bak "s|API_BASE_URL=http://3.6.173.209:8080|API_BASE_URL=https://$DOMAIN_NAME|g" .env

# Set up certificate renewal
echo "🔄 Setting up automatic certificate renewal..."
(crontab -l 2>/dev/null; echo "0 3 * * * /usr/bin/certbot renew --quiet --post-hook 'systemctl restart clinic-api'") | crontab -

# Deploy with HTTPS
echo "🚀 Deploying with HTTPS enabled..."
./deploy.sh production

echo ""
echo "🎉 HTTPS setup completed!"
echo "========================================"
echo "📡 Your API is now accessible at:"
echo "   🔒 HTTPS: https://$DOMAIN_NAME"
echo "   🔒 Health Check: https://$DOMAIN_NAME/api/v1/health"
echo ""
echo "📊 Useful commands:"
echo "   Check SSL: curl -I https://$DOMAIN_NAME/api/v1/health"
echo "   SSL Grade: https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN_NAME"
echo "   Renew cert: sudo certbot renew"
echo ""
echo "⚠️  Notes:"
echo "   - HTTP traffic is automatically redirected to HTTPS"
echo "   - Certificates auto-renew via cron job"
echo "   - Update your mobile/web apps to use HTTPS URLs"