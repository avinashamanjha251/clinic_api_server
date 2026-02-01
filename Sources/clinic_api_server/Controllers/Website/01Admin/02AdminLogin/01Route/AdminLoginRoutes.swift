import Vapor

struct AdminLoginRoutes {
    static func configure(_ r: RoutesBuilder) throws {
        // Public login endpoint (supports both JSON body and Basic Auth)
        r.post(path: .adminLogin) { try await AdminLoginViewModel.login(req: $0) }
    }
}
