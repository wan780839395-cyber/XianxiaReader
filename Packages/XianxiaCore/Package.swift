// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "XianxiaCore",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "XianxiaCore", targets: ["XianxiaCore"])],
    targets: [
        // Apple builds must use the selected SDK's SQLite, not host Homebrew paths.
        // Linux installs the standard system headers/library with the apt provider.
        .systemLibrary(name: "CSQLite", providers: [.apt(["libsqlite3-dev"])]),
        .target(name: "XianxiaCore", dependencies: ["CSQLite"], resources: [.process("Database/Migrations")]),
        .testTarget(name: "XianxiaCoreTests", dependencies: ["XianxiaCore", "CSQLite"])
    ]
)
