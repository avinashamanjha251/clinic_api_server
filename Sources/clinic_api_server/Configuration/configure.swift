import Vapor
import MongoDBVapor

public func configure(_ app: Application) async throws {
    // Encode/Decode settings
    // app.content.use(encoder: ...) if needed
    
    // 1. Mongo Configuration
    let manager = MongoManager(app: app)
    try await manager.bootstrap()
    app.mongoManager = manager   // stored safely
    
    // 2. Security & Middleware Configuration
    // We use a custom error middleware to standardise responses
    app.middleware.use(CustomErrorMiddleware())
    
    SecurityConfig.configure(app)
    
    // 3. Register Routes
    try routes(app)
}
