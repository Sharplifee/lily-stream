import Foundation
import Combine

struct LiveBroadcast: Identifiable, Equatable {
    let id: String
    let title: String
    let host: String
    var viewers: Int
}

/// Single source of truth for the UI: who is live right now, and what this
/// device is currently doing.
@MainActor
final class RoomStore: ObservableObject {
    @Published var live: [LiveBroadcast] = []
    @Published var connection: ConnectionState = .idle
    @Published var isBroadcasting = false
    @Published var watching: LiveBroadcast?

    let transport = LiveKitTransport()
    let taps = TapChain()
    let overlays = OverlayStack()
    private let recorder = RecorderTap()
    private var bag = Set<AnyCancellable>()

    init() {
        taps.register(recorder)
        EventBus.shared.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in self?.handle(event) }
            .store(in: &bag)
    }

    func start() async {
        await Presence.shared.observe { [weak self] rooms in
            Task { @MainActor in self?.live = rooms }
        }
    }

    func goLive(title: String) async {
        recorder.begin(title: title)
        do {
            try await transport.publish(roomID: DeviceIdentity.current, title: title)
            isBroadcasting = true
            await Presence.shared.announce(title: title, host: DeviceIdentity.displayName)
        } catch {
            connection = .failed(error.localizedDescription)
        }
    }

    func stopLive() async {
        await transport.leave()
        await recorder.finish()
        await Presence.shared.withdraw()
        isBroadcasting = false
    }

    func watch(_ broadcast: LiveBroadcast) async {
        do {
            try await transport.subscribe(roomID: broadcast.id)
            watching = broadcast
        } catch {
            connection = .failed(error.localizedDescription)
        }
    }

    func stopWatching() async {
        await transport.leave()
        watching = nil
    }

    private func handle(_ event: StreamEvent) {
        if case .connectionChanged(let state) = event { connection = state }
    }
}
