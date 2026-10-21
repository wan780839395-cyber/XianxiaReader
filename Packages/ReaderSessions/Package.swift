// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ReaderSessions",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "ReaderSessions", targets: ["ReaderSessions"])],
    targets: [
        .target(name: "ReaderSessions"),
        .testTarget(name: "ReaderSessionsTests", dependencies: ["ReaderSessions"])
    ]
)
