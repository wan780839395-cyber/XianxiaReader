import SwiftUI
import XianxiaCore

@MainActor struct ReaderMenuView: View {
    let book: Book
    @ObservedObject var model: ReaderViewModel
    let returnToLibrary: () -> Void
    let showContents: () -> Void
    let showBookmarks: () -> Void
    let showSearch: () -> Void
    let showAppearance: () -> Void
    var returningToLibrary = false
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.libraryReduceMotionRequested) private var requestedReduceMotion
    private var palette: ReaderPalette { ReaderPalette(theme: model.appearance.theme) }
    private var reduceMotion: Bool { systemReduceMotion || requestedReduceMotion || model.interaction.reduceMotion }
    private var visible: Bool { model.menuVisible || !model.isReady }

    var body: some View {
        VStack(spacing: 0) {
            if visible && !model.automaticScrollPresented {
                header
                    .background { headerBackdrop }
                    .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: -10)))
            }
            Spacer(minLength: 12)
            if model.returnPosition != nil { returnControls.padding(.bottom, 8).transition(.opacity) }
            if model.automaticScrollPresented { automaticScrollControls }
            else if visible { footer.transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 10))) }
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .tint(palette.accent).foregroundStyle(palette.text)
        .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.92), value: visible)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.16), value: model.returnPosition != nil)
        .transaction { if reduceMotion { $0.animation = nil; $0.disablesAnimations = true } }
    }

    /// A page-colored edge hides text around the floating header without blur,
    /// moving the navigator, or intercepting its taps and scrolling gestures.
    private var headerBackdrop: some View {
        model.appearance.theme.background
            .padding(.horizontal, -14).padding(.top, -8)
            .ignoresSafeArea(edges: .top)
            .overlay(alignment: .bottom) {
                LinearGradient(colors: [model.appearance.theme.background, .clear],
                               startPoint: .top, endPoint: .bottom)
                    .frame(height: 24).offset(y: 24)
            }
            .allowsHitTesting(false).accessibilityHidden(true)
    }

    private var returnControls: some View {
        HStack(spacing: 8) {
            Button { Task { await model.returnToReading() } } label: {
                HStack(spacing: 9) {
                    Image(systemName: "arrow.uturn.backward").font(.system(size: 16, weight: .medium))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(model.navigationInProgress ? "正在跳转…" : "回到跳转前").font(.subheadline.weight(.medium))
                        if let title = model.returnPosition?.chapterTitle {
                            Text(title).font(.caption2).foregroundStyle(palette.secondaryText).lineLimit(1)
                        }
                    }
                    Spacer(minLength: 0)
                }.frame(minHeight: 44).contentShape(Rectangle())
            }.accessibilityIdentifier("reader.return.go")
                .accessibilityLabel("回到跳转前").accessibilityHint("回到本次目录、书签或搜索跳转的出发位置")
            Button("留在此处") { model.stayAtCurrentPosition() }
                .font(.caption).frame(minWidth: 76, minHeight: 44)
                .accessibilityIdentifier("reader.return.stay")
        }
        .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: reduceMotion))
        .disabled(model.navigationInProgress || !model.isReady)
        .padding(.horizontal, 14).padding(.vertical, 6)
        .readerSurface(palette, radius: 20, elevated: true)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Button(action: returnToLibrary) {
                Group {
                    if returningToLibrary { ProgressView() }
                    else { Image(systemName: "chevron.down").font(.system(size: 17, weight: .medium)) }
                }.frame(width: 44, height: 44).contentShape(Rectangle())
            }.accessibilityLabel("返回书库").accessibilityValue(returningToLibrary ? "正在保存并返回" : "")
                .disabled(returningToLibrary)
            VStack(alignment: .leading, spacing: 3) {
                Text(book.title).font(.subheadline.weight(.medium)).lineLimit(1)
                if !book.author.isEmpty {
                    Text(book.author).font(.caption2).foregroundStyle(palette.secondaryText).lineLimit(1)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            Button { Task { await model.addBookmark() } } label: {
                Image(systemName: "bookmark").font(.system(size: 18))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("添加书签").disabled(!model.isReady)
            .accessibilityIdentifier("reader.bookmark.add")
        }
        .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: reduceMotion)).padding(7)
        .readerSurface(palette, elevated: true).disabled(model.navigationInProgress)
    }

    private var footer: some View {
        VStack(spacing: 14) {
            ReaderProgressView(state: model.progress, palette: palette, showBookProgress: model.interaction.showsBookProgress)
            HStack(spacing: 12) {
                pageButton(forward: false)
                Spacer(minLength: 0)
                Menu {
                    Picker("阅读方式", selection: Binding(get: { model.readingMode }, set: { model.setReadingMode($0) })) {
                        ForEach(ReaderMode.allCases, id: \.self) { mode in
                            Label(mode.title, systemImage: mode.symbol).tag(mode)
                                .disabled(mode != .horizontal && model.engine?.supportsContinuousScrolling != true)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: model.readingMode.symbol)
                        Text(model.readingMode == .continuous ? "连续滚动" : model.readingMode.title)
                        Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold))
                    }
                    .font(.caption).padding(.horizontal, 14).frame(minHeight: 44)
                    .background(palette.control, in: Capsule())
                }
                .accessibilityLabel("阅读方式").accessibilityValue(model.readingMode.title)
                .accessibilityIdentifier("reader.mode")
                Spacer(minLength: 0)
                pageButton(forward: true)
            }
            Divider().overlay(palette.border)
            HStack(alignment: .top, spacing: 8) {
                tool("目录", symbol: "list.bullet", id: "reader.contents.open", action: showContents)
                tool("书签", symbol: "bookmark", id: "reader.bookmarks.open", action: showBookmarks)
                tool("搜索", symbol: "magnifyingglass", id: "reader.search.open", action: showSearch)
                    .disabled(model.engine?.searchProvider == nil)
                tool("慢滚", symbol: "play.circle", id: "reader.autoscroll.open", action: model.showAutomaticScroll)
                    .disabled(model.engine?.automaticScrollProvider == nil || model.engine?.supportsContinuousScrolling != true)
                tool("设置", symbol: "textformat.size", id: "reader.appearance.open", action: showAppearance)
                    .disabled(model.engine?.appearanceProvider == nil)
            }
        }
        .padding(18).disabled(!model.isReady || model.navigationInProgress)
        .readerSurface(palette, radius: 26, elevated: true)
    }

    private var automaticScrollControls: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Button {
                    if model.automaticScrollState.isActive { model.pauseAutomaticScroll() }
                    else { model.startAutomaticScroll() }
                } label: {
                    Label(model.automaticScrollState.isActive ? "暂停" : "开始",
                          systemImage: model.automaticScrollState.isActive ? "pause.fill" : "play.fill")
                        .font(.subheadline.weight(.medium)).frame(minWidth: 76, minHeight: 44)
                }.accessibilityIdentifier("reader.autoscroll.toggle")
                    .accessibilityValue(automaticScrollStatus)
                    .disabled(reduceMotion || model.automaticScrollState == .finished)
                Spacer(minLength: 0)
                Button { model.adjustAutomaticScrollSpeed(by: -0.5) } label: {
                    Image(systemName: "minus").frame(width: 44, height: 44)
                }.accessibilityLabel("放慢慢滚").accessibilityIdentifier("reader.autoscroll.slower")
                    .disabled(model.interaction.automaticScrollSpeed <= 0.5)
                Text(String(format: "%.1f", model.interaction.automaticScrollSpeed))
                    .font(.subheadline.monospacedDigit()).frame(minWidth: 28)
                    .accessibilityLabel("慢滚速度")
                    .accessibilityValue(String(format: "每分钟 %.1f 屏", model.interaction.automaticScrollSpeed))
                    .accessibilityIdentifier("reader.autoscroll.speed")
                Button { model.adjustAutomaticScrollSpeed(by: 0.5) } label: {
                    Image(systemName: "plus").frame(width: 44, height: 44)
                }.accessibilityLabel("加快慢滚").accessibilityIdentifier("reader.autoscroll.faster")
                    .disabled(model.interaction.automaticScrollSpeed >= 6)
                Button { model.endAutomaticScroll() } label: {
                    Image(systemName: "xmark").frame(width: 44, height: 44)
                }.accessibilityLabel("退出慢滚").accessibilityIdentifier("reader.autoscroll.close")
            }
            Text(model.interactionSaveFailure ?? (reduceMotion ? "减少动态效果已开启，慢滚停用" : "\(automaticScrollStatus) · 屏/分 · 轻触正文暂停"))
                .font(.caption).foregroundStyle(palette.secondaryText)
                .accessibilityIdentifier("reader.autoscroll.status")
            if model.interactionSaveFailure != nil {
                Button("重试保存") { model.retryInteractionSave() }.frame(minHeight: 44)
                    .accessibilityIdentifier("reader.autoscroll.retry-save")
            }
        }
        .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: reduceMotion))
        .padding(.horizontal, 12).padding(.vertical, 10)
        .readerSurface(palette, radius: 24, elevated: true)
    }

    private var automaticScrollStatus: String {
        switch model.automaticScrollState {
        case .stopped: return "准备慢滚"
        case .running: return "正在慢滚"
        case .waiting: return "等待章节"
        case .paused: return "已暂停"
        case .finished: return "已到书尾"
        }
    }

    private func pageButton(forward: Bool) -> some View {
        let label = model.scrolling ? (forward ? "下一屏" : "上一屏") : (forward ? "下一页" : "上一页")
        return Button { Task { await model.engine?.turnPage(forward: forward) } } label: {
            Image(systemName: model.readingMode == .verticalScreen
                  ? (forward ? "chevron.down" : "chevron.up") : (forward ? "chevron.right" : "chevron.left"))
                .font(.system(size: 16, weight: .medium)).frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: reduceMotion, filled: true))
        .accessibilityLabel(label)
        .accessibilityIdentifier(forward ? "reader.page.next" : "reader.page.previous")
    }

    private func tool(_ label: String, symbol: String, id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: symbol).font(.system(size: 21, weight: .regular)).frame(height: 24)
                Text(label).font(.caption).fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 56).contentShape(Rectangle())
        }
        .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: reduceMotion))
        .accessibilityLabel(label == "设置" ? "阅读设置" : label)
        .accessibilityIdentifier(id)
    }
}
