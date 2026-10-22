// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ReaderSearch",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "ReaderSearch", targets: ["ReaderSearch"])],
    dependencies: [.package(path: "../XianxiaCore")],
    targets: [
        .target(name: "ReaderSearch", dependencies: [.product(name: "XianxiaCore", package: "XianxiaCore")]),
        .testTarget(name: "ReaderSearchTests", dependencies: ["ReaderSearch", .product(name: "XianxiaCore", package: "XianxiaCore")])
    ]
)
