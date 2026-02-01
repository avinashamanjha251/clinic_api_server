import Vapor

struct AdminRegisterRoutes {
    static func configure(_ route: RoutesBuilder) throws {
        // Public registration endpoint
        route.post(path: .adminRegister) {
            try await AdminRegisterViewModel.register(req: $0)
        }
    }
}

