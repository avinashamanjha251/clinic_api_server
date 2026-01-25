import Vapor
import MongoDBVapor

// MongoSchemaModel is now defined in MongoManager.swift
// protocol MongoSchemaModel: Codable {
//     static var collectionName: String { get }
// }

extension MongoSchemaModel {
    // Helper to get collection from a request's application
    static func collection(on app: Application) -> MongoCollection<Self> {
        app.mongoDB.client.db(Environment.get("MONGO_DB_NAME") ?? "home").collection(Self.collectionName, withType: Self.self)
    }
}

class BaseMongoViewModel<Model: MongoSchemaModel> {
    
    // Generic helpers
    
    // Create
    func createDocument(_ model: Model, on req: Request) async throws {
        _ = try await Model.collection(on: req.application)
            .insertOne(model)
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
    func updateDocument(objectId: BSONObjectID, model: Model, on req: Request) async throws {
        try await Model.collection(on: req.application)
            .findOneAndReplace(filter: ["_id": .objectID(objectId)], replacement: model)
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
