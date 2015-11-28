//
//  main.swift
//  parse
//
//  Created by Geordie Jay on 28.11.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

import Foundation

let originalString = "{\"widget\":{\"debug\":\"on\",\"window\":{\"title\":\"Sample Konfabulator Widget\",\"name\":\"main's_window\",\"width\":500,\"height\":500},\"image\":{\"src\":\"Images/Sun.png\",\"name\":\"sun1\",\"hOffset\":250,\"vOffset\":250,\"alignment\":\"center\"},\"text\":{\"data\":\"Click Here\",\"size\":36,\"style\":\"bold\",\"name\":\"text1\",\"hOffset\":250,\"vOffset\":100,\"alignment\":\"center\",\"onMouseUp\":\"sun1.opacity = (sun1.opacity / 100) * 90;\"}}}"
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
