import MongoDBVapor
import Vapor

struct AdminRegisterViewModel: AdminRegisterProtocol {

    // Base view model for database operations
    static let baseViewModel = BaseMongoViewModel<SMAdminUserModel>()

    static func register(req: Request) async throws -> Response {
        SecurityLogging.log("Admin registration process started", request: req, level: .info)

        // 1. Decode and validate registration request
        let registerRequest: SMAdminRegisterRequest = try req.decodeContent(
            SMAdminRegisterRequest.self)
        try registerRequest.validate()

        SecurityLogging.log(
            "Registration request decoded and validated for username: \(registerRequest.username)",
            request: req, level: .info)

        // Note: Validation is now handled by Validatable protocol
        // - Name: 2-100 characters, not empty
        // - Username: 3-50 characters, not empty
        // - Password: 6-100 characters, not empty
        // - All fields are automatically trimmed via @Trimmed property wrapper

        // 2. Check if username already exists using BaseMongoViewModel
        SecurityLogging.log(
            "Checking if username already exists: \(registerRequest.username)", request: req,
            level: .info)
        let existingUser = try await baseViewModel.readOne(
            filter: ["username": .string(registerRequest.username)],
            on: req
        )

        guard existingUser == nil else {
            SecurityLogging.log(
                "Registration failed - username already exists: \(registerRequest.username)",
                request: req, level: .warning)
            throw Abort(.conflict, reason: "Username already exists")
        }

        SecurityLogging.log(
            "Username availability confirmed: \(registerRequest.username)", request: req,
            level: .info)

        // 3. Hash the password
        SecurityLogging.log(
            "Hashing password for user: \(registerRequest.username)", request: req, level: .info)
        let passwordHash = try Bcrypt.hash(registerRequest.password)

        // 4. Create new admin user
        SecurityLogging.log(
            "Creating new admin user: \(registerRequest.username)", request: req, level: .info)
        let newAdmin = SMAdminUserModel(
            name: registerRequest.name,
            username: registerRequest.username,
            passwordHash: passwordHash,
            jwtId: UUID().uuidString,
            accessToken: ""
        )

        // 5. Save to database using BaseMongoViewModel
        SecurityLogging.log(
            "Saving admin user to database: \(registerRequest.username)", request: req, level: .info
        )
        guard
            let value = try await baseViewModel.createDocument(
                newAdmin,
                on: req)?.toBSONDocument
        else {
            SecurityLogging.log(
                "Admin registration failed - document creation failed for user: \(registerRequest.username)",
                request: req, level: .error)
            throw Abort(
                .internalServerError,
                reason: "ADMIN_REGISTRATION_ID_NOT_FOUND",
                identifier: "ADMIN_REGISTRATION_ID_NOT_FOUND")
        }

        SecurityLogging.log(
            "Admin user successfully saved to database: \(registerRequest.username)", request: req,
            level: .info)

        let newValue = try await fetchProfile(
            byObjectId: value.objectId,
            req: req)
        guard var newValue,
            let objectId = newValue._id
        else {
            SecurityLogging.log(
                "Admin registration failed - profile not found after creation for user: \(registerRequest.username)",
                request: req, level: .error)
            throw Abort(
                .internalServerError,
                reason: "ADMIN_REGISTRATION_PROFILE_NOT_FOUND",
                identifier: "ADMIN_REGISTRATION_PROFILE_NOT_FOUND")
        }

        // 6. Generate access token
        SecurityLogging.log(
            "Generating access token for user: \(registerRequest.username)", request: req,
            level: .info)
        let token = try req.jwtService.generateToken(for: newAdmin)
        newValue.accessToken = token

        SecurityLogging.log(
            "Updating user profile with access token for user: \(registerRequest.username)",
            request: req, level: .info)
        try await baseViewModel.updateDocument(
            objectId: objectId,
            model: newValue,
            on: req,
            ignoredKeys: [
                ApiKey.id,
                ApiKey.passwordHash,
                ApiKey.jwtId,
            ])
        try req.jwtService.verifyAndUpdateRequesthAuth(
            token: token,
            request: req)

        SecurityLogging.log(
            "Admin registration completed successfully for user: \(registerRequest.username)",
            request: req, level: .info)

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

    static func fetchProfile(
        byObjectId objectId: String,
        req: Request
    ) async throws -> SMAdminUserModel? {
        SecurityLogging.log(
            "Fetching admin profile by objectId: \(objectId)", request: req, level: .info)
        let filter: BSONDocument = [ApiKey.id: .objectID(try BSONObjectID(objectId))]
        if let profile = try await baseViewModel.readOne(
            filter: filter,
            on: req)
        {
            SecurityLogging.log(
                "Admin profile found successfully for objectId: \(objectId)", request: req,
                level: .info)
            return profile
        } else {
            SecurityLogging.log(
                "Admin profile not found for objectId: \(objectId)", request: req, level: .warning)
            throw Abort(.notFound, reason: "Admin User not found")
        }
    }
}
