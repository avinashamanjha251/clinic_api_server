import Vapor
@preconcurrency import MongoDBVapor

struct SMBlacklistedToken: MongoSchemaModel, Content {
    static var collectionName: String = "blacklisted_tokens"
    
    var _id: BSONObjectID?
    let jwtId: String         // The JWT ID (jti) of the revoked token
    let userId: String        // The user who logged out
    let revokedAt: Date       // When the token was revoked
    
    init(jwtId: String, userId: String) {
        self._id = BSONObjectID()
        self.jwtId = jwtId
        self.userId = userId
        self.revokedAt = Date()
    }
}
