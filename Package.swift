// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "AutoComplete",
    platforms: [
        .macOS(.v10_14), .iOS(.v13), .tvOS(.v13), .watchOS(.v7)
    ],
    products: [
        .library(
            name: "AutoComplete",
            targets: ["AutoComplete"]
        ),
    ],
    targets: [
        .target(
            name: "AutoComplete",
            dependencies: []
        ),
        .testTarget(
            name: "AutoCompleteTests",
            dependencies: ["AutoComplete"]
        ),
    ]
)
