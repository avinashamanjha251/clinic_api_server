# Admin Registration Module

Complete documentation for the Admin Registration API endpoint.

---

## Table of Contents
1. [Overview](#overview)
2. [API Endpoint](#api-endpoint)
3. [Architecture](#architecture)
4. [Validation System](#validation-system)
5. [Database Operations](#database-operations)
6. [Middleware Stack](#middleware-stack)
7. [Security Features](#security-features)
8. [Usage Examples](#usage-examples)
9. [Error Handling](#error-handling)

---

## Overview

The Admin Registration module provides a secure endpoint for creating new admin users with:
- ✅ Declarative validation using Vapor's `Validatable` protocol
- ✅ Automatic whitespace trimming with `@Trimmed` property wrapper
- ✅ Password hashing using Bcrypt
- ✅ BaseMongoViewModel for database operations
- ✅ Dual authentication support (JSON body + Basic Auth)
- ✅ Encryption/Decryption middleware support

---

## API Endpoint

### POST `/api/v1/admin/auth/register`

Creates a new admin user and returns an access token.

#### Request Body
```json
{
  "name": "John Doe",
  "username": "johndoe",
  "password": "securepassword123"
}
```

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Admin registered successfully",
  "data": {
    "name": "John Doe",
    "username": "johndoe",
    "accessToken": "your-access-token-here",
    "tokenType": "Bearer",
    "expiresIn": 3600
  }
}
```

#### Error Responses

**400 Bad Request - Validation Failed**
```json
{
  "error": true,
  "reason": "Name is required and cannot be empty"
}
```

**409 Conflict - Username Exists**
```json
{
  "error": true,
  "reason": "Username already exists"
}
```

---

## Architecture

### Folder Structure
```
01AdminRegister/
├── 01Route/
│   └── AdminRegisterRoutes.swift          # Route configuration
├── 02Protocols/
│   └── AdminRegisterProtocol.swift        # Protocol definition
├── 03Model/
│   ├── SMAdminUserModel.swift             # MongoDB schema
│   ├── SMAdminRegisterRequest.swift       # Request model with validation
│   └── SMAdminRegisterResponse.swift      # Response model
├── 04ViewModel/
│   └── AdminRegisterViewModel.swift       # Business logic
├── 05Helpers/
│   └── AdminRegistrationError.swift       # Error messages
└── README.md                              # This file
```

### Key Components

#### 1. Request Model (`SMAdminRegisterRequest.swift`)
```swift
struct SMAdminRegisterRequest: Content, Validatable {
    @Trimmed var name: String
    @Trimmed var username: String
    @Trimmed var password: String
    
    static func validations(_ validations: inout Validations) {
        validations.add(apiKey: ApiKey.name,
                        as: String.self,
                        is: !.empty && .count(2...100),
                        customFailureDescription: AdminRegistrationError.nameNotAllowedToBeEmpty)
        
        validations.add(apiKey: ApiKey.username,
                        as: String.self,
                        is: !.empty && .count(3...50),
                        customFailureDescription: AdminRegistrationError.usernameNotAllowedToBeEmpty)
        
        validations.add(apiKey: ApiKey.password,
                        as: String.self,
                        is: !.empty && .count(6...100),
                        customFailureDescription: AdminRegistrationError.passwordNotAllowedToBeEmpty)
    }
}
```

#### 2. ViewModel (`AdminRegisterViewModel.swift`)
```swift
struct AdminRegisterViewModel: AdminRegisterProtocol {
    
    // Base view model for database operations
    static let baseViewModel = BaseMongoViewModel<SMAdminUserModel>()
    
    static func register(req: Request) async throws -> Response {
        // 1. Validate request
        try SMAdminRegisterRequest.validate(content: req)
        let registerRequest = try req.decodeContent(SMAdminRegisterRequest.self)
        
        // 2. Check username uniqueness
        let existingUser = try await baseViewModel.readOne(
            filter: ["username": .string(registerRequest.username)],
            on: req
        )
        
        guard existingUser == nil else {
            throw Abort(.conflict, reason: "Username already exists")
        }
        
        // 3. Hash password and create user
        let passwordHash = try Bcrypt.hash(registerRequest.password)
        let newAdmin = SMAdminUserModel(
            name: registerRequest.name,
            username: registerRequest.username,
            passwordHash: passwordHash
        )
        
        // 4. Save to database
        try await baseViewModel.createDocument(newAdmin, on: req)
        
        // 5. Return response with token
        // ...
    }
}
```

#### 3. Database Model (`SMAdminUserModel.swift`)
```swift
struct SMAdminUserModel: MongoSchemaModel {
    static var collectionName: String = "admin_users"
    
    var _id: BSONObjectID?
    let name: String
    let username: String
    let passwordHash: String
    let createdAt: Date
    let updatedAt: Date
}
```

---

## Validation System

### Validation Rules

| Field | Constraints | Error Message |
|-------|-------------|---------------|
| **name** | • Not empty<br>• 2-100 characters<br>• Auto-trimmed | "Name is required and cannot be empty" |
| **username** | • Not empty<br>• 3-50 characters<br>• Auto-trimmed | "Username is required and cannot be empty" |
| **password** | • Not empty<br>• 6-100 characters<br>• Auto-trimmed | "Password is required and cannot be empty" |

### @Trimmed Property Wrapper

Automatically removes leading/trailing whitespace:

```swift
@propertyWrapper
public struct Trimmed: Codable {
    private var value: String
    
    public var wrappedValue: String {
        get { value }
        set { value = newValue.trimmingCharacters(in: .whitespaces) }
    }
}
```

**Example:**
```json
// Input
{
  "name": "  John Doe  ",
  "username": "  johndoe  "
}

// After @Trimmed processing
{
  "name": "John Doe",
  "username": "johndoe"
}
```

### Validation Flow

```
Request → Decode → Validate → Process
                      ↓
                   Fail? → Return 400 with error
                      ↓
                   Pass → Continue to business logic
```

---

## Database Operations

### Using BaseMongoViewModel

The module uses `BaseMongoViewModel<SMAdminUserModel>()` for all database operations:

#### Check if User Exists
```swift
let existingUser = try await baseViewModel.readOne(
    filter: ["username": .string(username)],
    on: req
)
```

#### Create New User
```swift
try await baseViewModel.createDocument(newAdmin, on: req)
```

#### Available Methods
- `createDocument()` - Insert new document
- `readOne()` - Find single document
- `readFilteredRawData()` - Query with filters
- `updateDocument()` - Update existing document
- `delete()` - Delete document
- `aggregate()` - Run aggregation pipeline

### Database Schema

**Collection:** `admin_users`

```javascript
{
  "_id": ObjectId,
  "name": String,
  "username": String,        // Unique
  "passwordHash": String,    // Bcrypt hashed
  "createdAt": Date,
  "updatedAt": Date
}
```

---

## Middleware Stack

### Route Configuration
```swift
let adminAuth = r.grouped("admin", "auth")
                 .grouped(AdminBasicAuthenticator())      // 1. Basic Auth
                 .grouped(DecryptionMiddleware())         // 2. Decrypt body
                 .grouped(EncryptionResponseMiddleware()) // 3. Encrypt response
```

### Middleware Order (Important!)
1. **AdminBasicAuthenticator** - Validates HTTP Basic Auth headers
2. **DecryptionMiddleware** - Decrypts encrypted request body
3. **EncryptionResponseMiddleware** - Encrypts response body

### Authentication Methods

#### Method 1: JSON Body (Primary)
```bash
POST /api/v1/admin/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "username": "johndoe",
  "password": "securepass123"
}
```

#### Method 2: HTTP Basic Auth (Alternative)
```bash
POST /api/v1/admin/auth/register
Authorization: Basic base64(username:password)
Content-Type: application/json

{
  "name": "John Doe"
}
```

---

## Security Features

### 1. Password Hashing
- **Algorithm:** Bcrypt
- **Implementation:** `Bcrypt.hash(password)`
- **Storage:** Only hashed passwords stored in database

### 2. Input Validation
- Declarative validation rules
- Automatic whitespace trimming
- Length constraints enforced
- Type safety guaranteed

### 3. Username Uniqueness
- Database-level uniqueness check
- Prevents duplicate registrations
- Returns 409 Conflict on duplicates

### 4. Encryption Support
- Request body encryption via `DecryptionMiddleware`
- Response encryption via `EncryptionResponseMiddleware`
- Transparent to business logic

### 5. Basic Auth Support
- Optional HTTP Basic Authentication
- Dual authentication methods
- Flexible client integration

---

## Usage Examples

### cURL Examples

#### Standard Registration
```bash
curl -X POST http://localhost:8080/api/v1/admin/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "username": "johndoe",
    "password": "securepass123"
  }'
```

#### With Basic Auth
```bash
curl -X POST http://localhost:8080/api/v1/admin/auth/register \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic $(echo -n 'johndoe:securepass123' | base64)" \
  -d '{
    "name": "John Doe"
  }'
```

### Swift Client Example
```swift
struct RegisterRequest: Codable {
    let name: String
    let username: String
    let password: String
}

let request = RegisterRequest(
    name: "John Doe",
    username: "johndoe",
    password: "securepass123"
)

let url = URL(string: "http://localhost:8080/api/v1/admin/auth/register")!
var urlRequest = URLRequest(url: url)
urlRequest.httpMethod = "POST"
urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
urlRequest.httpBody = try JSONEncoder().encode(request)

let (data, response) = try await URLSession.shared.data(for: urlRequest)
let result = try JSONDecoder().decode(RegisterResponse.self, from: data)
```

---

## Error Handling

### Validation Errors (400)

| Error | Cause | Solution |
|-------|-------|----------|
| "Name is required and cannot be empty" | Name < 2 chars | Provide name with 2-100 characters |
| "Username is required and cannot be empty" | Username < 3 chars | Provide username with 3-50 characters |
| "Password is required and cannot be empty" | Password < 6 chars | Provide password with 6-100 characters |

### Business Logic Errors

| Status | Error | Cause | Solution |
|--------|-------|-------|----------|
| 409 | "Username already exists" | Duplicate username | Choose different username |
| 500 | "Internal server error" | Database/system error | Check logs, retry |

### Error Response Format
```json
{
  "error": true,
  "reason": "Detailed error message"
}
```

---

## Testing

### Valid Test Cases

```json
// Minimum valid values
{
  "name": "Jo",
  "username": "joe",
  "password": "pass12"
}

// With whitespace (auto-trimmed)
{
  "name": "  John Doe  ",
  "username": "  johndoe  ",
  "password": "  securepass123  "
}

// Maximum length
{
  "name": "A very long name with exactly 100 characters...",
  "username": "username_with_50_chars_exactly_here_test",
  "password": "A very secure password with 100 characters..."
}
```

### Invalid Test Cases

```json
// Name too short
{
  "name": "J",
  "username": "johndoe",
  "password": "securepass123"
}

// Username too short
{
  "name": "John Doe",
  "username": "jo",
  "password": "securepass123"
}

// Password too short
{
  "name": "John Doe",
  "username": "johndoe",
  "password": "12345"
}

// Empty fields
{
  "name": "",
  "username": "",
  "password": ""
}
```

---

## Pattern Consistency

This module follows the same patterns used throughout the application:

### Validation Pattern
```swift
// Same as SMOtpValidator
struct SMAdminRegisterRequest: Content, Validatable {
    @Trimmed var field: String
    static func validations(_ validations: inout Validations) { ... }
}
```

### Database Pattern
```swift
// Same as other view models
static let baseViewModel = BaseMongoViewModel<Model>()
```

### Route Pattern
```swift
// Same middleware stack as login
.grouped(AdminBasicAuthenticator())
.grouped(DecryptionMiddleware())
.grouped(EncryptionResponseMiddleware())
```

---

## Summary

The Admin Registration module provides:

✅ **Secure Registration** - Bcrypt password hashing  
✅ **Input Validation** - Declarative validation with `Validatable`  
✅ **Auto-Trimming** - `@Trimmed` property wrapper  
✅ **Database Operations** - `BaseMongoViewModel` integration  
✅ **Dual Authentication** - JSON body + Basic Auth support  
✅ **Encryption Support** - Request/response encryption  
✅ **Error Handling** - Comprehensive error messages  
✅ **Pattern Consistency** - Matches application standards  

For questions or issues, refer to the source code or contact the development team.
