// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CombineExtensions",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(name: "CombineExtensions", targets: ["CombineExtensions"]),
    ],
    dependencies: [
        .package(name: "Entwine", url: "https://github.com/tcldr/Entwine.git", from: "0.9.0"),
    ],
    targets: [
        .target(name: "CombineExtensions", dependencies: []),
        .testTarget(name: "CombineExtensionsTests",
                    dependencies: [
                        "CombineExtensions",
                        .product(name: "EntwineTest", package: "Entwine")
                    ]),
    ]
)
