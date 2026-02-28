import Vapor

struct AdminLoginRoutes {
    static func configure(_ r: RoutesBuilder) throws {
        // Public login endpoint (supports both JSON body and Basic Auth)
        r.post(path: .adminLogin) { try await AdminLoginViewModel.login(req: $0) }
        
        // Protected logout endpoint (requires valid access token)
        let protected = r.grouped(AccessTokenMiddleware())
        protected.post(path: .adminLogout) { try await AdminLoginViewModel.logout(req: $0) }
    }
}
