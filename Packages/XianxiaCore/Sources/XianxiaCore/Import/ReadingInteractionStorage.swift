import Foundation

extension BookFileStore {
    public func readingInteraction() throws -> ReadingInteraction {
        let url = try resolve("Preferences/interaction-v1.json")
        let attributes: [FileAttributeKey: Any]
        do { attributes = try manager.attributesOfItem(atPath: url.path) }
        catch let error as CocoaError where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile {
            return ReadingInteraction()
        }
        guard attributes[.type] as? FileAttributeType == .typeRegular else { throw StorageError.unsafePath }
        guard let size = (attributes[.size] as? NSNumber)?.int64Value, size <= 16_384 else {
            throw ReadingAppearanceError.oversizedFile
        }
        return try JSONDecoder().decode(ReadingInteraction.self, from: Data(contentsOf: url)).validated()
    }

    public func saveReadingInteraction(_ value: ReadingInteraction) throws {
        let data = try JSONEncoder().encode(value.validated())
        try manager.createDirectory(at: resolve("Preferences"), withIntermediateDirectories: true)
        let url = try resolve("Preferences/interaction-v1.json")
        try data.write(to: url, options: .atomic)
    }
}
