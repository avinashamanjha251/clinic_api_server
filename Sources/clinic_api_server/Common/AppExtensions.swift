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
    case MONGODB_URI_DEV
    case MONGODB_URI_PROD
    case BASIC_AUTH_USERNAME
    case BASIC_AUTH_PASSWORD
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
