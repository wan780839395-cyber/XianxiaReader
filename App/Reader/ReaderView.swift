import ReadingInterfaces
import SwiftUI
import UIKit
import XianxiaCore

#if DEBUG
private let readerPresentationDiagnosticsEnabled = true
#else
private let readerPresentationDiagnosticsEnabled = false
#endif

@MainActor struct ReaderView: View {
    let book: Book
    let onReturnToLibrary: (() -> Void)?
    @StateObject private var model: ReaderViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.libraryReduceMotionRequested) private var requestedReduceMotion
    @State private var showContents = false
    @State private var showBookmarks = false
    @State private var showSearch = false
    @State private var showAppearance = false
    @State private var returningToLibrary = false
    @State private var visible = false
    @State private var presentationTrace: [String] = []
    @State private var traceSession = readerPresentationDiagnosticsEnabled ? UUID().uuidString : ""
    @EnvironmentObject private var fontInbox: FontDocumentInbox

    init(book: Book, services: AppServices, factory: any ReaderEngineFactory, onReturnToLibrary: (() -> Void)? = nil) {
        self.book = book
        self.onReturnToLibrary = onReturnToLibrary
        _model = StateObject(wrappedValue: ReaderViewModel(book: book, services: services, factory: factory))
    }

    var body: some View {
        ZStack {
            if let engine = model.engine {
                ReaderSurface(viewController: engine.viewController, pageColor: model.appearance.theme.background)
                    .accessibilityAction(named: "显示阅读菜单") { model.menuVisible = true }
            }
            if let failure = model.openFailure {
                VStack(spacing: 16) {
                    Image(systemName: "book.closed").font(.largeTitle)
                    Text("书籍无法打开").font(.headline)
                    Text(failure).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    Button("重试") { Task { await model.retryOpen() } }
                }.padding(32)
            } else if !model.isReady && !returningToLibrary {
                ProgressView(model.openStatus).accessibilityIdentifier("reader.open.status")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            // Menu geometry follows the reader viewport, independently of
            // transient publication/loading content in the surface below it.
            ReaderMenuView(book: book, model: model, returnToLibrary: {
                guard !returningToLibrary else { return }
                returningToLibrary = true
                Task {
                    await model.saveNow(source: .returnToLibrary)
                    guard visible else { return }
                    if let failure = model.settingsSaveFailure {
                        returningToLibrary = false; model.errorMessage = failure
                    } else {
                        // Preserve the rendered page during native dismissal.
                        // onDisappear closes and invalidates this session.
                        if let onReturnToLibrary { onReturnToLibrary() } else { dismiss() }
                    }
                }
            }, showContents: { showContents = true }, showBookmarks: { showBookmarks = true },
               showSearch: { showSearch = true }, showAppearance: {
                tracePresentation("settings.tap")
                showAppearance = true
                tracePresentation("settings.requested")
            }, returningToLibrary: returningToLibrary)
        }
        .background(model.appearance.theme.background)
        .tint(ReaderPalette(theme: model.appearance.theme).accent)
        .readerColorScheme(model.appearance.theme)
        .overlay(alignment: .top) { FontInboxFeedback(inbox: fontInbox) }
        .overlay(alignment: .topLeading) { presentationDiagnostic }
        .sheet(isPresented: $showAppearance, onDismiss: {
            tracePresentation("settings.dismissed")
            guard visible else { return }
            Task {
                await model.saveNow(source: .settingsDismissed)
                guard visible, !returningToLibrary, !showAppearance, model.isReady, scenePhase == .active else { return }
                if let failure = model.positionSaveFailure { model.errorMessage = failure }
            }
        }) {
            ReaderAppearanceView(model: model)
                .onAppear { tracePresentation("settings.content.appeared") }
                .onDisappear { tracePresentation("settings.content.disappeared") }
        }
        .sheet(isPresented: $showContents) {
            ReaderContentsView(chapters: model.chapters, bookTitle: book.title, theme: model.appearance.theme) { chapter in
                showContents = false
                Task { await model.go(to: chapter) }
            }
        }
        .sheet(isPresented: $showBookmarks) {
            ReaderBookmarksView(bookmarks: model.bookmarks, theme: model.appearance.theme,
                                onSelect: { bookmark in
                showBookmarks = false
                Task { await model.go(to: bookmark) }
            }, onDelete: { bookmark in Task { await model.removeBookmark(bookmark) } })
        }
        .sheet(isPresented: $showSearch) {
            if let provider = model.engine?.searchProvider {
                ReaderSearchView(provider: provider, theme: model.appearance.theme,
                                 reduceMotion: model.interaction.reduceMotion) { result in
                    try await model.go(to: result)
                    showSearch = false
                }
            }
        }
        .alert("阅读提示", isPresented: Binding(get: { model.errorMessage != nil },
                                              set: { if !$0 { model.errorMessage = nil } })) {
            Button("知道了") { model.errorMessage = nil }
        } message: { Text(model.errorMessage ?? "") }
        .task {
            visible = true; tracePresentation("reader.appeared")
            model.setAdditionalReduceMotion(requestedReduceMotion); await model.open()
            tracePresentation("reader.open.returned")
        }
        .onChange(of: requestedReduceMotion) { model.setAdditionalReduceMotion($0) }
        .onChange(of: showAppearance) { _ in tracePresentation("settings.binding.changed") }
        .onChange(of: model.navigationInProgress) { _ in tracePresentation("navigation.changed") }
        .onDisappear { tracePresentation("reader.disappeared"); visible = false; model.close() }
        .onChange(of: scenePhase) { phase in
            if phase != .active { model.pauseAutomaticScroll(); Task { await model.saveNow(source: .sceneInactive) } }
        }
    }

    @ViewBuilder private var presentationDiagnostic: some View {
        if readerPresentationDiagnosticsEnabled && ProcessInfo.processInfo.environment["XR_READER_UI_SETTINGS"] == "1" {
            Text(presentationTrace.joined(separator: " | ") + model.saveDiagnosticSummary)
                .font(.system(size: 1)).frame(width: 1, height: 1).clipped().opacity(0.01)
                .allowsHitTesting(false).accessibilityIdentifier("reader.presentation.diagnostic")
        }
    }

    private func tracePresentation(_ event: String) {
        guard readerPresentationDiagnosticsEnabled, ProcessInfo.processInfo.environment["XR_READER_UI_SETTINGS"] == "1" else { return }
        var controller = model.engine?.viewController
        while let parent = controller?.parent { controller = parent }
        let value = "\(traceSession.prefix(8)):\(Int(ProcessInfo.processInfo.systemUptime * 1000)):\(event) requested=\(showAppearance) visible=\(visible) ready=\(model.isReady) navigating=\(model.navigationInProgress) returning=\(returningToLibrary) attached=\(controller?.viewIfLoaded?.window != nil) modal=\(controller?.presentedViewController != nil) presenting=\(controller?.isBeingPresented == true) dismissing=\(controller?.isBeingDismissed == true) transitioning=\(controller?.transitionCoordinator != nil)"
        presentationTrace.append(value)
        if presentationTrace.count > 16 { presentationTrace.removeFirst(presentationTrace.count - 16) }
        NSLog("XRPresentation %@", value)
    }
}
