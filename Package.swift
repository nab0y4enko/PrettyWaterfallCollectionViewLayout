// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrettyWaterfallCollectionViewLayout",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "PrettyWaterfallCollectionViewLayout",
            targets: [
                "HorizontalWaterfall",
                "VerticalWaterfall"
            ]
        )
    ],
    targets: [
        .target(
            name: "HorizontalWaterfall",
            dependencies: [],
            path: "Sources/HorizontalWaterfall"
        ),
        .target(
            name: "VerticalWaterfall",
            dependencies: [],
            path: "Sources/VerticalWaterfall"
        )
    ]
)
