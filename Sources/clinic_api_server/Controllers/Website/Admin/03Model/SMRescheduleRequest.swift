import Vapor

struct SMRescheduleRequest: Content {
    let appointmentId: String
    let newDate: Date
    let newTime: String
}
