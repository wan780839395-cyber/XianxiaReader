import Foundation
import XianxiaCore

public enum ReaderNavigationError: LocalizedError {
    case busy, unavailable
    public var errorDescription: String? {
        switch self {
        case .busy: return "正在跳转，请稍候。"
        case .unavailable: return "当前位置尚未稳定，请稍后再试。"
        }
    }
}

/// One owner for excursion origins and the lock shared with font rebuilding.
/// Capture and navigation are narrow capabilities; no engine or storage is held.
@MainActor public final class ReaderNavigationCoordinator {
    public var onStateWillChange: (() -> Void)?
    public private(set) var returnPosition: ReadingPosition? { willSet { onStateWillChange?() } }
    public private(set) var inProgress = false { willSet { onStateWillChange?() } }
    private var requestID: UUID?

    public init() {}

    /// The existing font transaction has its own owner/guards. It reserves this
    /// same navigation lock without changing its capture/save/reopen sequence.
    public func beginExternal(_ request: UUID) {
        requestID = request
        inProgress = true
    }

    public func endExternal(_ request: UUID) { finish(request) }

    public func close() {
        requestID = nil
        inProgress = false
        returnPosition = nil
    }

    public func stay() {
        guard !inProgress else { return }
        returnPosition = nil
    }

    public func navigate(bookID: UUID, session: UUID, sessionID: () -> UUID?, isBlocked: () -> Bool,
                         pause: () -> Void, capture: @MainActor () async throws -> ReadingPosition,
                         onSuccess: () -> Void, operation: @MainActor () async throws -> Void,
                         returning: Bool = false) async throws {
        // The extra module entry must not bind an old caller to a reopened reader.
        guard sessionID() == session else { throw CancellationError() }
        guard requestID == nil, !isBlocked() else { throw ReaderNavigationError.busy }
        let request = UUID()
        requestID = request
        inProgress = true
        defer { finish(request) }
        pause()
        // Keep the first complete origin for this excursion. Unlike explicit
        // saving, this is a single fresh capture with no unavailable retry loop.
        var origin = returnPosition
        if origin == nil && !returning { origin = try await capture() }
        try Task.checkCancellation()
        guard sessionID() == session, requestID == request else { throw CancellationError() }
        guard returning || origin?.bookID == bookID else { throw ReaderNavigationError.unavailable }
        try await operation()
        try Task.checkCancellation()
        guard sessionID() == session, requestID == request else { throw CancellationError() }
        returnPosition = returning ? nil : origin
        onSuccess()
    }

    private func finish(_ request: UUID) {
        if requestID == request {
            requestID = nil
            inProgress = false
        }
    }
}
