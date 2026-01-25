//
//  AppExtensions.swift
//  ClinicAPIServer
//
//  Created by Antigravity on 25/01/26.
//

import Vapor

enum EnvironmentType: String {
    case dev
    case prod
}

enum EnvironmentKey: String {
    case API_KEY = "API_KEY"
    case ENCRYPTION_KEY = "ENCRYPTION_KEY"
    case BASIC_AUTH_USERNAME = "BASIC_AUTH_USERNAME"
    case BASIC_AUTH_PASSWORD = "BASIC_AUTH_PASSWORD"
    case MONGODB_URI_PROD = "MONGODB_URI_PROD"
    case MONGODB_URI_DEV = "MONGODB_URI_DEV"
    case JWT_SECRET = "JWT_SECRET"
}

extension Application {
    var environmentType: EnvironmentType? {
        // Map Vapor's Environment to our EnvironmentType
        switch environment {
        case .production:
            return .prod
        case .development:
            return .dev
        default:
            // Fallback or treat others as dev, or return nil
            if environment == .testing {
                return .dev 
            }
            return .dev
        }
    }
}

extension Environment {
    
    init(type: EnvironmentType) {
        switch type {
        case .dev:
            self = Self.development
        case .prod:
            self = Self.production
        }
    }
    
    static func get(environmentKey: EnvironmentKey) -> String? {
        Self.get(environmentKey.rawValue)
    }
}

struct DecryptedDataKey: StorageKey {
    typealias Value = Data
}

extension Request {
    private struct CollectedBodyKey: StorageKey {
        typealias Value = ByteBuffer
    }
    
    var collectedBody: ByteBuffer? {
        get { storage[CollectedBodyKey.self] }
        set { storage[CollectedBodyKey.self] = newValue }
    }

    var decryptedBody: Data? {
        get { storage[DecryptedDataKey.self] }
        set { storage[DecryptedDataKey.self] = newValue }
    }
}
