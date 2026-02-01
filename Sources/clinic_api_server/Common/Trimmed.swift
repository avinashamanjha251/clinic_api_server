//
//  Trimmed.swift
//  clinic_api_server
//
//  Created by Avinash Aman on 26/01/26.
//

import Vapor

/// Property wrapper that automatically trims whitespace from string values
@propertyWrapper
public struct Trimmed: Content {
    private var value: String
    
    public var wrappedValue: String {
        get { value }
        set { value = newValue.trimmingCharacters(in: .whitespaces) }
    }
    
    public init(wrappedValue: String) {
        self.value = wrappedValue.trimmingCharacters(in: .whitespaces)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.value = rawValue.trimmingCharacters(in: .whitespaces)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
