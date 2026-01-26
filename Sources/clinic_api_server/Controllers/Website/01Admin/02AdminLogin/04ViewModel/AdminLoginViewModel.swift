import Vapor
import MongoDBVapor

struct AdminLoginViewModel: AdminLoginProtocol {
    
    static func login(req: Request) async throws -> Response {
        // 1. Check if authenticated via Basic Auth Middleware
        if let _ = req.auth.get(AdminUser.self) {
            return try await generateToken(on: req)
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
        
        guard loginRequest.username == adminUsername && 
              loginRequest.password == adminPassword else {
            throw Abort(.unauthorized, reason: "Invalid username or password")
        }
        
        return try await generateToken(on: req)
    }

    private static func generateToken(on req: Request) async throws -> Response {
        let token = Environment.get(environmentKey: .ENCRYPTION_KEY) ?? "monalisha_admin_token_2026"
        
        return await ResponseHandler.success(
            message: "Admin login successful",
            data: SMAdminLoginResponse(token: token),
            on: req
        )
    }
}
