//
//  Copyright 2026 Readium Foundation. All rights reserved.
//  Use of this source code is governed by the BSD-style license
//  available in the top-level LICENSE file of the project.
//

import Foundation
import ReadiumInternal
import ReadiumShared
import WebKit

/// A generic `WKURLSchemeHandler` that serves files, directories, and
/// arbitrary resources at named routes using a custom URL scheme (e.g.
/// `readium://`).
@MainActor final class WebViewServer: NSObject, WKURLSchemeHandler, Loggable {
    /// The custom scheme used to serve the content.
    let scheme: String

    /// Format sniffer used to infer the media type of served resources.
    let formatSniffer: FormatSniffer

    init(scheme: String, formatSniffer: FormatSniffer) {
        self.scheme = scheme
        self.formatSniffer = formatSniffer
        super.init()
    }

    // MARK: - Route registration

    private enum RouteHandler {
        case file(FileURL)
        case directory(FileURL)
        case resources(@MainActor (RelativeURL) async -> (Resource, MediaType)?)
    }

    /// Registered routes, sorted by reverse alphabetical order to ensure
    /// longest-prefix matching of routes sharing a common prefix.
    private var routes: [(path: String, baseURL: AbsoluteURL, handler: RouteHandler)] = []

    /// Serves a single local file at the given route.
    ///
    /// - Returns: The absolute URL (e.g. `readium://assets/fonts/abc/Font.otf`)
    ///   to the served file.
    @discardableResult
    func serve(file: FileURL, at route: String) -> AbsoluteURL {
        let route = normalizedRoute(route)
        let baseURL = AnyURL(string: "\(scheme)://\(route)")!.absoluteURL!
        insertRoute((path: route, baseURL: baseURL, handler: .file(file)))
        return baseURL
    }

    /// Serves a local directory at the given route.
    ///
    /// All files under the directory are accessible.
    ///
    /// - Returns: The absolute base URL (e.g. `readium://assets/`) to the
    ///   served directory.
    @discardableResult
    func serve(directory: FileURL, at route: String) -> AbsoluteURL {
        let route = normalizedRoute(route, isDirectory: true)
        let baseURL = AnyURL(string: "\(scheme)://\(route)")!.absoluteURL!
        insertRoute((path: route, baseURL: baseURL, handler: .directory(directory)))
        return baseURL
    }

    /// Serves resources at the given route using a handler callback.
    ///
    /// The handler receives a relative URL and returns a `Resource`, or
    /// `nil` for 404. Returned resources are automatically wrapped in a
    /// `BufferingResource` cache.
    ///
    /// Returns the base URL (e.g. `readium://{uuid}/`).
    @discardableResult
    func serve(at route: String, handler: @escaping @MainActor (RelativeURL) async -> (Resource, MediaType)?) -> AbsoluteURL {
        let route = normalizedRoute(route, isDirectory: true)
        let baseURL = AnyURL(string: "\(scheme)://\(route)")!.absoluteURL!
        insertRoute((path: route, baseURL: baseURL, handler: .resources(handler)))
        return baseURL
    }

    /// Removes the handler at the given route.
    func remove(at route: String) {
        let route = normalizedRoute(route)
        routes.removeAll { $0.path.hasPrefix(route) }
    }

    private func normalizedRoute(_ route: String, isDirectory: Bool = false) -> String {
        var r = route.removingPrefix("/")
        if isDirectory {
            r = r.addingSuffix("/")
        }
        return r
    }

    private func insertRoute(_ entry: (path: String, baseURL: AbsoluteURL, handler: RouteHandler)) {
        // Remove any existing route with the same path.
        routes.removeAll { $0.path == entry.path }
        routes.append(entry)
        // Reverse alphabetical order ensures longest-prefix matching:
        // routes sharing a common prefix are grouped with longer ones first.
        routes.sort { $0.path > $1.path }
    }

    // MARK: - Active tasks & caching

    /// Tracks active tasks for cancellation support.
    private var activeTasks: [ObjectIdentifier: Task<Void, Never>] = [:]

