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
            name: "Generation",
            targets: ["Generation"]),
        .library(
            name: "GenerationMacros",
            targets: ["GenerationMacros"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
    ],
    targets: [
        .target(
            name: "Generation",
            dependencies: []
        ),

        .macro(
            name: "GenerationMacrosImpl",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        .target(
            name: "GenerationMacros",
            dependencies: [
                "GenerationMacrosImpl",
                "Generation"
            ]
        ),

        .testTarget(
            name: "GenerationTests",
            dependencies: ["Generation", "GenerationMacros"]
        ),
    ]
)
