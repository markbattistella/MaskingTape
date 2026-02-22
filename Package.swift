// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MaskingTape",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "MaskingTape",
            targets: ["MaskingTape"]
        )
    ],
    targets: [
        .target(
            name: "MaskingTape",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "MaskingTapeTests",
            dependencies: ["MaskingTape"],
            path: "Tests/MaskingTapeTests",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
