// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "XianxiaReading",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "ReadingInterfaces", targets: ["ReadingInterfaces"]),
        .library(name: "ReadiumAdapter", targets: ["ReadiumAdapter"]),
        .library(name: "ReaderFonts", targets: ["ReaderFonts"])
    ],
    dependencies: [
        .package(path: "../XianxiaCore"),
        .package(path: "../BookImports"),
        .package(path: "../ReaderSearch"),
        .package(path: "../../Vendor/ReadiumToolkit")
    ],
    targets: [
        .target(name: "ReadingInterfaces", dependencies: [.product(name: "XianxiaCore", package: "XianxiaCore"), .product(name: "BookImports", package: "BookImports"), .product(name: "ReaderSearch", package: "ReaderSearch")]),
        .target(name: "ReaderFonts", dependencies: [
            "ReadingInterfaces",
            .product(name: "XianxiaCore", package: "XianxiaCore")
        ]),
        .target(name: "ReadiumAdapter", dependencies: [
            "ReadingInterfaces",
            .product(name: "XianxiaCore", package: "XianxiaCore"),
            .product(name: "ReadiumShared", package: "ReadiumToolkit"),
            .product(name: "ReadiumStreamer", package: "ReadiumToolkit"),
            .product(name: "ReadiumNavigator", package: "ReadiumToolkit")
        ])
    ]
)
