import CSQLite
import Foundation

public actor SQLiteBookRepository: BookRepository {
    private let database: SQLiteConnection
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(url: URL) throws { database = try SQLiteConnection(url: url) }

    public func books() throws -> [BookSummary] {
        try librarySnapshot().books
    }

    public func librarySnapshot() throws -> LibrarySnapshot {
        let records = try database.query("""
            SELECT b.payload, p.progression, p.updated_at, r.book_id FROM books b
            LEFT JOIN reading_positions p ON p.book_id = b.id
            LEFT JOIN removed_books r ON r.book_id = b.id
            ORDER BY r.removed_at DESC, COALESCE(p.updated_at, b.imported_at) DESC, b.id
            """) { row in
            (BookSummary(
                book: try decoder.decode(Book.self, from: SQLiteConnection.data(row, column: 0)),
                progression: sqlite3_column_type(row, 1) == SQLITE_NULL ? nil : sqlite3_column_double(row, 1),
                lastReadAt: sqlite3_column_type(row, 2) == SQLITE_NULL ? nil : Date(timeIntervalSince1970: sqlite3_column_double(row, 2))
            ), sqlite3_column_type(row, 3) != SQLITE_NULL)
        }
        return LibrarySnapshot(books: records.filter { !$0.1 }.map { $0.0 }, removedBooks: records.filter { $0.1 }.map { $0.0 })
    }

    public func allBookIDs() throws -> Set<UUID> {
        Set(try database.query("SELECT id FROM books;") { row in
            guard let text = sqlite3_column_text(row, 0), let id = UUID(uuidString: String(cString: text)) else {
                throw DatabaseError(message: "书籍身份损坏，已停止导入恢复。")
            }
            return id
        })
    }

    public func moveToTrash(_ id: UUID) throws {
        try Task.checkCancellation()
        try database.transaction {
            try requireBook(id)
            try database.run("INSERT INTO removed_books(book_id, removed_at) VALUES (?, ?) ON CONFLICT(book_id) DO NOTHING;",
                             [.text(id.uuidString), .real(Date().timeIntervalSince1970)])
        }
    }

    public func restoreBook(_ id: UUID) throws {
        try Task.checkCancellation()
        try database.transaction {
            try requireBook(id)
            try database.run("DELETE FROM removed_books WHERE book_id = ?;", [.text(id.uuidString)])
        }
    }

    private func requireBook(_ id: UUID) throws {
        guard try !database.query("SELECT 1 FROM books WHERE id = ?;", [.text(id.uuidString)], map: { _ in true }).isEmpty else {
            throw BookEditingError.bookNotFound
        }
    }

    public func insert(_ book: Book, chapters: [Chapter]) throws {
        guard chapters.allSatisfy({ $0.bookID == book.id }) else {
            throw DatabaseError(message: "章节不属于当前书籍。")
        }
        try database.transaction {
            try database.run("INSERT INTO books(id, payload, imported_at) VALUES (?, ?, ?);",
                             [.text(book.id.uuidString), .blob(try encoder.encode(book)), .real(book.importedAt.timeIntervalSince1970)])
            for chapter in chapters {
                try database.run("INSERT INTO chapters(id, book_id, ordinal, payload) VALUES (?, ?, ?, ?);",
                                 [.text(chapter.id), .text(book.id.uuidString), .integer(chapter.ordinal), .blob(try encoder.encode(chapter))])
            }
        }
    }

    public func renameBook(_ id: UUID, title: String) throws -> Book {
        let title = try BookTitle.validated(title)
        try Task.checkCancellation()
        // Read the latest payload under a write transaction, never overwrite it
        // with the UI's potentially stale Book snapshot. Identity/files are unchanged.
        return try database.transaction {
            guard var book = try database.query("SELECT payload FROM books WHERE id = ?;", [.text(id.uuidString)], map: {
                try decoder.decode(Book.self, from: SQLiteConnection.data($0, column: 0))
            }).first else { throw BookEditingError.bookNotFound }
            book.title = title
            try database.run("UPDATE books SET payload = ? WHERE id = ?;", [.blob(try encoder.encode(book)), .text(id.uuidString)])
            return book
        }
    }

    public func position(for bookID: UUID) throws -> ReadingPosition? {
        try database.query("SELECT payload FROM reading_positions WHERE book_id = ?;", [.text(bookID.uuidString)]) {
            try decoder.decode(ReadingPosition.self, from: SQLiteConnection.data($0, column: 0))
        }.first
    }

    public func save(_ position: ReadingPosition) throws {
        try database.run("""
            INSERT INTO reading_positions(book_id, progression, updated_at, payload) VALUES (?, ?, ?, ?)
            ON CONFLICT(book_id) DO UPDATE SET progression = excluded.progression,
            updated_at = excluded.updated_at, payload = excluded.payload
            WHERE excluded.updated_at >= reading_positions.updated_at;
            """, [.text(position.bookID.uuidString), position.progression.map(SQLValue.real) ?? .null,
                   .real(position.updatedAt.timeIntervalSince1970), .blob(try encoder.encode(position))])
    }

    public func chapters(for bookID: UUID) throws -> [Chapter] {
        try database.query("SELECT payload FROM chapters WHERE book_id = ? ORDER BY ordinal;", [.text(bookID.uuidString)]) {
            try decoder.decode(Chapter.self, from: SQLiteConnection.data($0, column: 0))
        }
    }

    public func bookmarks(for bookID: UUID) throws -> [Bookmark] {
        try database.query("SELECT payload FROM bookmarks WHERE book_id = ? ORDER BY created_at DESC;", [.text(bookID.uuidString)]) {
            try decoder.decode(Bookmark.self, from: SQLiteConnection.data($0, column: 0))
        }
    }

    public func add(_ bookmark: Bookmark) throws {
        try database.run("INSERT INTO bookmarks(id, book_id, created_at, payload) VALUES (?, ?, ?, ?);",
                         [.text(bookmark.id.uuidString), .text(bookmark.bookID.uuidString),
                          .real(bookmark.createdAt.timeIntervalSince1970), .blob(try encoder.encode(bookmark))])
    }

    public func removeBookmark(_ id: UUID) throws {
        try database.run("DELETE FROM bookmarks WHERE id = ?;", [.text(id.uuidString)])
    }
}
