import SwiftUI
import UIKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class ReaderSearchFieldTests: XCTestCase {
    @MainActor func testNativeQueryFieldKeepsChineseCompositionAndCaretAcrossThemeThenClears() async throws {
        let state = QueryState()
        let host = UIHostingController(rootView: QueryHarness(state: state))
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previous = scene.windows.first { $0.isKeyWindow }
        let window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        window.rootViewController = host; window.makeKeyAndVisible()
        window.layoutIfNeeded()
        defer { window.isHidden = true; window.rootViewController = nil; previous?.makeKey() }
        XCTAssertTrue(window.isKeyWindow)
        XCTAssertTrue(window.windowScene === scene)
        let field = try await queryField(in: host.view)
        print("Query diagnostic: mounted \(field.bounds), key=\(window.isKeyWindow)")
        XCTAssertGreaterThanOrEqual(field.bounds.height, 44)
        XCTAssertEqual(field.accessibilityIdentifier, "reader.search.query")
        XCTAssertTrue(field.becomeFirstResponder())
        field.insertText("山风"); field.sendActions(for: .editingChanged)
        XCTAssertEqual(state.text, "山风")
        field.setMarkedText("拼音", selectedRange: NSRange(location: 1, length: 0))
        field.sendActions(for: .editingChanged)
        let marked = try XCTUnwrap(field.markedTextRange)
        let selection = try XCTUnwrap(field.selectedTextRange)
        let originalText = field.text
        let markedStart = field.offset(from: field.beginningOfDocument, to: marked.start)
        let caret = field.offset(from: field.beginningOfDocument, to: selection.start)
        state.theme = .charcoal
        try await waitUntil("theme update", diagnostics: { self.describe(field) }) { field.keyboardAppearance == .dark }
        XCTAssertEqual(field.text, originalText)
        XCTAssertEqual(field.offset(from: field.beginningOfDocument, to: try XCTUnwrap(field.markedTextRange).start), markedStart)
        XCTAssertEqual(field.offset(from: field.beginningOfDocument, to: try XCTUnwrap(field.selectedTextRange).start), caret)

        state.text = ""
        try await waitUntil("clear marked text", diagnostics: { self.describe(field) }) { field.text == "" && field.markedTextRange == nil }
        XCTAssertTrue(field.isFirstResponder)
        field.insertText("云海"); field.sendActions(for: .editingChanged)
        XCTAssertEqual(state.text, "云海")
        state.focused = false
        try await waitUntil("end editing", diagnostics: { self.describe(field) }) { !field.isFirstResponder }
        XCTAssertEqual(state.text, "云海")
    }

    @MainActor private func queryField(in view: UIView) async throws -> UITextField {
        @MainActor func find(_ view: UIView) -> UITextField? {
            if let field = view as? UITextField { return field }
            for child in view.subviews {
                if let field = find(child) { return field }
            }
            return nil
        }
        try await waitUntil("native field layout", diagnostics: {
            if let field = find(view) { return self.describe(field) }
            return "No UITextField; host=\(view.bounds), window=\(String(describing: view.window))"
        }) { (find(view)?.bounds.height ?? 0) >= 44 }
        return try XCTUnwrap(find(view))
    }

    @MainActor private func describe(_ field: UITextField) -> String {
        "bounds=\(field.bounds), text=\(String(describing: field.text)), marked=\(String(describing: field.markedTextRange)), focused=\(field.isFirstResponder), keyboard=\(field.keyboardAppearance.rawValue)"
    }

    @MainActor private func waitUntil(_ phase: String, diagnostics: () -> String,
                                     file: StaticString = #filePath, line: UInt = #line,
                                     condition: () -> Bool) async throws {
        print("Query diagnostic waiting: \(phase)")
        for _ in 0..<100 {
            if condition() { print("Query diagnostic passed: \(phase)"); return }
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        print("Query diagnostic failure: \(phase); \(diagnostics())")
        XCTFail("Native query field did not reach \(phase): \(diagnostics())", file: file, line: line)
        throw QueryFailure.timeout
    }
}

private enum QueryFailure: Error { case timeout }

@MainActor private final class QueryState: ObservableObject {
    @Published var text = ""
    @Published var focused = false
    @Published var theme = ReadingTheme.warm
}

@MainActor private struct QueryHarness: View {
    @ObservedObject var state: QueryState
    var body: some View {
        ReaderSearchField(text: $state.text, focused: $state.focused,
                          palette: ReaderPalette(theme: state.theme), onSubmit: {})
            .padding(16)
    }
}
