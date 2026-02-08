//
//  AIProxyJSONValue.swift
//
//
//  Created by Lou Zell on 12/15/24.
//

import Foundation

/// A type that can represent any JSON value
///
/// Used in request bodies where the value can be of any type
nonisolated public enum AIProxyJSONValue: Decodable, Encodable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null
    case array([AIProxyJSONValue])
    case object([String: AIProxyJSONValue])

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        case .array(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
            return
        }

        if let stringVal = try? container.decode(String.self) {
            self = .string(stringVal)
            return
        }

        if let intVal = try? container.decode(Int.self) {
            self = .int(intVal)
            return
        }

        if let doubleVal = try? container.decode(Double.self) {
            self = .double(doubleVal)
            return
        }

        if let boolVal = try? container.decode(Bool.self) {
            self = .bool(boolVal)
            return
        }

        if let arrayVal = try? container.decode([AIProxyJSONValue].self) {
            self = .array(arrayVal)
            return
        }

        if let objectVal = try? container.decode([String: AIProxyJSONValue].self) {
            self = .object(objectVal)
            return
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "AIProxyJSONValue value cannot be decoded"
        )
    }
}

extension Dictionary where Key == String, Value == AIProxyJSONValue {
    var untypedDictionary: [String: any Sendable] {
        self.mapValues { $0.toAnySendable() }
    }
}

extension AIProxyJSONValue {
    fileprivate func toAnySendable() -> any Sendable {
        switch self {
        case .string(let str): return str
        case .int(let int): return int
        case .double(let double): return double
        case .bool(let bool): return bool
        case .null: return NSNull()
        case .array(let array): return array.map { $0.toAnySendable() }
        case .object(let dict): return dict.mapValues { $0.toAnySendable() }
        }
    }
}
