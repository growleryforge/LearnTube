import SwiftUI

// MARK: - Drawing a NumberVisual
//
// One view for everything a number problem can put on screen. Plain token rows
// still go through `EmojiCountView`; the rest are here. Design rules:
//   - the whole starting group is always drawn, never just the answer
//   - things that leave stay on screen, faded and crossed off, so the
//     subtraction is visible as an event rather than implied by the words
//   - ten-frames are real 5x2 frames, so "ten and some more" is something he
//     can see before he can name it

struct NumberVisualView: View {
    let visual: NumberVisual

    var body: some View {
        switch visual {
        case .none:
            EmptyView()
        case .tokens(let t):
            EmojiCountView(tokens: t)
        case .takeAway(let emoji, let start, let gone):
            TakeAwayVisual(emoji: emoji, start: start, gone: gone)
        case .tens(let emoji, let tens, let ones):
            panel {
                FlowRow(spacing: 10) {
                    ForEach(0..<max(0, tens), id: \.self) { _ in TenFrame(emoji: emoji, filled: 10) }
                    ForEach(0..<max(0, ones), id: \.self) { _ in cell(emoji) }
                }
            }
        case .frame(let emoji, let filled):
            panel { TenFrame(emoji: emoji, filled: filled, big: true) }
        case .compare(let top, let a, let bottom, let b):
            panel {
                Grid(horizontalSpacing: 6, verticalSpacing: 8) {
                    GridRow { ForEach(0..<a, id: \.self) { _ in cell(top) } }
                    GridRow { ForEach(0..<max(a, b), id: \.self) { i in
                        if i < b { cell(bottom) } else { Color.clear.frame(width: 44, height: 44) }
                    } }
                }
            }
        case .groups(let emoji, let size, let count):
            panel {
                FlowRow(spacing: 10) {
                    ForEach(0..<count, id: \.self) { _ in
                        HStack(spacing: 2) {
                            ForEach(0..<size, id: \.self) { _ in EmojiView(emoji: emoji, size: 26, tint: .white) }
                        }
                        .padding(.horizontal, 8).padding(.vertical, 6)
                        .background(Theme.surfaceHi)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
        }
    }

    private func cell(_ emoji: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Theme.surfaceHi)
            EmojiView(emoji: emoji, size: 28, tint: .white)
        }
        .frame(width: 44, height: 44)
    }

    private func panel<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

/// The whole group, then the leavers fade and get crossed off after a beat.
/// He watches them go instead of being told they went.
struct TakeAwayVisual: View {
    let emoji: String
    let start: Int
    let gone: Int
    @State private var left = false
    private let cols = [GridItem(.adaptive(minimum: 52, maximum: 64), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: cols, spacing: 8) {
            ForEach(0..<start, id: \.self) { i in
                let leaving = i >= start - gone
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.surfaceHi)
                    EmojiView(emoji: emoji, size: 34, tint: .white)
                    if leaving && left {
                        Image(systemName: "xmark")
                            .font(.system(size: 30, weight: .black))
                            .foregroundStyle(Theme.red)
                    }
                }
                .frame(height: 56)
                .opacity(leaving && left ? 0.28 : 1)
                .offset(y: leaving && left ? -6 : 0)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onAppear {
            left = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeInOut(duration: 0.5)) { left = true }
            }
        }
    }
}

/// A 5x2 ten-frame. Filled cells hold the emoji; empty cells are drawn as
/// dashed outlines so "how many more to make ten" is countable.
struct TenFrame: View {
    let emoji: String
    let filled: Int
    var big = false

    var body: some View {
        let s: CGFloat = big ? 52 : 30
        VStack(spacing: 3) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: 3) {
                    ForEach(0..<5, id: \.self) { col in
                        let i = row * 5 + col
                        ZStack {
                            RoundedRectangle(cornerRadius: big ? 10 : 6, style: .continuous)
                                .fill(i < filled ? Theme.surfaceHi : Color.clear)
                            if i >= filled {
                                RoundedRectangle(cornerRadius: big ? 10 : 6, style: .continuous)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
                                    .foregroundStyle(.white.opacity(0.45))
                            } else {
                                EmojiView(emoji: emoji, size: big ? 32 : 18, tint: .white)
                            }
                        }
                        .frame(width: s, height: s)
                    }
                }
            }
        }
        .padding(4)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

/// Wrapping row layout (iOS 16 `Layout`), so a run of frames and tokens flows
/// onto new lines on a phone instead of squeezing.
struct FlowRow: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x > 0 && x + s.width > width { x = 0; y += rowH + spacing; rowH = 0 }
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
        return CGSize(width: width, height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x > bounds.minX && x + s.width > bounds.maxX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            v.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
    }
}
