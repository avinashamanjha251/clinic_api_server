import Vapor

struct AboutRoutes {
    static func configure(_ route: RoutesBuilder) throws {
        route.get("about", use: AboutViewModel.getData)
    }
}
