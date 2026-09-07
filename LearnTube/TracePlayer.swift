import SwiftUI
import UIKit
import CoreText

/// Real on-screen writing practice: the child traces each shape with a finger.
/// Dots sit along the guide and light up as the finger passes near them.
/// Forgiving by design (no "wrong stroke" scolding) — finishing ~80% of the
/// dots counts as done.
///
/// Two flavors share this player:
///   - `.trace(prompt:, items:)`: bare letters and digits, the original games
///   - `.traceScene(prompt:, steps:)`: every stroke has an animal at the start
///     and somewhere to get to at the end, and the stroke can be a pre-writing
///     shape (line, circle, wave, zigzag, loop) or a letter in either case.
///     That is the writing-mechanics ladder, and the animals are the reason
///     he opens it.
struct TracePlayer: View {
    let prompt: String
    let steps: [TraceStep]
    let accent: Color
    let onComplete: () -> Void

    /// The original letter games: uppercase glyphs, no story.
    init(prompt: String, items: [String], accent: Color, onComplete: @escaping () -> Void) {
        self.prompt = prompt
        self.steps = items.map { TraceStep("", .glyph($0.uppercased()), from: "") }
        self.accent = accent; self.onComplete = onComplete
    }
    init(prompt: String, steps: [TraceStep], accent: Color, onComplete: @escaping () -> Void) {
        self.prompt = prompt; self.steps = steps; self.accent = accent; self.onComplete = onComplete
    }

    @State private var index = 0
    @State private var guidePath = Path()
    @State private var targets: [CGPoint] = []
    @State private var hit: Set<Int> = []
    @State private var ink: [CGPoint] = []
    @State private var canvasSize: CGSize = .zero
    @State private var justFinished = false
    @State private var mood: MascotMood = .idle

    private var step: TraceStep { steps[min(index, max(0, steps.count - 1))] }
    private var label: String {
        if case .glyph(let g) = step.stroke { return g }
        return ""
    }
    private var bubble: String {
        if !step.say.isEmpty { return step.say }
        return label.isEmpty ? prompt : "Trace the \(label)  ✏️"
    }

