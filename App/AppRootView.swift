import SwiftUI

@MainActor struct AppRootView: View {
    @State private var services: AppServices?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let services {
                LibraryView(services: services)
            } else if let errorMessage {
                VStack(spacing: 18) {
                    Image(systemName: "externaldrive.badge.exclamationmark").font(.largeTitle)
                    Text("书库无法打开").font(.title2)
                    Text(errorMessage).foregroundStyle(.secondary)
                    Button("重试") { Task { await load() } }
                }.padding()
            } else {
                ProgressView("正在准备书库…")
            }
        }
        .task { if services == nil { await load() } }
    }

    @MainActor private func load() async {
        errorMessage = nil
        do { services = try await AppServices.create() }
        catch { errorMessage = error.localizedDescription }
    }
}
