import ReaderPositions
import ReadingInterfaces
import XianxiaCore

@MainActor final class ReaderEnginePositionSource: ReaderPositionSource {
    enum UnavailableReason: String { case returnedNil, engineUnavailable }
    private let engine: any ReaderEngine
    private let observeUnavailable: ((UnavailableReason) -> Void)?
    init(_ engine: any ReaderEngine, observeUnavailable: ((UnavailableReason) -> Void)? = nil) {
        self.engine = engine
        self.observeUnavailable = observeUnavailable
    }
    var supportsTextCapture: Bool { engine.appearanceProvider?.supportsTextAppearance != false }
    var currentPosition: ReadingPosition? { engine.currentPosition }

    func captureCurrentPosition() async throws -> ReadingPosition? {
        do {
            let value = try await engine.captureCurrentPosition()
            if value == nil { observeUnavailable?(.returnedNil) }
            return value
        }
        // Translate the existing engine's transient condition into the narrow
        // source contract. All other errors propagate unchanged.
        catch ReaderPositionCaptureError.unavailable { observeUnavailable?(.engineUnavailable); return nil }
    }
}

@MainActor final class ReaderPositionRepository: ReaderPositionStorage {
    private let repository: any BookRepository
    init(_ repository: any BookRepository) { self.repository = repository }
    func save(_ position: ReadingPosition) async throws { try await repository.save(position) }
}