    var body: some View {
        GameStage(mood: mood, prompt: bubble, confetti: justFinished) {
            VStack(spacing: 12) {
                ProgressDots(total: max(steps.count, 1), done: index, accent: accent)
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.white)
                    GeometryReader { geo in
                        Canvas { ctx, _ in draw(ctx) }
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { v in addPoint(v.location) }
                            )
                            .onAppear { setup(geo.size) }
                            .onChange(of: index) { _ in setup(geo.size) }
                    }
                    .padding(10)
                }
                .frame(height: 320)
                .padding(.horizontal, 6)
                // The word the letter starts, tied to the animal: "d" ... duck.
                if !step.word.isEmpty {
                    HStack(spacing: 10) {
                        if !step.from.isEmpty { EmojiView(emoji: step.from, size: 30, tint: .white) }
                        Text(step.word)
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                Button { setup(canvasSize) } label: {
                    Label("Start over", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(accent.opacity(0.9))
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: Drawing

    private func draw(_ ctx: GraphicsContext) {
        // Faint thick guide + crisp outline of the shape.
        ctx.stroke(guidePath, with: .color(Color(white: 0.82)),
                   style: StrokeStyle(lineWidth: 22, lineCap: .round, lineJoin: .round))
        ctx.stroke(guidePath, with: .color(Color(white: 0.65)), lineWidth: 1.5)
        // Dots along the path: grey until traced, green once hit.
        for (i, t) in targets.enumerated() {
            let r: CGFloat = 4.5
            let rect = CGRect(x: t.x - r, y: t.y - r, width: r * 2, height: r * 2)
            ctx.fill(Path(ellipseIn: rect),
                     with: .color(hit.contains(i) ? Theme.green : Color(white: 0.7)))
        }
        // Where to start: a green ring on the first dot, so the stroke begins
        // where a written letter begins (top, or the left).
        if let first = targets.first, hit.isEmpty {
            let r: CGFloat = 13
            ctx.stroke(Path(ellipseIn: CGRect(x: first.x - r, y: first.y - r, width: r * 2, height: r * 2)),
                       with: .color(Theme.green), lineWidth: 3)
        }
        // The child's ink.
        if ink.count > 1 {
            var p = Path(); p.addLines(ink)
            ctx.stroke(p, with: .color(accent),
                       style: StrokeStyle(lineWidth: 13, lineCap: .round, lineJoin: .round))
        }
        // The animal at the start and the place it's going at the end, sitting
        // just off the stroke so they never cover the dots.
        if let first = targets.first, !step.from.isEmpty {
            ctx.draw(Text(step.from).font(.system(size: 40)), at: offset(first, from: targets.dropFirst().first))
        }
        if let last = targets.last, !step.to.isEmpty, targets.count > 1 {
            ctx.draw(Text(step.to).font(.system(size: 40)), at: offset(last, from: targets.dropLast().last))
        }
    }

    /// A point ~34pt away from `p`, on the side away from its neighbour along
    /// the stroke, so the emoji sits beyond the stroke's end.
    private func offset(_ p: CGPoint, from n: CGPoint?) -> CGPoint {
        guard let n = n else { return CGPoint(x: p.x, y: p.y - 34) }
        let dx = p.x - n.x, dy = p.y - n.y
        let len = max(1, hypot(dx, dy))
        var q = CGPoint(x: p.x + dx / len * 34, y: p.y + dy / len * 34)
        // Keep it on the canvas.
        q.x = min(max(q.x, 22), canvasSize.width - 22)
        q.y = min(max(q.y, 22), canvasSize.height - 22)
        return q
    }

    // MARK: Interaction

    private func addPoint(_ p: CGPoint) {
        guard !justFinished else { return }
        ink.append(p)
        for (i, t) in targets.enumerated() where !hit.contains(i) {
            if hypot(p.x - t.x, p.y - t.y) < 26 { hit.insert(i) }
        }
        let enough = targets.isEmpty ? ink.count > 40
                                     : Double(hit.count) / Double(targets.count) >= 0.8
        if enough { finishStep() }
    }

    private func finishStep() {
        justFinished = true
        mood = .cheer
        SFX.correct()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            if index + 1 < steps.count {
                index += 1
                justFinished = false
                mood = .idle
            } else {
                SFX.win(); onComplete()
            }
        }
    }

    // MARK: Geometry

    private func setup(_ size: CGSize) {
        canvasSize = size
        ink = []; hit = []
        guard size.width > 1, steps.indices.contains(index) else { guidePath = Path(); targets = []; return }
        // Leave room around the shape for the animal and the destination.
        let margin: CGFloat = (step.from.isEmpty && step.to.isEmpty) ? 0.72 : 0.62
        let cg: CGPath
        let flip: Bool
        switch step.stroke {
        case .glyph(let s):
            guard let g = Self.glyphPath(s) else { guidePath = Path(); targets = []; return }
            cg = g; flip = true
        default:
            cg = Self.strokePath(step.stroke); flip = false
        }
        let box = cg.boundingBoxOfPath
        guard box.width > 0 || box.height > 0 else { guidePath = Path(); targets = []; return }
        let target = min(size.width, size.height) * margin
        let scale = target / max(box.width, box.height, 0.001)
        let drawW = box.width * scale, drawH = box.height * scale
        let offX = (size.width - drawW) / 2
        let offY = (size.height - drawH) / 2
        var t: CGAffineTransform
        if flip {
            t = CGAffineTransform(translationX: offX, y: offY)
                .scaledBy(x: scale, y: -scale)
                .translatedBy(x: -box.minX, y: -box.maxY)
        } else {
            t = CGAffineTransform(translationX: offX, y: offY)
                .scaledBy(x: scale, y: scale)
                .translatedBy(x: -box.minX, y: -box.minY)
        }
        let tp = cg.copy(using: &t) ?? cg
        guidePath = Path(tp)
        let raw = Self.polyline(cg).map { $0.applying(t) }
        targets = Self.resample(raw, spacing: 20, cap: 34)
    }

    // MARK: Pre-writing strokes (unit square, y down, drawn in writing order)

    static func strokePath(_ s: TraceStroke) -> CGPath {
        let p = CGMutablePath()
        func line(_ pts: [(Double, Double)]) {
            guard let f = pts.first else { return }
            p.move(to: CGPoint(x: f.0, y: f.1))
            for q in pts.dropFirst() { p.addLine(to: CGPoint(x: q.0, y: q.1)) }
        }
        /// Circle traced the way a letter c/o/a starts: from the top, going
        /// counter-clockwise (left first).
        func circle(cx: Double, cy: Double, r: Double, turns: Double = 1, startAngle: Double = -Double.pi / 2) {
            let n = Int(48 * turns)
            for i in 0...n {
                let a = startAngle - Double(i) / 48 * 2 * Double.pi
                let pt = CGPoint(x: cx + r * cos(a), y: cy + r * sin(a))
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
        }
        switch s {
        case .down:       line([(0.5, 0.0), (0.5, 1.0)])
        case .across:     line([(0.0, 0.5), (1.0, 0.5)])
        case .circle:     circle(cx: 0.5, cy: 0.5, r: 0.45)
        case .arc:
            p.move(to: CGPoint(x: 0.05, y: 0.75))
            p.addQuadCurve(to: CGPoint(x: 0.95, y: 0.75), control: CGPoint(x: 0.5, y: -0.35))
        case .wave:
            p.move(to: CGPoint(x: 0.0, y: 0.5))
            for i in 0..<3 {
                let x0 = Double(i) / 3, x1 = Double(i + 1) / 3
                p.addQuadCurve(to: CGPoint(x: (x0 + x1) / 2, y: 0.5), control: CGPoint(x: x0 + (x1 - x0) / 4, y: 0.05))
                p.addQuadCurve(to: CGPoint(x: x1, y: 0.5), control: CGPoint(x: x0 + 3 * (x1 - x0) / 4, y: 0.95))
            }
        case .zigzag:     line([(0.0, 0.85), (0.2, 0.15), (0.4, 0.85), (0.6, 0.15), (0.8, 0.85), (1.0, 0.15)])
        case .loops:
            // Three cursive loops moving right: the "e" motion.
            p.move(to: CGPoint(x: 0.0, y: 0.7))
            for i in 0..<3 {
                let x = 0.18 + Double(i) * 0.32
                p.addCurve(to: CGPoint(x: x + 0.14, y: 0.7),
                           control1: CGPoint(x: x + 0.22, y: -0.2),
                           control2: CGPoint(x: x - 0.22, y: -0.2))
            }
        case .spiral:
            let n = 120
            for i in 0...n {
                let f = Double(i) / Double(n)
                let a = f * 3 * 2 * Double.pi
                let r = 0.48 * (1 - f * 0.9)
                let pt = CGPoint(x: 0.5 + r * cos(a), y: 0.5 + r * sin(a))
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
        case .cross:
            line([(0.5, 0.0), (0.5, 1.0)])
            line([(0.0, 0.5), (1.0, 0.5)])
        case .square:     line([(0.05, 0.05), (0.05, 0.95), (0.95, 0.95), (0.95, 0.05), (0.05, 0.05)])
        case .triangle:   line([(0.5, 0.05), (0.05, 0.95), (0.95, 0.95), (0.5, 0.05)])
        case .diagonalDown: line([(0.05, 0.05), (0.95, 0.95)])
        case .diagonalUp:   line([(0.05, 0.95), (0.95, 0.05)])
        case .xMark:
            line([(0.05, 0.05), (0.95, 0.95)])
            line([(0.95, 0.05), (0.05, 0.95)])
        case .points(let pts): line(pts.map { ($0.x, $0.y) })
        case .glyph: break
        }
        return p
    }

    // MARK: CoreText helpers

    /// The outline of a single character in a rounded, kid-friendly font,
    /// in whatever case it was given (lowercase letters are how most words are
    /// written, so "d for duck" traces a lowercase d).
    static func glyphPath(_ s: String) -> CGPath? {
        let name = UIFont(name: "ArialRoundedMTBold", size: 100) != nil ? "ArialRoundedMTBold" : "Helvetica-Bold"
        let font = CTFontCreateWithName(name as CFString, 100, nil)
        var chars = Array(s.utf16)
        var glyphs = [CGGlyph](repeating: 0, count: chars.count)
        guard CTFontGetGlyphsForCharacters(font, &chars, &glyphs, chars.count),
              let g = glyphs.first, g != 0,
              let path = CTFontCreatePathForGlyph(font, g, nil) else { return nil }
        return path
    }

    /// Flatten a CGPath into a dense polyline (curves subdivided).
    static func polyline(_ path: CGPath) -> [CGPoint] {
        var pts: [CGPoint] = []
        var cur = CGPoint.zero
        func cubic(_ p0: CGPoint, _ c1: CGPoint, _ c2: CGPoint, _ p1: CGPoint) {
            let n = 12
            for i in 1...n {
                let t = CGFloat(i) / CGFloat(n), m = 1 - t
                let x = m*m*m*p0.x + 3*m*m*t*c1.x + 3*m*t*t*c2.x + t*t*t*p1.x
                let y = m*m*m*p0.y + 3*m*m*t*c1.y + 3*m*t*t*c2.y + t*t*t*p1.y
                pts.append(CGPoint(x: x, y: y))
            }
        }
        func quad(_ p0: CGPoint, _ c: CGPoint, _ p1: CGPoint) {
            let n = 9
            for i in 1...n {
                let t = CGFloat(i) / CGFloat(n), m = 1 - t
                pts.append(CGPoint(x: m*m*p0.x + 2*m*t*c.x + t*t*p1.x,
                                   y: m*m*p0.y + 2*m*t*c.y + t*t*p1.y))
            }
        }
        path.applyWithBlock { elPtr in
            let e = elPtr.pointee
            switch e.type {
            case .moveToPoint: cur = e.points[0]; pts.append(cur)
            case .addLineToPoint: cur = e.points[0]; pts.append(cur)
            case .addQuadCurveToPoint: quad(cur, e.points[0], e.points[1]); cur = e.points[1]
            case .addCurveToPoint: cubic(cur, e.points[0], e.points[1], e.points[2]); cur = e.points[2]
            case .closeSubpath: break
            @unknown default: break
            }
        }
        return pts
    }

    /// Space points out roughly every `spacing` points; cap the total count.
    static func resample(_ pts: [CGPoint], spacing: CGFloat, cap: Int) -> [CGPoint] {
        guard let first = pts.first else { return [] }
        var out = [first]
        var last = first
        for p in pts.dropFirst() {
            if hypot(p.x - last.x, p.y - last.y) >= spacing { out.append(p); last = p }
        }
        if out.count <= cap { return out }
        let step = Double(out.count) / Double(cap)
        return (0..<cap).map { out[Int(Double($0) * step)] }
    }
}
