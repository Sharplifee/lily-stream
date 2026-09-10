import Foundation
import Combine

/// App-wide event bus. Everything deferred from v1 — score tracking, highlight
/// detection, announcers, Live Activities — subscribes here rather than adding
/// new plumbing.
enum StreamEvent {
    case broadcastStarted(id: String, title: String)
    case broadcastEnded(id: String)
    case viewerJoined(id: String, name: String)
    case viewerLeft(id: String)
    case connectionChanged(ConnectionState)
}

enum ConnectionState: Equatable {
    case idle
    case connecting
    case live
    case reconnecting
    case failed(String)
}

final class EventBus {
    static let shared = EventBus()
    private let subject = PassthroughSubject<StreamEvent, Never>()
    var publisher: AnyPublisher<StreamEvent, Never> { subject.eraseToAnyPublisher() }
    func emit(_ event: StreamEvent) { subject.send(event) }
}