    /// Bounded cache of buffered resources keyed by publication-relative URL.
    ///
    /// Reusing the same ``Resource`` across requests lets compressed ZIP
    /// resources benefit from forward-seek optimization instead of
    /// decompressing from offset 0 on every request.
    ///
    /// Oldest entries are evicted when the cache exceeds its capacity.
    private var resourceCache = BoundedResourceCache()

    // Nil opaque storage in Release; access is confined to the DEBUG extension.
    private var loadingRequestObservationStorage: AnyObject?

    /// Removes cached resources matching the given predicate, forcing them to
    /// be re-served on the next request.
    func clearResourceCache(where predicate: (RelativeURL, MediaType) -> Bool) {
        resourceCache.remove(where: predicate)
    }

    // MARK: - WKURLSchemeHandler

    func webView(_ webView: WKWebView, start urlSchemeTask: any WKURLSchemeTask) {
        let taskID = ObjectIdentifier(urlSchemeTask)
        #if DEBUG
            loadingRequests.start(task: taskID, web: ObjectIdentifier(webView), url: urlSchemeTask.request.url)
        #endif
        activeTasks[taskID] = Task {
            await serve(urlSchemeTask)
            _ = activeTasks.removeValue(forKey: taskID)
            #if DEBUG
                loadingRequests.returned(task: taskID, cancelled: Task.isCancelled)
            #endif
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: any WKURLSchemeTask) {
        let taskID = ObjectIdentifier(urlSchemeTask)
        activeTasks.removeValue(forKey: taskID)?.cancel()
        #if DEBUG
            loadingRequests.note(task: taskID, phase: .stopSeen)
        #endif
    }

    // MARK: - Serving

    private func serve(_ urlSchemeTask: WKURLSchemeTask) async {
        guard let requestURL = urlSchemeTask.request.url else {
            await fail(urlSchemeTask, with: URLError(.badURL))
            return
        }

        // Find the matching route (longest prefix wins).
        for route in routes {
            switch route.handler {
            case let .file(file):
                guard route.baseURL.isEquivalentTo(requestURL) else {
                    continue
                }
                #if DEBUG
                    loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .routeFile)
                #endif
                await serveFile(urlSchemeTask, at: file, requestURL: requestURL, allowCrossOrigin: true)
                return

            case let .directory(directory):
                guard
                    let relativeURL = route.baseURL.relativize(requestURL),
                    let file = directory.resolve(relativeURL)?.fileURL,
                    directory.isParent(of: file)
                else {
                    continue
                }
                #if DEBUG
                    loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .routeDirectory)
                #endif
                await serveFile(urlSchemeTask, at: file, requestURL: requestURL, allowCrossOrigin: true)
                return

            case let .resources(handler):
                guard let relativeURL = route.baseURL.relativize(requestURL) else {
                    continue
                }
                #if DEBUG
                    loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .routePublication)
                #endif
                await serveResource(
                    urlSchemeTask,
                    relativeURL: relativeURL,
                    handler: handler,
                    requestURL: requestURL
                )
                return
            }
        }

        await fail(urlSchemeTask, with: URLError(.fileDoesNotExist))
    }

    /// Serves a resource from a handler callback, with caching.
    private func serveResource(
        _ urlSchemeTask: WKURLSchemeTask,
        relativeURL: RelativeURL,
        handler: @MainActor (RelativeURL) async -> (Resource, MediaType)?,
        requestURL: URL
    ) async {
        // Reuse a cached buffered resource to benefit from forward-seek
        // optimization and read-ahead buffering, or create and cache a new
        // one.
        let resource: Resource
        let mediaType: MediaType
        if let (cachedResource, cachedMediaType) = resourceCache[relativeURL] {
            #if DEBUG
                loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .cacheHit)
            #endif
            resource = cachedResource
            mediaType = cachedMediaType
        } else {
            #if DEBUG
                loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .handlerAwait)
            #endif
            guard let (newResource, newMediaType) = await handler(relativeURL) else {
                await fail(urlSchemeTask, with: URLError(.fileDoesNotExist))
                return
            }
            resource = newResource.buffered(size: 256 * 1024)
            mediaType = newMediaType
            resourceCache.set(relativeURL, resource: resource, mediaType: mediaType)
        }

        #if DEBUG
            loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .resourceReady)
        #endif

        await serveResource(
            resource,
            with: urlSchemeTask,
            mediaType: mediaType,
            requestURL: requestURL
        )
    }

    /// Reads a local file and sends it as a response.
    ///
    /// Local files are served for the static assets routes (Readium assets
    /// and font files), which publication documents load cross-origin —
    /// hence `allowCrossOrigin`.
    private func serveFile(
        _ urlSchemeTask: WKURLSchemeTask,
        at file: FileURL,
        requestURL: URL,
        allowCrossOrigin: Bool
    ) async {
        await serveResource(
            FileResource(file: file),
            with: urlSchemeTask,
            mediaType: mediaTypeFromURL(file),
            requestURL: requestURL,
            allowCrossOrigin: allowCrossOrigin
        )
    }

    private func serveResource(
        _ resource: Resource,
        with urlSchemeTask: WKURLSchemeTask,
        mediaType: MediaType?,
        requestURL: URL,
        allowCrossOrigin: Bool = false
    ) async {
        // Try to serve a byte range if the client requested one and the
        // resource length is known.
        #if DEBUG
            loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .lengthAwait)
        #endif
        if
            let totalLength = await (try? resource.estimatedLength().get()).flatMap({ $0 }),
            let range = urlSchemeTask.request.byteRange(in: totalLength)
        {
            #if DEBUG
                loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .rangeReadAwait)
            #endif
            let result = await resource.read(range: range)
            switch result {
            case let .success(data):
                #if DEBUG
                    loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .readReturned, bytes: data.count)
                #endif
                await respond(urlSchemeTask, with: data, range: range, totalLength: totalLength, mediaType: mediaType, url: requestURL, allowCrossOrigin: allowCrossOrigin)
            case let .failure(error):
                #if DEBUG
                    loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .readFailure, error: error as NSError)
                #endif
                log(.error, "Failed to read resource \(requestURL.path) range \(range): \(error)")
                await fail(urlSchemeTask, with: URLError(.resourceUnavailable))
            }
            return
        }

        // Full read fallback.
        #if DEBUG
            loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .readAwait)
        #endif
        let result = await resource.read()
        switch result {
        case let .success(data):
            #if DEBUG
                loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .readReturned, bytes: data.count)
            #endif
            await respond(urlSchemeTask, with: data, range: nil, totalLength: UInt64(data.count), mediaType: mediaType, url: requestURL, allowCrossOrigin: allowCrossOrigin)
        case let .failure(error):
            #if DEBUG
                loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .readFailure, error: error as NSError)
            #endif
            log(.error, "Failed to read resource \(requestURL.path): \(error)")
            await fail(urlSchemeTask, with: URLError(.resourceUnavailable))
        }
    }

    private func mediaTypeFromURL(_ url: URLConvertible) -> MediaType? {
        guard let ext = url.anyURL.pathExtension else {
            return nil
        }
        return formatSniffer.sniffHints(FormatHints(fileExtension: ext))?.mediaType
    }

    // MARK: - Response helpers

    /// Sends data as a response, optionally as a 206 Partial Content when a
    /// byte range was requested.
    ///
    /// - Parameters:
    ///   - range: The byte range being served, or `nil` for a full 200
    ///     response.
    ///   - totalLength: The total size of the resource (used in
    ///     `Content-Range`).
    private func respond(
        _ urlSchemeTask: WKURLSchemeTask,
        with data: Data,
        range: Range<UInt64>?,
        totalLength: UInt64,
        mediaType: MediaType?,
        url: URL,
        allowCrossOrigin: Bool
    ) async {
        var headers: [String: String] = [
            "Content-Length": "\(data.count)",
            "Accept-Ranges": "bytes",
        ]

        if allowCrossOrigin {
            // Static assets (e.g. fonts declared with
            // `fontFamilyDeclarations`) are served under a different origin
            // than the publication documents referencing them
            // (readium://assets vs readium://{uuid}). Unlike stylesheets or
            // images, font fetches are CORS-gated by WebKit, so fonts never
            // load without this header. Mirrors `allowCors()` in the Kotlin
            // toolkit's WebViewServer. See issue #802.
            headers["Access-Control-Allow-Origin"] = "*"
        }

        if let mediaType {
            headers["Content-Type"] = mediaType.string
        }

        let statusCode: Int
        if let range = range {
            statusCode = 206
            headers["Content-Range"] = "bytes \(range.lowerBound)-\(range.upperBound - 1)/\(totalLength)"
        } else {
            statusCode = 200
        }

        guard let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        ) else {
            await fail(urlSchemeTask, with: URLError(.unknown))
            return
        }

        // Guard against task cancellation to avoid calling WKURLSchemeTask
        // methods after WebKit has stopped the task.
        guard !Task.isCancelled else { return }
        #if DEBUG
            loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .responsePrepared, bytes: data.count)
        #endif
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
        #if DEBUG
            loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .finishCalled)
        #endif
    }

    private func fail(_ urlSchemeTask: WKURLSchemeTask, with error: Error) async {
        guard !Task.isCancelled else { return }
        urlSchemeTask.didFailWithError(error)
        #if DEBUG
            loadingRequests.note(task: ObjectIdentifier(urlSchemeTask), phase: .failCalled, error: error as NSError)
        #endif
    }
}

