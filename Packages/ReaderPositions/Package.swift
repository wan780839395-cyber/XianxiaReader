// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ReaderPositions",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "ReaderPositions", targets: ["ReaderPositions"])],
    dependencies: [.package(path: "../XianxiaCore")],
    targets: [
        .target(name: "ReaderPositions", dependencies: [
            .product(name: "XianxiaCore", package: "XianxiaCore")
        ]),
        .testTarget(name: "ReaderPositionsTests", dependencies: [
            "ReaderPositions",
            .product(name: "XianxiaCore", package: "XianxiaCore")
        ])
    ]
)
