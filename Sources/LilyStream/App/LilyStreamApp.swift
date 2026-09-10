import SwiftUI

@main
struct LilyStreamApp: App {
    @StateObject private var store = RoomStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .task { await store.start() }
        }
    }
}
