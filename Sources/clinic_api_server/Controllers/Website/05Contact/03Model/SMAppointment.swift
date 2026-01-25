import Vapor
@preconcurrency import MongoDBVapor

struct SMAppointment: MongoSchemaModel, Content {
    static var collectionName = "appointments"
    
    var _id: BSONObjectID?
    var id: BSONObjectID? { _id }
    
    let name: String
    let email: String?
    let phone: String
    let service: String
    let message: String
    var preferredDate: String
    var preferredTime: String
    var status: String // pending, confirmed, cancelled
    let createdAt: Double
    
    init(id: BSONObjectID? = nil,
         name: String,
         email: String?,
         phone: String,
         service: String,
         message: String,
         preferredDate: String,
         preferredTime: String,
         status: String = "pending",
         createdAt: Double = Date().toMillis()) {
        self._id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.service = service
        self.message = message
        self.preferredDate = preferredDate
        self.preferredTime = preferredTime
        self.status = status
        self.createdAt = createdAt
    }
}