private extension URLRequest {
    /// Parses an HTTP `Range` header value (RFC 7233) into a byte range.
    func byteRange(in totalLength: UInt64) -> Range<UInt64>? {
        Range(httpRange: value(forHTTPHeaderField: "Range") ?? "", in: totalLength)
    }
}

/// A simple bounded FIFO cache for ``Resource`` instances.
///
/// Evicts the oldest entries when the number of cached resources exceeds
/// ``capacity``, preventing unbounded memory growth as the user navigates
/// through chapters.
private struct BoundedResourceCache {
    private let capacity = 8
    private var entries: [RelativeURL: (Resource, MediaType)] = [:]
    private var order: [RelativeURL] = []

    subscript(key: RelativeURL) -> (Resource, MediaType)? {
        entries[key]
    }

    mutating func set(_ key: RelativeURL, resource: Resource, mediaType: MediaType) {
        if entries[key] == nil {
            order.append(key)
        }
        entries[key] = (resource, mediaType)

        while order.count > capacity {
            let evicted = order.removeFirst()
            entries.removeValue(forKey: evicted)
        }
    }

    mutating func remove(where predicate: (RelativeURL, MediaType) -> Bool) {
        let toRemove = order.filter { url in
            entries[url].map { predicate(url, $0.1) } ?? false
        }
        for url in toRemove {
            entries.removeValue(forKey: url)
        }
        order = order.filter { entries[$0] != nil }
    }
}

