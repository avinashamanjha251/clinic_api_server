import Vapor

struct SMCommunityActivity: Content {
    let title: String
    let description: String
    let date: String?
}
