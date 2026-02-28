import Vapor
import MongoDBVapor

struct AdminLoginViewModel: AdminLoginProtocol {
    
    static let baseViewModel = BaseMongoViewModel<SMAdminUserModel>()
    
    static func login(req: Request) async throws -> Response {
        // 1. Check if authenticated via Basic Auth Middleware
        if let _ = req.auth.get(AdminUser.self) {
            let rootUsername = Environment.get(environmentKey: .BASIC_AUTH_USERNAME) ?? "admin"
            return try await generateTokenForRoot(on: req, username: rootUsername)
        }

        // 2. Fallback to decoding login request JSON body
        let loginRequest: SMAdminLoginRequest
        if let decryptedData = req.decryptedBody {
            loginRequest = try JSONDecoder().decode(SMAdminLoginRequest.self, from: decryptedData)
        } else {
            loginRequest = try req.content.decode(SMAdminLoginRequest.self)
        }
        
        let adminUsername = Environment.get(environmentKey: .BASIC_AUTH_USERNAME) ?? "admin"
        let adminPassword = Environment.get(environmentKey: .BASIC_AUTH_PASSWORD) ?? "password"
        
        // 3. Root Admin validation
        if loginRequest.username == adminUsername && loginRequest.password == adminPassword {
            return try await generateTokenForRoot(on: req, username: adminUsername)
        }
        
        // 4. MongoDB Admin validation
        let existingUser = try await baseViewModel.readOne(
            filter: ["username": .string(loginRequest.username)],
            on: req
        )
        guard var user = existingUser,
              try Bcrypt.verify(loginRequest.password, created: user.passwordHash) else {
            throw Abort(.unauthorized, reason: "Invalid username or password")
        }
        
        // 5. Generate token and update DB
        let token = try req.jwtService.generateToken(for: user)
        user.accessToken = token
        
        if let objectId = user._id {
            try? await baseViewModel.updateDocument(
                objectId: objectId,
                model: user,
                on: req,
                ignoredKeys: [ApiKey.id, ApiKey.passwordHash, ApiKey.jwtId]
            )
        }
        
        return await ResponseHandler.success(
            message: "Admin login successful",
            data: SMAdminLoginResponse(token: token),
            on: req
        )
    }

    private static func generateTokenForRoot(on req: Request, username: String) async throws -> Response {
        let rootUser = SMAdminUserModel(
            name: "Root Admin",
            username: username,
            passwordHash: "",
            jwtId: UUID().uuidString,
            accessToken: ""
        )
        
        let token = try req.jwtService.generateToken(for: rootUser)
        return await ResponseHandler.success(
            message: "Admin login successful",
            data: SMAdminLoginResponse(token: token),
            on: req
        )
    }
    
    // MARK: - Logout
    
    static func logout(req: Request) async throws -> Response {
        // 1. Get the authenticated JWT payload
        guard let payload = req.auth.get(JWTUserPayload.self) else {
            throw Abort(.unauthorized, reason: "Not authenticated")
        }
        
        // 2. Blacklist the token's jwtId so it can't be used again
        let blacklistedToken = SMBlacklistedToken(
            jwtId: payload.jwtId.value,
            userId: payload.userId
        )
        
        let blacklistVM = BaseMongoViewModel<SMBlacklistedToken>()
        _ = try await blacklistVM.createDocument(blacklistedToken, on: req)
        
        // 3. Clear the stored accessToken in the user's DB record (if DB user)
        if let objId = try? BSONObjectID(payload.userId) {
            _ = try await baseViewModel.update(
                filter: ["_id": .objectID(objId)],
                to: ["accessToken": .string("")],
                on: req
            )
        }
        
        return await ResponseHandler.success(
            message: "Logged out successfully",
            data: nil as ResponseHandler.EmptyData?,
            on: req
        )
    }
}
