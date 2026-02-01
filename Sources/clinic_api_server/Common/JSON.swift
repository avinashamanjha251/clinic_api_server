//
//  JSON.swift
//  clinic_api_server
//
//  Created by Avinash Aman on 25/01/26.
//

import Foundation
import SwiftBSON

typealias JSONDictionary = [String: Any]
typealias JSONDictionaryArray = [JSONDictionary]
typealias JSONArray = [JSON]

struct JSON: Sendable, Codable {
    private var value: JSONType
    
    private enum JSONType: Sendable, Codable {
        case null
        case bool(Bool)
        case int(Int)
        case double(Double)
        case string(String)
        case array([JSON])
        case dictionary([String: JSON])
    }
    
    // MARK: - Initializers
    init() {
        self.value = .null
    }
    
    init(_ value: Any?) {
        guard let unwrapped = value else {
            self.value = .null
            return
        }
        if let json = value as? JSON {
            self = json
        } else if let bool = unwrapped as? Bool {
            self.value = .bool(bool)
        } else if let int = unwrapped as? Int {
            self.value = .int(int)
        } else if let double = unwrapped as? Double {
            self.value = .double(double)
        } else if let string = unwrapped as? String {
            self.value = .string(string)
        } else if let array = unwrapped as? [JSON] {
            self.value = .array(array)
        } else if let array = unwrapped as? [Any] {
            self.value = .array(array.map { JSON($0) })
        } else if let bson = unwrapped as? BSON {
            self.value = Self.bsonToJSON(bson: bson)
        } else if let dict = unwrapped as? [String: Any] {
            self.value = .dictionary(dict.mapValues {
                JSON($0)
            })
        } else if let dict = unwrapped as? [String: JSON] {
            self.value = .dictionary(dict)
        } else {
            self.value = .null
        }
    }
    
    init(_ data: Data, options: JSONSerialization.ReadingOptions = []) throws {
        let object = try JSONSerialization.jsonObject(with: data, options: options)
        self.init(object)
    }
    
    init(parseJSON jsonString: String) throws {
        guard let data = jsonString.data(using: .utf8) else {
            throw JSONError.invalidJSON
        }
        try self.init(data)
    }
    
    // MARK: - Subscript
    
    subscript(index: Int) -> JSON {
        if case .array(let array) = value, array.indices.contains(index) {
            return array[index]
        }
        return JSON(nil)
    }
    
    subscript(key: String) -> JSON {
        if case .dictionary(let dict) = value {
            return dict[key] ?? JSON(nil)
        }
        return JSON(nil)
    }
    
    
    // MARK: - Getters
    
    var string: String? {
        if case .string(let str) = value {
            return str
        }
        return nil
    }
    
    var stringValue: String {
        switch value {
        case .string(let str): return str
        case .int(let int): return String(int)
        case .double(let double): return String(double)
        case .bool(let bool): return String(bool)
        case .null: return ""
        default: return ""
        }
    }
    
    var int: Int? {
        switch value {
        case .int(let int): return int
        case .double(let double): return Int(double)
        case .string(let str): return Int(str)
        case .bool(let bool): return bool ? 1 : 0
        default: return nil
        }
    }
    
    var intValue: Int {
        return int ?? 0
    }
    
    var double: Double? {
        switch value {
        case .double(let double): return double
        case .int(let int): return Double(int)
        case .string(let str): return Double(str)
        default: return nil
        }
    }
    
    var doubleValue: Double {
        return double ?? 0.0
    }
    
    var bool: Bool? {
        switch value {
        case .bool(let bool): return bool
        case .int(let int): return int != 0
        case .double(let double): return double != 0
        case .string(let str): return str.lowercased() == "true"
        default: return nil
        }
    }
    
    var boolValue: Bool {
        return bool ?? false
    }
    
    var array: [JSON]? {
        if case .array(let array) = value {
            return array
        }
        return nil
    }
    
    var arrayValue: [JSON] {
        return array ?? []
    }
    
