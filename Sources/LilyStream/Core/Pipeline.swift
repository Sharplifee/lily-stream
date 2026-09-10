import Foundation
import AVFoundation

// MARK: - Insertion point A: capture
/// Anything that can produce frames. v1 ships the device camera.
/// A GoPro source conforms to this later and nothing above it changes.
protocol CaptureSource: AnyObject {
    var displayName: String { get }
    func start() async throws
    func stop()
}

// MARK: - Insertion point B: frame taps
/// Observers on the frame path. A tap must never block — it drops frames
/// rather than stalling the stream.
protocol FrameTap: AnyObject {
    func receive(_ buffer: CMSampleBuffer)
}

final class TapChain {
    private var taps: [FrameTap] = []
    private let queue = DispatchQueue(label: "lilystream.taps", qos: .utility)
    func register(_ tap: FrameTap) { taps.append(tap) }
    func dispatch(_ buffer: CMSampleBuffer) {
        queue.async { [taps] in for tap in taps { tap.receive(buffer) } }
    }
}

// MARK: - Insertion point C: transport
/// How frames reach viewers. The UI never learns which transport is in use,
/// or whether it is Wi-Fi, cellular, or peer-to-peer.
protocol Transport: AnyObject {
    var state: ConnectionState { get }
    func publish(roomID: String, title: String) async throws
    func subscribe(roomID: String) async throws
    func leave() async
}

// MARK: - Insertion point D: overlays
/// Composited above the video. v1 registers none. Score bug, replay loop and
/// broadcast graphics each become one conformer added to this array.
protocol OverlayLayer: AnyObject {
    var identifier: String { get }
    var isActive: Bool { get set }
}

final class OverlayStack {
    private(set) var layers: [OverlayLayer] = []
    func add(_ layer: OverlayLayer) { layers.append(layer) }
    func remove(_ identifier: String) { layers.removeAll { $0.identifier == identifier } }
}
