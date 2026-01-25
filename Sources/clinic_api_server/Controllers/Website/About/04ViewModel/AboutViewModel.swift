import Vapor

struct AboutViewModel: AboutViewModelProtocol {
    static func getInfo(req: Request) async throws -> Response {
        let info = SMMissionValues(
            mission: "To provide the best dental care.",
            story: "Founded in 2005...",
            values: ["Compassionate Care", "Excellence", "Trust & Integrity", "Innovation"]
        )
        return await ResponseHandler.success(data: info, on: req)
    }
    
    static func getTeam(req: Request) async throws -> Response {
        let team = [
            SMTeamMember(name: "Dr. Sarah Johnson", role: "Chief Dentist", bio: "15 years experience.", imageUrl: nil),
            SMTeamMember(name: "Dr. Michael Chen", role: "Orthodontist", bio: "Specialist in braces.", imageUrl: nil)
        ]
        return await ResponseHandler.success(data: team, on: req)
    }
    
    static func getFacility(req: Request) async throws -> Response {
        let facility = SMFacilityInfo(
            description: "State of the art facility.",
            technologies: ["Digital X-rays", "CEREC", "Laser Dentistry"]
        )
        return await ResponseHandler.success(data: facility, on: req)
    }
    
    static func getCommunity(req: Request) async throws -> Response {
        let activities = [
            SMCommunityActivity(title: "School Visits", description: "Teaching kids oral hygiene", date: "Monthly"),
            SMCommunityActivity(title: "Health Fairs", description: "Free checkups", date: "Quarterly")
        ]
        return await ResponseHandler.success(data: activities, on: req)
    }
}
