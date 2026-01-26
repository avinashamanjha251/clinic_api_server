import Vapor

struct AdminRegisterRoutes {
    static func configure(_ r: RoutesBuilder) throws {
        let adminAuth = r.grouped("admin")
                         .grouped(AdminBasicAuthenticator())
                         .grouped(DecryptionMiddleware())
                         .grouped(EncryptionResponseMiddleware())
        
        // Public registration endpoint
        adminAuth.post("register", use: AdminRegisterViewModel.register)
    }
}

