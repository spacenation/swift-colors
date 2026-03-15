// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Colors",
    products: [
        .library(name: "Colors", targets: ["Colors"]),
    ],
    targets: [
        .target(
            name: "Colors",
            dependencies: [],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "ColorsTests", dependencies: ["Colors"]),
    ]
)
