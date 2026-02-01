import Vapor

struct ServicesRoutes {
    static func configure(_ route: RoutesBuilder) throws {
        route.get(path: .services) { try await ServicesViewModel.getList(req: $0) }
    }
}
