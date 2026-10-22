// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "BookImports",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "BookImports", targets: ["BookImports"])],
    dependencies: [.package(path: "../XianxiaCore")],
    targets: [
        .target(name: "BookImports", dependencies: [.product(name: "XianxiaCore", package: "XianxiaCore")]),
        .testTarget(name: "BookImportsTests", dependencies: ["BookImports", .product(name: "XianxiaCore", package: "XianxiaCore")])
    ]
)
