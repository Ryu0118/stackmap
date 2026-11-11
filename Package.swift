// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "stackmap",
    platforms: [
        .macOS(.v26),
    ],
    products: [
        .executable(name: "stackmap", targets: ["stackmap"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.2"),
        .package(url: "https://github.com/jpsim/Yams", from: "6.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "stackmap",
            dependencies: ["StackmapCLI"]
        ),
        .target(
            name: "StackmapCLI",
            dependencies: [
                "StackmapKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "StackmapKit",
            dependencies: [
                .product(name: "Yams", package: "Yams"),
            ]
        ),
        .testTarget(
            name: "StackmapKitTests",
            dependencies: ["StackmapKit"]
        ),
        .testTarget(
            name: "StackmapCLITests",
            dependencies: ["StackmapCLI", "StackmapKit"]
        ),
    ]
)
