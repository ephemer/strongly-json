//
//  QuickJSON.swift
//  StronglyJSON
//
//  Created by Geordie Jay on 26.11.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

//: Playground - noun: a place where people can play

public typealias Index = String.UnicodeScalarIndex

public protocol JSON: CustomStringConvertible {
    var description: String {get}
    static func fromString(str: String.UnicodeScalarView, startIndex: Index) throws -> (JSON, Index)
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
    }
}

public struct ContainerToken: JSON {
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

    public static func fromString(str: String.UnicodeScalarView, startIndex: Index) throws -> (JSON, Index) {
        var tokens: [JSON] = []
        var curIndex = startIndex
        let containerType: ContainerType = (str[curIndex] == "{") ? .Object : .Array

        while ++curIndex < str.endIndex {
            switch str[curIndex] {
            case "-", "0"..."9", "t"/*rue*/, "f"/*alse*/, "n"/*ull*/:
                do {
                    let (subtoken, endIndex) = try PrimitiveToken.fromString(str, startIndex: curIndex)
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
                    let (subtoken, endIndex) = try ContainerToken.fromString(str, startIndex: curIndex)
                    tokens.append(subtoken)
                    curIndex = endIndex
                    continue
                } catch { throw error }

            case "]" where containerType == .Array:
                return (ContainerToken(type: containerType, tokens: tokens), curIndex)

            case "}" where containerType == .Object:
                if tokens.count % 2 == 0 {
                    return (ContainerToken(type: containerType, tokens: tokens), curIndex)
                }
                // else break the loop, below, which leads to a PartialInputProvided error

            case ":" where containerType == .Object && tokens.count % 2 == 1:
                continue

            case ",", " ", "\n", "\u{000A}", "\u{000B}", "\u{000C}", "\u{000D}", "\u{0085}":
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

struct StringToken: JSON {
    let string: String.UnicodeScalarView
    var description: String { return String(string) }

    static func fromString(str: String.UnicodeScalarView, startIndex: Index) throws -> (JSON, Index) {
        let initialQuoteMark = str[startIndex]
        var curIndex = startIndex

        while ++curIndex < str.endIndex {
            switch str[curIndex] {
            case initialQuoteMark:
                return (StringToken(string: str[startIndex.successor() ..< curIndex]), curIndex)
            default:
                continue
            }
        }

        // The string literal was never closed with the same token it was opened with
        throw JSONError(reason: .PartialInputProvided, index: startIndex)
    }
}

struct PrimitiveToken: JSON {
    private enum PrimitiveType {
        case Boolean, Null, Integer, Double
    }

    let intValue: Int
    let doubleValue: Double
    let isNull: Bool
    let boolValue: Bool

    var description: String {
        // XXX: fix me
        return doubleValue.description
    }

    static func fromString(str: String.UnicodeScalarView, startIndex: Index) throws -> (JSON, Index) {
        var curIndex = startIndex

        // test for bool / null
        if
            str[startIndex] == "t" &&
            str[++curIndex] == "r" &&
            str[++curIndex] == "u" &&
            str[++curIndex] == "e"
        {
            return (PrimitiveToken(intValue: 1, doubleValue: 1, isNull: false, boolValue: true), curIndex)
        } else if
            str[startIndex] == "f" &&
            str[++curIndex] == "a" &&
            str[++curIndex] == "l" &&
            str[++curIndex] == "s" &&
            str[++curIndex] == "e"
        {
            return (PrimitiveToken(intValue: 0, doubleValue: 0, isNull: false, boolValue: false), curIndex)
        } else if
            str[startIndex] == "n" &&
            str[++curIndex] == "u" &&
            str[++curIndex] == "l" &&
            str[++curIndex] == "l"
        {
            return (PrimitiveToken(intValue: 0, doubleValue: 0, isNull: true, boolValue: false), curIndex)
        }

        // test for number

        var numberContainsDecimalPoint = false

        while ++curIndex < str.endIndex {
            switch str[curIndex] {
            case "-":
                if (curIndex != startIndex) {
                    throw JSONError(reason: .InvalidCharacter, index: curIndex)
                }

            case ".":
                if (numberContainsDecimalPoint) {
                    throw JSONError(reason: .InvalidCharacter, index: curIndex)
                } else {
                    numberContainsDecimalPoint = true
                }

            case "0"..."9":
                continue

            case ",", "}", "]":
//                let substr = String(str[startIndex ..< curIndex])
                // XXX: boolValue here isn't strictly correct
                return (PrimitiveToken(intValue: 0, doubleValue: 0, isNull: false, boolValue: true), curIndex.predecessor())

            default:
                throw JSONError(reason: .InvalidCharacter, index: curIndex)
            }
        }

        // if non-strict, just return a NumberToken, else:
        throw JSONError(reason: .RootLevelMustBeAContainer, index: startIndex)
    }
}