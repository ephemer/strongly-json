# StronglyJSON

A pure Swift 2.0 (no Foundation), strongly typed JSON parser.

```
let arrayStr = "[1, 0.5, null]".unicodeScalars
let json: JSON = JSONContainer.fromString(arrayStr, arrayStr.startIndex)
json == [1, 0.5, nil] // this may not work right now with the new QuickJSON implementation, but it is planned


// More examples to come, this is just a branch to show the comparitive speeds of the new QuickJSON implementation compared to NSJSONSerialization
```


## Usage:

xxx: todo


## Features:

- Easy to use: make and read from JSON arrays, primitives and dictionaries with natural Swift syntax
- No weird operator overloads
- There is a basic test suite included that will be added to as development continues
- Doesn't use NSJSONSerialization or any other other non-standard-library APIs. It'll work cross-platform when Swift gets open-sourced.
- Relative speed is difficult to measure at this point: the current code produces a fully structured, statically typed dataset from the get-go. NSJSONSerialization and other solutions need further checks and logic to piece apart what's inside. I'm working on measuring this in a meaningful way.
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
