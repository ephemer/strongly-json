//
//  StronglyJSON.swift
//  StronglyJSON
//
//  Created by Geordie Jay on 12.09.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

public enum JSON {
    case JSONArray([JSON])
    case JSONObject([String : JSON])
    case JSONString(String)
    case JSONInt(Int)
    case JSONDouble(Double)
    case JSONBool(Bool)
    case JSONNull
}

// MARK: Easy to use accessors

extension JSON {
    subscript(i: Int) -> JSON? {
        switch self {
        case .JSONArray(let array) where i < array.count: return array[i]
        default: return nil
        }
    }
    
    subscript(key: String) -> JSON? {
        switch self {
        case .JSONObject(let obj): return obj[key]
        default: return nil
        }
    }
    
    public var asString: String {
        return self.description
    }
    
    // This ensures the syntax gets correctly exported as serialised JSON
    // XXX: I have not tested this much yet, as the focus has been serializing input
    public var asJSONString: String {
        switch self {
        case .JSONString(let string): return string.debugDescription
        default: return self.description
        }
    }
    
    public var asInt: Int? {
        switch self {
        case .JSONInt(let int): return int
        default: return nil
        }
    }
    
    public var asDouble: Double? {
        switch self {
        case .JSONInt(let int): return Double(int)
        case .JSONDouble(let double): return double
        default: return nil
        }
    }
    
    public var asBool: Bool {
        switch self {
        case .JSONBool(let bool): return bool
        case .JSONInt(let int): return int != 0
        case .JSONDouble(let double): return double != 0
        case .JSONString(let string): return string.characters.count > 0
        case .JSONObject: return true
        case .JSONArray: return true
        case .JSONNull: return false
        }
    }
    
    public var asDict: [String: JSON]? {
        switch self {
        case .JSONObject(let dict): return dict
        default: return nil
        }
    }
    
    public var isNull: Bool {
        return self == .JSONNull
    }
    
}


// MARK: Convert to string (including verbose debugging version)

extension JSON : CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case let .JSONString(o): return o
        case let .JSONInt(o): return "\(o)"
        case let .JSONDouble(o): return "\(o)"
        case let .JSONBool(o): return "\(o)"
        case let .JSONArray(o): return "\(o)"
        case let .JSONObject(o): return "\(o)"
        case .JSONNull: return "null"
        }
    }
    
    public var debugDescription: String {
        switch self {
        case let .JSONString(o): return o.debugDescription
        case let .JSONInt(o): return "JSONInt(\(o))"
        case let .JSONDouble(o): return "JSONDouble(\(o))"
        case let .JSONBool(o): return "JSONBool(\(o))"
        case let .JSONArray(o): return "JSONArray: \(o)"
        case let .JSONObject(o): return "JSONObject: \(o)"
        case .JSONNull: return "JSONNull"
        }
    }
}


// MARK:- Convert strings and other literals into JSON

extension JSON : StringLiteralConvertible {
    public init(stringLiteral string: String) {
        self = JSONParser(jsonString: string).parse()
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self = JSON(stringLiteral: value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self = JSON(stringLiteral: value)
    }
}

extension JSON : BooleanLiteralConvertible, IntegerLiteralConvertible, FloatLiteralConvertible, NilLiteralConvertible, ArrayLiteralConvertible, DictionaryLiteralConvertible {
    public init(nilLiteral: ()) {
        self = .JSONNull
    }
    
    public init(booleanLiteral value: Bool) {
        self = .JSONBool(value)
    }
    
    public init(integerLiteral value: Int) {
        self = .JSONInt(value)
    }
    
    public init(floatLiteral value: Double) {
        self = .JSONDouble(value)
    }
    
    public init(arrayLiteral elements: JSON...) {
        self = .JSONArray(elements)
    }
    
    public init(dictionaryLiteral pairs: (String, JSON)...) {
        self = .JSONObject([String: JSON](keyValuePairs: pairs))
    }
}

private extension Dictionary {
    init(keyValuePairs: [(Key, Value)]) {
        self.init()
        keyValuePairs.forEach { self[$0.0] = $0.1 }
    }
}


// MARK:- Equatable conformance

extension JSON : Equatable {}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
    case let (.JSONInt(a), .JSONInt(b)): return a == b
    case let (.JSONString(a), .JSONString(b)): return a == b
    case let (.JSONDouble(a), .JSONDouble(b)): return a == b
    case let (.JSONBool(a), .JSONBool(b)): return a == b
    case let (.JSONArray(a), .JSONArray(b)): return a == b
    case let (.JSONObject(a), .JSONObject(b)): return a == b
    case (.JSONNull, .JSONNull): return true
    default: return false
    }
}
