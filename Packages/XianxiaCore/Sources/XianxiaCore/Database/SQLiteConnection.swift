import CSQLite
import Foundation

public struct DatabaseError: LocalizedError {
    public let message: String
    public var errorDescription: String? { "书库数据库错误：\(message)" }
}

enum SQLValue {
    case text(String), blob(Data), real(Double), integer(Int), null
}

/// Exclusively owned by SQLiteBookRepository. Never pass the handle across isolation boundaries.
final class SQLiteConnection {
    private var handle: OpaquePointer?
    private let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    init(url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let code = sqlite3_open_v2(url.path, &handle, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil)
        do {
            guard code == SQLITE_OK else { throw failure() }
            sqlite3_busy_timeout(handle, 5_000)
            try execute("PRAGMA foreign_keys = ON;")
            let version = try query("PRAGMA user_version;") { Int(sqlite3_column_int($0, 0)) }.first ?? 0
            // Reject a newer schema before changing journal mode or applying any migration.
            guard version <= 1 else { throw DatabaseError(message: "数据库版本 \(version) 高于此应用支持的版本，请更新应用。") }
            try execute("PRAGMA journal_mode = WAL;")
            if version == 0 {
                guard let migration = Bundle.module.url(forResource: "001_initial", withExtension: "sql") else {
                    throw DatabaseError(message: "缺少数据库迁移资源。")
                }
                try execute(String(contentsOf: migration, encoding: .utf8))
            }
        } catch {
            // A throwing initializer may otherwise retain the SQLite handle on retry.
            sqlite3_close(handle)
            handle = nil
            throw error
        }
    }

    deinit { sqlite3_close(handle) }

    func execute(_ sql: String) throws {
        guard sqlite3_exec(handle, sql, nil, nil, nil) == SQLITE_OK else { throw failure() }
    }

    func run(_ sql: String, _ values: [SQLValue] = []) throws {
        let statement = try prepare(sql, values)
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_DONE else { throw failure() }
    }

    func query<T>(_ sql: String, _ values: [SQLValue] = [], map: (OpaquePointer) throws -> T) throws -> [T] {
        let statement = try prepare(sql, values)
        defer { sqlite3_finalize(statement) }
        var result: [T] = []
        while true {
            switch sqlite3_step(statement) {
            case SQLITE_ROW: result.append(try map(statement))
            case SQLITE_DONE: return result
            default: throw failure()
            }
        }
    }

    func transaction<T>(_ body: () throws -> T) throws -> T {
        try execute("BEGIN IMMEDIATE;")
        do {
            let result = try body()
            try execute("COMMIT;")
            return result
        } catch {
            // Preserve the original failure; rollback is a best-effort database cleanup.
            try? execute("ROLLBACK;")
            throw error
        }
    }

    static func data(_ statement: OpaquePointer, column: Int32) -> Data {
        let count = Int(sqlite3_column_bytes(statement, column))
        guard let bytes = sqlite3_column_blob(statement, column), count > 0 else { return Data() }
        return Data(bytes: bytes, count: count)
    }

    private func prepare(_ sql: String, _ values: [SQLValue]) throws -> OpaquePointer {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            throw failure()
        }
        do {
            for (offset, value) in values.enumerated() {
                let index = Int32(offset + 1)
                let code: Int32
                switch value {
                case .text(let text): code = sqlite3_bind_text(statement, index, text, -1, transient)
                case .blob(let data):
                    code = data.withUnsafeBytes { sqlite3_bind_blob(statement, index, $0.baseAddress, Int32($0.count), transient) }
                case .real(let value): code = sqlite3_bind_double(statement, index, value)
                case .integer(let value): code = sqlite3_bind_int64(statement, index, Int64(value))
                case .null: code = sqlite3_bind_null(statement, index)
                }
                guard code == SQLITE_OK else { throw failure() }
            }
            return statement
        } catch {
            sqlite3_finalize(statement)
            throw error
        }
    }

    private func failure() -> DatabaseError {
        DatabaseError(message: handle.map { String(cString: sqlite3_errmsg($0)) } ?? "无法打开数据库。")
    }
}
