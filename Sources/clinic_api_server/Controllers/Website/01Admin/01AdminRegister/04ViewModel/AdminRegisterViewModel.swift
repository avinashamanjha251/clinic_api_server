import Vapor
import MongoDBVapor

struct AdminRegisterViewModel: AdminRegisterProtocol {
    
    // Base view model for database operations
    static let baseViewModel = BaseMongoViewModel<SMAdminUserModel>()
    
    static func register(req: Request) async throws -> Response {
        // 1. Decode and validate registration request
        try SMAdminRegisterRequest.validate(content: req)
        let registerRequest: SMAdminRegisterRequest = try req.decodeContent(SMAdminRegisterRequest.self)
        
        // Note: Validation is now handled by Validatable protocol
        // - Name: 2-100 characters, not empty
        // - Username: 3-50 characters, not empty
        // - Password: 6-100 characters, not empty
        // - All fields are automatically trimmed via @Trimmed property wrapper
        
        // 2. Check if username already exists using BaseMongoViewModel
        let existingUser = try await baseViewModel.readOne(
            filter: ["username": .string(registerRequest.username)],
            on: req
        )
        
        guard existingUser == nil else {
            throw Abort(.conflict, reason: "Username already exists")
        }
        
        // 3. Hash the password
        let passwordHash = try Bcrypt.hash(registerRequest.password)
        
        // 4. Create new admin user
        let newAdmin = SMAdminUserModel(
            name: registerRequest.name,
            username: registerRequest.username,
            passwordHash: passwordHash
        )
        
        // 5. Save to database using BaseMongoViewModel
        try await baseViewModel.createDocument(newAdmin, on: req)
        
        // 6. Generate access token
        let token = Environment.get(environmentKey: .ENCRYPTION_KEY) ?? "monalisha_admin_token_2026"
        
        // 7. Return response with name, username, and access token
        return await ResponseHandler.success(
            message: "Admin registered successfully",
            data: SMAdminRegisterResponse(
                name: registerRequest.name,
                username: registerRequest.username,
                token: token
            ),
            on: req
        )
    }
}
