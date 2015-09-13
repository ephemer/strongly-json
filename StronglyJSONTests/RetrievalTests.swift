//
//  RetrievalTests.swift
//  StronglyJSON
//
//  Created by Geordie Jay on 13.09.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

import XCTest
@testable import StronglyJSON

class RetrievalTests: XCTestCase {
    
    // MARK: Simple tests
    
    let simpleJSONArray: JSON = [.JSONInt(123), .JSONBool(true), .JSONString("a string ")]
    let simpleJSONDict: JSON = ["test1": .JSONBool(false), "test2": .JSONDouble(999.999), "test3": .JSONNull]
    
    func testSimpleArrayRetrieval() {
        XCTAssert(simpleJSONArray[0] == .JSONInt(123))
        XCTAssert(simpleJSONArray[1] == .JSONBool(true))
        XCTAssert(simpleJSONArray[2] == .JSONString("a string "))
    }
    
    func testSimpleArrayRetrievalWithExplicitTypes() {
        XCTAssert(simpleJSONArray[0]?.asInt == 123)
        XCTAssert(simpleJSONArray[1]?.asBool == true)
        XCTAssert(simpleJSONArray[2]?.asString == "a string ")
    }
    
    func testSimpleDictionaryRetrieval() {
        XCTAssert(simpleJSONDict["test1"] == false)
        XCTAssert(simpleJSONDict["test2"] == 999.999)
        XCTAssert(simpleJSONDict["test3"]?.isNull == true)
    }
    
    
    // MARK: With more complex data structures
    
    let complexJSONArray: JSON = [-1, nil, ["int" : 123, "double" : -123.456, "array" : [1]], [true, false, true]]
    let complexJSONDict: JSON = ["iHave": ["an", "array", "inside"], "andMe": ["a":"dictionary", "it's": [true, ["not": false]]]]
    
    
    func testComplexArrayRetrieval() {
        XCTAssert(complexJSONArray[0] == -1)
        XCTAssert(complexJSONArray[1] == .JSONNull)
        XCTAssert(complexJSONArray[2]?["array"] == [1])
        XCTAssert(complexJSONArray[3]?[1] == .JSONBool(false))
    }
    
    func testComplexArrayRetrievalWithExplicitTypes() {
        XCTAssert(complexJSONArray[0]?.asInt == -1)
        XCTAssert(complexJSONArray[1]?.isNull == true)
        XCTAssert(complexJSONArray[2]?["double"]?.asInt == nil)
        XCTAssert(complexJSONArray[3]?[2]?.asString == "true")
    }
    
    func testComplexDictionaryRetrieval() {
        XCTAssert(complexJSONDict["iHave"]?[2] == "inside")
        XCTAssert(complexJSONDict["andMe"]?["a"] == "dictionary")
        XCTAssert(complexJSONDict["andMe"]?["it's"]?[1]?["not"] == false)
    }

    
}
