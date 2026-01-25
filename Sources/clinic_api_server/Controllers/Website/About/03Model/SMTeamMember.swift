import Vapor

struct SMTeamMember: Content {
    let name: String
    let role: String
    let bio: String
    let imageUrl: String?
}
