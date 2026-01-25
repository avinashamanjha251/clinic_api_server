import Vapor

struct SMUpdateStatusRequest: Content {
    let appointmentId: String
    let status: String
}
