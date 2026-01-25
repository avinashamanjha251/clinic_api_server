import Vapor

struct ServicesRoutes {
    static func configure(_ route: RoutesBuilder) throws {        
        route.get("services", use: ServicesViewModel.getList)
    }
}
