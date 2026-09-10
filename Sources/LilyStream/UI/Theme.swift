import SwiftUI

enum Theme {
    static let bg = Color(red: 0.04, green: 0.04, blue: 0.05)
    static let card = Color(red: 0.09, green: 0.09, blue: 0.11)
    static let stroke = Color.white.opacity(0.08)
    static let text = Color.white
    static let dim = Color.white.opacity(0.55)
    static let accent = Color(red: 0.35, green: 0.78, blue: 1.0)
    static let liveRed = Color(red: 1.0, green: 0.23, blue: 0.31)

    static func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

/// Big tactile tile used for every primary action.
struct Tile<Content: View>: View {
    var tint: Color = Theme.card
    let action: () -> Void
    @ViewBuilder var content: () -> Content
    @State private var pressed = false

    var body: some View {
        Button {
            Theme.haptic()
            action()
        } label: {
            content()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(tint)
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .stroke(Theme.stroke, lineWidth: 1)
                        )
                )
                .scaleEffect(pressed ? 0.97 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}

/// Pulsing dot used on anything currently live.
struct LiveDot: View {
    @State private var on = false
    var body: some View {
        Circle()
            .fill(Theme.liveRed)
            .frame(width: 10, height: 10)
            .shadow(color: Theme.liveRed.opacity(0.8), radius: on ? 8 : 2)
            .scaleEffect(on ? 1.15 : 0.9)
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: on)
            .onAppear { on = true }
    }
}
