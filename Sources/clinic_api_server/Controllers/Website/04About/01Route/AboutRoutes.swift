import Vapor

struct AboutRoutes {
    static func configure(_ route: RoutesBuilder) throws {       
        route.get(path: .about) { try await AboutViewModel.getData(req: $0) }
    }
}
