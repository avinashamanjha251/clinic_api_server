import Vapor

struct AboutRoutes {
    static func configure(_ r: RoutesBuilder) throws {
        let about = r.grouped("about")
        
        about.get("info", use: AboutViewModel.getInfo)
        about.get("team", use: AboutViewModel.getTeam)
        about.get("facility", use: AboutViewModel.getFacility)
        about.get("community", use: AboutViewModel.getCommunity)
    }
}
