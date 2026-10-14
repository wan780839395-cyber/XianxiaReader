// swift-tools-version:5.10
//
//  Copyright 2026 Readium Foundation. All rights reserved.
//  Use of this source code is governed by the BSD-style license
//  available in the top-level LICENSE file of the project.
//

import PackageDescription

let package = Package(
    name: "Readium",
    defaultLocalization: "en",
    platforms: [.iOS("15.0")],
    products: [
        .library(name: "ReadiumShared", targets: ["ReadiumShared"]),
        .library(name: "ReadiumStreamer", targets: ["ReadiumStreamer"]),
        .library(name: "ReadiumNavigator", targets: ["ReadiumNavigator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.10.0"),
        .package(url: "https://github.com/marmelroy/Zip.git", from: "2.1.2"),
        .package(url: "https://github.com/ra1028/DifferenceKit.git", from: "1.3.0"),
        .package(url: "https://github.com/readium/Fuzi.git", from: "4.0.0"),
        .package(url: "https://github.com/readium/GCDWebServer.git", from: "4.0.0"),
        .package(url: "https://github.com/readium/ZIPFoundation.git", from: "3.0.1"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.13.5"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.16.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.5.0"),
    ],
    targets: [
        .target(name: "ReadiumInternal", path: "Sources/Internal"),
        .target(name: "ReadiumShared", dependencies: ["ReadiumInternal", "SwiftSoup", "Zip", .product(name: "ReadiumFuzi", package: "Fuzi"), .product(name: "ReadiumZIPFoundation", package: "ZIPFoundation")], path: "Sources/Shared", resources: [.process("Resources")], linkerSettings: [.linkedFramework("CoreServices"), .linkedFramework("UIKit")]),
        .target(name: "ReadiumStreamer", dependencies: ["CryptoSwift", "ReadiumShared", .product(name: "ReadiumFuzi", package: "Fuzi")], path: "Sources/Streamer", resources: [.copy("Assets")]),
        .target(name: "ReadiumNavigator", dependencies: ["ReadiumInternal", "ReadiumShared", "DifferenceKit", "SwiftSoup"], path: "Sources/Navigator", resources: [.copy("EPUB/Assets"), .process("Resources")])
    ]
)
