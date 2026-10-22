import SwiftUI
import UIKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class LibraryBoundaryTests: XCTestCase {
    @MainActor func testShelfDefersModelCreationUntilMountedAndKeepsItAcrossLayout() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("LibraryBoundary-\(UUID().uuidString)")
        let services = try await AppServices.create(storageRoot: root)
        let created = expectation(description: "SwiftUI installs the shelf model")
        var creations = 0
        func model() -> LibraryViewModel {
            creations += 1; created.fulfill()
            return LibraryViewModel(services: services)
        }
        let shelf = LibraryView(files: services.files, model: model(), readerDestination: { _, _ in AnyView(EmptyView()) })
        XCTAssertEqual(creations, 0, "Constructing a shelf value must preserve StateObject's lazy model initializer")
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previous = scene.windows.first { $0.isKeyWindow }, window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        window.rootViewController = UIHostingController(rootView: shelf.environmentObject(FontDocumentInbox()))
        defer { window.isHidden = true; window.rootViewController = nil; previous?.makeKey() }
        window.makeKeyAndVisible(); window.layoutIfNeeded()
        await fulfillment(of: [created], timeout: 2)
        window.setNeedsLayout(); window.layoutIfNeeded()
        XCTAssertEqual(creations, 1)
    }
}