#if DEBUG
extension WebViewServer {
    private var loadingRequests: LoadingRequestJournal {
        if let journal = loadingRequestObservationStorage as? LoadingRequestJournal { return journal }
        let journal = LoadingRequestJournal()
        loadingRequestObservationStorage = journal
        return journal
    }

    func bindLoadingObservation(_ webView: WKWebView, trace: String, documentURL: URL) {
        loadingRequests.bind(web: ObjectIdentifier(webView), owner: trace, documentURL: documentURL)
    }

    func loadingRequestDiagnostic(_ webView: WKWebView, trace: String) -> String {
        loadingRequests.snapshot(web: ObjectIdentifier(webView), owner: trace)
    }

    func retireLoadingObservation(_ webView: WKWebView, trace: String) {
        loadingRequests.retire(web: ObjectIdentifier(webView), owner: trace)
    }

    func recordLoadingNavigationError(_ webView: WKWebView, trace: String, error: NSError) {
        loadingRequests.navigationError(web: ObjectIdentifier(webView), owner: trace, error: error)
    }

    func recordLoadingProcessTermination(_ webView: WKWebView, trace: String) {
        loadingRequests.processTerminated(web: ObjectIdentifier(webView), owner: trace)
    }
}

// Synchronous, metadata-only observation. Never retains WebKit objects or resource data.
private struct LoadingRequestReceipt: Encodable {
    enum Phase: String, Encodable {
        case started, routeFile, routeDirectory, routePublication, handlerAwait, cacheHit, resourceReady
        case lengthAwait, rangeReadAwait, readAwait, readReturned, readFailure
        case responsePrepared, finishCalled, failCalled, stopSeen, returned
    }
    let request: Int
    let category: String
    let root: Bool
    let startedAfterRetire: Bool
    let startedUptime: Double
    var lastUptime: Double
    var phase: Phase = .started
    var lastEvent: Phase = .started
    var readReturned = false
    var responsePrepared = false
    var finishCalled = false
    var failCalled = false
    var stopSeen = false
    var returned = false
    var cancelledAtReturn = false
    var bytes: Int?
    var firstErrorDomain: String?
    var firstErrorCode: Int?
    var callbackErrorDomain: String?
    var callbackErrorCode: Int?
}

