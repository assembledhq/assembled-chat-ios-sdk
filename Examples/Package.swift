// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AssembledChatExample",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AssembledChatExample",
            targets: ["AssembledChatExample"]),
    ],
    dependencies: [
        // Reference to the parent AssembledChat SDK
        .package(name: "AssembledChat", path: "../")
    ],
    targets: [
        .target(
            name: "AssembledChatExample",
            dependencies: ["AssembledChat"],
            path: "AssembledChatExample"
        )
    ]
)

