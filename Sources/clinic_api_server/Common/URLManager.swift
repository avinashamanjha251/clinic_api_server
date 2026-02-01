//
//  URLManager.swift
//  clinic_api_server
//
//  Created by Avinash Aman on 31/01/26.
//

import Foundation
import Vapor

let baseURL: String = "http://127.0.0.1:8080"

class URLManager {
    
    enum ApiVersion: String {
        case v1 = "/api/v1/"
        case v2 = "/api/v2/"
    }
    
    enum EndPoint: String, CaseIterable {
        // General
        case health = "health"
        case uploads = "uploads"
        
        // User / Website
        case home = "home"
        case contact = "contact"
        case createAppointment = "contact/appointment"
        case services = "services"
        case about = "about"
        
        // Admin Auth
        case adminRegister = "admin/register"
        case adminLogin = "admin/auth/login"
        
        // Admin Dashboard / Appointments
        case adminAppointmentsList = "admin/appointments/list"
        case adminAppointmentsCalendarSummary = "admin/appointments/calendar-summary"
        case adminAppointmentsStatus = "admin/appointments/status"
        case adminAppointmentsReschedule = "admin/appointments/reschedule"
        case adminAppointmentsDate = "admin/appointments/date-appointments"
        
        func path(_ version: ApiVersion = .v1) -> [PathComponent] {
            let pathList = (version.rawValue + self.rawValue).pathComponents
            return pathList
        }
        
        var pathComponent: [PathComponent] {
            self.rawValue.pathComponents
        }
    }
    
    static var publicPathList: [EndPoint] {
        [.uploads, .health]
    }
    static var basicAuthPathList: [EndPoint] {
        [.home, .contact, .services, .about,
         .createAppointment, .adminLogin, .adminRegister]
    }
    static var jwtPathList: [EndPoint] {
        // Admin routes likely use JWT or similar auth in future, but for now they are under admin group
        return [.adminAppointmentsList,
                .adminAppointmentsCalendarSummary,
            .adminAppointmentsStatus,
                .adminAppointmentsReschedule,
                .adminAppointmentsDate]
    }
    static var decryptinonEndpointList: [URLManager.EndPoint] {
        []
    }
    static var allowedRoutes: [HTTPMethod: [URLManager.EndPoint]] {
        let dict: [HTTPMethod: [URLManager.EndPoint]] = [
            .GET: [.health, .uploads, .contact, .services, .about,
                   .adminAppointmentsList, .adminAppointmentsCalendarSummary, .adminAppointmentsDate],
            .POST: [.createAppointment, .adminRegister, .adminLogin,
                    .adminAppointmentsStatus, .adminAppointmentsReschedule],
            .PUT: [],
            .DELETE: []
        ]
        return dict
    }
    
    // Parse request path to EndPoint enum
    static func from(path: String) throws -> (ApiVersion, EndPoint) {
        // Try each version
        for version in [ApiVersion.v1, ApiVersion.v2] {
            // Remove version prefix from path
            guard path.hasPrefix(version.rawValue) else { continue }
            
            let endpointPath = path.replacingOccurrences(of: version.rawValue, with: "")
            
            // Try to match endpoint
            for endpoint in EndPoint.allCases {
                if endpoint.rawValue == endpointPath {
                    return (version, endpoint)
                }
            }
        }
        throw Abort(.notFound, reason: "Invalid url")
    }
    
    // Check if request is Admin Auth (Login or Register)
    static func isAdminAuthRequest(request: Request) -> Bool {
        guard request.method == .POST,
              let (_, endpoint) = try? self.from(path: request.url.path) else {
            return false
        }
        return jwtPathList.contains(endpoint)
    }
}

extension HTTPMethod: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
}
