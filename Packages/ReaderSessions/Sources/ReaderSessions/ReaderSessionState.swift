import Foundation

/// Owns admission and synchronous publication for one reader's open session.
/// It does not own engines, tasks, settings, or position persistence.
@MainActor public final class ReaderSessionState {
    public private(set) var requestID: UUID?
    public private(set) var started = false
    private var bookID: UUID?

    public init() {}

    /// A failed open remains owned until close/retry, just like a ready reader.
    public func begin(bookID: UUID) -> UUID? {
        guard !started else { return nil }
        let request = UUID()
        started = true
        requestID = request
        self.bookID = bookID
        return request
    }

    /// Call after the engine's synchronous final-position callback.
    public func invalidate() {
        started = false
        requestID = nil
        bookID = nil
    }

    /// Preserve the existing owner while a failed font rebuild permits reopening.
    public func allowReopening() { started = false }

    /// Check ownership and publish in the same actor turn; no new await boundary.
    /// Already accepted asynchronous work may finish, but must re-enter this gate
    /// before publishing a completion or an error.
    @discardableResult public func accept(_ owner: UUID, bookID: UUID? = nil,
                                          perform: () -> Void) -> Bool {
        guard requestID == owner else { return false }
        if let bookID, self.bookID != bookID { return false }
        perform()
        return true
    }
}
