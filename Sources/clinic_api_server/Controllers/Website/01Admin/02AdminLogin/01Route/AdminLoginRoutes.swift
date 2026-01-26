import Vapor

struct AdminLoginRoutes {
    static func configure(_ r: RoutesBuilder) throws {
        let adminAuth = r.grouped("admin", "auth")
                         .grouped(AdminBasicAuthenticator())
                         .grouped(DecryptionMiddleware())
                         .grouped(EncryptionResponseMiddleware())
        
        // Public login endpoint (supports both JSON body and Basic Auth)
        adminAuth.post("login", use: AdminLoginViewModel.login)
    }
}
