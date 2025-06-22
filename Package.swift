// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TLog",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "TLog",
            targets: ["TLog"]),
    ],
    targets: [
        .target(
            name: "TLog",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableExperimentalFeature("StrictConcurrency"),
                .define("TLOG_ENABLE_LOGGING", .when(configuration: .debug))
            ]
        ),
        .testTarget(
            name: "TLogTests",
            dependencies: ["TLog"]),
    ]
)
