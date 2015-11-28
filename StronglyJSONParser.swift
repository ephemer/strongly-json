//
//  StronglyJSONLexer.swift
//  StronglyJSON
//
//  Created by Geordie Jay on 17.09.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

typealias Char = UnicodeScalar
private let SingleQuote: Char        = "'"
private let DoubleQuote: Char        = "\""
private let OpenSquareBracket: Char  = "["
private let CloseSquareBracket: Char = "]"
private let OpenCurlyBracket: Char   = "{"
private let CloseCurlyBracket: Char  = "}"
private let Separator: Char          = ","
private let ValueDelimiter: Char     = ":"


class JSONParser {
    let jsonString: String.UnicodeScalarView
    var lowerBound: String.UnicodeScalarIndex
    var curIndex: String.UnicodeScalarIndex
    
    init(jsonString: String) {
        self.jsonString = jsonString.unicodeScalars
        lowerBound = self.jsonString.indices.first!
        curIndex = lowerBound
    }
    
    private enum JSONNodeType {
        case rootNode, singleQuote, doubleQuote, array, object
        init?(startingCharacter character: Char) {
            switch character {
            case SingleQuote: self = .singleQuote
            case DoubleQuote: self = .doubleQuote
            case OpenSquareBracket: self = .array
            case OpenCurlyBracket: self = .object
            default: return nil
            }
        }
        
        var isQuotedString: Bool {
            return self == .singleQuote || self == .doubleQuote
        }
    }
    
    func advanceLowerBound() {
        lowerBound = curIndex.successor()
    }
    
    func parse() -> JSON {
        if jsonString.isAPlainString {
            return .JSONValue(String(jsonString))
        }
        return parseAs(.rootNode)
    }
    
    private func parseAs(node: JSONNodeType) -> JSON {
        // We want to start at the 2nd character of any node that has a parent
        if (node != .rootNode) {
            advanceLowerBound()
            curIndex = lowerBound
        }
        
        let startedNodeAt = lowerBound
        
        var tokens: [JSON] = []
        
        func addTokenSinceLowerBound() {
            let chars = jsonString[lowerBound ..< curIndex].trimmed()
            if chars.count > 0 {
                let str = String(chars)
                addToken(.JSONValue(str))
            } else {
                advanceLowerBound()
            }
        }
        
        func addToken(token: JSON) {
            tokens.append(token)
            advanceLowerBound()
        }
        
        while curIndex < jsonString.endIndex {
            let char = jsonString[curIndex]
            
            switch char {
            case
            // Close any unclosed tokens, if appropriate
            SingleQuote where node == .singleQuote,
            DoubleQuote where node == .doubleQuote:
                addTokenSinceLowerBound()
                let str = tokens.map{$0.asString}.reduce("", combine: +)
                return .JSONValue(str)
                
            case CloseSquareBracket where node == .array:
                addTokenSinceLowerBound()
                return .JSONArray(tokens)
            
            case CloseCurlyBracket where node == .object:
                addTokenSinceLowerBound()
                return .JSONObject(tokens.toDict())
            
            // Parse the contents of a new token
            case SingleQuote, DoubleQuote, OpenSquareBracket, OpenCurlyBracket:
                // We already dealt with (possibly) closing brackets above
                if (node == .singleQuote || node == .doubleQuote) { break }
                let token = parseAs(JSONNodeType(startingCharacter: char)!)
                addToken(token)
                
            // Deal with separators
            case
            Separator where node == .object || node == .array,
            ValueDelimiter where node == .object:
                addTokenSinceLowerBound()
            
            // This is not a special case, wait until we find something that is
            default: break
            }
            curIndex = curIndex.successor()
        }
        
        if node == .rootNode && tokens.count == 1 {
            return tokens[0]
        }
        
        if tokens.count > 0 {
            print("\nNode type", node, "didn't get closed:")
            print(String(jsonString[startedNodeAt ..< curIndex]))
            print("Tokens", tokens, "\n")
        }
        return nil
    }
}


// MARK: Standard library helpers

extension Array where Element : CustomStringConvertible {
    func toDict () -> [String: Element] { // should throw
        var dict = [String: Element]()
        if (self.count % 2) != 0 { return dict }
        for i in 0.stride(to: self.count, by: 2) {
            dict[self[i].description] = self[i + 1]
        }
        return dict
    }
}

private extension Bool {
    init?(_ string: String) {
        switch string.lowercaseString {
        case "true": self = true
        case "false": self = false
        default: return nil
        }
    }
}


let whitespaceCharset: Set<UnicodeScalar> = [
    " ", "\n", "\u{000A}", "\u{000B}", "\u{000C}", "\u{000D}", "\u{0085}"
]

private extension String.UnicodeScalarView {
    var isAPlainString: Bool {return !self.isAnArray && !self.isAnObject}
    var isAnArray: Bool { return self.first == "[" && self.last == "]" }
    var isAnObject: Bool { return self.first == "{" && self.last == "}" }
    
    func trimmed() -> String.UnicodeScalarView {
        var chars = self
        while chars.count > 0 {
            if whitespaceCharset.contains(chars.first!) {
                chars = chars.dropFirst()
            } else if whitespaceCharset.contains(chars.last!) {
                chars = chars.dropLast()
            } else {
                break
            }
        }
        
        return chars
    }
}