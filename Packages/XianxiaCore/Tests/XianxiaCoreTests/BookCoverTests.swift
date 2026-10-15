import CSQLite
import Foundation
import XCTest
@testable import XianxiaCore

final class BookCoverTests: XCTestCase {
    private func context() throws -> (URL, BookFileStore, SQLiteBookRepository) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let files = try BookFileStore(root: root.appendingPathComponent("Storage"))
        let repository = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        return (root, files, repository)
    }
    private func storedBook(_ root: URL, _ files: BookFileStore) async throws -> Book {
        let source = root.appendingPathComponent("original.txt"); try Data("原书保持不变".utf8).write(to: source)
        let staged = try await files.stageTXT(from: source), paths = try await files.finalize(staged, coverData: Data("默认封面".utf8))
        return Book(id: staged.id, title: "云海", author: "原创作者", format: .txt, filePath: paths.filePath, coverPath: paths.coverPath, txtEncoding: .utf8)
    }
    func testLegacyPayloadDecodesAndCoverPathsAreDerivedOnlyFromIdentity() throws {
        let old = Book(title: "旧书", format: .epub, filePath: "book.epub", coverPath: "cover.jpg")
        var payload = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(old)) as? [String: Any])
        payload.removeValue(forKey: "coverOverride")
        let decoded = try JSONDecoder().decode(Book.self, from: JSONSerialization.data(withJSONObject: payload))
        XCTAssertEqual(decoded, old); XCTAssertNil(decoded.coverOverride); XCTAssertEqual(decoded.displayCoverPath, "cover.jpg")
        let cover = BookCoverOverride()
        XCTAssertEqual(cover.originalPath(bookID: old.id), "Books/\(old.id.uuidString)/Artwork/\(cover.assetID.uuidString)/original")
        XCTAssertFalse(cover.thumbnailPath(bookID: old.id).contains(".."))
        XCTAssertNotEqual(cover.directory(bookID: old.id), cover.directory(bookID: UUID()))
    }
    func testCoverReplacementResetReopenAndTrashKeepIdentityAndRelatedData() async throws {
        let (root, files, repository) = try context(), book = try await storedBook(root, files)
        let original = try Data(contentsOf: files.resolve(book.filePath)), defaultCover = try Data(contentsOf: files.resolve(try XCTUnwrap(book.coverPath)))
        let chapter = Chapter(id: "c1", bookID: book.id, ordinal: 0, title: "第一章", startByte: 0, endByte: 6)
        let position = ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data("complete locator".utf8), progression: 0.42)
        let bookmark = Bookmark(position: position, title: "书签")
        try await repository.insert(book, chapters: [chapter]); try await repository.save(position); try await repository.add(bookmark)
        let cover = BookCoverOverride(), changed = try await repository.setCoverOverride(book.id, cover: cover)
        var expected = book; expected.coverOverride = cover
        XCTAssertEqual(changed, expected); XCTAssertEqual(changed.displayCoverPath, cover.thumbnailPath(bookID: book.id))
        try await repository.moveToTrash(book.id)
        let reopened = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite")), snapshot = try await reopened.librarySnapshot()
        XCTAssertTrue(snapshot.books.isEmpty); XCTAssertEqual(snapshot.removedBooks.first?.book, expected)
        try await reopened.restoreBook(book.id)
        let reset = try await reopened.setCoverOverride(book.id, cover: nil)
        XCTAssertEqual(reset, book); XCTAssertEqual(reset.displayCoverPath, book.coverPath)
        let savedPosition = try await reopened.position(for: book.id), chapters = try await reopened.chapters(for: book.id), bookmarks = try await reopened.bookmarks(for: book.id)
        XCTAssertEqual(savedPosition, position); XCTAssertEqual(chapters, [chapter]); XCTAssertEqual(bookmarks, [bookmark])
        XCTAssertEqual(try Data(contentsOf: files.resolve(book.filePath)), original)
        XCTAssertEqual(try Data(contentsOf: files.resolve(try XCTUnwrap(book.coverPath))), defaultCover)
        let control = try SQLiteConnection(url: root.appendingPathComponent("library.sqlite"))
        XCTAssertEqual(try control.query("PRAGMA user_version;") { Int(sqlite3_column_int($0, 0)) }.first, 2)
    }
    func testCoverCommitReadsLatestPayloadAndRenamePreservesNewOverride() async throws {
        let (root, _, first) = try context(), second = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        let book = Book(title: "旧名", author: "原作者", format: .epub, filePath: "original.epub")
        try await first.insert(book, chapters: [])
        let renamed = try await second.renameBook(book.id, title: "最新书名"), cover = BookCoverOverride()
        let updated = try await first.setCoverOverride(book.id, cover: cover)
        var expected = renamed; expected.coverOverride = cover
        XCTAssertEqual(updated, expected)
        let final = try await second.renameBook(book.id, title: "再改名")
        XCTAssertEqual(final.coverOverride, cover); XCTAssertEqual(final.author, book.author)
    }
    func testMissingCancelledAndRealWriteFailureDoNotPublishCoverAndRetryWorks() async throws {
        let (root, _, repository) = try context(), cover = BookCoverOverride()
        do { _ = try await repository.setCoverOverride(UUID(), cover: cover); XCTFail("Missing book") }
        catch { XCTAssertEqual(error as? BookEditingError, .bookNotFound) }
        let book = Book(title: "云海", format: .txt, filePath: "original.txt"); try await repository.insert(book, chapters: [])
        let cancelled = Task { withUnsafeCurrentTask { $0?.cancel() }; return try await repository.setCoverOverride(book.id, cover: cover) }
        do { _ = try await cancelled.value; XCTFail("Cancellation") } catch { XCTAssertTrue(error is CancellationError) }
        let control = try SQLiteConnection(url: root.appendingPathComponent("library.sqlite"))
        try control.execute("CREATE TRIGGER deny_cover BEFORE UPDATE ON books BEGIN SELECT RAISE(ABORT,'cover denied'); END;")
        do { _ = try await repository.setCoverOverride(book.id, cover: cover); XCTFail("Failure must propagate") }
        catch { XCTAssertTrue(error.localizedDescription.contains("cover denied")) }
        let unchanged = try await repository.books(); XCTAssertEqual(unchanged.first?.book, book)
        try control.execute("DROP TRIGGER deny_cover;")
        let retried = try await repository.setCoverOverride(book.id, cover: cover); XCTAssertEqual(retried.coverOverride, cover)
    }
    func testStagingFinalizationRollbackRetryAndStartupKeepOriginalAndAllCommittedArtwork() async throws {
        let (root, files, repository) = try context(), book = try await storedBook(root, files)
        try await repository.insert(book, chapters: [])
        let source = root.appendingPathComponent("image.bin"), bytes = Data("opaque source bytes".utf8), thumbnail = Data([0xFF,0xD8,0xFF,0xD9])
        try bytes.write(to: source)
        let staged = try await files.stageCover(from: source, bookID: book.id)
        XCTAssertEqual(try Data(contentsOf: staged.originalURL), bytes)
        let cover = try await files.finalizeCover(staged, thumbnailJPEG: thumbnail)
        XCTAssertEqual(try Data(contentsOf: files.resolve(cover.originalPath(bookID: book.id))), bytes)
        try await files.rollbackCoverFinalization(staged)
        XCTAssertEqual(try Data(contentsOf: staged.originalURL), bytes)
        let retry = try await files.finalizeCover(staged, thumbnailJPEG: thumbnail); XCTAssertEqual(retry, cover)
        _ = try await repository.setCoverOverride(book.id, cover: cover)
        let pending = try await files.stageCover(from: source, bookID: book.id)
        try await files.recoverImports(knownBookIDs: [book.id])
        XCTAssertFalse(FileManager.default.fileExists(atPath: pending.originalURL.path))
        XCTAssertEqual(try Data(contentsOf: files.resolve(cover.thumbnailPath(bookID: book.id))), thumbnail)
        XCTAssertEqual(try Data(contentsOf: files.resolve(book.filePath)), Data("原书保持不变".utf8))
        XCTAssertEqual(try Data(contentsOf: files.resolve(try XCTUnwrap(book.coverPath))), Data("默认封面".utf8))
        let cancelled = try await files.stageCover(from: source, bookID: book.id)
        try await files.discardCover(cancelled)
        XCTAssertFalse(FileManager.default.fileExists(atPath: cancelled.originalURL.path))
        XCTAssertEqual(try Data(contentsOf: source), bytes)
    }
    func testEmptyOversizedDirectoryAndLinkedSourcesRejectWithoutPublishing() async throws {
        let (root, files, _) = try context(), source = root.appendingPathComponent("image.bin")
        try Data().write(to: source)
        do { _ = try await files.stageCover(from: source, bookID: UUID()); XCTFail("Empty") } catch { XCTAssertEqual(error as? BookCoverError, .invalidImage) }
        let handle = try FileHandle(forWritingTo: source)
        try handle.seek(toOffset: UInt64(BookFileStore.maximumCoverBytes)); try handle.write(contentsOf: Data([1])); try handle.close()
        do { _ = try await files.stageCover(from: source, bookID: UUID()); XCTFail("Too large") } catch { XCTAssertEqual(error as? BookCoverError, .imageTooLarge) }
        do { _ = try await files.stageCover(from: root, bookID: UUID()); XCTFail("Directory") } catch { XCTAssertEqual(error as? BookCoverError, .invalidImage) }
        let link = root.appendingPathComponent("linked"); try FileManager.default.createSymbolicLink(at: link, withDestinationURL: source)
        do { _ = try await files.stageCover(from: link, bookID: UUID()); XCTFail("Symlink") } catch { XCTAssertEqual(error as? BookCoverError, .invalidImage) }
        XCTAssertFalse(FileManager.default.fileExists(atPath: files.root.appendingPathComponent("StagingCovers").path))
    }
    func testStagingParentSymlinkAndDanglingLinkNeverWriteOutsideStorage() async throws {
        for dangling in [false, true] {
            let (root, files, _) = try context(), source = root.appendingPathComponent("image.bin"), outside = root.appendingPathComponent("outside")
            try Data([1,2,3]).write(to: source)
            if !dangling { try FileManager.default.createDirectory(at: outside, withIntermediateDirectories: true) }
            try FileManager.default.createSymbolicLink(at: files.root.appendingPathComponent("StagingCovers"), withDestinationURL: outside)
            do { _ = try await files.stageCover(from: source, bookID: UUID()); XCTFail("Managed link") } catch { XCTAssertEqual(error as? StorageError, .unsafePath) }
            if !dangling { XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: outside.path).isEmpty) }
        }
    }
    func testThumbnailAndArtworkDanglingLinksRejectThenAllowSafeRetry() async throws {
        let (root, files, _) = try context(), book = try await storedBook(root, files), source = root.appendingPathComponent("image.bin")
        try Data([1,2,3]).write(to: source)
        let staged = try await files.stageCover(from: source, bookID: book.id)
        let thumbnail = staged.originalURL.deletingLastPathComponent().appendingPathComponent("thumbnail.jpg"), outside = root.appendingPathComponent("outside")
        try FileManager.default.createSymbolicLink(at: thumbnail, withDestinationURL: outside)
        do { _ = try await files.finalizeCover(staged, thumbnailJPEG: Data([1])); XCTFail("Linked target") } catch { XCTAssertEqual(error as? StorageError, .unsafePath) }
        try FileManager.default.removeItem(at: thumbnail)
        let artwork = try files.resolve("Books/\(book.id.uuidString)/Artwork")
        try FileManager.default.createSymbolicLink(at: artwork, withDestinationURL: outside)
        do { _ = try await files.finalizeCover(staged, thumbnailJPEG: Data([1])); XCTFail("Linked parent") } catch { XCTAssertEqual(error as? StorageError, .unsafePath) }
        XCTAssertFalse(FileManager.default.fileExists(atPath: outside.path))
        try FileManager.default.removeItem(at: artwork)
        let cover = try await files.finalizeCover(staged, thumbnailJPEG: Data([1]))
        XCTAssertTrue(FileManager.default.fileExists(atPath: try files.resolve(cover.originalPath(bookID: book.id)).path))
    }
    func testCancelledStagesAndInvalidThumbnailsLeaveRecoverableDraftsAndRootAliasWorks() async throws {
        let (root, files, _) = try context(), book = try await storedBook(root, files), source = root.appendingPathComponent("image.bin")
        try Data([1,2,3]).write(to: source)
        let task = Task { withUnsafeCurrentTask { $0?.cancel() }; return try await files.stageCover(from: source, bookID: book.id) }
        do { _ = try await task.value; XCTFail("Cancellation") } catch { XCTAssertTrue(error is CancellationError) }
        let staged = try await files.stageCover(from: source, bookID: book.id)
        for bytes in [Data(), Data(repeating: 1, count: 2*1_024*1_024+1)] {
            do { _ = try await files.finalizeCover(staged, thumbnailJPEG: bytes); XCTFail("Bounded thumbnail") }
            catch { XCTAssertEqual(error as? BookCoverError, .invalidThumbnail) }
        }
        XCTAssertEqual(try Data(contentsOf: staged.originalURL), Data([1,2,3]))
        let alias = root.appendingPathComponent("alias"); try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: files.root)
        let aliased = try BookFileStore(root: alias), copied = try await aliased.stageCover(from: source, bookID: book.id)
        XCTAssertEqual(aliased.root, files.root); XCTAssertEqual(try Data(contentsOf: copied.originalURL), Data([1,2,3]))
    }
}
