import SwiftUI
import UIKit

/// Real on-screen writing practice, done the way handwriting is taught:
///
///   * a letter is its STROKES, in order (stroke 1, then stroke 2...)
///   * a stroke starts at the green dot and follows the dots in order
///   * one stroke = one finger-down; lifting early resets that stroke
///   * wandering off the path resets that stroke (no reward for scribbling)
///
/// Only the current stroke takes ink. The others are shown as faint guides
/// so he can see the whole letter, and finished strokes stay drawn in colour.
/// Words are the same thing letter after letter, so "cow" is c, then o,
/// then w, in writing order.
///
/// Two flavors share this player:
///   - `.trace(prompt:, items:)`: bare letters and digits, the original games
///   - `.traceScene(prompt:, steps:)`: an animal at the start, somewhere to get
///     to, and the stroke can be a pre-writing shape or a letter or a word.
struct TracePlayer: View {
    let prompt: String
    let steps: [TraceStep]
    let accent: Color
    let onComplete: () -> Void

    init(prompt: String, items: [String], accent: Color, onComplete: @escaping () -> Void) {
        self.prompt = prompt
        self.steps = items.map { TraceStep("", .glyph($0), from: "") }
        self.accent = accent; self.onComplete = onComplete
    }
    init(prompt: String, steps: [TraceStep], accent: Color, onComplete: @escaping () -> Void) {
        self.prompt = prompt; self.steps = steps; self.accent = accent; self.onComplete = onComplete
    }

    // Which step, which stroke of it, how far along that stroke.
    @State private var index = 0
    @State private var strokes: [[CGPoint]] = []      // canvas coords, dots ~14pt apart
    @State private var strokeIndex = 0
    @State private var nextDot = 0
    @State private var ink: [CGPoint] = []            // the finger, current stroke
    @State private var done: [[CGPoint]] = []         // finished strokes' ink
    @State private var tracing = false
    @State private var laidOutFor: CGSize = .zero
    @State private var justFinished = false
    @State private var mood: MascotMood = .idle
    @State private var hint = ""                      // "Start at the green dot"
    @State private var shake = 0                      // bumps to animate a reset

    // Ballpark, not precision: about two finger-widths. Order and direction
    // are what make it writing; a shaky line is still a line.
    private let startRadius: CGFloat = 52   // how close the finger must land to the start dot
    private let hitRadius: CGFloat = 36     // how close to count a dot
    private let offPath: CGFloat = 70       // farther than this from the stroke = wandered off

    private var step: TraceStep { steps[min(index, max(0, steps.count - 1))] }
    private var label: String {
        if case .glyph(let g) = step.stroke { return g }
        return ""
    }
    private var bubble: String {
        if !hint.isEmpty { return hint }
        if !step.say.isEmpty { return step.say }
        return label.isEmpty ? prompt : "Write \(label)  ✏️"
    }

