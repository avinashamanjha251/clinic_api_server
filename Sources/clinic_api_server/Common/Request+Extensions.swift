import Vapor

extension Request {
    var clientIP: String {
        // Order: X-Forwarded-For -> X-Real-IP -> Remote Address
        if let xForwardedFor = headers.first(name: "X-Forwarded-For") {
            return xForwardedFor.split(separator: ",").first?.trimmingCharacters(in: .whitespaces) ?? xForwardedFor
        }
        if let xRealIP = headers.first(name: "X-Real-IP") {
            return xRealIP
        }
        return remoteAddress?.description ?? "unknown"
    }
    
    func authenticatedUserId() throws -> String {
        // Simple header check for now
        guard let userId = headers.first(name: "X-User-Id") else {
            throw Abort(.unauthorized, reason: "Missing X-User-Id header")
        }
        return userId
    }
    
    var requestId: String? {
        headers.first(name: "X-Request-Id")
    }
}
