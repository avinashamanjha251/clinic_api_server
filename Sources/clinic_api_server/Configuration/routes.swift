import Vapor

func routes(_ app: Application) throws {
    let api = app.grouped("api", "v1")
    
    // Health Check
    api.get("health") { req in
        ["status": "ok"]
    }
    
    // Register Controller Routes
    try ContactRoutes.configure(api)
    try AdminLoginRoutes.configure(api)
    try AdminRegisterRoutes.configure(api)
    try AdminRoutes.configure(api)
    try ServicesRoutes.configure(api)
    try AboutRoutes.configure(api)
}
