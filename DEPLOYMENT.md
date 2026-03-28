# Clinic API Server - Docker Deployment

## Overview
This Docker configuration provides a production-ready deployment for the Clinic API Server with all required environment variables and CORS support for mobile and web applications.

## Files Created
- `Dockerfile` - Multi-stage Docker build for the Swift Vapor application
- `docker-compose.yml` - Complete service orchestration
- `nginx.conf` - Reverse proxy with CORS headers and security
- `deploy.sh` - Automated deployment script
- `.env.template` - Environment variable template

## Quick Start

### 1. Environment Setup
```bash
# Copy and customize environment variables
cp .env.template .env
# Edit .env with your actual values
```

### 2. Deploy
```bash
# Make deployment script executable (already done)
chmod +x deploy.sh

# Deploy to production
./deploy.sh production
```

### 3. Verify Deployment
The API will be accessible at: `http://3.6.173.209:8080`

## Architecture

### Services
1. **clinic-api**: Main Swift Vapor application
2. **nginx**: Reverse proxy with CORS and security headers

### Network Configuration
- **Port 8080**: Direct API access
- **Port 80**: HTTP through Nginx (with CORS enabled)
- **Port 443**: HTTPS (when SSL certificates are configured)

### Security Features
- CORS enabled for mobile and web apps
- Rate limiting (10 requests/second)
- Security headers (XSS, Content-Type, Frame-Options)
- Health checks
- Non-root container execution

## Mobile & Web App Integration

### CORS Configuration
The server is configured to accept requests from:
- All origins (`*`)
- Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH
- Custom headers: X-User-Id, X-Admin-Token, Authorization

### API Endpoints
Base URL: `http://3.6.173.209:8080`

Example mobile app configuration:
```javascript
const API_BASE_URL = 'http://3.6.173.209:8080';
const headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer your-jwt-token',
  'X-User-Id': 'user-id-here'
};
```

## Environment Variables

### Required Variables
All variables from `.env` are automatically loaded:
- Database: MongoDB connection strings
- Authentication: JWT secrets and basic auth
- Email: SMTP configuration
- Security: Encryption keys

### AWS Lightsail Integration
- Static IP: `3.6.173.209`
- Configured in nginx and docker-compose
- Health checks enabled for load balancer compatibility

## Management Commands

### Start Services
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### View Logs
```bash
docker-compose logs -f clinic-api
```

### Rebuild and Deploy
```bash
./deploy.sh production
```

### Health Check
```bash
curl http://3.6.173.209:8080/health
```

## SSL/HTTPS Setup (Optional)

To enable HTTPS:
1. Obtain SSL certificates
2. Place them in `./ssl/cert.pem` and `./ssl/key.pem`
3. Uncomment HTTPS section in `nginx.conf`
4. Restart services

## Monitoring

### Health Checks
- Docker health checks every 30 seconds
- Nginx upstream health monitoring
- Application-level health endpoint

### Logs
- Application logs: `docker-compose logs clinic-api`
- Nginx logs: `docker-compose logs nginx`
- System logs: Available through Docker

## Troubleshooting

### Common Issues
1. **Port conflicts**: Ensure ports 80, 443, 8080 are available
2. **Environment variables**: Check `.env` file exists and is properly formatted
3. **MongoDB connection**: Verify MONGODB_URI_PROD is accessible
4. **CORS issues**: Check nginx configuration and restart if modified

### Debug Commands
```bash
# Check container status
docker-compose ps

# Enter container for debugging
docker-compose exec clinic-api /bin/bash

# Check environment variables
docker-compose exec clinic-api printenv
```

## Production Recommendations

1. **Security**: Use secrets management (AWS Secrets Manager)
2. **Monitoring**: Add Prometheus/Grafana for metrics
3. **Backup**: Implement MongoDB backup strategy
4. **SSL**: Enable HTTPS with proper certificates
5. **Firewall**: Configure AWS security groups properly
6. **Scaling**: Use Docker Swarm or Kubernetes for multiple instances