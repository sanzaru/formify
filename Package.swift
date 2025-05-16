// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Formify",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)],
    products: [
        .library(
            name: "Formify",
            targets: ["Formify"]),
    ],
    targets: [
        .target(
            name: "Formify"
        ),
        .testTarget(
            name: "FormifyTests",
            dependencies: ["Formify"]
        ),
    ]
)
