//
//  StringLiteralTests.swift
//  StronglyJSON
//
//  Created by Geordie Jay on 13.09.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//


import XCTest
@testable import StronglyJSON

class StringLiteralTests: XCTestCase {
    
    // MARK: Simple data structures
    
    func testMakeJSONInt() {
        let json: JSON = "123"
        XCTAssert(json == .JSONInt(123))
    }
    
    func testMakeJSONDouble() {
        let json: JSON = "123.321"
        XCTAssert(json == .JSONDouble(123.321))
    }
    
    func testMakeJSONBool() {
        let json: JSON = "true"
        XCTAssert(json == .JSONBool(true))
    }
    
    func testMakeJSONNull() {
        let json: JSON = "null"
        XCTAssert(json == .JSONNull)
    }
    
    func testMakeJSONString() {
        let json: JSON = "here's a string, make of it what you will"
        XCTAssert(json == .JSONString("here's a string, make of it what you will"))
    }
    
    func testMakeJSONArray() {
        let json: JSON = "[true, 123, 123.456]"
        XCTAssert(json == .JSONArray([true, 123, 123.456]))
    }
    
    func testMakeJSONObject() {
        let json: JSON = "{anInteger:123, aFloatValue: 123.456}"
        XCTAssert(json == .JSONObject([
            "anInteger" : 123,
            "aFloatValue" : 123.456
            ]))
    }

    
    // MARK: More complex data structures
    
    func testMakeComplexJSONArray() {
        let json: JSON = "[[1,2,3],true,  0.123, {test: true, int: 1}  ] "
        let staticJson: JSON = [
            [1,2,3],
            true,
            0.123,
            [
                "test": true,
                "int": 1
            ]
        ]

        XCTAssert(json == staticJson)
    }
    
}
