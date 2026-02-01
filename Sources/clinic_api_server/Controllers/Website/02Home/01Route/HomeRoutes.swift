import Vapor

struct HomeRoutes {
    static func configure(_ routes: RoutesBuilder) throws {
        routes.get(path: .home) { try await HomeViewModel.getInfo(req: $0) }

    }
}
