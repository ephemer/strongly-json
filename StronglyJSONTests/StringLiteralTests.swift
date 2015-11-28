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
        let json: JSON = 123
        XCTAssert(json == .JSONValue("123"))
    }
    
    func testMakeJSONDouble() {
        let json: JSON = 123.321
        XCTAssert(json == .JSONValue("123.321"))
    }
    
    func testMakeJSONBool() {
        let json: JSON = true
        XCTAssert(json == .JSONValue("true"))
    }
    
    func testMakeJSONNull() {
        let json: JSON = nil
        XCTAssert(json == .JSONValue("null"))
    }
    
    func testMakeJSONString() {
        let json: JSON = "here's a string, make of it what you will"
        XCTAssert(json == .JSONValue("here's a string, make of it what you will"))
    }
    
    func testMakeJSONArray() {
        let string = "[true, 123, 123.456]"
        let parser = JSONParser(jsonString: string)
        let json = parser.parse()
        
        XCTAssert(json == .JSONArray([true, 123, 123.456]), json.debugDescription)
    }
    
    func testMakeJSONObject() {
        let string = "{'anInteger':123, 'aFloatValue': 123.456}"
        let parser = JSONParser(jsonString: string)
        let json = parser.parse()
        
        let literal: JSON = .JSONObject([
            "anInteger" : 123,
            "aFloatValue" : 123.456
        ])

        XCTAssert(json == literal, json.debugDescription)
    }

    
    // MARK: More complex data structures
    
    func testMakeComplexJSONArray() {
        let string = "{\"widget\":{\"debug\":\"on\",\"window\":{\"title\":\"Sample Konfabulator Widget\",\"name\":\"main's_window\",\"width\":500,\"height\":500},\"image\":{\"src\":\"Images/Sun.png\",\"name\":\"sun1\",\"hOffset\":250,\"vOffset\":250,\"alignment\":\"center\"},\"text\":{\"data\":\"Click Here\",\"size\":36,\"style\":\"bold\",\"name\":\"text1\",\"hOffset\":250,\"vOffset\":100,\"alignment\":\"center\",\"onMouseUp\":\"sun1.opacity = (sun1.opacity / 100) * 90;\"}}}"
        
        let parser = JSONParser(jsonString: string)
        let json = parser.parse()
        
        let staticJson: JSON = [
            "widget": [
                "debug":"on",
                "window": [
                    "title":"Sample Konfabulator Widget",
                    "name":"main's_window",
                    "width":500,
                    "height":500
                ],
                "image": [
                    "src":"Images/Sun.png",
                    "name":"sun1",
                    "hOffset":250,
                    "vOffset":250,
                    "alignment":"center"
                ],
                "text": [
                    "data":"Click Here",
                    "size":36,
                    "style":"bold",
                    "name":"text1",
                    "hOffset":250,
                    "vOffset":100,
                    "alignment":"center",
                    "onMouseUp":"sun1.opacity = (sun1.opacity / 100) * 90;"
                ]
            ]
        ]
        
        XCTAssert(json == staticJson, json.debugDescription)
    }
    
}
