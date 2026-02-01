import Vapor
@preconcurrency import MongoDBVapor

struct SMAdminUserModel: MongoSchemaModel {
    static var collectionName: String = "admin_users"
    
    var _id: BSONObjectID?
    let name: String
    let username: String
    let passwordHash: String
    let jwtId: String
    var accessToken: String
    let createdAt: Date
    let updatedAt: Date
    
    init(name: String,
         username: String,
         passwordHash: String,
         jwtId: String,
         accessToken: String) {
        self._id = BSONObjectID()
        self.name = name
        self.username = username
        self.passwordHash = passwordHash
        self.jwtId = jwtId
        self.accessToken = accessToken
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
