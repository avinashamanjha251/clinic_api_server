# HTTPS Setup Guide

This guide covers two methods to enable HTTPS for your Clinic API server on AWS Lightsail.

## Method 1: With Domain Name (Recommended for Production)

### Prerequisites
1. Own a domain name (e.g., `api.clinicname.com`)
2. Point domain's A record to your server IP: `3.6.173.209`
3. Wait for DNS propagation (usually 1-24 hours)

### Setup Steps
1. **Update the setup script**:
   ```bash
   # Edit setup-https.sh
   nano setup-https.sh
   # Change DOMAIN_NAME="your-domain.com" to your actual domain
   ```

2. **Run HTTPS setup**:
   ```bash
   ./setup-https.sh
   ```

3. **Access your API**:
   - 🔒 **HTTPS**: `https://your-domain.com/api/v1/health`
   - ✅ **Trusted SSL**: No browser warnings
   - 🔄 **Auto-renewal**: Certificates renew automatically

### Benefits
- ✅ Trusted SSL certificates (no browser warnings)
- ✅ Automatic certificate renewal
- ✅ Production-ready security
- ✅ SEO and user trust benefits

---

## Method 2: Self-Signed SSL (Quick Setup, IP-Based)

### For immediate HTTPS testing or development

1. **Generate self-signed certificate**:
   ```bash
   ./setup-self-signed-ssl.sh
   ```

2. **Deploy with HTTPS enabled**:
   ```bash
   docker compose up -d --build
   ```

3. **Access your API**:
   - 🔒 **HTTPS**: `https://3.6.173.209/api/v1/health`
   - ⚠️ **Browser warning**: Users must accept "Not Secure" warning
   - 📱 **Mobile apps**: May need to accept untrusted certificates

### Limitations
- ⚠️ Browser security warnings
- ❌ Not suitable for production
- 📱 Mobile apps may reject untrusted certificates

---

## Mobile & Web App Integration

### Update your API base URLs:

**For Domain-based HTTPS**:
```javascript
const API_BASE_URL = 'https://your-domain.com';

// Example API call
const response = await fetch(`${API_BASE_URL}/api/v1/health`, {
  method: 'GET',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer your-jwt-token'
  }
});
```

**For IP-based HTTPS** (development only):
```javascript
const API_BASE_URL = 'https://3.6.173.209';
// Note: Mobile apps may need additional SSL configuration
```

### Mobile App Configuration

**iOS (Swift)**:
```swift
// For self-signed certificates in development only
// Add to Info.plist for development
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>3.6.173.209</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

**Android (Kotlin)**:
```kotlin
// For self-signed certificates in development only
// Create network security config
```

---

## AWS Lightsail Firewall Configuration

Ensure these ports are open in AWS Lightsail console:

1. **Go to**: AWS Lightsail → Your Instance → Networking tab
2. **Add firewall rules**:
   - **HTTPS**: Port 443, Protocol TCP
   - **HTTP**: Port 80, Protocol TCP (for redirects)
   - **SSH**: Port 22, Protocol TCP
   - **API Direct**: Port 8080, Protocol TCP (optional)

---

## Security Best Practices

### 1. Force HTTPS Redirect
Your nginx is configured to redirect all HTTP traffic to HTTPS automatically.

### 2. Security Headers
The following security headers are automatically added:
- `Strict-Transport-Security`: Force HTTPS
- `X-Frame-Options`: Prevent clickjacking
- `X-Content-Type-Options`: Prevent MIME sniffing
- `X-XSS-Protection`: XSS protection

### 3. CORS Configuration
CORS is properly configured for:
- All origins (`*`) - update for production to specific domains
- Required headers for mobile/web apps
- Proper preflight handling

---

## Testing HTTPS

### 1. Health Check
```bash
curl -k https://3.6.173.209/api/v1/health
# or with domain:
curl https://your-domain.com/api/v1/health
```

### 2. SSL Grade Check (for domain-based SSL)
Visit: https://www.ssllabs.com/ssltest/analyze.html?d=your-domain.com

### 3. Browser Test
Open in browser and check for:
- 🔒 Lock icon in address bar
- No security warnings (for domain-based SSL)
- Proper CORS headers in developer tools

---

## Troubleshooting

### Common Issues

1. **Certificate errors**:
   - Verify domain points to correct IP
   - Check DNS propagation: `nslookup your-domain.com`

2. **Port 443 blocked**:
   - Check AWS Lightsail firewall settings
   - Verify nginx is running: `docker compose ps`

3. **Mixed content warnings**:
   - Update all API calls to use HTTPS URLs
   - Check for HTTP assets loaded on HTTPS pages

### Commands for debugging:
```bash
# Check certificate validity
openssl s_client -connect 3.6.173.209:443

# Check nginx logs
docker compose logs nginx

# Restart services
docker compose restart
```

---

## Recommendation

**For Production**: Use Method 1 (Domain + Let's Encrypt)
**For Development/Testing**: Use Method 2 (Self-signed)

The domain-based approach provides the best security, user experience, and mobile app compatibility.