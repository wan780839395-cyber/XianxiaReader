import Foundation
import ReadingInterfaces
import SwiftUI

@MainActor final class ReaderSearchViewModel: ObservableObject {
    @Published private(set) var query = ""
    @Published private(set) var results: [ReaderSearchHit] = []
    @Published private(set) var isLoading = false
    @Published private(set) var canLoadMore = false
    @Published private(set) var didSearch = false
    @Published private(set) var errorMessage: String?
    var reachedLimit: Bool { results.count >= ReaderSearchLimits.displayedResults }

    private let provider: any ReaderSearchProviding
    private let onSelect: (ReaderSearchHit) async throws -> Void
    private var task: Task<Void, Never>?
    private var session: (any ReaderSearchSession)?
    private var requestID: UUID?

    init(provider: any ReaderSearchProviding, onSelect: @escaping (ReaderSearchHit) async throws -> Void) {
        self.provider = provider
        self.onSelect = onSelect
    }

    func setQuery(_ value: String) {
        guard query != value else { return }
        cancel()
        query = value
    }

    func search() {
        let keyword = query.trimmingCharacters(in: .whitespacesAndNewlines)
        cancel()
        guard !keyword.isEmpty, keyword.count <= ReaderSearchLimits.queryCharacters else {
            errorMessage = ReaderSearchError.invalidQuery.localizedDescription
            return
        }
        let id = UUID()
        requestID = id
        isLoading = true
        didSearch = true
        task = Task {
            do {
                let session = try await provider.search(query: keyword)
                guard !Task.isCancelled, requestID == id else { await session.cancel(); return }
                self.session = session
                await receiveNext(from: session, requestID: id)
            } catch {
                guard !Task.isCancelled, requestID == id else { return }
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    func loadMore() {
        guard !isLoading, canLoadMore, !reachedLimit, let session, let id = requestID else { return }
        isLoading = true
        errorMessage = nil
        task = Task { await receiveNext(from: session, requestID: id) }
    }

    func cancel() {
        requestID = nil
        task?.cancel()
        task = nil
        if let session { Task { await session.cancel() } }
        session = nil
        isLoading = false
        canLoadMore = false
        didSearch = false
        results = []
        errorMessage = nil
    }

    func select(_ result: ReaderSearchHit) async {
        guard !isLoading, results.contains(where: { $0.id == result.id }), let id = requestID else { return }
        do { try await onSelect(result) }
        catch {
            guard requestID == id else { return }
            errorMessage = "无法打开这个搜索结果：\(error.localizedDescription)"
        }
    }

    private func receiveNext(from session: any ReaderSearchSession, requestID id: UUID) async {
        do {
            let page = try await session.next()
            guard !Task.isCancelled, requestID == id else { await session.cancel(); return }
            isLoading = false
            if let page {
                let remaining = ReaderSearchLimits.displayedResults - results.count
                results.append(contentsOf: page.prefix(remaining))
                canLoadMore = !reachedLimit
                if reachedLimit { self.session = nil; await session.cancel() }
            } else {
                canLoadMore = false
                self.session = nil
                await session.cancel()
            }
        } catch {
            guard !Task.isCancelled, requestID == id else { await session.cancel(); return }
            isLoading = false
            canLoadMore = false
            errorMessage = "搜索未完成：\(error.localizedDescription)"
            self.session = nil
            await session.cancel()
        }
    }
}
