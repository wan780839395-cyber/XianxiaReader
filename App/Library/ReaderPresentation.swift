import Foundation
import XianxiaCore

/// Each opening gets a new identity even when the same book is reopened.
struct ReaderPresentation: Identifiable {
    let id = UUID()
    let book: Book
}
