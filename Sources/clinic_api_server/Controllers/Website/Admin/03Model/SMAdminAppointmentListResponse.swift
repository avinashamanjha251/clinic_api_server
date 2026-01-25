import Vapor
import MongoDBVapor

struct SMAdminAppointmentListResponse: Content {
    let items: [CMAppointment]
    let page: Int
    let hasMore: Bool
}
