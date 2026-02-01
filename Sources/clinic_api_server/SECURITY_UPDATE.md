# Security & Middleware Update Summary

## ✅ All Routes Secured with Basic Auth

Authentication/Security layers have been applied to all endpoints according to their role (User vs Admin).

### 1. User / Public Routes
Secured with `SimpleBasicAuthMiddleware` + Encryption Stack.
These routes require the Basic Auth credentials defined in environment variables (`BASIC_AUTH_USERNAME`, `BASIC_AUTH_PASSWORD`).

| Module | Route | Middleware Applied |
|--------|-------|-------------------|
| **Contact** | `GET /api/v1/contact` | ✅ Basic Auth, Encryption |
| **Contact** | `POST /api/v1/contact/appointment` | ✅ Basic Auth, Encryption |
| **Services** | `GET /api/v1/services` | ✅ Basic Auth, Encryption |
| **About** | `GET /api/v1/about` | ✅ Basic Auth, Encryption |

### 2. Admin Routes
Secured with `AdminBasicAuthenticator` + Encryption Stack.
These routes require the same Basic Auth credentials but perform Admin-specific authentication logic.

| Module | Route | Middleware Applied |
|--------|-------|-------------------|
| **Admin Login** | `POST /api/v1/admin/auth/login` | ✅ Admin Basic Auth, Encryption |
| **Admin Register** | `POST /api/v1/admin/register` | ✅ Admin Basic Auth, Encryption |

### 3. Middleware Stack Details

#### Encryption Layer
- **DecryptionMiddleware**: Decrypts incoming request body/query (`data` parameter).
- **EncryptionResponseMiddleware**: Encrypts outgoing response body.

#### Authentication Layer
- **SimpleBasicAuthMiddleware**:
  - Used for public data endpoints.
  - Returns `401 Unauthorized` if credentials content match `BASIC_AUTH_USERNAME`/`PASSWORD`.
  
- **AdminBasicAuthenticator**:
  - Used for Admin Auth endpoints.
  - Logs in `AdminUser` to `req.auth` upon success.
  - Supports dual auth (Basic Auth Header OR JSON Body logic in ViewModel).

## Configuration

Ensure the following Environment Variables are set:
```bash
BASIC_AUTH_USERNAME=your_username
BASIC_AUTH_PASSWORD=your_password
ENCRYPTION_KEY=your_encryption_key
```

## How to Access

### User Routes (e.g. Services)
```bash
curl -X GET http://localhost:8080/api/v1/services \
  -H "Authorization: Basic base64(user:pass)" \
  -H "Content-Type: application/json"
# Note: Data parameter might be required via query string if encryption is strict
```

### Admin Routes
```bash
curl -X POST http://localhost:8080/api/v1/admin/register \
  -H "Authorization: Basic base64(user:pass)" \
  -H "Content-Type: application/json" \
  -d '...encrypted_payload...'
```
