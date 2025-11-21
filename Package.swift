// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AssembledChat",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AssembledChat",
            targets: ["AssembledChat"]
        )
    ],
    targets: [
        .target(
            name: "AssembledChat",
            path: "Sources/AssembledChat",
            resources: nil,
            swiftSettings: [
                .define("SPM")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)

