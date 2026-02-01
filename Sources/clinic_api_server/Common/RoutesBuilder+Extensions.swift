//
//  RoutesBuilder+Extensions.swift
//  clinic_api_server
//
//  Created by Avinash Aman on 31/01/26.
//

import Vapor

typealias ResponseCompletion = @Sendable (Request) async throws -> Response
typealias anyRoutesBuilder = any RoutesBuilder

extension RoutesBuilder {
   
    func grouped(version: URLManager.ApiVersion = .v1,
                 path: URLManager.EndPoint) -> anyRoutesBuilder {
        grouped(path.path(version))
    }
    
    func get(path: URLManager.EndPoint,
             version: URLManager.ApiVersion = .v1,
             completion: @escaping ResponseCompletion) {
        self.on(.GET,
                path.path(version),
                use: completion)
    }
    
    func post(path: URLManager.EndPoint,
              version: URLManager.ApiVersion = .v1,
              completion: @escaping ResponseCompletion) {
        self.on(.POST,
                path.path(version),
                use: completion)
    }
    
    func put(path: URLManager.EndPoint,
             version: URLManager.ApiVersion = .v1,
             completion: @escaping ResponseCompletion) {
        self.on(.PUT,
                path.path(version),
                use: completion)
    }
    
    func delete(path: URLManager.EndPoint,
                version: URLManager.ApiVersion = .v1,
                completion: @escaping ResponseCompletion) {
        self.on(.DELETE,
                path.path(version),
                use: completion)
    }
    
    func multipart(path: URLManager.EndPoint,
                   version: URLManager.ApiVersion = .v1,
                   completion: @escaping ResponseCompletion) {
        self.on(.POST,
                path.path(version),
                body: .stream,
                use: completion)
    }
}
