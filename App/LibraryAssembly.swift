import LibraryShelf
import ReadiumAdapter
import SwiftUI
import XianxiaCore

// Concrete SDK/storage composition belongs to the App, outside the shelf feature.
extension SQLiteBookRepository: LibraryRepository {}

extension LibraryViewModel {
    convenience init(services: AppServices, defaults: UserDefaults = .standard) {
        self.init(repository: services.repository, files: services.files,
                  importer: EPUBImportService(repository: services.repository, files: services.files,
                                              metadata: ReadiumPublicationLoader()), defaults: defaults)
    }
}

extension LibraryView {
    init(services: AppServices, model: LibraryViewModel? = nil) {
        self.init(files: services.files, model: model ?? LibraryViewModel(services: services), readerDestination: { book, dismiss in
            AnyView(ReaderView(book: book, services: services,
                               factory: ReadiumEngineFactory(storageRoot: services.files.root), onReturnToLibrary: dismiss))
        })
    }
}
