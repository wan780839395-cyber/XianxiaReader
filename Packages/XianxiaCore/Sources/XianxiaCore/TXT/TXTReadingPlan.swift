import Foundation

public struct TXTReadingResource: Equatable, Sendable {
    public let href: String
    public let chapter: Chapter
    public let startByte: Int64
    public let endByte: Int64
}

public struct TXTReadingPlan: Sendable {
    public static let version = 1
    public static let resourceBytes = 64 * 1024
    public let index: TXTPreparedIndex
    public let resources: [TXTReadingResource]

    public func resource(href: String) -> TXTReadingResource? { resources.first { $0.href == href } }
    public func firstResource(chapterID: String) -> TXTReadingResource? { resources.first { $0.chapter.id == chapterID } }
}

/// Generates only lightweight range metadata; never retains all chapter bodies.
public actor TXTReadingPlanner {
    private let reader = TXTChapterWindowReader()
    public init() {}
    public func build(index: TXTPreparedIndex, file: URL) async throws -> TXTReadingPlan {
        var resources: [TXTReadingResource] = []
        for chapter in index.chapters where chapter.startByte != nil {
            var offset: Int64 = 0
            while true {
                try Task.checkCancellation()
                let window = try await reader.read(file: file, chapter: chapter, localByteOffset: offset,
                                                   maximumBytes: TXTReadingPlan.resourceBytes)
                guard window.endByte > window.startByte else { throw TXTProcessingError.invalidChapterRange }
                resources.append(TXTReadingResource(href: "txt-v\(TXTReadingPlan.version)/\(index.normalizedSHA256)/b\(window.startByte).xhtml",
                    chapter: chapter, startByte: window.startByte, endByte: window.endByte))
                if window.isEndOfChapter { break }
                offset = window.nextLocalByteOffset
            }
        }
        guard !resources.isEmpty else { throw TXTProcessingError.emptyText }
        return TXTReadingPlan(index: index, resources: resources)
    }
}

/// A source-bound byte/text anchor complements the engine's opaque full Locator.
public struct TXTReadingAnchor: Codable, Equatable, Sendable {
    public let version: Int
    public let parserVersion: Int
    public let normalizerVersion: Int
    public let codecIdentifier: String
    public let sourceSHA256: String
    public let normalizedSHA256: String
    public let chapterID: String
    public let resourceStartByte: Int64
    public let resourceEndByte: Int64
    public let paragraphStartByte: Int64
    public let characterUTF16Offset: Int

    public init(plan: TXTReadingPlan, resource: TXTReadingResource, paragraphStartByte: Int64, characterUTF16Offset: Int) {
        version = TXTReadingPlan.version
        parserVersion = TXTChapterHeadingRecognizer.parserVersion
        normalizerVersion = TXTNormalizer.version
        codecIdentifier = TXTNormalizer.codecIdentifier
        sourceSHA256 = plan.index.sourceSHA256
        normalizedSHA256 = plan.index.normalizedSHA256
        chapterID = resource.chapter.id
        resourceStartByte = resource.startByte; resourceEndByte = resource.endByte
        self.paragraphStartByte = paragraphStartByte; self.characterUTF16Offset = characterUTF16Offset
    }
    public func isValid(plan: TXTReadingPlan, resource: TXTReadingResource) -> Bool {
        version == TXTReadingPlan.version && sourceSHA256 == plan.index.sourceSHA256
            && parserVersion == TXTChapterHeadingRecognizer.parserVersion && normalizerVersion == TXTNormalizer.version
            && codecIdentifier == TXTNormalizer.codecIdentifier
            && normalizedSHA256 == plan.index.normalizedSHA256 && chapterID == resource.chapter.id
            && resourceStartByte == resource.startByte && resourceEndByte == resource.endByte
            && paragraphStartByte >= resource.startByte && paragraphStartByte < resource.endByte
            && characterUTF16Offset >= 0 && characterUTF16Offset <= TXTReadingPlan.resourceBytes
    }
}
