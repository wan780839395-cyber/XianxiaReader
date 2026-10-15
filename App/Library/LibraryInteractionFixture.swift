#if DEBUG
import SwiftUI
import UIKit
import XianxiaCore

private enum LibraryFixtureError: Error { case preferencesUnavailable }

/// UI automation only: isolated storage/defaults, normal import and repository APIs.
/// No fixture root, launch flag or seeded book is included in the Release build.
@MainActor struct LibraryInteractionFixture {
    let services: AppServices
    let model: LibraryViewModel
    let reduceMotion: Bool

    static func prepareIfRequested() async throws -> Self? {
        let environment = ProcessInfo.processInfo.environment
        guard let value = environment["XR_LIBRARY_UI_TEST_ID"], let id = UUID(uuidString: value) else { return nil }
        let support = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let root = support.appendingPathComponent("LibraryInteractionUITests/\(id.uuidString)")
        let services = try await AppServices.create(storageRoot: root)
        guard let defaults = UserDefaults(suiteName: "LibraryInteractionUITests.\(id.uuidString)") else {
            throw LibraryFixtureError.preferencesUnavailable
        }
        let known = try await services.repository.allBookIDs()
        if known.isEmpty {
            guard let sample = Bundle.main.url(forResource: "云海问道-UTF8", withExtension: "txt", subdirectory: "Fixtures") else {
                throw ImportError.missingSample
            }
            let importer = TXTBookImportService(files: services.files, repository: services.repository)
            for (index, title) in ["云海问道", "山门旧事", "剑过青山"].enumerated() {
                let book = try await importer.importBook(from: sample)
                _ = try await services.repository.renameBook(book.id, title: title)
                if index == 0 {
                    // Diagnostic fixture progress only; UI gestures never open this fake locator.
                    try await services.repository.save(ReadingPosition(bookID: book.id, engineID: "ui-test.fixture", locatorData: Data([4,2]), progression: 0.42))
                    if environment["XR_LIBRARY_UI_COVER"] == "1" {
                        guard let image = Bundle.main.url(forResource: "cover-original", withExtension: "png", subdirectory: "Fixtures") else {
                            throw ImportError.missingSample
                        }
                        let coverService = CoverImportService(files: services.files, repository: services.repository)
                        let draft = try await coverService.prepare(from: image, bookID: book.id)
                        _ = try await coverService.save(draft)
                    }
                }
            }
            defaults.set(environment["XR_LIBRARY_UI_LAYOUT"] == "list" ? "list" : "grid", forKey: "library.layout.v1")
            defaults.set("recent", forKey: "library.sort.v1")
        }
        let model = LibraryViewModel(services: services, defaults: defaults)
        return Self(services: services, model: model,
                    reduceMotion: UIAccessibility.isReduceMotionEnabled || environment["XR_LIBRARY_UI_REDUCE_MOTION"] == "1")
    }
}
#else
import SwiftUI

/// Release has no environment-controlled fixture setup.
@MainActor struct LibraryInteractionFixture {
    let services: AppServices
    let model: LibraryViewModel
    let reduceMotion: Bool
    static func prepareIfRequested() async throws -> Self? { nil }
}
#endif
