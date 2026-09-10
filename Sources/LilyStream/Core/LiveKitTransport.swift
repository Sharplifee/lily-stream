import Foundation
import LiveKit

/// v1 transport. LiveKit gives sub-second delivery over both Wi-Fi and
/// cellular, handles NAT traversal and reconnection, and supports several
/// broadcasters at once — which is what makes "any device with the app" work
/// without the user ever choosing a connection type.
final class LiveKitTransport: NSObject, Transport, RoomDelegate {
    let room = Room()
    private(set) var state: ConnectionState = .idle {
        didSet { EventBus.shared.emit(.connectionChanged(state)) }
    }

    override init() {
        super.init()
        room.add(delegate: self)
    }

    func publish(roomID: String, title: String) async throws {
        state = .connecting
        let creds = try await TokenService.mint(roomID: roomID, publish: true)
        try await room.connect(url: creds.url, token: creds.token)
        try await room.localParticipant.setCamera(enabled: true)
        try await room.localParticipant.setMicrophone(enabled: true)
        state = .live
        EventBus.shared.emit(.broadcastStarted(id: roomID, title: title))
    }

    func subscribe(roomID: String) async throws {
        state = .connecting
        let creds = try await TokenService.mint(roomID: roomID, publish: false)
        try await room.connect(url: creds.url, token: creds.token)
        state = .live
    }

    func leave() async {
        await room.disconnect()
        state = .idle
    }

    // MARK: RoomDelegate

    func room(_ room: Room, didUpdateConnectionState connectionState: ConnectionState_LK,
              from oldState: ConnectionState_LK) {
        switch connectionState {
        case .connected: state = .live
        case .reconnecting: state = .reconnecting
        case .disconnected: state = .idle
        default: break
        }
    }
}

/// Alias so LiveKit's own connection enum does not collide with ours.
typealias ConnectionState_LK = LiveKit.ConnectionState
