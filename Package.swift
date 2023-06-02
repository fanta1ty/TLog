// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TLog",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "TLog",
            targets: ["TLog"]),
    ],
    targets: [
        .target(
            name: "TLog"),
        .testTarget(
            name: "TLogTests",
            dependencies: ["TLog"]),
    ]
)
