import SwiftUI
import LiveKit

struct BroadcastView: View {
    @EnvironmentObject var store: RoomStore

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let track = store.transport.room.localParticipant.firstCameraVideoTrack {
                SwiftUIVideoView(track).ignoresSafeArea()
            }
            VStack {
                HStack(spacing: 10) {
                    LiveDot()
                    Text("LIVE").font(.caption.weight(.heavy)).foregroundStyle(.white)
                    Spacer()
                    Text("\(store.transport.room.remoteParticipants.count) watching")
                        .font(.caption).foregroundStyle(.white.opacity(0.75))
                }
                .padding(.horizontal, 20).padding(.top, 16)
                Spacer()
                Tile(tint: Theme.liveRed.opacity(0.9)) {
                    Task { await store.stopLive() }
                } content: {
                    Text("End stream")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 24).padding(.bottom, 30)
            }
        }
    }
}
