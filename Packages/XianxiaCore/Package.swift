// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "XianxiaCore",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "XianxiaCore", targets: ["XianxiaCore"]),
        .library(name: "ReaderPositions", targets: ["ReaderPositions"]),
        .executable(name: "TXTPerformanceProbe", targets: ["TXTPerformanceProbe"])
    ],
    targets: [
        // Apple builds must use the selected SDK's SQLite, not host Homebrew paths.
        // Linux installs the standard system headers/library with the apt provider.
        .systemLibrary(name: "CSQLite", providers: [.apt(["libsqlite3-dev"])]),
        // Public SDK CoreFoundation on Apple; glibc iconv on Linux. No host Homebrew paths.
        .target(name: "CTextCodec", publicHeadersPath: "include",
                linkerSettings: [.linkedFramework("CoreFoundation", .when(platforms: [.iOS, .macOS]))]),
        .target(name: "XianxiaCore", dependencies: ["CSQLite", "CTextCodec"], resources: [.process("Database/Migrations")]),
        .target(name: "ReaderPositions", dependencies: ["XianxiaCore"]),
        .testTarget(name: "ReaderPositionsTests", dependencies: ["ReaderPositions", "XianxiaCore"]),
        // Desktop CI tool only; the iOS app still links only the Core library product.
        .executableTarget(name: "TXTPerformanceProbe", dependencies: ["XianxiaCore"], path: "Benchmarks/TXTPerformanceProbe"),
        .testTarget(name: "XianxiaCoreTests", dependencies: ["XianxiaCore", "CSQLite"])
    ]
)
