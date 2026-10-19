import Combine
import Foundation
import XianxiaCore

/// The settings boundary has no reader, navigator, locator or presentation dependency.
protocol ReaderSettingsStorage: Sendable {
    func readingAppearance() async throws -> ReadingAppearance
    func readingInteraction() async throws -> ReadingInteraction
    func saveReadingAppearance(_ value: ReadingAppearance) async throws
    func saveReadingInteraction(_ value: ReadingInteraction) async throws
}

extension BookFileStore: ReaderSettingsStorage {}

/// Shared by AppServices so a closing reader cannot write behind a newer reader.
/// Enqueue synchronously on MainActor; an actor alone does not order work across awaits.
@MainActor final class ReaderSettingsPersistence {
    struct Completion: Equatable {
        let owner: UUID
        let errorMessage: String?
    }

    @Published private(set) var appearanceCompletion: Completion?
    @Published private(set) var interactionCompletion: Completion?

    private let storage: any ReaderSettingsStorage
    private var appearanceTask: Task<Void, Never>?
    private var interactionTask: Task<Void, Never>?
    private var appearanceRequestID: UUID?
    private var interactionRequestID: UUID?

    nonisolated init(storage: any ReaderSettingsStorage) {
        self.storage = storage
    }

    func readingAppearance() async throws -> ReadingAppearance {
        while let pending = appearanceTask { await pending.value }
        return try await storage.readingAppearance()
    }

    func readingInteraction() async throws -> ReadingInteraction {
        while let pending = interactionTask { await pending.value }
        return try await storage.readingInteraction()
    }

    func saveAppearance(_ value: ReadingAppearance, owner: UUID) {
        let requestID = UUID()
        appearanceRequestID = requestID
        let previous = appearanceTask
        let storage = storage
        appearanceTask = Task { [weak self] in
            await previous?.value
            let errorMessage: String?
            do { try await storage.saveReadingAppearance(value); errorMessage = nil }
            catch { errorMessage = error.localizedDescription }
            guard let self, self.appearanceRequestID == requestID else { return }
            self.appearanceTask = nil
            self.appearanceCompletion = Completion(owner: owner, errorMessage: errorMessage)
        }
    }

    func saveInteraction(_ value: ReadingInteraction, owner: UUID) {
        let requestID = UUID()
        interactionRequestID = requestID
        let previous = interactionTask
        let storage = storage
        interactionTask = Task { [weak self] in
            await previous?.value
            let errorMessage: String?
            do { try await storage.saveReadingInteraction(value); errorMessage = nil }
            catch { errorMessage = error.localizedDescription }
            guard let self, self.interactionRequestID == requestID else { return }
            self.interactionTask = nil
            self.interactionCompletion = Completion(owner: owner, errorMessage: errorMessage)
        }
    }

    /// Include writes queued while suspended in either lane, rather than returning
    /// after an obsolete snapshot of just one of the queues has completed.
    func flush() async {
        while appearanceTask != nil || interactionTask != nil {
            let appearance = appearanceTask
            let interaction = interactionTask
            await appearance?.value
            await interaction?.value
        }
    }
}
