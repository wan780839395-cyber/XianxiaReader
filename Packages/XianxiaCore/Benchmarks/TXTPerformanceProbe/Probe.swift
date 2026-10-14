import Dispatch
import Foundation
import XianxiaCore
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

/// Runs in a fresh desktop process per sample. Never loads a book into one String/Data.
@main struct TXTPerformanceProbe {
    struct Expected: Codable {
        struct Boundary: Codable { let title: String; let startByte: Int64; let endByte: Int64 }
        let name: String
        let sourceBytes: Int64
        let sourceSHA256: String
        let normalizedBytes: Int64
        let normalizedSHA256: String
        let chapters: [Boundary]
    }
    struct Reopen: Codable {
        let cacheValidationMilliseconds: Double
        let readingPlanMilliseconds: Double
        let peakRSSBytes: Int64
    }
    struct Report: Codable {
        let sample: Expected
        let operatingSystem: String
        let processorCount: Int
        let configuration: String
        let baselinePeakRSSBytes: Int64
        let coldImportMilliseconds: Double
        let afterImportPeakRSSBytes: Int64
        let directoryQueryMilliseconds: Double
        let reopens: [Reopen]
        let resourceCount: Int
        let maximumWindowBytes: Int
        let visitedBytes: Int64
        let windowTraversalMilliseconds: Double
        let finalPeakRSSBytes: Int64
        let allChecksPassed: Bool
    }
    enum Failure: Error { case arguments, expectation(String), resourceUsage(Int32), debugBuild }
    static func require(_ condition: Bool, _ description: String) throws {
        guard condition else { throw Failure.expectation(description) }
    }
    static func milliseconds(since start: UInt64) -> Double {
        Double(DispatchTime.now().uptimeNanoseconds - start) / 1_000_000
    }
    static func peakRSS() throws -> Int64 {
        var usage = rusage()
        #if canImport(Darwin)
        let status = getrusage(RUSAGE_SELF, &usage)
        let multiplier: Int64 = 1 // Current XNU reports bytes; the archived Apple man page is outdated.
        #else
        let status = getrusage(Int32(RUSAGE_SELF.rawValue), &usage)
        let multiplier: Int64 = 1024 // Linux ru_maxrss is KiB.
        #endif
        guard status == 0 else { throw Failure.resourceUsage(errno) }
        return Int64(usage.ru_maxrss) * multiplier
    }
    static func check(_ index: TXTPreparedIndex, expected: Expected) throws {
        try require(index.sourceSHA256 == expected.sourceSHA256, "Original SHA-256 changed")
        try require(index.normalizedSHA256 == expected.normalizedSHA256, "Normalized SHA-256 mismatch")
        try require(index.normalizedBytes == expected.normalizedBytes, "Normalized byte count mismatch")
        try require(index.chapters.count == expected.chapters.count, "Chapter count mismatch")
        for (actual, boundary) in zip(index.chapters, expected.chapters) {
            try require(actual.title == boundary.title && actual.startByte == boundary.startByte
                && actual.endByte == boundary.endByte, "Chapter title/range mismatch at ordinal \(actual.ordinal)")
        }
    }
    static func main() async throws {
        #if DEBUG
        throw Failure.debugBuild
        #else
        guard CommandLine.arguments.count == 4 else { throw Failure.arguments }
        let source = URL(fileURLWithPath: CommandLine.arguments[1])
        let expected = try JSONDecoder().decode(Expected.self, from: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[2])))
        let output = URL(fileURLWithPath: CommandLine.arguments[3])
        let root = source.deletingLastPathComponent().appendingPathComponent("Imported")
        // The caller owns this fresh temporary directory and deletes it only AFTER this process exits,
        // so a live SQLite actor is never unlinked during teardown.
        let files = try BookFileStore(root: root.appendingPathComponent("Storage"))
        let repository = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        let baseline = try peakRSS()
        var start = DispatchTime.now().uptimeNanoseconds
        let book = try await TXTBookImportService(files: files, repository: repository).importBook(from: source)
        let cold = milliseconds(since: start), afterImport = try peakRSS()
        print("Cold import finished: \(expected.sourceBytes) bytes, \(cold) ms")
        start = DispatchTime.now().uptimeNanoseconds
        let chapters = try await repository.chapters(for: book.id)
        let directory = milliseconds(since: start)
        try require(chapters.count == expected.chapters.count, "Committed directory count mismatch")
        let managedOriginal = try files.resolve(book.filePath)
        var reopens: [Reopen] = [], latestPlan: TXTReadingPlan?
        for iteration in 0..<3 {
            // Fresh actors model a library reopen, with OS file cache left intact.
            let cache = try TXTIndexCache(storageRoot: files.root)
            start = DispatchTime.now().uptimeNanoseconds
            let index = try await cache.prepare(source: managedOriginal, bookID: book.id)
            let validation = milliseconds(since: start)
            try require(index.reusedCache, "Reopen rebuilt a valid cache")
            try check(index, expected: expected)
            try require(index.chapters == chapters, "Cache differs from SQLite directory")
            let normalized = try await cache.normalizedURL(for: index)
            start = DispatchTime.now().uptimeNanoseconds
            let plan = try await TXTReadingPlanner().build(index: index, file: normalized)
            let planning = milliseconds(since: start)
            if let previous = latestPlan { try require(plan.resources == previous.resources, "Resource anchors changed on reopen") }
            latestPlan = plan
            reopens.append(Reopen(cacheValidationMilliseconds: validation, readingPlanMilliseconds: planning, peakRSSBytes: try peakRSS()))
            print("Reopen \(iteration+1): validate \(validation) ms, plan \(planning) ms")
        }
        guard let plan = latestPlan else { throw Failure.expectation("No reading plan") }
        let normalized = try files.resolve(plan.index.normalizedRelativePath)
        let handle = try FileHandle(forReadingFrom: normalized)
        let reader = TXTChapterWindowReader()
        var next: Int64 = 0, maximum = 0
        start = DispatchTime.now().uptimeNanoseconds
        do {
            for resource in plan.resources {
                guard let chapterStart = resource.chapter.startByte else { throw Failure.expectation("Non-leaf resource") }
                let length = resource.endByte - resource.startByte
                try require(resource.startByte == next && length > 0 && length <= Int64(TXTReadingPlan.resourceBytes), "Gap, overlap or unbounded window")
                let window = try await reader.read(file: normalized, chapter: resource.chapter,
                    localByteOffset: resource.startByte-chapterStart, maximumBytes: max(4,Int(length)))
                let bytes = Data(window.text.utf8)
                try handle.seek(toOffset: UInt64(next))
                let reference = try handle.read(upToCount: bytes.count)
                try require(reference == bytes && window.endByte == resource.endByte, "Window changed source bytes")
                maximum = max(maximum, bytes.count); next = window.endByte
            }
            try handle.close()
        } catch {
            let original = error
            do { try handle.close() }
            catch { throw TXTNormalizationError.cleanupFailed(original: String(describing: original), cleanup: String(describing: error)) }
            throw original
        }
        try require(next == expected.normalizedBytes, "Tail bytes lost")
        let report = Report(sample: expected, operatingSystem: ProcessInfo.processInfo.operatingSystemVersionString,
            processorCount: ProcessInfo.processInfo.processorCount, configuration: "Release",
            baselinePeakRSSBytes: baseline, coldImportMilliseconds: cold, afterImportPeakRSSBytes: afterImport,
            directoryQueryMilliseconds: directory, reopens: reopens, resourceCount: plan.resources.count,
            maximumWindowBytes: maximum, visitedBytes: next, windowTraversalMilliseconds: milliseconds(since: start),
            finalPeakRSSBytes: try peakRSS(), allChecksPassed: true)
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted,.sortedKeys]
        try encoder.encode(report).write(to: output, options: .atomic)
        #endif
    }
}
