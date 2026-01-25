//
//  MongoManager.swift
//  DailyExpenseTracker
//
//  Created by Avinash Aman on 15/11/25.
//

import Vapor
import MongoDBVapor

struct MongoManagerKey: StorageKey {
    typealias Value = MongoManager
}

protocol MongoSchemaModel: Codable, Sendable {
    static var collectionName: String { get }
}

extension Application {
    var mongoManager: MongoManager {
        get {
            self.storage[MongoManagerKey.self]!
        }
        set {
            self.storage[MongoManagerKey.self] = newValue
        }
    }
}

final class MongoManager: @unchecked Sendable {
    private let app: Application
    private var client: MongoClient?
    private var database: MongoDatabase?
    
    init(app: Application) {
        self.app = app
    }
    
    // Bootstrap configuration depending on environment
    func bootstrap() async throws {
        guard let environmentType = app.environmentType else {
            throw Abort(.internalServerError, reason: "Failed to initiate environment")
        }
        app.logger.info("Initializing MongoDB for environment: \(environmentType.rawValue)")
        
        // Choose connection per environment
        let connectionString: String
        switch environmentType {
        case .prod:
            guard let str = Environment.get(environmentKey: .MONGODB_URI_PROD) else {
                throw Abort(.internalServerError, reason: "DB URI Not found")
            }
            connectionString = str
        case .dev:
            guard let str = Environment.get(environmentKey: .MONGODB_URI_DEV) else {
                throw Abort(.internalServerError, reason: "DB URI Not found")
            }
            connectionString = str
        }
        
        // 1. Initialize the MongoDB client via MongoDBVapor
        try app.mongoDB.configure(connectionString)
        self.client = app.mongoDB.client
        guard let client else {
            throw Abort(.internalServerError, reason: "Unable to initialize Mongo client")
        }
        
        // 2. Extract database name
        let dbName = URI(string: connectionString).path
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !dbName.isEmpty else {
            throw Abort(.internalServerError, reason: "No database name in connection string")
        }
        
        // 3. Access database instance
        database = client.db(dbName)
        app.logger.info("Connected to MongoDB database: \(dbName)")
        
        // 4. Check if DB exists; create if missing
        try await ensureDatabaseExists(client: client, dbName: dbName)
        app.logger.info("Mongo connection verified successfully.")
    }
    
    // MARK: - Database Validation
    private func ensureDatabaseExists(client: MongoClient,
                                      dbName: String) async throws {
        // Get all database names
        let existingDatabases = try await client.listDatabaseNames().get()
        if !existingDatabases.contains(dbName) {
            app.logger.warning("Database '\(dbName)' not found. Creating new one...")
            
            // Create by writing a dummy document
            let db = client.db(dbName)
            let initializer = db.collection("init_check")
            let dummy: BSONDocument = ["_createdAt": .datetime(Date())]
            
            // Inserting to create DB
            _ = try await initializer.insertOne(dummy)
            // Optional: Delete dummy document after creation
            _ = try await initializer.deleteMany([:])
            
            app.logger.info("Database '\(dbName)' created successfully.")
        } else {
            app.logger.info("Database '\(dbName)' already exists.")
        }
    }
    
    
    
    // Graceful shutdown
    func shutdown() {
        app.logger.info("Cleaning up MongoDB connection...")
        app.mongoDB.cleanup()
        cleanupMongoSwift()
    }
}

extension MongoManager {
    
    // Collection accessor
    func collection<T: MongoSchemaModel>(_ type: T.Type) throws -> MongoCollection<T> {
        guard let database else {
            throw Abort(.internalServerError, reason: "MongoDB not initialized. Call bootstrap() first.")
        }
        return database.collection(T.collectionName, withType: T.self)
    }
}
