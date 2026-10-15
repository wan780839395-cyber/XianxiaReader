import SwiftUI

private struct LibraryReduceMotionRequestKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// An additional request may reduce motion; it can never override the system to enable it.
    var libraryReduceMotionRequested: Bool {
        get { self[LibraryReduceMotionRequestKey.self] }
        set { self[LibraryReduceMotionRequestKey.self] = newValue }
    }
}
