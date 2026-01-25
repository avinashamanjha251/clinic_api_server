import Vapor

struct SMHomeInfoResponse: Content {
    let name: String
    let tagline: String
    let address: String
    let phone: String
    let email: String
    let hours: String
    let features: [String]
}
