//
//  ComprehensiveJSONReadTests.swift
//  StronglyJSON
//
//  Created by Geordie Jay on 27.09.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

import XCTest
@testable import StronglyJSON

class ComprehensiveJSONReadTests: XCTestCase {
    // https://adobe.github.io/Spry/samples/data_region/JSONDataSetSample.html
    func testSampleJSONFromAdobe() {
        let string = "[{\"id\":\"0001\",\"type\":\"donut\",\"name\":\"Cake\",\"ppu\":0.55,\"batters\":{\"batter\":[{\"id\":\"1001\",\"type\":\"Regular\"},{\"id\":\"1002\",\"type\":\"Chocolate\"},{\"id\":\"1003\",\"type\":\"Blueberry\"},{\"id\":\"1004\",\"type\":\"Devil's Food\"}]},\"topping\":[{\"id\":\"5001\",\"type\":\"None\"},{\"id\":\"5002\",\"type\":\"Glazed\"},{\"id\":\"5005\",\"type\":\"Sugar\"},{\"id\":\"5007\",\"type\":\"Powdered Sugar\"},{\"id\":\"5006\",\"type\":\"Chocolate with Sprinkles\"},{\"id\":\"5003\",\"type\":\"Chocolate\"},{\"id\":\"5004\",\"type\":\"Maple\"}]},{\"id\":\"0002\",\"type\":\"donut\",\"name\":\"Raised\",\"ppu\":0.55,\"batters\":{\"batter\":[{\"id\":\"1001\",\"type\":\"Regular\"}]},\"topping\":[{\"id\":\"5001\",\"type\":\"None\"},{\"id\":\"5002\",\"type\":\"Glazed\"},{\"id\":\"5005\",\"type\":\"Sugar\"},{\"id\":\"5003\",\"type\":\"Chocolate\"},{\"id\":\"5004\",\"type\":\"Maple\"}]},{\"id\":\"0003\",\"type\":\"donut\",\"name\":\"Old Fashioned\",\"ppu\":0.55,\"batters\":{\"batter\":[{\"id\":\"1001\",\"type\":\"Regular\"},{\"id\":\"1002\",\"type\":\"Chocolate\"}]},\"topping\":[{\"id\":\"5001\",\"type\":\"None\"},{\"id\":\"5002\",\"type\":\"Glazed\"},{\"id\":\"5003\",\"type\":\"Chocolate\"},{\"id\":\"5004\",\"type\":\"Maple\"}]}]"
        let parser = JSONParser(jsonString: string)
        let json = parser.parse()
        
        let literal: JSON = [
            [
                "id": "0001",
                "type": "donut",
                "name": "Cake",
                "ppu": 0.55,
                "batters": [
                    "batter": [
                        [ "id": "1001", "type": "Regular" ],
                        [ "id": "1002", "type": "Chocolate" ],
                        [ "id": "1003", "type": "Blueberry" ],
                        [ "id": "1004", "type": "Devil's Food" ]
                    ]
                ],
                "topping": [
                    [ "id": "5001", "type": "None" ],
                    [ "id": "5002", "type": "Glazed" ],
                    [ "id": "5005", "type": "Sugar" ],
                    [ "id": "5007", "type": "Powdered Sugar" ],
                    [ "id": "5006", "type": "Chocolate with Sprinkles" ],
                    [ "id": "5003", "type": "Chocolate" ],
                    [ "id": "5004", "type": "Maple" ]
                ]
            ],
            [
                "id": "0002",
                "type": "donut",
                "name": "Raised",
                "ppu": 0.55,
                "batters": [
                    "batter": [
                        [ "id": "1001", "type": "Regular" ]
                    ]
                ],
                "topping": [
                    [ "id": "5001", "type": "None" ],
                    [ "id": "5002", "type": "Glazed" ],
                    [ "id": "5005", "type": "Sugar" ],
                    [ "id": "5003", "type": "Chocolate" ],
                    [ "id": "5004", "type": "Maple" ]
                ]
            ],
            [
                "id": "0003",
                "type": "donut",
                "name": "Old Fashioned",
                "ppu": 0.55,
                "batters": [
                    "batter": [
                        [ "id": "1001", "type": "Regular" ],
                        [ "id": "1002", "type": "Chocolate" ]
                    ]
                ],
                "topping": [
                    [ "id": "5001", "type": "None" ],
                    [ "id": "5002", "type": "Glazed" ],
                    [ "id": "5003", "type": "Chocolate" ],
                    [ "id": "5004", "type": "Maple" ]
                ]
            ]
        ]
        
        XCTAssert(json == literal)
    }

}
