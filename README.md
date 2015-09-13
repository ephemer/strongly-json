# StronglyJSON

A pure Swift 2.0 (no Foundation), strongly typed JSON parser.

```
let json: JSON = "[1, 0.5, null]"
json == JSON.JSONArray([.JSONInt(1), .JSONDouble(0.5), .JSONNull])
json == [1, 0.5, nil]

let jsonFromInt: JSON = 4
jsonFromInt == JSON.JSONInt(4)

let jsonFromDict: JSON = ["someNullValue" : nil, "array" : [true, false], "nested" : ["key" : "value"]]
jsonFromDict["array"]?[0] == true
jsonFromDict["nested"]?["key"] == "value"
print(jsonFromDict["someNullValue"]) // prints "null"
```


## Usage:

- Just copy __StronglyJSON.swift__ into your project
- Note: this is Swift 2.0 code. You will need Xcode 7 or above.
- Fork / clone the repo to develop (pull requests welcome!)


## Features:

- Easy to use: make and read from JSON arrays, primitives and dictionaries with natural Swift syntax
- No weird operator overloads
- It's fast! (As far as I can see. I haven't tested against other Swift libraries, but in my early tests it was up to 4x faster than NSJSONSerialization, depending on the data structures). _And if it's not, let's improve it together!_
- There is a basic test suite included, that will be added to as development continues
- Doesn't use NSJSONSerialization or any other other non-standard-library APIs. It'll work cross-platform when Swift gets open-sourced.
- MIT Licence


## Why?

I am writing a pure-Swift version of Cordova-iOS (let's call it Cordova-iOS Version 6.0) with the dream of a Cordova that is fast, fun to develop for (less boilerplate, less weird workarounds, less juggling the type system), and based on new technologies (e.g. WKWebView) in a way that just works.

For that I needed a fast, reliable JSON API with a few ideals:
- It should be test-driven
- It should be written in Swift 2.0
- It should be fast and further optimisable

I wasn't satisfied with the other solutions out there for Swift, so this is my shot at writing my own. Early on I realised NSJSONSerialization does not play nice with Swift's static type system, so I went about tackling the serialization myself, for better or worse:

- We have full control over the code execution path (if it's slow, there's noone else to blame). This also means of course that there is plenty of further potential for optimisation.
- I was able to completely factor out any Apple frameworks, which will be particularly interesting for when Swift goes open source later in 2015.
