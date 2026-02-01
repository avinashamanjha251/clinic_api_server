import Vapor
import MongoDBVapor

struct AdminRegisterViewModel: AdminRegisterProtocol {
    
    // Base view model for database operations
    static let baseViewModel = BaseMongoViewModel<SMAdminUserModel>()
    
    static func register(req: Request) async throws -> Response {
        // 1. Decode and validate registration request
        let registerRequest: SMAdminRegisterRequest = try req.decodeContent(SMAdminRegisterRequest.self)
        try registerRequest.validate()
        
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
            passwordHash: passwordHash,
            jwtId: UUID().uuidString,
            accessToken: ""
        )
        
        // 5. Save to database using BaseMongoViewModel
        guard let value = try await baseViewModel.createDocument(newAdmin,
                                                                 on: req)?.toBSONDocument else {
            throw Abort(.internalServerError,
                        reason: "ADMIN_REGISTRATION_ID_NOT_FOUND",
                        identifier: "ADMIN_REGISTRATION_ID_NOT_FOUND")
        }
        
        let newValue = try await fetchProfile(byObjectId: value.objectId,
                                              req: req)
        guard var newValue,
              let objectId = newValue._id else {
            throw Abort(.internalServerError,
                        reason: "ADMIN_REGISTRATION_PROFILE_NOT_FOUND",
                        identifier: "ADMIN_REGISTRATION_PROFILE_NOT_FOUND")
        }
        
        // 6. Generate access token
        let token = try req.jwtService.generateToken(for: newAdmin)
        newValue.accessToken = token
        
        try await baseViewModel.updateDocument(objectId: objectId,
                                               model: newValue,
                                               on: req,
                                               ignoredKeys: [ApiKey.id,
                                                             ApiKey.passwordHash,
                                                             ApiKey.jwtId])
        try req.jwtService.verifyAndUpdateRequesthAuth(token: token,
                                                       request: req)
        
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
    
    static func fetchProfile(byObjectId objectId: String,
                             req: Request) async throws -> SMAdminUserModel? {
        let filter: BSONDocument = [ApiKey.id: .objectID(try BSONObjectID(objectId))]
        if let profile = try await baseViewModel.readOne(filter: filter,
                                                         on: req) {
            return profile
        } else {
            throw Abort(.notFound, reason: "Admin User not found")
        }
    }
}
