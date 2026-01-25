import Vapor
import MongoDBVapor
import Smtp

public func configure(_ app: Application) async throws {
    switch environmentType {
    case .dev:
        break
    case .prod:
        app.http.server.configuration.hostname = "0.0.0.0"
    }
    app.http.server.configuration.port = 8080
    
    // 1. Mongo Configuration
    let manager = MongoManager(app: app)
    try await manager.bootstrap()
    app.mongoManager = manager   // stored safely
    
    // 2. Security & Middleware Configuration
    // We use a custom error middleware to standardise responses
    app.middleware.use(CustomErrorMiddleware())
    
    SecurityConfig.configure(app)
    
    // 3. SMTP Configuration
    // Fallback values from your .env in case Environment.get returns nil
    
    guard let hostname = Environment.get(environmentKey: .SMTP_HOSTNAME),
          let portStr = Environment.get(environmentKey: .SMTP_PORT),
          let port = Int(portStr),
          let username = Environment.get(environmentKey: .SMTP_USERNAME),
          let password = Environment.get(environmentKey: .SMTP_PASSWORD) else {
        throw Abort(.internalServerError, reason: "SMTP config error")
    }
                         
    app.logger.info("Configuring SMTP: \(hostname):\(port) for user: \(username)")
    app.smtp.configuration = .init(hostname: hostname,
                                   port: port,
                                   signInMethod: .credentials(username: username,
                                                              password: password),
                                   secure: port == 465 ? .ssl : .startTls)
    // 4. Register Routes
    try routes(app)
}
