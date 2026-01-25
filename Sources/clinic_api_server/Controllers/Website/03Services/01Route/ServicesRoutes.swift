import Vapor

struct ServicesRoutes {
    static func configure(_ r: RoutesBuilder) throws {
        let services = r.grouped("services")
        
        services.get("list", use: ServicesViewModel.getList)
        services.get("detail", ":slug", use: ServicesViewModel.getDetail)
    }
}
