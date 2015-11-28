//
//  PerformanceTests.swift
//  StronglyJSON
//
//  Created by Geordie Jay on 22.11.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

@testable
import StronglyJSON

import XCTest
import Foundation

class PerformanceTests: XCTestCase {

    static let unicodeString = string.unicodeScalars

//    func runJSMNParsing() {
//        let parser = JSMNParser(chars: PerformanceTests.string.unicodeScalars)
//        do { try parser.parse() } catch {
//            print(error)
//        }
//    }
//
//    func testJSMNPerf() {
//        measureRepeatedly(1, block: runJSMNParsing)
//    }


    func runQuickParsing() {
        do {
            let str = PerformanceTests.unicodeString
            try ContainerToken.fromString(str, startIndex: str.startIndex)
        } catch {
            print(error)
        }
    }

    func testQuickPerf() {
        measureRepeatedly(5000, block: runQuickParsing)
    }


    static let string = "[{\"id\":\"0001\",\"type\":\"donut\",\"name\":\"Cake\",\"ppu\":0.55,\"batters\":{\"batter\":[{\"id\":\"1001\",\"type\":\"Regular\"},{\"id\":\"1002\",\"type\":\"Chocolate\"},{\"id\":\"1003\",\"type\":\"Blueberry\"},{\"id\":\"1004\",\"type\":\"Devil's Food\"}]},\"topping\":[{\"id\":\"5001\",\"type\":\"None\"},{\"id\":\"5002\",\"type\":\"Glazed\"},{\"id\":\"5005\",\"type\":\"Sugar\"},{\"id\":\"5007\",\"type\":\"Powdered Sugar\"},{\"id\":\"5006\",\"type\":\"Chocolate with Sprinkles\"},{\"id\":\"5003\",\"type\":\"Chocolate\"},{\"id\":\"5004\",\"type\":\"Maple\"}]},{\"id\":\"0002\",\"type\":\"donut\",\"name\":\"Raised\",\"ppu\":0.55,\"batters\":{\"batter\":[{\"id\":\"1001\",\"type\":\"Regular\"}]},\"topping\":[{\"id\":\"5001\",\"type\":\"None\"},{\"id\":\"5002\",\"type\":\"Glazed\"},{\"id\":\"5005\",\"type\":\"Sugar\"},{\"id\":\"5003\",\"type\":\"Chocolate\"},{\"id\":\"5004\",\"type\":\"Maple\"}]},{\"id\":\"0003\",\"type\":\"donut\",\"name\":\"Old Fashioned\",\"ppu\":0.55,\"batters\":{\"batter\":[{\"id\":\"1001\",\"type\":\"Regular\"},{\"id\":\"1002\",\"type\":\"Chocolate\"}]},\"topping\":[{\"id\":\"5001\",\"type\":\"None\"},{\"id\":\"5002\",\"type\":\"Glazed\"},{\"id\":\"5003\",\"type\":\"Chocolate\"},{\"id\":\"5004\",\"type\":\"Maple\"}]},{\"id\":\"0001\",\"type\":\"donut\",\"name\":\"Cake\",\"ppu\":0.55,\"batters\":{\"batter\":[{\"id\":\"1001\",\"type\":\"Regular\"},{\"id\":\"1002\",\"type\":\"Chocolate\"},{\"id\":\"1003\",\"type\":\"Blueberry\"},{\"id\":\"1004\",\"type\":\"Devil's Food\"}]},\"topping\":[{\"id\":\"5001\",\"type\":\"None\"},{\"id\":\"5002\",\"type\":\"Glazed\"},{\"id\":\"5005\",\"type\":\"Sugar\"},{\"id\":\"5007\",\"type\":\"Powdered Sugar\"},{\"id\":\"5006\",\"type\":\"Chocolate with Sprinkles\"},{\"id\":\"5003\",\"type\":\"Chocolate\"},{\"id\":\"5004\",\"type\":\"Maple\"}]},{\"id\":\"0002\",\"type\":\"donut\",\"name\":\"Raised\",\"ppu\":0.55,\"batters\":{\"batter\":[{\"id\":\"1001\",\"type\":\"Regular\"}]},\"topping\":[{\"id\":\"5001\",\"type\":\"None\"},{\"id\":\"5002\",\"type\":\"Glazed\"},{\"id\":\"5005\",\"type\":\"Sugar\"},{\"id\":\"5003\",\"type\":\"Chocolate\"},{\"id\":\"5004\",\"type\":\"Maple\"}]},{\"id\":\"0003\",\"type\":\"donut\",\"name\":\"Old Fashioned\",\"ppu\":0.55,\"batters\":{\"batter\":[{\"id\":\"1001\",\"type\":\"Regular\"},{\"id\":\"1002\",\"type\":\"Chocolate\"}]},\"topping\":[{\"id\":\"5001\",\"type\":\"None\"},{\"id\":\"5002\",\"type\":\"Glazed\"},{\"id\":\"5003\",\"type\":\"Chocolate\"},{\"id\":\"5004\",\"type\":\"Maple\"}]}]"

    static let stringData = string.dataUsingEncoding(NSUTF8StringEncoding)!

//    func testParserPerformance() {
//        measureRepeatedly(1000) {
//            let parser = JSONParser(jsonString: PerformanceTests.string)
//            let json = parser.parse()
//            let dict = json[0]
//            let id = dict?["id"]?.asString
//            XCTAssert(id == "0001")
//        }
//    }

    func testFoundationPerformance() {
        // This is an example of a performance test case.
        measureRepeatedly(5000) {
            let jsonData = try! NSJSONSerialization.JSONObjectWithData(PerformanceTests.stringData, options: []) as? NSArray
            let dict = jsonData?[0] as? NSDictionary
            let id = dict?["id"] as? String
            XCTAssert(id == "0001")
        }
    }

    func measureRepeatedly(repetitions: Int, block: () -> Void) {
        measureBlock {
            var i = repetitions
            while --i >= 0 { block() }
        }
    }
    
}
