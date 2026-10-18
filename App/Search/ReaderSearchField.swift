import SwiftUI
import UIKit

/// Give the actual native text field a 44pt minimum, including its AX/hit frame.
/// A SwiftUI frame around TextField can leave its editable native element at 22pt.
@MainActor struct ReaderSearchField: UIViewRepresentable {
    @Binding var text: String
    @Binding var focused: Bool
    let palette: ReaderPalette
    var prompt = "搜索书中关键词"
    var fieldIdentifier = "reader.search.query"
    let onSubmit: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.borderStyle = .none
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .search
        field.contentVerticalAlignment = .center
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        field.accessibilityIdentifier = fieldIdentifier
        field.accessibilityLabel = prompt
        field.delegate = context.coordinator
        field.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return field
    }

    func updateUIView(_ field: UITextField, context: Context) {
        context.coordinator.parent = self
        field.accessibilityIdentifier = fieldIdentifier
        field.accessibilityLabel = prompt
        // Keep the active Chinese input composition and caret intact. External
        // clear is intentional and may also discard the marked composition.
        if field.text != text && (text.isEmpty || field.markedTextRange == nil) { field.text = text }
        field.font = .preferredFont(forTextStyle: .body)
        field.textColor = UIColor(palette.text)
        field.tintColor = UIColor(palette.accent)
        field.keyboardAppearance = palette.theme.isDark ? .dark : .light
        field.attributedPlaceholder = NSAttributedString(string: prompt, attributes: [
            .foregroundColor: UIColor(palette.secondaryText)
        ])
        if focused && !field.isFirstResponder && field.window != nil { field.becomeFirstResponder() }
        else if !focused && field.isFirstResponder { field.resignFirstResponder() }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextField, context: Context) -> CGSize? {
        CGSize(width: proposal.width ?? 160, height: max(44, (uiView.font?.lineHeight ?? 22) + 16))
    }

    static func dismantleUIView(_ field: UITextField, coordinator: Coordinator) {
        field.delegate = nil
        field.removeTarget(coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        field.resignFirstResponder()
    }

    @MainActor final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: ReaderSearchField
        init(parent: ReaderSearchField) { self.parent = parent }

        @objc func textChanged(_ field: UITextField) { parent.text = field.text ?? "" }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            if !parent.focused { parent.focused = true }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            if parent.focused { parent.focused = false }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            parent.onSubmit()
            return true
        }
    }
}
