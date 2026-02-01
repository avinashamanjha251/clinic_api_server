//
//  Validatable+Extensions.swift
//  clinic_api_server
//
//  Created by Avinash Aman on 01/02/26.
//


import Vapor
import Foundation

extension Validations {
    mutating func add<T>(apiKey: String,
                         as type: T.Type = T.self,
                         is validator: Validator<T> = .valid,
                         required: Bool = true,
                         customFailureDescription: (any Error)? = nil) {
        self.add(ValidationKey(stringLiteral: apiKey),
                 as: type,
                 is: validator,
                 required: required,
                 customFailureDescription: customFailureDescription?.localizedDescription)
    }
}

extension Validatable where Self: Codable {
    /// Validates an already-decoded instance
    func validate() throws {
        var validations = Validations()
        Self.validations(&validations)
        
        // Encode to Data
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        
        // Convert Data to String
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw Abort(.internalServerError, reason: "Failed to convert data to JSON string")
        }
        
        // Validate using the JSON string
        let _ = try validations.validate(json: jsonString)
    }
}

extension ValidatorResults {
    /// Result for strong password validation
    struct StrongPassword {
        let isValid: Bool
    }
}

extension ValidatorResults.StrongPassword: ValidatorResult {
    var isFailure: Bool {
        !isValid
    }
    
    var successDescription: String? {
        "is a strong password"
    }
    
    var failureDescription: String? {
        "must contain at least one uppercase letter, one lowercase letter, one number, and one special character"
    }
}

extension Validator where T == String {
    /// Validates password strength
    static var strongPassword: Validator<T> {
        .init { value in
            let hasUppercase = value.contains(where: { $0.isUppercase })
            let hasLowercase = value.contains(where: { $0.isLowercase })
            let hasNumber = value.contains(where: { $0.isNumber })
            let hasSpecial = value.rangeOfCharacter(from: .init(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil
            let minLength = value.count >= 8
            
            let isValid = hasUppercase && hasLowercase && hasNumber && hasSpecial && minLength
            return ValidatorResults.StrongPassword(isValid: isValid)
        }
    }
}

extension ValidatorResults {
    struct PhoneNumber {
        let isValid: Bool
    }
}

extension ValidatorResults.PhoneNumber: ValidatorResult {
    var isFailure: Bool { !isValid }
    
    var successDescription: String? {
        "is a valid phone number"
    }
    
    var failureDescription: String? {
        "must be a valid phone number (10 digits, optionally starting with +)"
    }
}

extension Validator where T == String {
    /// Validates phone numbers (international format)
    static var phoneNumber: Validator<T> {
        .init { value in
            let pattern = "^\\+?[1-9]\\d{9,14}$"
            let regex = try? NSRegularExpression(pattern: pattern)
            let range = NSRange(value.startIndex..<value.endIndex, in: value)
            let isValid = regex?.firstMatch(in: value, range: range) != nil
            
            return ValidatorResults.PhoneNumber(isValid: isValid)
        }
    }
}

extension ValidatorResults {
    struct ValidURL {
        let isValid: Bool
    }
}

extension ValidatorResults.ValidURL: ValidatorResult {
    var isFailure: Bool { !isValid }
    
    var successDescription: String? {
        "is a valid URL"
    }
    
    var failureDescription: String? {
        "must be a valid URL with http:// or https://"
    }
}

extension Validator where T == String {
    /// Validates URLs with scheme requirement
    static var validURL: Validator<T> {
        .init { value in
            guard let url = URL(string: value),
                  let scheme = url.scheme,
                  ["http", "https"].contains(scheme.lowercased()) else {
                return ValidatorResults.ValidURL(isValid: false)
            }
            return ValidatorResults.ValidURL(isValid: true)
        }
    }
}

extension ValidatorResults {
    struct Username {
        let isValid: Bool
    }
}

extension ValidatorResults.Username: ValidatorResult {
    var isFailure: Bool { !isValid }
    
    var successDescription: String? {
        "is a valid username"
    }
    
    var failureDescription: String? {
        "must be 3-20 characters, alphanumeric with underscores and hyphens only"
    }
}

extension Validator where T == String {
    /// Validates username format
    static var username: Validator<T> {
        .init { value in
            let pattern = "^[a-zA-Z0-9_-]{3,20}$"
            let regex = try? NSRegularExpression(pattern: pattern)
            let range = NSRange(value.startIndex..<value.endIndex, in: value)
            let isValid = regex?.firstMatch(in: value, range: range) != nil
            
            return ValidatorResults.Username(isValid: isValid)
        }
    }
}

extension ValidatorResults {
    struct DateRange {
        let isValid: Bool
    }
}

extension ValidatorResults.DateRange: ValidatorResult {
    var isFailure: Bool { !isValid }
    
    var successDescription: String? {
        "is within valid date range"
    }
    
    var failureDescription: String? {
        "must be a future date"
    }
}

extension Validator where T == Date {
    /// Validates date is in the future
    static var futureDate: Validator<T> {
        .init { value in
            ValidatorResults.DateRange(isValid: value > Date())
        }
    }
    
    /// Validates date is in the past
    static var pastDate: Validator<T> {
        .init { value in
            ValidatorResults.DateRange(isValid: value < Date())
        }
    }
    
    /// Validates age range (for birthdate)
    static func ageRange(_ range: ClosedRange<Int>) -> Validator<T> {
        .init { value in
            let calendar = Calendar.current
            let now = Date()
            guard let age = calendar.dateComponents([.year], from: value, to: now).year else {
                return ValidatorResults.DateRange(isValid: false)
            }
            return ValidatorResults.DateRange(isValid: range.contains(age))
        }
    }
}
