import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: RoomStore
    @State private var showShare = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 18) {
                header
                goLiveTile
                liveList
                Spacer(minLength: 0)
                inviteButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .fullScreenCover(isPresented: $store.isBroadcasting) { BroadcastView() }
        .fullScreenCover(item: $store.watching) { ViewerView(broadcast: $0) }
        .sheet(isPresented: $showShare) { ShareSheet(items: [Invite.link]) }
    }

    private var header: some View {
        HStack {
            Text("LilyLive+")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.text)
            Spacer()
            if case .reconnecting = store.connection {
                Text("Reconnecting")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.dim)
            }
        }
    }

    private var goLiveTile: some View {
        Tile(tint: Theme.liveRed.opacity(0.16)) {
            Task { await store.goLive(title: "\(DeviceIdentity.displayName)'s stream") }
        } content: {
            VStack(spacing: 8) {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Theme.liveRed)
                Text("Go Live")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
            }
        }
    }

    @ViewBuilder private var liveList: some View {
        if store.live.isEmpty {
            VStack(spacing: 6) {
                Text("Nobody is live right now")
                    .font(.subheadline).foregroundStyle(Theme.dim)
            }
            .padding(.top, 30)
        } else {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(store.live) { broadcast in
                        Tile { Task { await store.watch(broadcast) } } content: {
                            HStack(spacing: 14) {
                                LiveDot()
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(broadcast.title)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(Theme.text)
                                    Text("\(broadcast.host) · \(broadcast.viewers) watching")
                                        .font(.caption).foregroundStyle(Theme.dim)
                                }
                                Spacer()
                                Image(systemName: "play.fill").foregroundStyle(Theme.accent)
                            }
                            .padding(.horizontal, 18)
                        }
                    }
                }
            }
        }
    }

    private var inviteButton: some View {
        Button {
            Theme.haptic(.light)
            showShare = true
        } label: {
            Label("Invite someone", systemImage: "square.and.arrow.up")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.accent)
        }
        .padding(.bottom, 12)
    }
}

enum Invite {
    static let link = URL(string: "https://testflight.apple.com/join/lilystream")!
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
