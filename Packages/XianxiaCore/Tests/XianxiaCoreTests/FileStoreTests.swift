import Foundation
import XCTest
@testable import XianxiaCore

final class FileStoreTests: XCTestCase {
    private struct FailedCopy: SourceFileCopying {
        struct CopyFailure: Error {}
        func copy(from source: URL, to destination: URL) throws {
            // Simulate a File Provider or disk failure after a partial file was created.
            try Data([0, 1]).write(to: destination)
            throw CopyFailure()
        }
    }
    private func temporaryRoot() throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        return root
    }

    func testStageFinalizeAndRecoveryPreserveCommittedBook() async throws {
        let root = try temporaryRoot()
        let source = root.appendingPathComponent("小说.EPUB")
        let bytes = Data("This is a storage test, not an EPUB parser test.".utf8)
        try bytes.write(to: source)
        let store = try BookFileStore(root: root.appendingPathComponent("Storage"))
        let staged = try await store.stageEPUB(from: source)
        let paths = try await store.finalize(staged, coverData: Data([1, 2, 3]))
        let file = try store.resolve(paths.filePath)
        XCTAssertEqual(try Data(contentsOf: file), bytes)
        XCTAssertTrue(FileManager.default.fileExists(atPath: source.path))
        let orphan = try await store.stageEPUB(from: source)
        let orphanPaths = try await store.finalize(orphan, coverData: nil)
        let interrupted = try await store.stageEPUB(from: source)
        try await store.recoverImports(knownBookIDs: [staged.id])
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: try store.resolve(orphanPaths.filePath).path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: interrupted.fileURL.path))
    }

    func testPathsCannotEscapeStorage() throws {
        let store = try BookFileStore(root: temporaryRoot())
        for path in ["../private.epub", "/tmp/private.epub", "Books/../../secret", "Books\\..\\secret", ""] {
            XCTAssertThrowsError(try store.resolve(path))
        }
        XCTAssertEqual(try store.resolve("Books/new/book.epub").path,
                       store.root.appendingPathComponent("Books/new/book.epub").path)
    }

    func testSymlinkCannotEscapeStorage() throws {
        let root = try temporaryRoot()
        let store = try BookFileStore(root: root.appendingPathComponent("Storage"))
        try FileManager.default.createSymbolicLink(at: store.root.appendingPathComponent("escape"),
                                                  withDestinationURL: root)
        XCTAssertThrowsError(try store.resolve("escape/secret.epub"))
        try Data([1]).write(to: root.appendingPathComponent("existing.epub"))
        XCTAssertThrowsError(try store.resolve("escape/existing.epub"))
    }

    func testManagedSymlinksAreRejectedEvenWhenTargetIsInsideRootOrMissing() throws {
        let root = try temporaryRoot()
        let store = try BookFileStore(root: root.appendingPathComponent("Storage"))
        let realDirectory = store.root.appendingPathComponent("Books")
        try FileManager.default.createDirectory(at: realDirectory, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: store.root.appendingPathComponent("alias"),
                                                  withDestinationURL: realDirectory)
        try FileManager.default.createSymbolicLink(at: store.root.appendingPathComponent("dangling"),
                                                  withDestinationURL: root.appendingPathComponent("absent"))
        for path in ["alias", "alias/new/book.epub", "dangling", "dangling/new/book.epub"] {
            XCTAssertThrowsError(try store.resolve(path))
        }
    }

    func testRootUnderExistingSymlinkIsCanonicalizedBeforePathChecks() throws {
        let root = try temporaryRoot()
        let actual = root.appendingPathComponent("Actual")
        try FileManager.default.createDirectory(at: actual, withIntermediateDirectories: true)
        let alias = root.appendingPathComponent("Alias")
        try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: actual)
        let store = try BookFileStore(root: alias.appendingPathComponent("NewStorage"))
        // Directory URLs can differ only in a trailing slash; verify the filesystem path.
        XCTAssertEqual(store.root.path, actual.appendingPathComponent("NewStorage").resolvingSymlinksInPath().path)
        XCTAssertEqual(try store.resolve("Books/new/book.epub").path,
                       actual.appendingPathComponent("NewStorage/Books/new/book.epub").path)
    }

    func testUnsupportedImportDoesNotCreateBookFiles() async throws {
        let root = try temporaryRoot()
        let source = root.appendingPathComponent("小说.txt")
        try Data("第一章".utf8).write(to: source)
        let store = try BookFileStore(root: root.appendingPathComponent("Storage"))
        do { _ = try await store.stageEPUB(from: source); XCTFail("TXT belongs to M2") }
        catch { XCTAssertTrue(error is StorageError) }
        let contents = try FileManager.default.contentsOfDirectory(atPath: store.root.path)
        XCTAssertTrue(contents.isEmpty)
    }

    func testPartialCopyFailureRemovesStagingAndPreservesOriginal() async throws {
        let root = try temporaryRoot()
        let source = root.appendingPathComponent("original.epub")
        let original = Data("original book bytes".utf8)
        try original.write(to: source)
        let store = try BookFileStore(root: root.appendingPathComponent("Storage"), sourceCopier: FailedCopy())
        let id = UUID()
        do { _ = try await store.stageEPUB(from: source, id: id); XCTFail("Copy must fail") }
        catch { XCTAssertTrue(error is FailedCopy.CopyFailure) }
        XCTAssertEqual(try Data(contentsOf: source), original)
        XCTAssertFalse(FileManager.default.fileExists(atPath: try store.resolve("Staging/\(id.uuidString)").path))
    }
}
