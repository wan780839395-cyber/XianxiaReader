import Foundation
import XianxiaCore

/// A nil fresh capture means temporarily unavailable during reflow. Other errors
/// remain failures. Fixed-layout pages retain their complete cached page locator.
@MainActor public protocol ReaderPositionSource: AnyObject {
    var supportsTextCapture: Bool { get }
    var currentPosition: ReadingPosition? { get }
    func captureCurrentPosition() async throws -> ReadingPosition?
}

/// The platform bridge delegates actual storage to the original repository actor.
@MainActor public protocol ReaderPositionStorage: AnyObject {
    func save(_ position: ReadingPosition) async throws
}

/// Owns capture, persistence and synchronous publication after the storage await.
/// Session lifecycle, motion/settings flushes and navigation remain with callers.
@MainActor public final class ReaderPositionPersistence {
    private let state: ReaderPositionState
    private let storage: any ReaderPositionStorage

    public init(state: ReaderPositionState, storage: any ReaderPositionStorage) {
        self.state = state
        self.storage = storage
    }

    public func captureAndSave(from source: any ReaderPositionSource, request: ReaderPositionState.SaveRequest,
                               sessionID: () -> UUID?) async {
        // The new module entry must never begin sampling an obsolete reader.
        guard let owner = sessionID(), state.isCurrent(request, sessionID: owner), !Task.isCancelled else { return }
        do {
            var sampled: ReadingPosition?
            if !source.supportsTextCapture {
                guard let page = source.currentPosition else { throw Unavailable() }
                sampled = page
            } else {
                let deadline = Date().addingTimeInterval(3)
                while sampled == nil {
                    sampled = try await source.captureCurrentPosition()
                    if sampled == nil {
                        guard state.isCurrent(request, sessionID: sessionID()), !Task.isCancelled else { return }
                        guard Date() < deadline else { throw Unavailable() }
                        try await Task.sleep(nanoseconds: 32_000_000)
                        guard state.isCurrent(request, sessionID: sessionID()), !Task.isCancelled else { return }
                    }
                }
            }
            try Task.checkCancellation()
            guard state.isCurrent(request, sessionID: sessionID()) else { return }
            guard let fresh = sampled else { throw Unavailable() }
            try await storage.save(fresh)
            guard state.isCurrent(request, sessionID: sessionID()), !Task.isCancelled else { return }
            state.saved(fresh, request: request, sessionID: sessionID())
        } catch is CancellationError {
            return
        } catch {
            guard state.isCurrent(request, sessionID: sessionID()) else { return }
            state.failed("阅读进度尚未保存：\(error.localizedDescription)", request: request, sessionID: sessionID())
        }
    }

    /// Every already-accepted position event keeps its original write attempt,
    /// including the engine's final close callback. Core rejects stale timestamps.
    public func persistEmitted(_ position: ReadingPosition, onFailure: (String) -> Void) async {
        do { try await storage.save(position) }
        catch { onFailure("阅读进度未能写入：\(error.localizedDescription)") }
    }

    private struct Unavailable: LocalizedError {
        var errorDescription: String? { "当前位置尚未稳定，请稍后再试。" }
    }
}
