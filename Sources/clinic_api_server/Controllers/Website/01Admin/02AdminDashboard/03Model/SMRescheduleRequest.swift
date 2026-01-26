import Vapor

struct SMRescheduleRequest: Content {
    let appointmentId: String
    let newDate: String
    let newTime: String
}
