import Vapor

struct SMMissionValues: Content {
    let mission: String
    let story: String
    let values: [String]
}
