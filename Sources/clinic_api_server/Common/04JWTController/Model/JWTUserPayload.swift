//
//  JWTUserPayload.swift
//  clinic_api_server
//
//  Created by Avinash Aman on 15/11/25.
//

import Vapor
import JWT

struct JWTUserPayload: JWTPayload, Authenticatable {
    // Token metadata
    var userId: String
    var email: String
    var exp: ExpirationClaim  // Expiration time
    var iat: IssuedAtClaim    // Issued at time
    var jwtId: IDClaim  // JWT ID (session identifier)

    // Verify token validity
    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