    var dictionary: [String: JSON]? {
        if case .dictionary(let dict) = value {
            return dict
        }
        return nil
    }
    
    var dictionaryValue: [String: JSON] {
        return dictionary ?? [:]
    }
    
    var dictionaryObject: [String: Any]? {
        guard case .dictionary(let dict) = value else { return nil }
        return dict.compactMapValues { $0.object }
    }
    
    var arrayObject: [Any]? {
        guard case .array(let array) = value else { return nil }
        return array.compactMap { $0.object }
    }
    
    var object: Any? {
        switch value {
        case .null: return nil
        case .bool(let bool): return bool
        case .int(let int): return int
        case .double(let double): return double
        case .string(let str): return str
        case .array(let array): return array.compactMap { $0.object }
        case .dictionary(let dict): return dict.compactMapValues { $0.object }
        }
    }
    
    var exists: Bool {
        if case .null = value {
            return false
        }
        return true
    }
    
    // MARK: - Codable
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            value = .null
        } else if let bool = try? container.decode(Bool.self) {
            value = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            value = .int(int)
        } else if let double = try? container.decode(Double.self) {
            value = .double(double)
        } else if let string = try? container.decode(String.self) {
            value = .string(string)
        } else if let array = try? container.decode([JSON].self) {
            value = .array(array)
        } else if let dict = try? container.decode([String: JSON].self) {
            value = .dictionary(dict)
        } else {
            throw JSONError.invalidJSON
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case .null:
            try container.encodeNil()
        case .bool(let bool):
            try container.encode(bool)
        case .int(let int):
            try container.encode(int)
        case .double(let double):
            try container.encode(double)
        case .string(let str):
            try container.encode(str)
        case .array(let array):
            try container.encode(array)
        case .dictionary(let dict):
            try container.encode(dict)
        }
    }
    
    // MARK: - Raw Data
    
    func rawData(options: JSONSerialization.WritingOptions = []) throws -> Data {
        guard let obj = object else {
            throw JSONError.invalidJSON
        }
        return try JSONSerialization.data(withJSONObject: obj, options: options)
    }
    
    func rawString(options: JSONSerialization.WritingOptions = []) -> String? {
        guard let data = try? rawData(options: options) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    mutating func removeValue(forKey key: String) {
        switch value {
        case .dictionary(var dict):
            dict.removeValue(forKey: key)
            value = .dictionary(dict)
        default:
            break
        }
    }
}

// MARK: - Error

enum JSONError: Error {
    case invalidJSON
}

// MARK: - Extensions for convenience

extension JSON: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self.value = .null
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: Bool) {
        self.value = .bool(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self.value = .int(value)
    }
}

extension JSON: ExpressibleByFloatLiteral {
    init(floatLiteral value: Double) {
        self.value = .double(value)
    }
}

extension JSON: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.value = .string(value)
    }
}

extension JSON: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: JSON...) {
        self.value = .array(elements)
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (String, JSON)...) {
        var dict = [String: JSON]()
        for (key, value) in elements {
            dict[key] = value
        }
        self.value = .dictionary(dict)
    }
}

extension JSON {
    /// Appends/merges a [String: Any] dictionary into this JSON (for .dictionary type only).
    mutating func merge(dictionary: [String: Any]) {
        guard case .dictionary(var dict) = value else { return }
        for (key, value) in dictionary {
            dict[key] = JSON(value)
        }
        value = .dictionary(dict)
    }
    
    /// Appends/merges a [String: JSON] dictionary into this JSON (for .dictionary type only).
    mutating func merge(jsonDictionary: [String: JSON]) {
        guard case .dictionary(var dict) = value else { return }
        for (key, value) in jsonDictionary {
            dict[key] = value
        }
        value = .dictionary(dict)
    }
    
    mutating func merge(json: JSON) {
        guard
            case .dictionary(var dict) = value,
            case .dictionary(let otherDict) = json.value
        else { return }
        for (key, value) in otherDict {
            dict[key] = value
        }
        value = .dictionary(dict)
    }
}

extension JSON: CustomStringConvertible, CustomDebugStringConvertible {
    
