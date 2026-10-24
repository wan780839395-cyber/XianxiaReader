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
    /// Fixed metadata only; emitted once on return, never for each retry.
    public struct CaptureDiagnostic: Equatable {
        public enum Reason: String {
            case entryRejected, fixedPositionMissing, sourceThrew
            case ownerOrCancellationAfterNil, nilAtDeadline, retryWaitThrew, ownerOrCancellationAfterWait
            case cancellationBeforeStorage, ownerChangedBeforeStorage, missingSample
            case storageThrew, ownerOrCancellationAfterStorage, cancelled, saved
        }
        public let reason: Reason
        public let attempts: Int
        public let unavailableCaptures: Int
        public let failurePublished: Bool
    }

    private let state: ReaderPositionState
    private let storage: any ReaderPositionStorage

    public init(state: ReaderPositionState, storage: any ReaderPositionStorage) {
        self.state = state
        self.storage = storage
    }

    public func captureAndSave(from source: any ReaderPositionSource, request: ReaderPositionState.SaveRequest,
                               diagnostic: ((CaptureDiagnostic) -> Void)? = nil,
                               sessionID: () -> UUID?) async {
        var reason = CaptureDiagnostic.Reason.entryRejected
        var attempts = 0, unavailableCaptures = 0
        var failurePublished = false
        defer { diagnostic?(CaptureDiagnostic(reason: reason, attempts: attempts,
                                             unavailableCaptures: unavailableCaptures, failurePublished: failurePublished)) }
        // The new module entry must never begin sampling an obsolete reader.
        guard let owner = sessionID(), state.isCurrent(request, sessionID: owner), !Task.isCancelled else { return }
        do {
            var sampled: ReadingPosition?
            if !source.supportsTextCapture {
                reason = .fixedPositionMissing
                guard let page = source.currentPosition else { throw Unavailable() }
                sampled = page
            } else {
                let deadline = Date().addingTimeInterval(3)
                while sampled == nil {
                    attempts += 1; reason = .sourceThrew
                    sampled = try await source.captureCurrentPosition()
                    if sampled == nil {
                        unavailableCaptures += 1; reason = .ownerOrCancellationAfterNil
                        guard state.isCurrent(request, sessionID: sessionID()), !Task.isCancelled else { return }
                        reason = .nilAtDeadline
                        guard Date() < deadline else { throw Unavailable() }
                        reason = .retryWaitThrew
                        try await Task.sleep(nanoseconds: 32_000_000)
                        reason = .ownerOrCancellationAfterWait
                        guard state.isCurrent(request, sessionID: sessionID()), !Task.isCancelled else { return }
                    }
                }
            }
            reason = .cancellationBeforeStorage
            try Task.checkCancellation()
            reason = .ownerChangedBeforeStorage
            guard state.isCurrent(request, sessionID: sessionID()) else { return }
            reason = .missingSample
            guard let fresh = sampled else { throw Unavailable() }
            reason = .storageThrew
            try await storage.save(fresh)
            reason = .ownerOrCancellationAfterStorage
            guard state.isCurrent(request, sessionID: sessionID()), !Task.isCancelled else { return }
            state.saved(fresh, request: request, sessionID: sessionID())
            reason = .saved
        } catch is CancellationError {
            reason = .cancelled
            return
        } catch {
            guard state.isCurrent(request, sessionID: sessionID()) else { return }
            state.failed("阅读进度尚未保存：\(error.localizedDescription)", request: request, sessionID: sessionID())
            failurePublished = true
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
