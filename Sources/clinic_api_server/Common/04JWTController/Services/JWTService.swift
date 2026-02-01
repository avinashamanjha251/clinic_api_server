//
//  JWTService.swift
//  clinic_api_server
//
//  Created by Avinash Aman on 15/11/25.
//

import Vapor
import JWT

struct JWTService: RouteProtocol {
    private let app: Application
    
    init(app: Application) {
        self.app = app
    }
    
    /// Generate JWT token for user
    func generateToken(for user: SMAdminUserModel) throws -> String {
        guard let userId = user._id?.hex else {
            throw Abort(.internalServerError, reason: "User ID missing")
        }
        let exp = Date().addingTimeInterval(60 * 60 * 24 * 365)// 365 days
        let payload = JWTUserPayload(userId: userId,
                                     email: user.username,
                                     exp: .init(value: exp),
                                     iat: .init(value: Date()),
                                     jwtId: IDClaim(value: user.jwtId))
        return try app.jwt.signers.sign(payload)
    }
    
    /// Verify and decode JWT token
    func verify(token: String) throws -> JWTUserPayload {
        return try app.jwt.signers.verify(token,
                                          as: JWTUserPayload.self)
    }
    
    func verifyAndUpdateRequesthAuth(token: String,
                                     request: Request) throws {
        let payload = try verify(token: token)
        request.auth.login(payload)
    }
}

extension JWTService {
    static func configure(_ app: Vapor.Application) throws {
        // Get JWT secret from environment
        guard let jwtSecret = Environment.get(environmentKey: .JWT_SECRET) else {
              throw Abort(.internalServerError,
                          reason: "JWT_SECRET not set")
          }
          
          // Configure JWT signer
          app.jwt.signers.use(.hs256(key: jwtSecret))
          
          // Store JWT service
          app.jwtService = JWTService(app: app)
    }
}

struct JWTServiceKey: StorageKey {
    typealias Value = JWTService
}

extension Application {
    var jwtService: JWTService {
        get {
            guard let service = storage[JWTServiceKey.self] else {
                fatalError("JWTService not configured")
            }
            return service
        }
        set {
            storage[JWTServiceKey.self] = newValue
        }
    }
}