    var description: String {
        rawString(options: .prettyPrinted) ?? "unknown"
    }
    
    var debugDescription: String {
        description
    }
}

extension JSON {
    var data: JSON {
        self[ApiKey.data]
    }
    var statusCode: Int {
        self[ApiKey.statusCode].intValue
    }
    var requestId: String {
        self[ApiKey.requestId].stringValue
    }
    var message: String {
        self[ApiKey.message].stringValue
    }
    var objectId: String {
        self[ApiKey.objectId].stringValue
    }
}

extension Encodable {
    func toJSON(ignoring ignoredKeys: [String] = []) -> JSON {
        
        func removeKeysRecursively(from dict: inout JSONDictionary,
                                   keysToRemove: Set<String>) {
            for key in keysToRemove {
                dict.removeValue(forKey: key)
            }
            for (key, value) in dict {
                if var nestedDict = value as? JSONDictionary {
                    removeKeysRecursively(from: &nestedDict,
                                          keysToRemove: keysToRemove)
                    dict[key] = nestedDict
                } else if var nestedArray = value as? [Any] {
                    for (index, element) in nestedArray.enumerated() {
                        if var elementDict = element as? JSONDictionary {
                            removeKeysRecursively(from: &elementDict,
                                                  keysToRemove: keysToRemove)
                            nestedArray[index] = elementDict
                        }
                    }
                    dict[key] = nestedArray
                }
            }
        }
        
        do {
            let data = try JSONEncoder().encode(self)
            guard var dictionary = try JSONSerialization.jsonObject(with: data,
                                                                    options: .allowFragments) as? JSONDictionary else {
                return JSON()
            }
            removeKeysRecursively(from: &dictionary,
                                  keysToRemove: Set(ignoredKeys))
            return JSON(dictionary)
        } catch {
            print("Error converting Codable to dictionary: \(error)")
            return JSON()
        }
    }
}

extension BSONDocument {
    func toJSON() -> JSON {
        var result: JSONDictionary = [:]
        for (key, value) in self {
            switch value {
            case .objectID(let objectId):
                result[key] = objectId.hex
            case .string(let string):
                result[key] = string
            case .int32(let int):
                result[key] = Int(int)
            case .int64(let int):
                result[key] = Int(int)
            case .double(let double):
                result[key] = double
            case .bool(let bool):
                result[key] = bool
            case .datetime(let date):
                result[key] = date.timeIntervalSince1970
            case .null:
                result[key] = NSNull()
            case .document(let doc):
                result[key] = doc.toJSON()
            case .array(let array):
                result[key] = array.map { bson in
                    if case .document(let doc) = bson {
                        return doc.toJSON()
                    }
                    return [:]
                }
            default:
                result[key] = nil
            }
        }
        return JSON(result)
    }
}

extension JSON {
    // Change this function to be non-mutating and private
    static private func bsonToJSON(bson: BSON) -> JSONType {
        switch bson {
        case .null:
            return .null
        case .bool(let bool):
            return .bool(bool)
        case .int32(let int):
            return .int(Int(int))
        case .int64(let int):
            return .int(Int(int))
        case .double(let double):
            return .double(double)
        case .string(let string):
            return .string(string)
        case .array(let array):
            return .array(array.map { JSON($0) })
        case .document(let doc):
            var dict: [String: JSON] = [:]
            for (key, value) in doc {
                dict[key] = JSON(value)
            }
            return .dictionary(dict)
        default:
            return .string(String(describing: bson))
        }
    }
}

extension Encodable {
    /// Converts any Codable model to a BSONDocument, optionally ignoring specified keys
    func toBSONDocument(ignoring ignoredKeys: [String] = []) -> BSONDocument {
        do {
            let encoder = BSONEncoder()
            var document = try encoder.encode(self)
            
            // Remove ignored keys
            for key in ignoredKeys {
                document[key] = nil
            }
            return document
        } catch {
            print("Encoding error: \(error)")
            return BSONDocument()
        }
    }
}
