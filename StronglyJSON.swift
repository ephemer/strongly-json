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

// MARK:- StringLiteralConvertible conformance

extension JSON : StringLiteralConvertible {
    public init(stringLiteral value: String) {
        let string = value.trimmed()
        
        if let int = Int(string) {
            self = .JSONInt(int)
        } else if let dbl = Double(string) {
            self = .JSONDouble(dbl)
        } else if let bool = JSON.boolFromString(string) {
            self = bool
        } else if string == "null" {
            self = .JSONNull
        } else if let array = JSON.arrayFromString(string) {
            self = array
        } else if let dict = try? JSON.dictFromString(string) {
            self = dict
        } else {
            self = .JSONString(string)
        }
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterType) {
        self = JSON(stringLiteral: String(value))
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalarType) {
        self = JSON(stringLiteral: String(value))
    }
}


// MARK: fromString helpers

private extension String {
    func trimmed() -> String {
        var chars = self.characters
        let whitespaceCharset: Set<Character> = [" ", "\u{000A}", "\u{000B}", "\u{000C}", "\u{000D}", "\u{0085}"]
        
        while chars.count > 0 {
            if whitespaceCharset.contains(chars.first!) {
                chars = chars.dropFirst()
            } else if whitespaceCharset.contains(chars.last!) {
                chars = chars.dropLast()
            } else {
                break
            }
        }
        
        return String(chars)
    }
}

extension JSON {
    
    static private func boolFromString(string: String) -> JSON? {
        switch string.lowercaseString {
        case "true": return true
        case "false": return false
        default: return nil
        }
    }
    
    private enum DictGenerationError : ErrorType {
        case NotSurroundedInCurlyBraces
        case ContentsIncorrect
    }
    
    static private func dictFromString(string: String) throws -> JSON {
        var chars = string.characters // copy on write
        if chars.first == "{" && chars.last == "}" {
            chars = chars.dropFirst().dropLast()
            
            var dict = [String : JSON]()
            let dictPairs = chars.splitIntoChunks()
            
            dictPairs.forEach {
                let dictComponents = $0.characters.split(":")
                if dictComponents.count != 2 { return }
                
                let key = String(dictComponents[0]).trimmed()
                dict[key] = JSON(stringLiteral: String(dictComponents[1]))
            }
            
            if dict.count == dictPairs.count {
                return JSON.JSONObject(dict)
            } else {
                throw DictGenerationError.ContentsIncorrect
            }
        }
        
        throw DictGenerationError.NotSurroundedInCurlyBraces
    }
    
    static private func arrayFromString(string: String) -> JSON? {
        var chars = string.characters // copy on write
        if chars.first == "[" && chars.last == "]" {
            chars = chars.dropFirst().dropLast()
            let jsonArray = chars.splitIntoChunks().map { JSON(stringLiteral: $0) }
            return .JSONArray(jsonArray)
        }
        
        return nil
    }
}

extension String.CharacterView {
    func splitIntoChunks(separator: Character = ",") -> [String] {
        var currentChunk = ""
        var chunks: [String] = []
        var brackets = [Character]()
        
        self.enumerate().forEach { (i, character) in
            switch character {
            case "[": brackets.append(character)
            case "{": brackets.append(character)
            case "]": if let i = brackets.indexOf("[") { brackets.removeAtIndex(i) }
            case "}": if let i = brackets.indexOf("{") { brackets.removeAtIndex(i) }
            case ",":
                if brackets.count == 0 {
                    chunks.append(currentChunk)
                    currentChunk = ""
                    return
                }
            default: break
            }
            
            currentChunk.append(character)
        }
        
        if currentChunk != "" { chunks.append(currentChunk) }
        
        // XXX: Fix this terrible error handling:
        if brackets.count != 0 { print("There was an unmatched count of brackets"); return [] }
        
        return chunks
    }
}


// MARK:- Conform to other literal convertibles

extension JSON : BooleanLiteralConvertible, IntegerLiteralConvertible, FloatLiteralConvertible {
    public init(booleanLiteral value: Bool) { self = .JSONBool(value)   }
    public init(integerLiteral value: Int)  { self = .JSONInt(value)    }
    public init(floatLiteral value: Double) { self = .JSONDouble(value) }
}

extension JSON : ArrayLiteralConvertible, DictionaryLiteralConvertible {
    public init(arrayLiteral elements: JSON...) {
        self = JSON.JSONArray(elements)
    }
    
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var dict = [String: JSON]()
        elements.forEach { dict[$0.0] = $0.1 }
        self = JSON.JSONObject(dict)
    }
}

extension JSON : NilLiteralConvertible {
    public init(nilLiteral: ()) {
        self = .JSONNull
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


// MARK:- Convert to string (including verbose debugging version)

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
        case let .JSONArray(o): return "JSONArray(\(o))"
        case let .JSONObject(o): return "JSONObject(\(o))"
        case .JSONNull: return "JSONNull"
        }
    }
}


// Make easy-to-use accessor API

extension JSON {
    subscript(i: Int) -> JSON? {
        switch self {
            case .JSONArray(let array): if i < array.count { return array[i] }
            default: break
        }
        return nil
    }
    
    subscript(key: String) -> JSON? {
        switch self {
            case .JSONObject(let obj): return obj[key]
            default: break
        }
        return nil
    }
    
    public var asString: String {
        return self.description
    }
    
    // This ensures the syntax gets correctly exported as serialised JSON
    // XXX: I have not tested this much yet, as the focus has been serializing input
    public var asJSONString: String {
        switch self {
        case .JSONString(let string): return "\"\(string)\""
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