private struct LoadingRequestSnapshot: Encodable {
    let schema = 1
    let scope = "observed-scheme-handler-starts-only"
    let server: String
    let available: Bool
    let ownerTrace: String?
    let webView: String?
    let capturedUptime: Double
    let coverageComplete: Bool
    let retired: Bool
    let rebound: Bool
    let rootRequests: Int
    let droppedRequests: Int
    let evictedOwners: Int
    let unboundStarts: Int
    let navigationErrorDomain: String?
    let navigationErrorCode: Int?
    let processTerminated: Bool
    let requests: [LoadingRequestReceipt]
    let reason: String?
}

@MainActor private final class LoadingRequestJournal {
    static let maximumOwners = 16 // Existing navigator budget is at most 12 live resource views.
    static let maximumRequestsPerOwner = 32 // Overflow is explicit; never evidence of delivery.
    @MainActor private final class Owner {
        let trace: String
        let web: ObjectIdentifier
        // Equality binding only, never encoded or printed; no body/header data is stored.
        let documentURL: URL
        var retired = false
        var rebound = false
        var rootRequests = 0
        var droppedRequests = 0
        var navigationErrorDomain: String?
        var navigationErrorCode: Int?
        var processTerminated = false
        var order: [Int] = []
        var rows: [Int: LoadingRequestReceipt] = [:]
        init(trace: String, web: ObjectIdentifier, documentURL: URL) {
            self.trace = trace; self.web = web; self.documentURL = documentURL
        }
    }
    private let server = UUID().uuidString
    private let clock: () -> Double
    private var bindings: [ObjectIdentifier: String] = [:]
    private var owners: [String: Owner] = [:]
    private var ownerOrder: [String] = []
    private var tasks: [ObjectIdentifier: (owner: String, request: Int)] = [:]
    private var nextRequest = 0
    private var evictedOwners = 0
    private var unboundStarts = 0

    init(clock: @escaping () -> Double = { ProcessInfo.processInfo.systemUptime }) { self.clock = clock }

