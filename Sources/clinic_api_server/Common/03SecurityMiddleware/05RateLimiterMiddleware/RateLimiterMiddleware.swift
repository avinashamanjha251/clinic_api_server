import Vapor

struct RateLimiterMiddleware: AsyncMiddleware {
    // Requirements: In-memory rate limiter.
    // NOTE: In a real distributed app, use Redis. For this project, memory is requested.
    
    // We need a thread-safe storage.
    actor RateLimitStore {
        struct Entry {
            var count: Int
            var startTime: Date
        }
        
        var ipLimits: [String: Entry] = [:]
        var userLimits: [String: Entry] = [:]
        
        func check(key: String, limit: Int, window: TimeInterval) -> (allowed: Bool, remaining: Int, reset: Date) {
            let now = Date()
            var entry = ipLimits[key] ?? Entry(count: 0, startTime: now)
            
            if now.timeIntervalSince(entry.startTime) > window {
                // Reset window
                entry.count = 0
                entry.startTime = now
            }
            
            if entry.count >= limit {
                return (false, 0, entry.startTime.addingTimeInterval(window))
            }
            
            entry.count += 1
            ipLimits[key] = entry
            
            return (true, limit - entry.count, entry.startTime.addingTimeInterval(window))
        }
    }
    
    static let store = RateLimitStore()
    
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Config
        let limitPerIP = Int(Environment.get("RATE_LIMIT_PER_IP") ?? "100") ?? 100
        let windowIP: TimeInterval = 15 * 60 // 15 mins
        
        let clientIP = request.clientIP
        
        let result = await Self.store.check(key: clientIP, limit: limitPerIP, window: windowIP)
        
        if !result.allowed {
            let headers: HTTPHeaders = [
                "Retry-After": String(Int(result.reset.timeIntervalSinceNow)),
                "Rate-Limit-Limit": String(limitPerIP),
                "Rate-Limit-Remaining": "0",
                "Rate-Limit-Reset": String(Int(result.reset.timeIntervalSince1970))
            ]
            // Return 429 via ResponseHandler logic (manually constructed here to match handler style)
            let errorResponse = await ResponseHandler.error(Abort(.tooManyRequests, reason: "Rate limit exceeded"), on: request)
            for (k, v) in headers {
                errorResponse.headers.replaceOrAdd(name: k, value: v)
            }
            return errorResponse
        }
        
        let response = try await next.respond(to: request)
        
        response.headers.replaceOrAdd(name: "Rate-Limit-Limit", value: String(limitPerIP))
        response.headers.replaceOrAdd(name: "Rate-Limit-Remaining", value: String(result.remaining))
        response.headers.replaceOrAdd(name: "Rate-Limit-Reset", value: String(Int(result.reset.timeIntervalSince1970)))
        
        return response
    }
}
