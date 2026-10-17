import SwiftUI
import XianxiaCore

/// Keep native list reuse, swipe actions and accessibility; no per-row shadows.
extension View {
    func readerPanelList(_ palette: ReaderPalette) -> some View {
        listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(palette.background)
            .foregroundStyle(palette.text)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(palette.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(palette.theme.isDark ? .dark : .light, for: .navigationBar)
    }

    func readerPanelPresentation(_ palette: ReaderPalette) -> some View {
        tint(palette.accent)
            .preferredColorScheme(palette.theme.isDark ? .dark : .light)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
    }
}

@MainActor struct ReaderPanelEmptyState: View {
    let symbol: String
    let title: String
    let message: String
    let palette: ReaderPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbol).font(.title2).foregroundStyle(palette.accent)
                .accessibilityHidden(true)
            Text(title).font(.headline).foregroundStyle(palette.text)
            Text(message).font(.subheadline).foregroundStyle(palette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 18)
        .accessibilityElement(children: .combine)
    }
}

@MainActor struct ReaderContentsView: View {
    let chapters: [Chapter]
    let bookTitle: String
    let theme: ReadingTheme
    let onSelect: (Chapter) -> Void
    @Environment(\.dismiss) private var dismiss
    private var palette: ReaderPalette { ReaderPalette(theme: theme) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if chapters.isEmpty {
                        ReaderPanelEmptyState(symbol: "list.bullet", title: "暂无目录",
                                              message: "可以继续翻页或滑动阅读。", palette: palette)
                    }
                    ForEach(chapters) { chapter in
                        Button { onSelect(chapter) } label: {
                            HStack(spacing: 12) {
                                Text(chapter.title).font(.body).foregroundStyle(palette.text)
                                    .padding(.leading, CGFloat(min(max(chapter.depth, 0), 6)) * 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "chevron.right").font(.caption2.weight(.medium))
                                    .foregroundStyle(palette.secondaryText).accessibilityHidden(true)
                            }
                            .frame(minHeight: 44).padding(.vertical, 4).contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("reader.contents.\(chapter.ordinal)")
                    }
                } header: {
                    Text(bookTitle).font(.caption).textCase(nil).foregroundStyle(palette.secondaryText)
                }
                .listRowBackground(palette.card).listRowSeparatorTint(palette.border)
            }
            .accessibilityIdentifier("reader.contents.list")
            .readerPanelList(palette)
            .navigationTitle("目录 · \(chapters.count) 条目")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }.frame(minHeight: 44)
                        .accessibilityIdentifier("reader.contents.done")
                }
            }
        }
        .readerPanelPresentation(palette)
    }
}

@MainActor struct ReaderBookmarksView: View {
    let bookmarks: [Bookmark]
    let theme: ReadingTheme
    let onSelect: (Bookmark) -> Void
    let onDelete: (Bookmark) -> Void
    @Environment(\.dismiss) private var dismiss
    private var palette: ReaderPalette { ReaderPalette(theme: theme) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if bookmarks.isEmpty {
                        ReaderPanelEmptyState(symbol: "bookmark", title: "尚未添加书签",
                                              message: "在阅读菜单右上角添加，留住想再读的位置。", palette: palette)
                            .accessibilityIdentifier("reader.bookmarks.empty")
                    }
                    ForEach(bookmarks) { bookmark in
                        Button { onSelect(bookmark) } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "bookmark.fill").font(.subheadline)
                                    .foregroundStyle(palette.accent).padding(.top, 3).accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(bookmark.title).font(.body).foregroundStyle(palette.text)
                                    Text(bookmark.createdAt, style: .date).font(.caption)
                                        .foregroundStyle(palette.secondaryText)
                                }.frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(minHeight: 44).padding(.vertical, 6).contentShape(Rectangle())
                        }
                        .buttonStyle(.plain).accessibilityIdentifier("reader.bookmark.entry")
                        .swipeActions {
                            Button("删除", role: .destructive) { onDelete(bookmark) }
                                .tint(Color(readerRGB: 0xA64F48))
                        }
                    }
                }
                .listRowBackground(palette.card).listRowSeparatorTint(palette.border)
            }
            .accessibilityIdentifier("reader.bookmarks.list")
            .readerPanelList(palette).navigationTitle("书签")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }.frame(minHeight: 44)
                        .accessibilityIdentifier("reader.bookmarks.done")
                }
            }
        }
        .readerPanelPresentation(palette)
    }
}