    private static func documentIdentity(_ url: URL) -> URL {
        if var parts = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            parts.fragment = nil
            if let clean = parts.url { return clean }
        }
        return url
    }

    func bind(web: ObjectIdentifier, owner: String, documentURL: URL) {
        guard UUID(uuidString: owner) != nil else { return }
        let url = Self.documentIdentity(documentURL)
        if let previous = owners[owner] {
            if previous.web != web || previous.documentURL != url { previous.rebound = true }
            return
        }
        if ownerOrder.count == Self.maximumOwners {
            let oldest = ownerOrder.removeFirst()
            if let old = owners.removeValue(forKey: oldest), bindings[old.web] == oldest {
                bindings.removeValue(forKey: old.web)
            }
            tasks = tasks.filter { $0.value.owner != oldest }
            evictedOwners += 1
        }
        owners[owner] = Owner(trace: owner, web: web, documentURL: url)
        ownerOrder.append(owner); bindings[web] = owner
    }

    private static func category(_ url: URL?) -> String {
        switch url?.pathExtension.lowercased() {
        case "xhtml", "html", "htm": return "document"
        case "css": return "css"
        case "js": return "js"
        case "ttf", "otf", "woff", "woff2": return "font"
        case "png", "jpg", "jpeg", "gif", "svg", "webp": return "image"
        default: return "other"
        }
    }

    func start(task: ObjectIdentifier, web: ObjectIdentifier, url: URL?) {
        guard let trace = bindings[web], let owner = owners[trace] else { unboundStarts += 1; return }
        if let old = tasks.removeValue(forKey: task) { owners[old.owner]?.droppedRequests += 1 }
        let root = url.map { Self.documentIdentity($0) == owner.documentURL } ?? false
        if root { owner.rootRequests += 1 }
        guard owner.order.count < Self.maximumRequestsPerOwner else { owner.droppedRequests += 1; return }
        nextRequest += 1
        let now = clock()
        owner.rows[nextRequest] = LoadingRequestReceipt(request: nextRequest, category: Self.category(url),
            root: root, startedAfterRetire: owner.retired, startedUptime: now, lastUptime: now)
        owner.order.append(nextRequest); tasks[task] = (trace, nextRequest)
    }

    private static func safeDomain(_ error: NSError) -> String {
        switch error.domain {
        case "NSCocoaErrorDomain", "NSURLErrorDomain", "NSPOSIXErrorDomain", "WKErrorDomain", "ReadiumShared.ReadError": return error.domain
        default: return "other"
        }
    }

    func note(task: ObjectIdentifier, phase: LoadingRequestReceipt.Phase, bytes: Int? = nil, error: NSError? = nil) {
        guard let key = tasks[task], let owner = owners[key.owner], var row = owner.rows[key.request] else { return }
        row.lastEvent = phase; row.lastUptime = clock()
        if phase != .stopSeen && phase != .returned { row.phase = phase }
        if let bytes { row.bytes = bytes }
        switch phase {
        case .readReturned: row.readReturned = true
        case .responsePrepared: row.responsePrepared = true
        case .finishCalled: row.finishCalled = true
        case .failCalled: row.failCalled = true
        case .stopSeen: row.stopSeen = true
        case .returned: row.returned = true
        default: break
        }
        if let error {
            if row.firstErrorDomain == nil { row.firstErrorDomain = Self.safeDomain(error); row.firstErrorCode = error.code }
            if phase == .failCalled { row.callbackErrorDomain = Self.safeDomain(error); row.callbackErrorCode = error.code }
        }
        owner.rows[key.request] = row
    }

    func returned(task: ObjectIdentifier, cancelled: Bool) {
        note(task: task, phase: .returned)
        if let key = tasks.removeValue(forKey: task), let owner = owners[key.owner] {
            owner.rows[key.request]?.cancelledAtReturn = cancelled
        }
    }

    func retire(web: ObjectIdentifier, owner trace: String) {
        guard let owner = owners[trace], owner.web == web else { return }
        owner.retired = true
    }

    func navigationError(web: ObjectIdentifier, owner trace: String, error: NSError) {
        guard let owner = owners[trace], owner.web == web, owner.navigationErrorDomain == nil else { return }
        owner.navigationErrorDomain = Self.safeDomain(error); owner.navigationErrorCode = error.code
    }

    func processTerminated(web: ObjectIdentifier, owner trace: String) {
        guard let owner = owners[trace], owner.web == web else { return }
        owner.processTerminated = true
    }

    func snapshot(web: ObjectIdentifier, owner trace: String) -> String {
        let owner = owners[trace].flatMap { $0.web == web ? $0 : nil }
        let value = LoadingRequestSnapshot(server: server, available: owner != nil, ownerTrace: owner?.trace,
            webView: owner.map { String(describing: $0.web) }, capturedUptime: clock(),
            coverageComplete: owner.map { $0.droppedRequests == 0 && !$0.rebound && $0.rootRequests > 0 } ?? false,
            retired: owner?.retired ?? false, rebound: owner?.rebound ?? false,
            rootRequests: owner?.rootRequests ?? 0, droppedRequests: owner?.droppedRequests ?? 0,
            evictedOwners: evictedOwners, unboundStarts: unboundStarts,
            navigationErrorDomain: owner?.navigationErrorDomain, navigationErrorCode: owner?.navigationErrorCode,
            processTerminated: owner?.processTerminated ?? false,
            requests: owner.map { item in item.order.compactMap { item.rows[$0] } } ?? [],
            reason: owner == nil ? "unbound-or-evicted" : nil)
        do {
            let encoder = JSONEncoder(); encoder.outputFormatting = [.sortedKeys]
            return String(decoding: try encoder.encode(value), as: UTF8.self)
        } catch {
            // Evidence failure is explicit; never replace the original load/test outcome.
            return "{\"schema\":1,\"available\":false,\"coverageComplete\":false,\"reason\":\"serialization-failed\"}"
        }
    }
}
#endif
