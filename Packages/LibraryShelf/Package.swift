// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "LibraryShelf",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "LibraryShelf", targets: ["LibraryShelf"])],
    dependencies: [.package(path: "../XianxiaCore")],
    targets: [
        .target(name: "LibraryShelf", dependencies: [.product(name: "XianxiaCore", package: "XianxiaCore")]),
        .testTarget(name: "LibraryShelfTests", dependencies: ["LibraryShelf", .product(name: "XianxiaCore", package: "XianxiaCore")])
    ]
)
