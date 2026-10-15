import Foundation

extension BookFileStore {
    /// Small JSON on the storage actor; all ancestors and the leaf obey managed-path checks.
    public func readingAppearance() throws -> ReadingAppearance {
        let url = try resolve("Preferences/reading-v1.json")
        let attributes: [FileAttributeKey: Any]
        do { attributes = try manager.attributesOfItem(atPath: url.path) }
        catch let error as CocoaError where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile {
            return ReadingAppearance()
        }
        guard attributes[.type] as? FileAttributeType == .typeRegular else { throw StorageError.unsafePath }
        guard let size = (attributes[.size] as? NSNumber)?.int64Value, size <= 16_384 else {
            throw ReadingAppearanceError.oversizedFile
        }
        return try JSONDecoder().decode(ReadingAppearance.self, from: Data(contentsOf: url)).validated()
    }

    public func saveReadingAppearance(_ value: ReadingAppearance) throws {
        let data = try JSONEncoder().encode(value.validated())
        let directory = try resolve("Preferences")
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = try resolve("Preferences/reading-v1.json")
        try data.write(to: url, options: .atomic)
    }
}
