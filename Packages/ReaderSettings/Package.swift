// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ReaderSettings",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "ReaderSettings", targets: ["ReaderSettings"])],
    dependencies: [.package(path: "../XianxiaCore")],
    targets: [
        .target(name: "ReaderSettings", dependencies: [
            .product(name: "XianxiaCore", package: "XianxiaCore")
        ]),
        .testTarget(name: "ReaderSettingsTests", dependencies: [
            "ReaderSettings",
            .product(name: "XianxiaCore", package: "XianxiaCore")
        ])
    ]
)
