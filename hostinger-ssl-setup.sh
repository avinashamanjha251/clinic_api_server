#!/bin/bash

# Hostinger Domain + SSL Setup Guide
# For use when you have a domain from Hostinger

set -e

DOMAIN_NAME="monalishadentalcare.com"  # Replace with your Hostinger domain
AWS_IP="3.6.173.209"
EMAIL="monalishadentalcareandopgcentr@gmail.com"

echo "🌐 Hostinger Domain + SSL Setup"
echo "==============================="

echo "📋 STEP 1: Domain Setup in Hostinger"
echo "   1. Login to Hostinger hPanel"
echo "   2. Go to DNS Zone Editor"
echo "   3. Add A record:"
echo "      Name: @ (root domain)"
echo "      Points to: $AWS_IP"
echo "      TTL: 300"
echo "   4. Add A record for API:"
echo "      Name: api"
echo "      Points to: $AWS_IP"
echo "      TTL: 300"
echo ""

echo "📋 STEP 2: Wait for DNS Propagation (5-30 minutes)"
echo "   Check with: nslookup $DOMAIN_NAME"
echo "   Should return: $AWS_IP"
echo ""

read -p "Have you completed DNS setup in Hostinger? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please complete DNS setup first and run this script again."
    exit 1
fi

# Test DNS resolution
echo "🔍 Testing DNS resolution..."
if nslookup $DOMAIN_NAME | grep -q $AWS_IP; then
    echo "✅ DNS is working correctly"
else
    echo "❌ DNS not propagated yet. Wait a few minutes and try again."
    exit 1
fi

# Install Certbot if not present
echo "📦 Installing Certbot..."
if ! command -v certbot &> /dev/null; then
    sudo apt update
    sudo snap install core; sudo snap refresh core
    sudo snap install --classic certbot
    sudo ln -sf /snap/bin/certbot /usr/bin/certbot
fi

# Stop nginx to free up port 80
echo "🛑 Stopping nginx for certificate generation..."
docker compose stop nginx || sudo systemctl stop nginx || true

# Generate SSL certificate
echo "🔐 Generating SSL certificate for $DOMAIN_NAME..."
sudo certbot certonly --standalone \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --domains $DOMAIN_NAME \
    --domains api.$DOMAIN_NAME \
    --non-interactive

# Setup SSL certificates
echo "📋 Setting up SSL certificates..."
sudo mkdir -p ./ssl
sudo cp /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem ./ssl/cert.pem
sudo cp /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem ./ssl/key.pem
sudo chown -R $USER:$USER ./ssl
sudo chmod 600 ./ssl/key.pem
sudo chmod 644 ./ssl/cert.pem

# Update nginx configuration
echo "⚙️  Updating nginx for HTTPS..."
sed -i "s/server_name 3.6.173.209;/server_name $DOMAIN_NAME api.$DOMAIN_NAME;/g" nginx.conf

# Update environment variables
echo "📝 Updating environment variables..."
sed -i "s|API_BASE_URL=http://3.6.173.209:8080|API_BASE_URL=https://$DOMAIN_NAME|g" .env
sed -i "s|API_BASE_URL=http://3.6.173.209:8080|API_BASE_URL=https://$DOMAIN_NAME|g" docker-compose.yml

# Set up auto-renewal
echo "🔄 Setting up certificate auto-renewal..."
(crontab -l 2>/dev/null; echo "0 3 * * * /usr/bin/certbot renew --quiet --post-hook 'docker compose restart nginx'") | crontab -

# Deploy with HTTPS
echo "🚀 Deploying with HTTPS..."
./deploy.sh production

echo ""
echo "🎉 HTTPS setup completed!"
echo "=========================="
echo "📡 Your API endpoints:"
echo "   🔒 Main: https://$DOMAIN_NAME/api/v1/health"
echo "   🔒 API:  https://api.$DOMAIN_NAME/api/v1/health"
echo ""
echo "📱 Mobile/Web App Base URLs:"
echo "   const API_BASE_URL = 'https://$DOMAIN_NAME';"
echo "   const API_BASE_URL = 'https://api.$DOMAIN_NAME';"
echo ""
echo "✅ Benefits:"
echo "   - Trusted SSL certificates (no browser warnings)"
echo "   - Automatic renewal via cron job"
echo "   - Professional domain setup"
echo "   - Mobile app compatibility"