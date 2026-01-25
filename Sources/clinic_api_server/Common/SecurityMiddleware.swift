import Vapor

struct SecurityMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Force HTTPS in production
        if request.application.environment == .production {
            if request.url.scheme != "https" {
                // Determine if it's behind a proxy that handles SSL
                let forwardedProto = request.headers.first(name: "X-Forwarded-Proto")
                if forwardedProto != "https" {
                     throw Abort(.forbidden, reason: "HTTPS is required")
                }
            }
        }
        
        // Basic Input Sanitization (Checking body/query for malicious patterns)
        // Note: Reading body might consume it, so we need to be careful. 
        // Vapor's Request body collection buffers it, so it's usually okay to read multiple times if collected.
        // However, middleware runs before body collection unless we explicitly collect.
        // For this example, we'll check query string and assume JSON body is handled safe by Codable, 
        // but checking raw description for patterns.
        
        let pathQuery = request.url.string
        if checkForMaliciousPatterns(pathQuery) {
            SecurityLogging.log("Malicious pattern in URL", request: request, level: .warning)
            throw Abort(.badRequest, reason: "Invalid request detected")
        }
        
        // Execute request
        let response = try await next.respond(to: request)
        
        // Security Headers
        response.headers.replaceOrAdd(name: "X-Content-Type-Options", value: "nosniff")
        response.headers.replaceOrAdd(name: "X-Frame-Options", value: "DENY")
        response.headers.replaceOrAdd(name: "X-XSS-Protection", value: "1; mode=block")
        response.headers.replaceOrAdd(name: "Referrer-Policy", value: "no-referrer")
        // Adjusted CSP for API
        response.headers.replaceOrAdd(name: "Content-Security-Policy", value: "default-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'")
        
        return response
    }
    
    private func checkForMaliciousPatterns(_ input: String) -> Bool {
        let inputLower = input.lowercased()
        let patterns = [
             "<script", "javascript:", "onerror=", "onload=",
             "union select", "drop table", "insert into"
        ]
        return patterns.contains { inputLower.contains($0) }
    }
}
