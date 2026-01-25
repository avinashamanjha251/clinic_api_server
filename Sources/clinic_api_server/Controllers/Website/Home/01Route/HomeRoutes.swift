import Vapor

struct HomeRoutes {
    static func configure(_ r: RoutesBuilder) throws {
        let home = r.grouped("home")
        
        home.get("info", use: HomeViewModel.getInfo)
        home.get("services", "summary", use: HomeViewModel.getServicesSummary)
    }
}
