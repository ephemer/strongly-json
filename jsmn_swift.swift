//
//  jsmn_swift.swift
//  StronglyJSON
//
//  Created by Geordie Jay on 22.11.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

/**
* Allocates a fresh unused token from the token pull.
*/

typealias CharIndex = String.UnicodeScalarIndex

class JSMNParser {
    init(chars: String.UnicodeScalarView) {
        self.chars = chars
        pos = chars.indices.first!
    }
    let chars: String.UnicodeScalarView
    var pos: CharIndex
    var tokens: [JSMNToken] = []
    var toksuper = -1
}


struct JSMNToken: CustomStringConvertible {
    init(type: JSMNType = .UNDEFINED, start: CharIndex?, end: CharIndex?, parent: Int?) {
        self.type = type
        self.start = start
        self.end = end
        self.parent = parent
    }

    var size = 0
    var type: JSMNType
    var start: CharIndex?
    var end: CharIndex?
    var parent: Int?
    var description: String {
        return "\(type): \(size) (parent: \(parent))"
    }
}

enum JSMNType {
    case UNDEFINED
    case OBJECT
    case ARRAY
    case STRING
    case PRIMITIVE
}

enum JSMNError: ErrorType {
    /* Not enough tokens were provided */
    case NoMem
    /* Invalid character inside JSON string */
    case InvalidCharacter
    /* The string is not a full JSON packet, more bytes expected */
    case PartialInputProvided
};

/**
* Fills next available token with JSON primitive.
*/
extension JSMNParser {
    func parsePrimitive() throws {
        let initialPos = pos

        for (; pos < chars.endIndex && chars[pos] != "\0"; pos++) {
            let char = chars[pos]
            switch char {
            // if _NOT_ STRICT
            // case ":":
            //     fallthrough
            // end if
            // In strict mode primitive must be followed by "," or "}" or "]"
            case "\t", "\r", "\n", " ", ",", "]", "}":
                let token = JSMNToken(type: .PRIMITIVE, start: initialPos, end: pos, parent: toksuper)
                tokens.append(token)
                pos--
                return
            default:
                break
            }

            if char.value < 32 || char.value >= 127 {
                throw JSMNError.InvalidCharacter
            }
        }

        // #ifdef JSMN_STRICT
        /* In strict mode primitive must be followed by a comma/object/array */
        pos = initialPos;
        throw JSMNError.PartialInputProvided;
        // #endif

    }

    /**
    * Fills next token with JSON string.
    */
    func parseString() throws {
        let start = self.pos

        /* Skip starting quote */
        pos++

        for (;self.pos < chars.endIndex && chars[self.pos] != "\0"; self.pos++) {
            let char = chars[self.pos]

            /* Quote: end of string */
            if (char == "\"") {
                let token = JSMNToken(type: .STRING, start: start.successor(), end: pos, parent: toksuper)
                tokens.append(token)
                return
            }

            /* Backslash: Quoted symbol expected */
            if char == "\\" && pos.successor() < chars.endIndex {
                self.pos++
                switch (chars[pos]) {
                    /* Allowed escaped symbols */
                case "\"", "/", "\\", "b", "f", "r", "n", "t":
                    break
                case "u":
                    /* Allows escaped symbol \uXXXX */
                    pos++
                    for (var i = 0; i < 4 && pos < chars.endIndex && chars[pos] != "\0"; i++) {
                        /* If it isn't a hex character we have an error */
                        let char = chars[pos].value
                        if !((char >= 48 && char <= 57) || /* 0-9 */
                             (char >= 65 && char <= 70) || /* A-F */
                             (char >= 97 && char <= 102 )) { /* a-f */
                                pos = start
                                throw JSMNError.InvalidCharacter
                        }
                        pos++
                    }

                    pos--

                default:
                    /* Unexpected symbol */
                    pos = start
                    throw JSMNError.InvalidCharacter
                }
            }

        }
    }

    /**
    * Parse JSON string and fill tokens.
    */
    func parse() throws -> Int {
        var count = tokens.count

        for (; pos < chars.endIndex && chars[pos] != "\0"; pos++) {
            let char = chars[pos]
            let tokenType: JSMNType

            switch(char) {
            case "{", "[":
                count++
                tokenType = (char == "{") ? .OBJECT : .ARRAY

                let token = JSMNToken(type: tokenType, start: pos, end: nil, parent: nil)
                tokens.append(token)

                if toksuper != -1 {
                    tokens[toksuper].size++
                    tokens[tokens.count - 1].parent = toksuper
                }

                toksuper = tokens.count - 1

            case "}", "]":
                tokenType = (char == "}") ? .OBJECT : .ARRAY

                if (tokens.count < 1) {
                    throw JSMNError.InvalidCharacter
                }

                var token = tokens[tokens.count - 1]

                for (;;) {
                    if (token.start != nil && token.end == nil) {
                        if (token.type != tokenType) {
                            throw JSMNError.InvalidCharacter
                        }
                        token.end = pos.successor()
                        toksuper = token.parent!
                        break
                    }
                    if (token.parent == -1) {
                        break
                    }
                    token = tokens[token.parent!]
                }

            case "\"":
                do { try parseString() } catch {
                    throw error
                }

                count++

                if (toksuper != -1) {
                    tokens[toksuper].size++;
                }

            case "\t", "\r", "\n", " ":
                print("lol")
            case ":":
                toksuper = tokens.count - 1
            case ",":
                if (toksuper != -1 &&
                    tokens[toksuper].type != .ARRAY &&
                    tokens[toksuper].type != .OBJECT) {
                        toksuper = tokens[toksuper].parent!;
                }

            //#ifdef JSMN_STRICT
            /* In strict mode primitives are: numbers and booleans */
            case "-", "0"..."9", "t", "f", "n":
                /* And they must not be keys of the object */

                if (toksuper != -1) {
                    let t = tokens[toksuper]
                    if (t.type == .OBJECT || (t.type == .STRING && t.size != 0)) {
                        throw JSMNError.InvalidCharacter
                    }
                }

                do { try parsePrimitive() } catch {
                    throw error
                }

                count++

                if toksuper != -1 {
                    tokens[toksuper].size++
                }
            // #else
            default:
                /* In non-strict mode every unquoted value is a primitive */
                //#ifdef JSMN_STRICT
                /* Unexpected char in strict mode */
                throw JSMNError.InvalidCharacter
                //#endif
            } // end switch

        } // end for loop

        for (var i = tokens.count - 1; i >= 0; i--) {
            /* Unmatched opened object or array */
            if (tokens[i].start != nil && tokens[i].end == nil) {
                throw JSMNError.PartialInputProvided
            }
        }

        return count
    }
}
