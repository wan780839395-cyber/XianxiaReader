// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "XianxiaCore",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "XianxiaCore", targets: ["XianxiaCore"])],
    targets: [
        .systemLibrary(name: "CSQLite", pkgConfig: "sqlite3", providers: [.apt(["libsqlite3-dev"]), .brew(["sqlite3"])]),
        .target(name: "XianxiaCore", dependencies: ["CSQLite"], resources: [.process("Database/Migrations")]),
        .testTarget(name: "XianxiaCoreTests", dependencies: ["XianxiaCore", "CSQLite"])
    ]
)
