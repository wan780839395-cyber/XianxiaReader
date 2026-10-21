import Foundation
import XianxiaCore

/// Owns opaque positions and acceptance of explicit save results. Sampling,
/// storage awaits and reader lifecycle remain with their existing callers.
@MainActor public final class ReaderPositionState {
    public struct SaveRequest: Equatable {
        fileprivate let id: UUID
        fileprivate let sessionID: UUID?
    }

    public private(set) var position: ReadingPosition?
    public private(set) var saveFailure: String?
    public var onPositionChanged: ((ReadingPosition?) -> Void)?
    /// Called before mutation, preserving the App's ObservableObject contract.
    public var onSaveFailureWillChange: (() -> Void)?
    private var activeSave: SaveRequest?

    public init() {}

    public func update(_ position: ReadingPosition?) {
        self.position = position
        onPositionChanged?(position)
    }

    public func beginSave(sessionID: UUID?) -> SaveRequest {
        let request = SaveRequest(id: UUID(), sessionID: sessionID)
        activeSave = request
        return request
    }

    public func isCurrent(_ request: SaveRequest, sessionID: UUID?) -> Bool {
        activeSave == request && request.sessionID == sessionID
    }

    public func endSave(_ request: SaveRequest) {
        if activeSave == request { activeSave = nil }
    }

    public func invalidateSave() { activeSave = nil }

    public func clearSaveFailure() {
        onSaveFailureWillChange?()
        saveFailure = nil
    }

    @discardableResult public func saved(_ position: ReadingPosition, request: SaveRequest, sessionID: UUID?) -> Bool {
        guard sessionID != nil, isCurrent(request, sessionID: sessionID) else { return false }
        update(position)
        clearSaveFailure()
        return true
    }

    @discardableResult public func failed(_ message: String, request: SaveRequest, sessionID: UUID?) -> Bool {
        guard sessionID != nil, isCurrent(request, sessionID: sessionID) else { return false }
        onSaveFailureWillChange?()
        saveFailure = message
        return true
    }
}
