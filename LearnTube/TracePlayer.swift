import SwiftUI
import UIKit
import CoreText

/// Real on-screen writing practice: the child traces each letter with a finger.
/// The letter's own font outline is the guide; dots sit along that outline and
/// light up as the finger passes near them. Forgiving by design (no "wrong
/// stroke" scolding) — finishing ~80% of the dots counts as done.
struct TracePlayer: View {
    let prompt: String
    let items: [String]          // single letters to trace, in order
    let accent: Color
    let onComplete: () -> Void

    @State private var index = 0
    @State private var guidePath = Path()
    @State private var targets: [CGPoint] = []
    @State private var hit: Set<Int> = []
    @State private var ink: [CGPoint] = []
    @State private var canvasSize: CGSize = .zero
    @State private var justFinished = false
    @State private var mood: MascotMood = .idle

    private var letter: String { items.isEmpty ? "" : items[min(index, items.count - 1)] }

    var body: some View {
        GameStage(mood: mood, prompt: "Trace the \(letter)  ✏️", confetti: justFinished) {
            VStack(spacing: 12) {
                ProgressDots(total: max(items.count, 1), done: index, accent: accent)
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
        // Faint thick guide + crisp outline of the letter.
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
        // The child's ink.
        if ink.count > 1 {
            var p = Path(); p.addLines(ink)
            ctx.stroke(p, with: .color(accent),
                       style: StrokeStyle(lineWidth: 13, lineCap: .round, lineJoin: .round))
        }
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
        if enough { finishLetter() }
    }

    private func finishLetter() {
        justFinished = true
        mood = .cheer
        SFX.correct()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            if index + 1 < items.count {
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
        guard size.width > 1, !letter.isEmpty, let cg = Self.glyphPath(letter) else {
            guidePath = Path(); targets = []; return
        }
        let box = cg.boundingBoxOfPath
        guard box.width > 0, box.height > 0 else { guidePath = Path(); targets = []; return }
        let target = min(size.width, size.height) * 0.72
        let scale = target / max(box.width, box.height)
        let drawW = box.width * scale, drawH = box.height * scale
        let offX = (size.width - drawW) / 2
        let offY = (size.height - drawH) / 2
        var t = CGAffineTransform(translationX: offX, y: offY)
            .scaledBy(x: scale, y: -scale)
            .translatedBy(x: -box.minX, y: -box.maxY)
        let tp = cg.copy(using: &t) ?? cg
        guidePath = Path(tp)
        let raw = Self.polyline(cg).map { $0.applying(t) }
        targets = Self.resample(raw, spacing: 20, cap: 30)
    }

    // MARK: CoreText helpers

    /// The outline of a single letter in a rounded, kid-friendly font.
    static func glyphPath(_ s: String) -> CGPath? {
        let name = UIFont(name: "ArialRoundedMTBold", size: 100) != nil ? "ArialRoundedMTBold" : "Helvetica-Bold"
        let font = CTFontCreateWithName(name as CFString, 100, nil)
        var chars = Array(s.uppercased().utf16)
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