    var body: some View {
        GameStage(mood: mood, prompt: bubble, confetti: justFinished) {
            VStack(spacing: 12) {
                ProgressDots(total: max(steps.count, 1), done: index, accent: accent)
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.white)
                    Canvas { ctx, size in
                        // Lay out from the size the canvas actually has, every
                        // draw: on iOS 16 the first pass can come before any
                        // size is known, and this is what keeps it from
                        // opening blank.
                        if size != laidOutFor && size.width > 1 {
                            DispatchQueue.main.async { layout(size) }
                        }
                        draw(ctx, size)
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { v in touch(v.location) }
                            .onEnded { _ in lift() }
                    )
                    .padding(10)
                }
                .frame(height: 340)
                .padding(.horizontal, 6)
                .modifier(Shake(times: shake))
                // The word the letter starts, tied to the animal: "d" ... duck.
                if !step.word.isEmpty, label != step.word {
                    HStack(spacing: 10) {
                        if !step.from.isEmpty { EmojiView(emoji: step.from, size: 34, tint: .white) }
                        Text(step.word)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                Button { resetStep() } label: {
                    Label("Start over", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(accent.opacity(0.9))
                        .clipShape(Capsule())
                }
            }
        }
        .onChange(of: index) { _ in laidOutFor = .zero }
    }

    // MARK: Drawing

    private func draw(_ ctx: GraphicsContext, _ size: CGSize) {
        guard !strokes.isEmpty else { return }
        // Every stroke of the letter, faint, so the whole shape is there.
        for (si, s) in strokes.enumerated() where si != strokeIndex && si >= done.count {
            var p = Path(); p.addLines(s)
            ctx.stroke(p, with: .color(Color(white: 0.80)),
                       style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round))
        }
        // Strokes he already wrote: his own ink, solid.
        for s in done where s.count > 1 {
            var p = Path(); p.addLines(s)
            ctx.stroke(p, with: .color(accent),
                       style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round))
        }
        // The current stroke: a tinted band, then dots, grey ahead and green behind.
        if strokeIndex < strokes.count {
            let cur = strokes[strokeIndex]
            var p = Path(); p.addLines(cur)
            ctx.stroke(p, with: .color(accent.opacity(0.22)),
                       style: StrokeStyle(lineWidth: 26, lineCap: .round, lineJoin: .round))
            for (i, t) in cur.enumerated() {
                let r: CGFloat = i < nextDot ? 6 : 5
                ctx.fill(Path(ellipseIn: CGRect(x: t.x - r, y: t.y - r, width: r * 2, height: r * 2)),
                         with: .color(i < nextDot ? Theme.green : Color(white: 0.55)))
            }
            // Direction: a little arrow a few dots in, until he's past it.
            if cur.count > 3, nextDot <= 3 {
                let a = cur[2], b = cur[3]
                let ang = atan2(b.y - a.y, b.x - a.x)
                var tri = Path()
                let tip = CGPoint(x: b.x + cos(ang) * 10, y: b.y + sin(ang) * 10)
                tri.move(to: tip)
                tri.addLine(to: CGPoint(x: tip.x - cos(ang - 0.5) * 14, y: tip.y - sin(ang - 0.5) * 14))
                tri.addLine(to: CGPoint(x: tip.x - cos(ang + 0.5) * 14, y: tip.y - sin(ang + 0.5) * 14))
                tri.closeSubpath()
                ctx.fill(tri, with: .color(accent.opacity(0.9)))
            }
            // The start: big green ring with the stroke number, and a finger
            // until he's on his way.
            if let first = cur.first, nextDot == 0 {
                let r: CGFloat = 17
                ctx.fill(Path(ellipseIn: CGRect(x: first.x - r, y: first.y - r, width: r * 2, height: r * 2)),
                         with: .color(Theme.green))
                ctx.draw(Text("\(strokeIndex + 1)").font(.system(size: 18, weight: .black, design: .rounded)).foregroundColor(.white),
                         at: first)
                ctx.draw(Text("👆").font(.system(size: 34)),
                         at: CGPoint(x: min(first.x + 26, size.width - 24), y: min(first.y + 34, size.height - 22)))
            }
        }
        // The finger's ink on the current stroke.
        if ink.count > 1 {
            var p = Path(); p.addLines(ink)
            ctx.stroke(p, with: .color(accent),
                       style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round))
        }
        // The animal and where it's going: at the ends of a pre-writing
        // stroke, or in the top corners for a letter or word.
        let isGlyph: Bool = { if case .glyph = step.stroke { return true } else { return false } }()
        if !step.from.isEmpty {
            let at = isGlyph ? CGPoint(x: 34, y: 32) : offset(strokes[0].first, from: strokes[0].dropFirst().first, size)
            ctx.draw(Text(step.from).font(.system(size: 44)), at: at)
        }
        if !step.to.isEmpty, let last = strokes.last, last.count > 1 {
            let at = isGlyph ? CGPoint(x: size.width - 34, y: 32) : offset(last.last, from: last.dropLast().last, size)
            ctx.draw(Text(step.to).font(.system(size: 44)), at: at)
        }
    }

    private func offset(_ p: CGPoint?, from n: CGPoint?, _ size: CGSize) -> CGPoint {
        guard let p = p else { return CGPoint(x: 34, y: 32) }
        guard let n = n else { return CGPoint(x: p.x, y: p.y - 38) }
        let dx = p.x - n.x, dy = p.y - n.y
        let len = max(1, hypot(dx, dy))
        var q = CGPoint(x: p.x + dx / len * 38, y: p.y + dy / len * 38)
        q.x = min(max(q.x, 26), size.width - 26)
        q.y = min(max(q.y, 26), size.height - 26)
        return q
    }

    // MARK: Interaction

    private func touch(_ p: CGPoint) {
        guard !justFinished, strokeIndex < strokes.count else { return }
        let cur = strokes[strokeIndex]
        if !tracing {
            // A stroke has to begin at its start dot. Anywhere else is ignored,
            // with a nudge toward the green dot.
            guard let first = cur.first else { return }
            if hypot(p.x - first.x, p.y - first.y) > startRadius {
                if hint.isEmpty { hint = "Start at the green dot 👆"; mood = .idle }
                return
            }
            tracing = true; hint = ""; ink = [p]; nextDot = 0
            SFX.tap()
        }
        ink.append(p)
        // Nearest dot just ahead of where he is: dots must be hit in order.
        var advanced = false
        for i in nextDot..<min(nextDot + 6, cur.count) {
            if hypot(p.x - cur[i].x, p.y - cur[i].y) <= hitRadius { nextDot = i + 1; advanced = true }
        }
        if !advanced {
            // Still allowed if he's near the part of the stroke he has done
            // (a wobble); wandering away from the whole stroke resets it.
            let near = cur.prefix(max(nextDot + 8, 1)).contains { hypot(p.x - $0.x, p.y - $0.y) <= offPath }
            if !near { failStroke("Oops! Stay on the dots. Start at the green dot 👆"); return }
        }
        if nextDot >= cur.count { completeStroke() }
    }

    private func lift() {
        guard tracing, !justFinished else { return }
        let cur = strokes[strokeIndex]
        // Reaching the last dot or two counts; lifting anywhere else resets.
        if nextDot >= cur.count - 2 { completeStroke() }
        else { failStroke("Keep your finger down all the way to the end. Try again from the green dot 👆") }
    }

    private func failStroke(_ msg: String) {
        tracing = false; ink = []; nextDot = 0
        hint = msg; mood = .oops
        withAnimation(.easeInOut(duration: 0.35)) { shake += 1 }
        // Log which glyph and which stroke reset, so the grown-up view shows
        // "L stroke 2" rather than a bare miss count.
        let what = label.isEmpty ? "shape" : label
        GameStats.recordMiss(prompt: "Write \(what) (stroke \(strokeIndex + 1))", tapped: msg, correct: what)
        SFX.wrong()
    }

    private func completeStroke() {
        guard tracing else { return }
        tracing = false
        done.append(ink); ink = []; nextDot = 0
        strokeIndex += 1
        hint = ""
        if strokeIndex >= strokes.count { finishStep() }
        else { SFX.correct(); mood = .happy }
    }

    private func finishStep() {
        justFinished = true
        mood = .cheer
        SFX.correct()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if index + 1 < steps.count {
                index += 1
                justFinished = false
                mood = .idle
            } else {
                SFX.win(); onComplete()
            }
        }
    }

    private func resetStep() {
        tracing = false; ink = []; done = []; nextDot = 0; strokeIndex = 0; hint = ""; mood = .idle
    }

    // MARK: Geometry

    /// Turn the step into canvas strokes: unit-box points scaled to fit.
    private func layout(_ size: CGSize) {
        laidOutFor = size
        resetStep()
        let unit: [[CGPoint]]
        let box: CGRect
        switch step.stroke {
        case .glyph(let s):
            (unit, box) = Self.wordStrokes(s)
        default:
            unit = Self.preWriting(step.stroke)
            box = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        guard !unit.isEmpty, box.width > 0, box.height > 0 else { strokes = []; return }
        let isGlyph: Bool = { if case .glyph = step.stroke { return true } else { return false } }()
        // Room for the animal: letters keep the corners free; shapes leave a
        // margin all round for the emoji at each end.
        let inset: CGFloat = isGlyph ? 24 : 58
        let availW = size.width - inset * 2, availH = size.height - inset * 2
        let scale = min(availW / box.width, availH / box.height)
        let w = box.width * scale, h = box.height * scale
        let ox = (size.width - w) / 2 - box.minX * scale
        let oy = (size.height - h) / 2 - box.minY * scale
        strokes = unit.map { s in
            Self.resample(s.map { CGPoint(x: $0.x * scale + ox, y: $0.y * scale + oy) }, spacing: 14)
        }
    }

    /// Strokes for a letter, digit or whole word, laid out left to right in
    /// unit units (each letter box is 1 tall), plus the bounds.
    static func wordStrokes(_ s: String) -> ([[CGPoint]], CGRect) {
        var out: [[CGPoint]] = []
        var x: CGFloat = 0
        for ch in s {
            guard let f = LetterStrokes.form(for: ch) else { continue }
            for st in f.strokes { out.append(st.map { CGPoint(x: $0.x + x, y: $0.y) }) }
            x += f.advance
        }
        // Single characters use their own box; words use the writing lines
        // (cap line to descender) so letters line up like on paper.
        if s.count == 1 {
            let pts = out.flatMap { $0 }
            let minX = pts.map(\.x).min() ?? 0, maxX = pts.map(\.x).max() ?? 1
            let minY = pts.map(\.y).min() ?? 0, maxY = pts.map(\.y).max() ?? 1
            return (out, CGRect(x: minX - 0.04, y: minY - 0.04, width: maxX - minX + 0.08, height: maxY - minY + 0.08))
        }
        return (out, CGRect(x: -0.02, y: 0.02, width: x + 0.02, height: 1.0))
    }

    /// Pre-writing shapes in a unit box, y down, one polyline per stroke.
    static func preWriting(_ s: TraceStroke) -> [[CGPoint]] {
        func P(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: x, y: y) }
        func line(_ pts: [(Double, Double)]) -> [CGPoint] { pts.map { P($0.0, $0.1) } }
        func circle(cx: Double, cy: Double, r: Double, turns: Double = 1, start: Double = -90) -> [CGPoint] {
            let n = Int(40 * turns)
            return (0...n).map { i in
                let a = (start - 360 * Double(i) / 40) * Double.pi / 180
                return P(cx + r * cos(a), cy + r * sin(a))
            }
        }
        func curve(_ p0: CGPoint, _ c: CGPoint, _ p1: CGPoint) -> [CGPoint] {
            (0...10).map { i in
                let t = CGFloat(i) / 10, m = 1 - t
                return CGPoint(x: m*m*p0.x + 2*m*t*c.x + t*t*p1.x, y: m*m*p0.y + 2*m*t*c.y + t*t*p1.y)
            }
        }
        switch s {
        case .down:         return [line([(0.5, 0.0), (0.5, 1.0)])]
        case .across:       return [line([(0.0, 0.5), (1.0, 0.5)])]
        case .circle:       return [circle(cx: 0.5, cy: 0.5, r: 0.45)]
        case .arc:          return [curve(P(0.05, 0.75), P(0.5, -0.35), P(0.95, 0.75))]
        case .wave:
            var pts: [CGPoint] = []
            for i in 0..<3 {
                let x0 = Double(i) / 3, x1 = Double(i + 1) / 3
                pts += curve(P(x0, 0.5), P(x0 + (x1 - x0) / 4, 0.05), P((x0 + x1) / 2, 0.5)).dropLast()
                pts += curve(P((x0 + x1) / 2, 0.5), P(x0 + 3 * (x1 - x0) / 4, 0.95), P(x1, 0.5))
            }
            return [pts]
        case .zigzag:       return [line([(0.0, 0.85), (0.2, 0.15), (0.4, 0.85), (0.6, 0.15), (0.8, 0.85), (1.0, 0.15)])]
        case .loops:
            var pts: [CGPoint] = [P(0.0, 0.7)]
            for i in 0..<3 {
                let x = 0.18 + Double(i) * 0.32
                // a loop: up and over to the left, back down to the right
                pts += circle(cx: x, cy: 0.42, r: 0.24, turns: 1, start: 110)
                pts.append(P(x + 0.14, 0.7))
            }
            return [pts]
        case .spiral:
            return [(0...120).map { i in
                let f = Double(i) / 120, a = f * 3 * 2 * Double.pi, r = 0.48 * (1 - f * 0.9)
                return P(0.5 + r * cos(a), 0.5 + r * sin(a))
            }]
        case .cross:        return [line([(0.5, 0.0), (0.5, 1.0)]), line([(0.0, 0.5), (1.0, 0.5)])]
        case .square:       return [line([(0.05, 0.05), (0.05, 0.95), (0.95, 0.95), (0.95, 0.05), (0.05, 0.05)])]
        case .triangle:     return [line([(0.5, 0.05), (0.05, 0.95), (0.95, 0.95), (0.5, 0.05)])]
        case .diagonalDown: return [line([(0.05, 0.05), (0.95, 0.95)])]
        case .diagonalUp:   return [line([(0.05, 0.95), (0.95, 0.05)])]
        case .xMark:        return [line([(0.05, 0.05), (0.95, 0.95)]), line([(0.95, 0.05), (0.05, 0.95)])]
        case .points(let pts): return [pts.map { P($0.x, $0.y) }]
        case .glyph:        return []
        }
    }

    /// Dots every `spacing` points along a polyline (interpolated, so long
    /// straight segments get dots too), always keeping the last point.
    static func resample(_ pts: [CGPoint], spacing: CGFloat) -> [CGPoint] {
        guard let first = pts.first else { return [] }
        var out = [first]
        var carry: CGFloat = 0
        for i in 1..<max(pts.count, 1) {
            let a = pts[i - 1], b = pts[i]
            let seg = hypot(b.x - a.x, b.y - a.y)
            guard seg > 0 else { continue }
            var d = spacing - carry
            while d <= seg {
                let t = d / seg
                out.append(CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t))
                d += spacing
            }
            carry = seg - (d - spacing)
        }
        if let last = pts.last, let end = out.last, hypot(last.x - end.x, last.y - end.y) > 4 { out.append(last) }
        return out
    }
}

/// A quick sideways wobble when a stroke resets.
private struct Shake: GeometryEffect {
    var times: Int
    private var phase: CGFloat
    init(times: Int) { self.times = times; self.phase = CGFloat(times) }
    var animatableData: CGFloat { get { phase } set { phase = newValue } }
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: sin(phase * .pi * 6) * 6, y: 0))
    }
}
