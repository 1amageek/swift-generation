// swift-tools-version: 6.2

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "swift-generation",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .macCatalyst(.v18),
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "SwiftGeneration",
            targets: ["SwiftGeneration"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftGeneration",
            dependencies: [
                "GenerationMacrosImpl",
            ]
        ),

        .macro(
            name: "GenerationMacrosImpl",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        .testTarget(
            name: "SwiftGenerationTests",
            dependencies: ["SwiftGeneration"]
        ),
    ]
)
