# DNS Configuration for api.monalishadentalcareandopgcentre.com

## Required DNS Records

Add these DNS records in your domain provider's control panel:

### A Record for API Subdomain
```
Type: A
Name: api
Value: 3.6.173.209
TTL: 300 (5 minutes)
```

This creates: `api.monalishadentalcareandopgcentre.com` → `3.6.173.209`

## Verification Steps

### 1. Check DNS Propagation
```bash
# Check if DNS is working
nslookup api.monalishadentalcareandopgcentre.com

# Should return:
# Name: api.monalishadentalcareandopgcentre.com
# Address: 3.6.173.209
```

### 2. Online DNS Checker
Visit: https://dnschecker.org
- Enter: `api.monalishadentalcareandopgcentre.com`
- Check A Record propagation globally

### 3. Test API Access
```bash
# Test HTTP (should work immediately after DNS)
curl http://api.monalishadentalcareandopgcentre.com/api/v1/health

# Test HTTPS (after running setup-https.sh)
curl https://api.monalishadentalcareandopgcentre.com/api/v1/health
```

## Deployment Steps

### 1. Configure DNS First
- Add the A record in your domain provider
- Wait 5-15 minutes for propagation

### 2. Deploy to AWS Lightsail
```bash
# Copy files to your AWS server
scp -r . user@3.6.173.209:/opt/clinic-api/

# On AWS server, run:
./aws-lightsail-deploy.sh    # Basic setup
./setup-https.sh             # Enable HTTPS with Let's Encrypt
```

### 3. Your API Will Be Available At:
- **HTTPS**: https://api.monalishadentalcareandopgcentre.com/api/v1/health
- **HTTP**: http://api.monalishadentalcareandopgcentre.com/api/v1/health (redirects to HTTPS)

## Mobile & Web App Integration

Update your app's API base URL to:
```javascript
const API_BASE_URL = 'https://api.monalishadentalcareandopgcentre.com';

// Example usage:
const response = await fetch(`${API_BASE_URL}/api/v1/health`);
```

## Common DNS Providers

### GoDaddy
1. Login → My Products → DNS
2. Add Record → Type: A, Name: api, Points to: 3.6.173.209

### Cloudflare  
1. Dashboard → DNS → Records
2. Add Record → Type: A, Name: api, IPv4: 3.6.173.209

### Namecheap
1. Domain List → Manage → Advanced DNS
2. Add Record → Type: A, Host: api, Value: 3.6.173.209

DNS propagation typically takes 5-30 minutes but can take up to 24 hours globally.