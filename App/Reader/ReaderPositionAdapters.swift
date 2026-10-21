import ReaderPositions
import ReadingInterfaces
import XianxiaCore

@MainActor final class ReaderEnginePositionSource: ReaderPositionSource {
    private let engine: any ReaderEngine
    init(_ engine: any ReaderEngine) { self.engine = engine }
    var supportsTextCapture: Bool { engine.appearanceProvider?.supportsTextAppearance != false }
    var currentPosition: ReadingPosition? { engine.currentPosition }

    func captureCurrentPosition() async throws -> ReadingPosition? {
        do { return try await engine.captureCurrentPosition() }
        // Translate the existing engine's transient condition into the narrow
        // source contract. All other errors propagate unchanged.
        catch ReaderPositionCaptureError.unavailable { return nil }
    }
}

@MainActor final class ReaderPositionRepository: ReaderPositionStorage {
    private let repository: any BookRepository
    init(_ repository: any BookRepository) { self.repository = repository }
    func save(_ position: ReadingPosition) async throws { try await repository.save(position) }
}
