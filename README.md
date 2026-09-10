# Lily Stream

Private live streaming for family. Open the app, tap Go Live, everyone else sees it.

## Architecture

The video path is a pipeline with four labelled insertion points, so deferred
features plug in rather than cut in:

| Point | Protocol | v1 conformers |
|---|---|---|
| A capture | `CaptureSource` | device camera (GoPro later) |
| B taps | `FrameTap` | `RecorderTap` (analysis/score later) |
| C transport | `Transport` | `LiveKitTransport` (peer-to-peer later) |
| D overlays | `OverlayLayer` | none (score bug, replay loop, graphics later) |

`EventBus` carries `StreamEvent` app-wide. Live Activities, notifications and
announcers become subscribers, not new plumbing.

## Build

No Mac required. Push to `main` triggers `.github/workflows/ios.yml`, which
generates the Xcode project with XcodeGen, signs with the team's persistent
distribution certificate, and produces a signed IPA.

## Status

Source is written and pushed. Not yet compiled — the first CI run is the first
compile. Signing profile and App Store Connect record are outstanding.
