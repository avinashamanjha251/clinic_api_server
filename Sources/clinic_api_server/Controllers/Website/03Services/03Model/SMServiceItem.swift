import Vapor

struct SMServiceItem: Content {
    let id: String
    let title: String
    let description: String
    let features: [String]
    let slug: String
}
