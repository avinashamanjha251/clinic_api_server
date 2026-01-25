import Vapor

struct SMFacilityInfo: Content {
    let description: String
    let technologies: [String]
}
