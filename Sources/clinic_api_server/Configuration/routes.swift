import Vapor

func routes(_ app: Application) throws {
    // Health Check
    app.get(path: .health) { req in
        return await ResponseHandler.success(data: ["status": "ok"], on: req)
    }
    
    // Register Controller Routes
    try groupRoutes(.admin, on: app)
    try groupRoutes(.user, on: app)
}

enum RouteGroup {
    case admin
    case user
}

func groupRoutes(_ group: RouteGroup, on app: Application) throws {
    let builder: RoutesBuilder
    
    switch group {
    case .admin:
        builder = app
            .grouped(try AdminBasicAuthenticator())
            .grouped(AdminAuthMiddleware())
            .grouped(DecryptionMiddleware())
            .grouped(EncryptionResponseMiddleware())
        
        try AdminLoginRoutes.configure(builder)
        try AdminRegisterRoutes.configure(builder)
        try AdminRoutes.configure(builder)
        
    case .user:
        builder = app
            .grouped(try SimpleBasicAuthMiddleware())
            .grouped(DecryptionMiddleware())
            .grouped(EncryptionResponseMiddleware())
        
        try ContactRoutes.configure(builder)
        try ServicesRoutes.configure(builder)
        try HomeRoutes.configure(builder)
        try AboutRoutes.configure(builder)
    }
}
