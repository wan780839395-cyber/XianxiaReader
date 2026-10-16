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
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.libraryReduceMotionRequested) private var requestedReduceMotion
    private var palette: ReaderPalette { ReaderPalette(theme: model.appearance.theme) }
    private var reduceMotion: Bool { systemReduceMotion || requestedReduceMotion || model.interaction.reduceMotion }
    private var visible: Bool { model.menuVisible || !model.isReady }

    var body: some View {
        VStack(spacing: 0) {
            if visible && !model.automaticScrollPresented { header.transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: -10))) }
            Spacer(minLength: 12)
            if model.automaticScrollPresented { automaticScrollControls }
            else if visible { footer.transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 10))) }
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .tint(palette.accent).foregroundStyle(palette.text)
        .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.92), value: visible)
        .transaction { if reduceMotion { $0.animation = nil; $0.disablesAnimations = true } }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Button(action: returnToLibrary) {
                Image(systemName: "chevron.down").font(.system(size: 17, weight: .medium))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }.accessibilityLabel("返回书库")
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
        .readerSurface(palette, elevated: true)
    }

    private var footer: some View {
        VStack(spacing: 14) {
            VStack(spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(model.position?.chapterTitle ?? "正文").font(.footnote).lineLimit(1)
                    Spacer(minLength: 0)
                    if let progress = model.position?.progression, progress.isFinite {
                        Text("\(Int(min(max(progress, 0), 1) * 100))%")
                            .font(.caption.monospacedDigit()).foregroundStyle(palette.secondaryText)
                    }
                }
                if let progress = model.position?.progression, progress.isFinite {
                    ProgressView(value: min(max(progress, 0), 1)).accessibilityLabel("全书阅读进度")
                }
            }
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
        .padding(18).disabled(!model.isReady)
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
                    .accessibilityLabel("每分钟屏数").accessibilityIdentifier("reader.autoscroll.speed")
                Button { model.adjustAutomaticScrollSpeed(by: 0.5) } label: {
                    Image(systemName: "plus").frame(width: 44, height: 44)
                }.accessibilityLabel("加快慢滚").accessibilityIdentifier("reader.autoscroll.faster")
                    .disabled(model.interaction.automaticScrollSpeed >= 6)
                Button { model.endAutomaticScroll() } label: {
                    Image(systemName: "xmark").frame(width: 44, height: 44)
                }.accessibilityLabel("退出慢滚").accessibilityIdentifier("reader.autoscroll.close")
            }
            Text(reduceMotion ? "减少动态效果已开启，慢滚停用" : "\(automaticScrollStatus) · 屏/分 · 轻触正文暂停")
                .font(.caption).foregroundStyle(palette.secondaryText)
                .accessibilityIdentifier("reader.autoscroll.status")
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
