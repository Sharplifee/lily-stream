import SwiftUI
import LiveKit

struct ViewerView: View {
    @EnvironmentObject var store: RoomStore
    let broadcast: LiveBroadcast

    private var remoteTrack: VideoTrack? {
        store.transport.room.remoteParticipants.values
            .compactMap { $0.firstCameraVideoTrack }
            .first
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let track = remoteTrack {
                SwiftUIVideoView(track).ignoresSafeArea()
            } else {
                VStack(spacing: 14) {
                    ProgressView().tint(.white)
                    Text(store.connection == .reconnecting ? "Reconnecting" : "Connecting")
                        .font(.subheadline).foregroundStyle(.white.opacity(0.7))
                }
            }
            VStack {
                HStack(spacing: 10) {
                    LiveDot()
                    Text(broadcast.title).font(.caption.weight(.semibold)).foregroundStyle(.white)
                    Spacer()
                    Button {
                        Theme.haptic(.light)
                        Task { await store.stopWatching() }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2).foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20).padding(.top, 16)
                Spacer()
            }
        }
    }
}
