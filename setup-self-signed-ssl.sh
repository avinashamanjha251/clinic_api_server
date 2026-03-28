#!/bin/bash

# Self-Signed SSL Setup for AWS Lightsail (IP-based)
# Use this if you don't have a domain name

set -e

AWS_IP="3.7.95.138"

echo "🔒 Setting up Self-Signed SSL for IP: $AWS_IP"
echo "==============================================="

# Create SSL directory
echo "📁 Creating SSL directory..."
mkdir -p ssl

# Generate self-signed certificate
echo "🔐 Generating self-signed SSL certificate..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/key.pem \
    -out ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=$AWS_IP" \
    -addext "subjectAltName = IP:$AWS_IP"

# Set proper permissions
chmod 600 ssl/key.pem
chmod 644 ssl/cert.pem

echo "✅ Self-signed certificate generated!"
echo ""
echo "⚠️  IMPORTANT NOTES:"
echo "   - Browsers will show 'Not Secure' warning for self-signed certificates"
echo "   - Users need to accept the security warning to proceed"
echo "   - For production, use a proper domain with Let's Encrypt SSL"
echo ""
echo "🚀 To enable HTTPS with this certificate:"
echo "   1. Update nginx.conf to uncomment HTTPS section"
echo "   2. Run: docker compose up -d --build"
echo "   3. Access via: https://$AWS_IP (accept security warning)"