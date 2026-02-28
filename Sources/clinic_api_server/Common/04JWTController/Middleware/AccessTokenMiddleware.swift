//
//  AccessTokenMiddleware.swift
//  clinic_api_server
//
//  Created by Avinash Aman on 28/02/26.
//

import Vapor
import CryptoSwift
import JWT
import MongoDBVapor

struct AccessTokenMiddleware: AsyncMiddleware {
    func respond(to request: Vapor.Request, chainingTo next: Vapor.AsyncResponder) async throws -> Vapor.Response {
        
        // 1. Check if token exists in header
        guard let bearer = request.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Missing Bearer Token")
        }
        
        do {
            // 2. Verify the token using your JWTService
            let payload = try request.jwtService.verify(token: bearer)
            
            // 3. Check if token has been blacklisted (logged out)
            let blacklistVM = BaseMongoViewModel<SMBlacklistedToken>()
            let blacklisted = try await blacklistVM.readOne(
                filter: ["jwtId": .string(payload.jwtId.value)],
                on: request
            )
            
            if blacklisted != nil {
                throw Abort(.unauthorized, reason: "Token has been revoked. Please login again.")
            }
            
            // 4. Authenticate the payload on the request
            request.auth.login(payload)
            
        } catch let abort as Abort {
            throw abort
        } catch {
            throw Abort(.unauthorized, reason: "Invalid or expired token: \(error.localizedDescription)")
        }
        
        // 5. Proceed to the next middleware/route handler
        return try await next.respond(to: request)
    }
}

