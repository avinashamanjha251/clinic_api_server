//
//  Validations+Extensions.swift
//  clinic_api_server
//
//  Created by Avinash Aman on 26/01/26.
//

import Vapor

extension Validations {
    /// Add a validation with custom API key and failure description
    mutating func add<T>(
        apiKey: String,
        as type: T.Type = T.self,
        is validator: Validator<T>,
        required: Bool = true,
        customFailureDescription: String? = nil
    ) where T: Validatable {
        self.add(ValidationKey(stringLiteral: apiKey),
                 as: type,
                 is: validator,
                 required: required,
                 customFailureDescription: customFailureDescription)
    }
    
    /// Add a validation with custom API key and failure description for non-Validatable types
    mutating func add<T>(
        apiKey: String,
        as type: T.Type = T.self,
        is validator: Validator<T>,
        required: Bool = true,
        customFailureDescription: String? = nil
    ) {
        self.add(ValidationKey(stringLiteral: apiKey),
                 as: type,
                 is: validator,
                 required: required)
    }
}
