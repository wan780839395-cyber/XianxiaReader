import SwiftUI

@MainActor struct AppRootView: View {
    @State private var services: AppServices?
    @State private var errorMessage: String?
    @State private var interactionFixture: LibraryInteractionFixture?
    @StateObject private var fontInbox = FontDocumentInbox()

    var body: some View {
        Group {
            if let fixture = interactionFixture {
                LibraryView(services: fixture.services, model: fixture.model)
                    .environment(\.libraryReduceMotionRequested, fixture.reduceMotion)
            } else { normalContent }
        }
        .task { if services == nil { await load() } }
        .onOpenURL { fontInbox.receive($0) }
        .environmentObject(fontInbox)
    }

    @ViewBuilder private var normalContent: some View {
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

    @MainActor private func load() async {
        errorMessage = nil
        do {
            let prepared = try await LibraryInteractionFixture.prepareIfRequested()
            if let fixture = prepared {
                interactionFixture = fixture; services = fixture.services
                fontInbox.attach(files: fixture.services.files); return
            }
            services = try await AppServices.create()
            if let services { fontInbox.attach(files: services.files) }
        }
        catch { errorMessage = error.localizedDescription }
    }
}
