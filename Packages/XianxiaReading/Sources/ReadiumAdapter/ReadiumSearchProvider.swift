import Foundation
import ReadiumShared
import ReadingInterfaces
import XianxiaCore

actor ReadiumSearchProvider: ReaderSearchProviding {
    private let publication: Publication
    private let bookID: UUID
    private let txtPlan: TXTReadingPlan?

    init(publication: Publication, bookID: UUID, txtPlan: TXTReadingPlan? = nil) {
        self.publication = publication
        self.bookID = bookID
        self.txtPlan = txtPlan
    }

    func search(query: String) async throws -> any ReaderSearchSession {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty, query.count <= ReaderSearchLimits.queryCharacters else {
            throw ReaderSearchError.invalidQuery
        }
        try Task.checkCancellation()
        let iterator = try await publication.search(query: query,
            options: .init(caseSensitive: false, diacriticSensitive: true, exact: true,
                           regularExpression: false)).get()
        try Task.checkCancellation()
        return ReadiumSearchSession(publication: publication, iterator: iterator, bookID: bookID, txtPlan: txtPlan)
    }
}

actor ReadiumSearchSession: ReaderSearchSession {
    // SearchService uses Weak<Publication>; keep resources alive for the cursor's lifetime.
    private var publication: Publication?
    private var iterator: (any SearchIterator)?
    private let bookID: UUID
    private let txtPlan: TXTReadingPlan?
    private var work: Task<LocatorCollection?, Error>?
    private var cancelled = false

    init(publication: Publication?, iterator: any SearchIterator, bookID: UUID, txtPlan: TXTReadingPlan? = nil) {
        self.publication = publication
        self.iterator = iterator
        self.bookID = bookID
        self.txtPlan = txtPlan
    }

    func next() async throws -> [ReaderSearchHit]? {
        guard !cancelled else { throw CancellationError() }
        guard work == nil else { throw ReaderSearchError.busy }
        guard let iterator else { return nil }
        try Task.checkCancellation()
        let task = Task {
            try Task.checkCancellation()
            let page = try await iterator.next().get()
            try Task.checkCancellation()
            return page
        }
        work = task
        defer { work = nil }
        let page: LocatorCollection?
        do {
            page = try await withTaskCancellationHandler(operation: { try await task.value },
                                                        onCancel: { task.cancel() })
            try Task.checkCancellation()
            guard !cancelled else { throw CancellationError() }
        } catch {
            self.iterator = nil
            publication = nil
            if cancelled || Task.isCancelled { throw CancellationError() }
            throw error
        }
        guard let page else { self.iterator = nil; publication = nil; return nil }
        return try page.locators.map { locator in
            let position: ReadingPosition
            if let txtPlan { position = try TXTPositionCodec.encode(locator, bookID: bookID, plan: txtPlan) }
            else { position = try ReadiumPositionCodec.encode(locator, bookID: bookID) }
            return ReaderSearchHit(title: locator.title ?? "正文", before: locator.text.before ?? "",
                            highlight: locator.text.highlight ?? "", after: locator.text.after ?? "",
                            position: position)
        }
    }

    func cancel() {
        cancelled = true
        work?.cancel()
        iterator = nil
        publication = nil
    }
}
