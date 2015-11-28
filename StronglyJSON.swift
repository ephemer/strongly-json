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
    case JSONValue(String)
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
        return self.description
    }
    
    public var asInt: Int? {
        switch self {
        case .JSONValue(let str): return Int(str)
        default: return nil
        }
    }
    
    public var asDouble: Double? {
        switch self {
        case .JSONValue(let str): return Double(str)
        default: return nil
        }
    }
    
    public var asBool: Bool {
        switch self {
        case .JSONValue(let str):
            return !str.isEmpty && Double(str) != 0 && str != "false" && str != "null"
        case .JSONObject: return true
        case .JSONArray: return true
        }
    }
    
    public var asDict: [String: JSON]? {
        switch self {
        case .JSONObject(let dict): return dict
        default: return nil
        }
    }
    
    public var isNull: Bool {
        if case .JSONValue(let val) = self where val == "null" {
            return true
        } else {
            return false
        }
    }
    
}


// MARK: Convert to string (including verbose debugging version)

extension JSON : CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case let .JSONValue(o): return o
        case let .JSONArray(o): return "\(o)"
        case let .JSONObject(o): return "\(o)"
        }
    }
    
    public var debugDescription: String {
        switch self {
        case let .JSONValue(o): return "JSONValue: \(o)"
        case let .JSONArray(o): return "JSONArray: \(o)"
        case let .JSONObject(o): return "JSONObject: \(o)"
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
        self = .JSONValue("null")
    }
    
    public init(booleanLiteral value: Bool) {
        self = .JSONValue("\(value)")
    }
    
    public init(integerLiteral value: Int) {
        self = .JSONValue("\(value)")
    }
    
    public init(floatLiteral value: Double) {
        self = .JSONValue("\(value)")
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
    case let (.JSONValue(a), .JSONValue(b)): return a == b
    case let (.JSONArray(a), .JSONArray(b)): return a == b
    case let (.JSONObject(a), .JSONObject(b)): return a == b
    default: return false
    }
}
