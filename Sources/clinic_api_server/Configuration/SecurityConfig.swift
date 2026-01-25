import Vapor

struct SecurityConfig {
    static func configure(_ app: Application) {
        // Register Security Middleware
        app.middleware.use(SecurityMiddleware())
        
        // Register Rate Limiter
        app.middleware.use(RateLimiterMiddleware())
        
        // CORS
        let corsConfiguration = CORSMiddleware.Configuration(
            allowedOrigin: .all,
            allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS, .PATCH],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin, "X-User-Id", "X-Admin-Token"]
        )
        let cors = CORSMiddleware(configuration: corsConfiguration)
        app.middleware.use(cors, at: .beginning)
    }
}
