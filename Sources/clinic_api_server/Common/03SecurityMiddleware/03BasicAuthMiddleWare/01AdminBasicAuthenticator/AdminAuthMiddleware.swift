//
//  AdminAuthMiddleware.swift
//  clinic_api_server
//
//  Created by Avinash Aman on 31/01/26.
//

import Vapor

// Simple Admin Auth Middleware
struct AdminAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let token = request.headers.first(name: "X-Admin-Token"),
              token == (Environment.get(environmentKey: .ENCRYPTION_KEY) ?? "monalisha_admin_token_2026") else {
            throw Abort(.unauthorized, reason: "Unauthorized access")
        }
        return try await next.respond(to: request)
    }
}
