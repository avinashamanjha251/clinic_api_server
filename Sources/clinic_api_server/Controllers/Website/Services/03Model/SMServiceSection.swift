import Vapor

struct SMServiceSection: Content {
    let category: String
    let items: [SMServiceItem]
}
