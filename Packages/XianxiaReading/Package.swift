// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "XianxiaReading",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "ReadingInterfaces", targets: ["ReadingInterfaces"]),
        .library(name: "ReadiumAdapter", targets: ["ReadiumAdapter"])
    ],
    dependencies: [
        .package(path: "../XianxiaCore"),
        .package(url: "https://github.com/readium/swift-toolkit.git", exact: "3.11.0")
    ],
    targets: [
        .target(name: "ReadingInterfaces", dependencies: [.product(name: "XianxiaCore", package: "XianxiaCore")]),
        .target(name: "ReadiumAdapter", dependencies: [
            "ReadingInterfaces",
            .product(name: "XianxiaCore", package: "XianxiaCore"),
            .product(name: "ReadiumShared", package: "swift-toolkit"),
            .product(name: "ReadiumStreamer", package: "swift-toolkit"),
            .product(name: "ReadiumNavigator", package: "swift-toolkit")
        ])
    ]
)
