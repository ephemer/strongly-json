//
//  QuickJSON.swift
//  StronglyJSON
//
//  Created by Geordie Jay on 26.11.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

typealias Index = String.UnicodeScalarIndex

protocol JSONSerializer {
    static func fromString(str: String.UnicodeScalarView, startIndex: Index) throws -> (JSON, Index)
}

protocol JSON: CustomStringConvertible {
    //    var asDouble: Double? {get}
    //    var asString: String? {get}
    //    var asInteger: Int? {get}
    //    var asBool: Bool {get}
    //    var isNull: Bool {get}
}

struct JSONError: ErrorType, CustomStringConvertible {
    let reason: Reason
    let index: Index
    var description: String {
        return "\(reason) at \(index)"
    }

    enum Reason {
        case InvalidCharacter
        case PartialInputProvided
        case RootLevelMustBeAContainer
        case InvalidNumberPrimitive
    }
}

public struct JSONContainer: JSON, JSONSerializer {
    private enum ContainerType {
        case Array, Object
    }

    private let type: ContainerType
    let tokens: [JSON]

    public var description: String {
        if type == .Array {
            return tokens.description
        } else {
            var dict = [String: JSON]()
            for i in 0.stride(to: tokens.count, by: 2) {
                let key = tokens[i].description
                let value = tokens[i+1]
                dict[key] = value
            }
            return dict.description
        }
    }

    static func fromString(str: String.UnicodeScalarView, startIndex: Index) throws -> (JSON, Index) {
        var tokens: [JSON] = []
        tokens.reserveCapacity(300) // XXX: a magic number, obviously. maybe worth estimating in an initial pass, even if we overestimate at e.g. 1/4 of str.count

        var curIndex = startIndex
        let containerType: ContainerType = (str[curIndex] == "{") ? .Object : .Array

        while ++curIndex < str.endIndex {
            switch str[curIndex] {
            case "-", "0"..."9":
                do {
                    let (subtoken, endIndex) = try JSONNumber.fromString(str, startIndex: curIndex)
                    tokens.append(subtoken)
                    curIndex = endIndex
                    continue
                } catch { throw error }

            case "t"/*rue*/, "f"/*alse*/:
                do {
                    let (subtoken, endIndex) = try Bool.fromString(str, startIndex: curIndex)
                    tokens.append(subtoken)
                    curIndex = endIndex
                    continue
                } catch { throw error }

            case "n"/*ull*/:
                do {
                    let (subtoken, endIndex) = try JSONNull.fromString(str, startIndex: curIndex)
                    tokens.append(subtoken)
                    curIndex = endIndex
                    continue
                } catch { throw error }

            case "\"", "'":
                do {
                    let (subtoken, endIndex) = try StringToken.fromString(str, startIndex: curIndex)
                    tokens.append(subtoken)
                    curIndex = endIndex
                    continue
                } catch { throw error }

            case "[", "{":
                do {
                    let (subtoken, endIndex) = try JSONContainer.fromString(str, startIndex: curIndex)
                    tokens.append(subtoken)
                    curIndex = endIndex
                    continue
                } catch { throw error }

            case "]" where containerType == .Array:
                return (JSONContainer(type: .Array, tokens: tokens), curIndex)

            case "}" where containerType == .Object:
                if tokens.count % 2 == 0 {
                    return (JSONContainer(type: .Object, tokens: tokens), curIndex)
                }
                // else break the loop, below, which leads to a PartialInputProvided error

            case ":" where containerType == .Object && tokens.count % 2 == 1:
                continue

            case ",", " ", "\n", "\u{000B}", "\u{000C}", "\u{000D}", "\u{0085}":
                continue

            default:
                throw JSONError(reason: .InvalidCharacter, index: curIndex)
            }

            // All valid cases are covered above (with continue statements)
            // So if we get here, break the loop and throw PartialInputProvided, below
            break
        }

        // If we get here and haven't returned our ContainerToken yet:
        throw JSONError(reason: .PartialInputProvided, index: startIndex)
    }
}


extension String: JSON {
    public var description: String {
        return self
    }
}

struct StringToken: JSONSerializer {
    let string: String.UnicodeScalarView
    var description: String { return String(string) }

    static func fromString(str: String.UnicodeScalarView, startIndex: Index) throws -> (JSON, Index) {
        let initialQuoteMark = str[startIndex]
        var curIndex = startIndex

        while ++curIndex < str.endIndex {
            switch str[curIndex] {
            case initialQuoteMark:
                return (String(str[startIndex.successor() ..< curIndex]), curIndex)
            default:
                continue
            }
        }

        // The string literal was never closed with the same token it was opened with
        throw JSONError(reason: .PartialInputProvided, index: startIndex)
    }
}

extension Bool : JSON, JSONSerializer {
    public var description: String {
        return "\(self)"
    }

    static func fromString(str: String.UnicodeScalarView, startIndex: Index) throws -> (JSON, Index) {
        var curIndex = startIndex
        if
            str[startIndex] == "t" &&
            str[++curIndex] == "r" &&
            str[++curIndex] == "u" &&
            str[++curIndex] == "e"
        {
            return (true, curIndex)
        } else if
            str[startIndex] == "f" &&
            str[++curIndex] == "a" &&
            str[++curIndex] == "l" &&
            str[++curIndex] == "s" &&
            str[++curIndex] == "e"
        {
            return (false, curIndex)
        }
        else {
            throw JSONError(reason: .InvalidCharacter, index: curIndex)
        }
    }
}

extension Int: JSON {}
extension Double: JSON {}

struct JSONNull : JSON, JSONSerializer {
    var description: String {
        return "null"
    }

    static func fromString(str: String.UnicodeScalarView, startIndex: Index) throws -> (JSON, Index) {
        var curIndex = startIndex
        if
            str[startIndex] == "n" &&
            str[++curIndex] == "u" &&
            str[++curIndex] == "l" &&
            str[++curIndex] == "l"
        {
            return (JSONNull(), curIndex)
        }
        else {
            throw JSONError(reason: .InvalidCharacter, index: curIndex)
        }
    }
}

struct JSONNumber: JSONSerializer {
    static func fromString(str: String.UnicodeScalarView, startIndex: Index) throws -> (JSON, Index) {
        var curIndex = startIndex
        var foundDecimalPoint = false

        if str[startIndex] == "-" {
            // A minus sign is fine here, but throw an
            // error if one is found in the loop below.
            curIndex++
        }

        while curIndex < str.endIndex {
            switch str[curIndex] {
            case "0"..."9":
                break

            case ",", "}", "]":
                let numAsString = String(str[startIndex..<curIndex])
                let lastNumericalIndex = curIndex.predecessor()

                if foundDecimalPoint {
                    if let doubleVal = Double(numAsString) {
                        return (doubleVal, lastNumericalIndex)
                    }
                } else {
                    if let intVal = Int(numAsString) {
                        return (intVal, lastNumericalIndex)
                    }
                }

                // In the unlikely event we get here, it's because we weren't able to convert
                // the string to an Int or Double (presumably because of an overflow).
                throw JSONError(reason: .InvalidNumberPrimitive, index: startIndex)

            case ".":
                if (foundDecimalPoint) {
                    // More than one decimal point found in this Number
                    throw JSONError(reason: .InvalidNumberPrimitive, index: curIndex)
                } else {
                    foundDecimalPoint = true
                }

            default:
                throw JSONError(reason: .InvalidCharacter, index: curIndex)
            }

            curIndex++

        }

        // if non-strict, just return a NumberToken, else:
        throw JSONError(reason: .RootLevelMustBeAContainer, index: startIndex)
    }
}