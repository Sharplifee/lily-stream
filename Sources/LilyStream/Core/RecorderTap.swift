import Foundation
import AVFoundation

/// Writes every broadcast to local storage so a missed match is never lost.
/// The only tap registered in v1.
final class RecorderTap: FrameTap {
    private var writer: AVAssetWriter?
    private var input: AVAssetWriterInput?
    private var started = false
    private(set) var outputURL: URL?

    func begin(title: String) {
        let safe = title.replacingOccurrences(of: "/", with: "-")
        let name = "\(safe)-\(Int(Date().timeIntervalSince1970)).mp4"
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(name)
        outputURL = url
        guard let writer = try? AVAssetWriter(outputURL: url, fileType: .mp4) else { return }
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 1920,
            AVVideoHeightKey: 1080
        ]
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        input.expectsMediaDataInRealTime = true
        if writer.canAdd(input) { writer.add(input) }
        self.writer = writer
        self.input = input
    }

    func receive(_ buffer: CMSampleBuffer) {
        guard let writer, let input else { return }
        if !started {
            writer.startWriting()
            writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(buffer))
            started = true
        }
        guard input.isReadyForMoreMediaData else { return }
        input.append(buffer)
    }

    func finish() async {
        input?.markAsFinished()
        await writer?.finishWriting()
        writer = nil; input = nil; started = false
    }
}
