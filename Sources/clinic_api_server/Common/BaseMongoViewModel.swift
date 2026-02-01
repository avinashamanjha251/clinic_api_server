import Vapor
import MongoDBVapor

// MongoSchemaModel is now defined in MongoManager.swift
// protocol MongoSchemaModel: Codable {
//     static var collectionName: String { get }
// }

extension MongoSchemaModel {
    // Helper to get collection from a request's application
    static var dbName: String? {
        switch environmentType {
        case .prod:
            return Environment.get(environmentKey: .MONGO_DB_NAME_PROD)
        case .dev:
            return Environment.get(environmentKey: .MONGO_DB_NAME_DEV)
        }
    }
    static func collection(on app: Application) throws -> MongoCollection<Self> {
        guard let dbName = Self.dbName else {
            throw Abort(.badRequest, reason: "DB Name not found")
        }
        return app.mongoDB.client.db(dbName).collection(Self.collectionName,
                                                        withType: Self.self)
    }
}

class BaseMongoViewModel<Model: MongoSchemaModel> {
    
    // Generic helpers
    
    // Create
    func createDocument(_ model: Model, on req: Request) async throws -> InsertOneResult? {
        let response = try await Model.collection(on: req.application)
            .insertOne(model)
        return response
    }
    
    // Read One
    func readOne(filter: BSONDocument, on req: Request) async throws -> Model? {
        try await Model.collection(on: req.application)
            .findOne(filter)
    }
    
    // Read Filtered
    func readFilteredRawData(
        filters: BSONDocument,
        sortKey: String = "_id",
        ascending: Bool = true,
        skipCount: Int = 0,
        limit: Int = 20,
        on req: Request
    ) async throws -> [Model] {
        let sortDoc: BSONDocument = [sortKey: ascending ? 1 : -1]
        
        return try await Model.collection(on: req.application)
            .find(filters, options: FindOptions(limit: limit, skip: skipCount, sort: sortDoc))
            .toArray()
    }
    
    // Update
    @discardableResult
    func update(filter: BSONDocument,
                to updateDoc: BSONDocument,
                on req: Request) async throws -> UpdateResult? {
        try await Model.collection(on: req.application).updateOne(filter: filter,
                                       update: ["$set": .document(updateDoc)])
    }
    
    @discardableResult
    func updateDocument(objectId: BSONObjectID,
                        model: Model,
                        on req: Request,
                        ignoredKeys: [String] = []) async throws -> JSON {
        let rawData = model.toBSONDocument(ignoring: [ApiKey.id])
        let filter: BSONDocument = [ApiKey.id: .objectID(objectId)]
        let _ = try await update(filter: filter,
                                 to: rawData,
                                 on: req)
        let jsonData = model.toJSON(ignoring: ignoredKeys)
        return jsonData
    }
    
    // Delete
    func delete(filter: BSONDocument, on req: Request) async throws {
        _ = try await Model.collection(on: req.application)
            .deleteOne(filter)
    }
    
    // Aggregate
    func aggregate(pipeline: [BSONDocument], on req: Request) async throws -> [BSONDocument] {
         try await Model.collection(on: req.application)
            .aggregate(pipeline)
            .toArray()
    }
}

extension InsertOneResult {
    var toBSONDocument: JSON {
        switch insertedID {
        case .objectID(let objectId):
            return JSON([ApiKey.objectId: objectId.hex])
        default:
            return JSON([ApiKey.objectId: insertedID.stringValue])
        }
    }
}
