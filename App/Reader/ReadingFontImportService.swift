import CoreText
import Foundation
import XianxiaCore

/// Font parsing stays off the UI executor. WebKit uses Readium's asset channel;
/// no process-wide font registration or private font API is needed.
actor ReadingFontImportService {
    private let files: BookFileStore
    init(files: BookFileStore) { self.files = files }

    func importFont(from source: URL) async throws -> ReadingFontAsset {
        let scoped = source.startAccessingSecurityScopedResource()
        defer { if scoped { source.stopAccessingSecurityScopedResource() } }
        let staged = try await files.stageReadingFont(from: source)
        do {
            try Task.checkCancellation()
            guard let stream = InputStream(url: staged.fileURL) else { throw ReadingFontError.invalidFont }
            stream.open()
            var signature = [UInt8](repeating: 0, count: 4)
            let count = stream.read(&signature, maxLength: 4)
            stream.close()
            guard count == 4, signature == [0, 1, 0, 0] || signature == [79, 84, 84, 79] else {
                throw ReadingFontError.unsupportedFile
            }
            guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(staged.fileURL as CFURL) as? [CTFontDescriptor],
                  descriptors.count == 1, let descriptor = descriptors.first else { throw ReadingFontError.invalidFont }
            let font = CTFontCreateWithFontDescriptor(descriptor, 18, nil)
            guard CTFontGetGlyphCount(font) > 0 else { throw ReadingFontError.invalidFont }
            let rawName = CTFontCopyFullName(font) as String
            let name = String(String.UnicodeScalarView(rawName.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) })).trimmingCharacters(in: .whitespacesAndNewlines)
            try Task.checkCancellation()
            return try await files.commitReadingFont(staged, displayName: String(name.prefix(80)))
        } catch {
            let original = error
            do { try await files.discardReadingFont(staged) }
            catch { throw StorageError.cleanupFailed(original: original.localizedDescription, cleanup: error.localizedDescription) }
            throw original
        }
    }
}
