import Vapor

struct HomeRoutes {
    static func configure(_ routes: RoutesBuilder) throws {
        routes.get("home", use: HomeViewModel.getInfo)
    }
}
