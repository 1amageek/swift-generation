# swift-generation

Structured output generation for Swift. Define types that language models can generate with compile-time schema validation.

## Overview

`swift-generation` provides the core protocols, types, and macros for structured generation from language models. Use `@Generable` to make your Swift types generatable with schema constraints enforced at compile time.

```swift
import SwiftGeneration

@Generable(description: "A movie review")
struct MovieReview {
    @Guide(description: "Movie title")
    var title: String

    @Guide(description: "Rating", .range(1...5))
    var rating: Int

    @Guide(description: "Brief summary")
    var summary: String
}
```

The `@Generable` macro automatically conforms your type to the `Generable` protocol, generating:

- `GenerationSchema` for constrained sampling
- `init(_ content: GeneratedContent)` for parsing model output
- `var generatedContent: GeneratedContent` for serialization
- `PartiallyGenerated` type for streaming support

## Requirements

- Swift 6.2+
- macOS 15+ / iOS 18+ / macCatalyst 18+ / visionOS 2+

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/1amageek/swift-generation.git", from: "0.5.0")
]
```

Then add the targets to your module:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "SwiftGeneration", package: "swift-generation"),
    ]
)
```

## Core Types

### `Generable` Protocol

```swift
protocol Generable: ConvertibleFromGeneratedContent, ConvertibleToGeneratedContent {
    associatedtype PartiallyGenerated: ConvertibleFromGeneratedContent = Self
    static var generationSchema: GenerationSchema { get }
}
```

### `GeneratedContent`

A JSON-like value type representing model output:

```swift
enum Kind {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([GeneratedContent])
    case structure(properties: [String: GeneratedContent], orderedKeys: [String])
}
```

### `GenerationSchema`

Defines the structure and constraints for generation. Supports objects, arrays, enums, and dictionary types.

### `@Guide` Constraints

```swift
@Guide(description: "Age", .range(0...120))
var age: Int

@Guide(description: "Tags", .minimumCount(1), .maximumCount(5))
var tags: [String]

@Guide(description: "Status", .anyOf(["active", "inactive"]))
var status: String
```

## Built-in Conformances

`String`, `Bool`, `Int`, `Float`, `Double`, `Decimal`, `UUID`, `Date`, `URL`, `Array`, `Optional`, and `Dictionary` conform to `Generable` out of the box.

## License

MIT
