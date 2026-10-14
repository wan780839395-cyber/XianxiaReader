import Foundation
import ReadiumShared
import XianxiaCore

struct TXTPreparedPublication {
    let publication: Publication
    let plan: TXTReadingPlan
    let renderer: TXTResourceRenderer
    let reusedReadingPlanCache: Bool
    func locator(_ position: ReadingPosition, bookID: UUID) async throws -> Locator {
        let (locator,anchor,resource) = try TXTPositionCodec.decode(position, bookID: bookID, plan: plan)
        try await renderer.validate(anchor, resource: resource)
        return locator
    }
}

actor TXTReadiumPublicationLoader {
    func open(book: Book, fileURL: URL, storageRoot: URL) async throws -> TXTPreparedPublication {
        let files = try BookFileStore(root: storageRoot)
        guard book.format == .txt, try files.resolve(book.filePath).standardizedFileURL == fileURL.standardizedFileURL else {
            throw EPUBError.invalidURL
        }
        let cache = try TXTIndexCache(storageRoot: files.root)
        let index = try await cache.prepare(source: fileURL, bookID: book.id, encoding: book.txtEncoding ?? .automatic)
        let reading = try await TXTReadingPlanCache(storageRoot: files.root).prepare(index: index)
        let plan = reading.plan
        try Task.checkCancellation()
        let renderer = TXTResourceRenderer(files: files, index: index)
        let order = plan.resources.map { Link(href: $0.href, mediaType: .xhtml, title: $0.chapter.title) }
        let toc = index.chapters.compactMap { chapter -> Link? in
            guard let resource = plan.firstResource(chapterID: chapter.id) else { return nil }
            return Link(href: resource.href, mediaType: .xhtml, title: chapter.title)
        }
        let metadata = Metadata(identifier: book.id.uuidString, conformsTo: [.epub], title: book.title,
                                languages: ["zh-Hans"], layout: .reflowable, readingProgression: .ltr)
        let services = PublicationServicesBuilder(
            content: DefaultContentService.makeFactory(resourceContentIteratorFactories: [HTMLResourceContentIterator.Factory()]),
            positions: PerResourcePositionsService.makeFactory(fallbackMediaType: .xhtml),
            search: SafeTextSearchService.makeFactory())
        let publication = Publication(manifest: Manifest(metadata: metadata, readingOrder: order, tableOfContents: toc),
            container: TXTReadiumContainer(plan: plan, renderer: renderer), servicesBuilder: services)
        return TXTPreparedPublication(publication: publication, plan: plan, renderer: renderer, reusedReadingPlanCache: reading.reusedCache)
    }
}

private struct TXTReadiumContainer: Container {
    let sourceURL: AbsoluteURL? = nil
    let entries: Set<AnyURL>
    let resources: [String:TXTReadingResource]
    let renderer: TXTResourceRenderer
    init(plan: TXTReadingPlan, renderer: TXTResourceRenderer) {
        resources = Dictionary(uniqueKeysWithValues: plan.resources.map { ($0.href,$0) })
        entries = Set(plan.resources.compactMap { AnyURL(string: $0.href) })
        self.renderer = renderer
    }
    subscript(url: any URLConvertible) -> (any Resource)? {
        guard let resource = resources[url.anyURL.removingQuery().removingFragment().string] else { return nil }
        // DataResource is scoped to one request/window, never a retained whole-book resource map.
        return DataResource {
            do { return .success(try await renderer.render(resource)) }
            catch { return .failure(.decoding(error)) }
        }
    }
}
