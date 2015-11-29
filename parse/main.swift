//
//  main.swift
//  parse
//
//  Created by Geordie Jay on 28.11.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

import Foundation

let originalString = "[{\"id\":\"0001\",\"type\":\"donut\",\"name\":\"Cake\",\"ppu\":0.55,\"batters\":{\"batter\":[{\"id\":\"1001\",\"type\":\"Regular\"},{\"id\":\"1002\",\"type\":\"Chocolate\"},{\"id\":\"1003\",\"type\":\"Blueberry\"},{\"id\":\"1004\",\"type\":\"Devil's Food\"}]},\"topping\":[{\"id\":\"5001\",\"type\":\"None\"},{\"id\":\"5002\",\"type\":\"Glazed\"},{\"id\":\"5005\",\"type\":\"Sugar\"},{\"id\":\"5007\",\"type\":\"Powdered Sugar\"},{\"id\":\"5006\",\"type\":\"Chocolate with Sprinkles\"},{\"id\":\"5003\",\"type\":\"Chocolate\"},{\"id\":\"5004\",\"type\":\"Maple\"}]},{\"id\":\"0002\",\"type\":\"donut\",\"name\":\"Raised\",\"ppu\":0.55,\"batters\":{\"batter\":[{\"id\":\"1001\",\"type\":\"Regular\"}]},\"topping\":[{\"id\":\"5001\",\"type\":\"None\"},{\"id\":\"5002\",\"type\":\"Glazed\"},{\"id\":\"5005\",\"type\":\"Sugar\"},{\"id\":\"5003\",\"type\":\"Chocolate\"},{\"id\":\"5004\",\"type\":\"Maple\"}]},{\"id\":\"0003\",\"type\":\"donut\",\"name\":\"Old Fashioned\",\"ppu\":0.55,\"batters\":{\"batter\":[{\"id\":\"1001\",\"type\":\"Regular\"},{\"id\":\"1002\",\"type\":\"Chocolate\"}]},\"topping\":[{\"id\":\"5001\",\"type\":\"None\"},{\"id\":\"5002\",\"type\":\"Glazed\"},{\"id\":\"5003\",\"type\":\"Chocolate\"},{\"id\":\"5004\",\"type\":\"Maple\"}]}]"

let string = originalString.unicodeScalars
let stringData = originalString.dataUsingEncoding(NSUTF8StringEncoding)!


for i in 0...50000 {
    let container = try! JSONContainer.fromString(string, startIndex: string.startIndex)
}

for i in 0...50000 {
    let container = try! NSJSONSerialization.JSONObjectWithData(stringData, options: [])
}

print(try! NSJSONSerialization.JSONObjectWithData(stringData, options: []))
print(try! JSONContainer.fromString(string, startIndex: string.startIndex).0)
