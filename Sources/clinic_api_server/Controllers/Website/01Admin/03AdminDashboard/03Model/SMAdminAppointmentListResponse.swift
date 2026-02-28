import Vapor
import MongoDBVapor

struct SMAdminAppointmentListResponse: Content {
    let items: [SMAppointment]
    let page: Int
    let hasMore: Bool
}
