import CoreGraphics
import Foundation

// MARK: - How letters are written
//
// A letter is a list of STROKES, each one a polyline in a 1x1 box, in the
// order a child is taught to write it (Zaner-Bloser style print): stroke 1
// first, top to bottom, left to right. The tracer only accepts the current
// stroke, from its start dot, along its dots, in one finger-down. That is
// what makes it writing practice instead of colouring.
//
// Box: x grows to the right, y grows DOWN. Lines the letters sit on:
//   cap line    0.06   (tops of capitals, b d f h k l t)
//   x-height    0.42   (tops of a c e m n o r s u v w x z)
//   baseline    0.78
//   descender   0.98   (tails of g j p q y)
// `advance` is how far the next letter starts to the right.

struct LetterForm {
    let strokes: [[CGPoint]]
    let advance: CGFloat
}

enum LetterStrokes {

    static func form(for ch: Character) -> LetterForm? {
        if ch == " " { return LetterForm(strokes: [], advance: 0.36) }
        return table[ch]
    }

    /// Every character we can write. Words are checked against this before
    /// they're offered, so a missing glyph never reaches the screen.
    static func canWrite(_ s: String) -> Bool { s.allSatisfy { form(for: $0) != nil } }

    // MARK: Building blocks

    private static func P(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: x, y: y) }

    /// A straight polyline.
    private static func line(_ pts: (Double, Double)...) -> [CGPoint] { pts.map { P($0.0, $0.1) } }

    /// Points along an ellipse arc. Angles in degrees, y-down screen sense:
    /// 0 = right, 90 = bottom, -90 (or 270) = top, 180 = left. Going from a
    /// larger angle to a smaller one moves counter-clockwise on screen (the way
    /// c, o, a, d, g start: over the top and down the left).
    private static func arc(_ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double,
                            _ a0: Double, _ a1: Double) -> [CGPoint] {
        let n = max(6, Int(abs(a1 - a0) / 12))
        return (0...n).map { i in
            let a = (a0 + (a1 - a0) * Double(i) / Double(n)) * Double.pi / 180
            return P(cx + rx * cos(a), cy + ry * sin(a))
        }
    }
    private static func arc(_ cx: Double, _ cy: Double, _ r: Double, _ a0: Double, _ a1: Double) -> [CGPoint] {
        arc(cx, cy, r, r, a0, a1)
    }
    /// Several pieces joined into one continuous stroke.
    private static func join(_ parts: [CGPoint]...) -> [CGPoint] {
        var out: [CGPoint] = []
        for p in parts {
            if let last = out.last, let first = p.first, hypot(last.x - first.x, last.y - first.y) < 0.001 {
                out.append(contentsOf: p.dropFirst())
            } else { out.append(contentsOf: p) }
        }
        return out
    }
    private static func F(_ adv: Double, _ strokes: [CGPoint]...) -> LetterForm {
        LetterForm(strokes: strokes, advance: adv)
    }

    // A dot (the top of i and j) is a very short stroke so it still needs a tap.
    private static func dot(_ x: Double, _ y: Double) -> [CGPoint] { line((x, y - 0.02), (x, y + 0.02)) }

    // MARK: The letters

    private static let table: [Character: LetterForm] = {
        var t: [Character: LetterForm] = [:]

        // ---- lowercase (x-height 0.42, baseline 0.78, descender 0.98) ----
        t["a"] = F(0.58, arc(0.28, 0.60, 0.18, -30, -390), line((0.46, 0.42), (0.46, 0.78)))
        t["b"] = F(0.58, line((0.10, 0.06), (0.10, 0.78)), arc(0.28, 0.60, 0.18, 180, -180))
        t["c"] = F(0.56, arc(0.30, 0.60, 0.18, -40, -320))
        t["d"] = F(0.58, arc(0.28, 0.60, 0.18, -30, -390), line((0.46, 0.06), (0.46, 0.78)))
        t["e"] = F(0.56, join(line((0.12, 0.60), (0.48, 0.60)), arc(0.30, 0.60, 0.18, 0, -320)))
        t["f"] = F(0.44, join(arc(0.34, 0.22, 0.16, -20, -180), line((0.18, 0.22), (0.18, 0.78))),
                   line((0.04, 0.42), (0.34, 0.42)))
        t["g"] = F(0.58, arc(0.28, 0.60, 0.18, -30, -390),
                   join(line((0.46, 0.42), (0.46, 0.84)), arc(0.28, 0.84, 0.18, 0, 180)))
        t["h"] = F(0.58, line((0.10, 0.06), (0.10, 0.78)),
                   join(arc(0.28, 0.60, 0.18, 180, 360), line((0.46, 0.60), (0.46, 0.78))))
        t["i"] = F(0.32, line((0.16, 0.42), (0.16, 0.78)), dot(0.16, 0.28))
        t["j"] = F(0.40, join(line((0.30, 0.42), (0.30, 0.84)), arc(0.16, 0.84, 0.14, 0, 180)), dot(0.30, 0.28))
        t["k"] = F(0.54, line((0.10, 0.06), (0.10, 0.78)), line((0.42, 0.42), (0.10, 0.64)), line((0.18, 0.58), (0.44, 0.78)))
        t["l"] = F(0.32, line((0.16, 0.06), (0.16, 0.78)))
        t["m"] = F(0.78, line((0.10, 0.42), (0.10, 0.78)),
                   join(arc(0.24, 0.56, 0.14, 180, 360), line((0.38, 0.56), (0.38, 0.78))),
                   join(arc(0.52, 0.56, 0.14, 180, 360), line((0.66, 0.56), (0.66, 0.78))))
        t["n"] = F(0.58, line((0.10, 0.42), (0.10, 0.78)),
                   join(arc(0.28, 0.60, 0.18, 180, 360), line((0.46, 0.60), (0.46, 0.78))))
        t["o"] = F(0.58, arc(0.29, 0.60, 0.18, -90, -450))
        t["p"] = F(0.58, line((0.10, 0.42), (0.10, 0.98)), arc(0.28, 0.60, 0.18, 180, -180))
        t["q"] = F(0.58, arc(0.28, 0.60, 0.18, -30, -390), line((0.46, 0.42), (0.46, 0.98)))
        t["r"] = F(0.46, line((0.10, 0.42), (0.10, 0.78)), arc(0.26, 0.58, 0.16, 180, 330))
        t["s"] = F(0.52, join(arc(0.27, 0.51, 0.09, -30, -270), arc(0.27, 0.69, 0.09, -90, 150)))
        t["t"] = F(0.44, line((0.20, 0.14), (0.20, 0.78)), line((0.04, 0.42), (0.36, 0.42)))
        t["u"] = F(0.58, join(line((0.10, 0.42), (0.10, 0.62)), arc(0.28, 0.62, 0.18, 180, 0), line((0.46, 0.62), (0.46, 0.42))),
                   line((0.46, 0.42), (0.46, 0.78)))
        t["v"] = F(0.50, line((0.04, 0.42), (0.23, 0.78), (0.42, 0.42)))
        t["w"] = F(0.72, line((0.04, 0.42), (0.19, 0.78), (0.34, 0.42), (0.49, 0.78), (0.64, 0.42)))
        t["x"] = F(0.50, line((0.06, 0.42), (0.42, 0.78)), line((0.42, 0.42), (0.06, 0.78)))
        t["y"] = F(0.52, line((0.06, 0.42), (0.26, 0.78)), line((0.46, 0.42), (0.14, 0.98)))
        t["z"] = F(0.50, line((0.06, 0.42), (0.42, 0.42), (0.06, 0.78), (0.42, 0.78)))

        // ---- capitals (cap line 0.06, baseline 0.78) ----
        t["A"] = F(0.68, line((0.32, 0.06), (0.06, 0.78)), line((0.32, 0.06), (0.58, 0.78)), line((0.16, 0.52), (0.48, 0.52)))
        t["B"] = F(0.62, line((0.10, 0.06), (0.10, 0.78)),
                   join(line((0.10, 0.06), (0.30, 0.06)), arc(0.30, 0.24, 0.18, -90, 90), line((0.30, 0.42), (0.10, 0.42))),
                   join(line((0.10, 0.42), (0.32, 0.42)), arc(0.32, 0.60, 0.18, -90, 90), line((0.32, 0.78), (0.10, 0.78))))
        t["C"] = F(0.68, arc(0.36, 0.42, 0.28, 0.36, -40, -320))
        t["D"] = F(0.66, line((0.10, 0.06), (0.10, 0.78)),
                   join(line((0.10, 0.06), (0.24, 0.06)), arc(0.24, 0.42, 0.30, 0.36, -90, 90), line((0.24, 0.78), (0.10, 0.78))))
        t["E"] = F(0.58, line((0.10, 0.06), (0.10, 0.78)), line((0.10, 0.06), (0.50, 0.06)), line((0.10, 0.42), (0.42, 0.42)), line((0.10, 0.78), (0.50, 0.78)))
        t["F"] = F(0.56, line((0.10, 0.06), (0.10, 0.78)), line((0.10, 0.06), (0.50, 0.06)), line((0.10, 0.42), (0.40, 0.42)))
        t["G"] = F(0.70, arc(0.36, 0.42, 0.28, 0.36, -40, -360), line((0.38, 0.42), (0.64, 0.42)))
        t["H"] = F(0.64, line((0.10, 0.06), (0.10, 0.78)), line((0.54, 0.06), (0.54, 0.78)), line((0.10, 0.42), (0.54, 0.42)))
        t["I"] = F(0.50, line((0.26, 0.06), (0.26, 0.78)), line((0.08, 0.06), (0.44, 0.06)), line((0.08, 0.78), (0.44, 0.78)))
        t["J"] = F(0.54, join(line((0.42, 0.06), (0.42, 0.60)), arc(0.26, 0.60, 0.16, 0, 180)))
        t["K"] = F(0.62, line((0.10, 0.06), (0.10, 0.78)), line((0.50, 0.06), (0.10, 0.50)), line((0.20, 0.42), (0.52, 0.78)))
        t["L"] = F(0.56, line((0.10, 0.06), (0.10, 0.78)), line((0.10, 0.78), (0.50, 0.78)))
        t["M"] = F(0.76, line((0.08, 0.78), (0.08, 0.06)), line((0.08, 0.06), (0.34, 0.60)), line((0.34, 0.60), (0.60, 0.06)), line((0.60, 0.06), (0.60, 0.78)))
        t["N"] = F(0.66, line((0.10, 0.78), (0.10, 0.06)), line((0.10, 0.06), (0.54, 0.78)), line((0.54, 0.78), (0.54, 0.06)))
        t["O"] = F(0.70, arc(0.34, 0.42, 0.28, 0.36, -90, -450))
        t["P"] = F(0.60, line((0.10, 0.06), (0.10, 0.78)),
                   join(line((0.10, 0.06), (0.30, 0.06)), arc(0.30, 0.26, 0.20, -90, 90), line((0.30, 0.46), (0.10, 0.46))))
        t["Q"] = F(0.72, arc(0.34, 0.42, 0.28, 0.36, -90, -450), line((0.42, 0.60), (0.62, 0.82)))
        t["R"] = F(0.62, line((0.10, 0.06), (0.10, 0.78)),
                   join(line((0.10, 0.06), (0.30, 0.06)), arc(0.30, 0.26, 0.20, -90, 90), line((0.30, 0.46), (0.10, 0.46))),
                   line((0.28, 0.46), (0.54, 0.78)))
        t["S"] = F(0.60, join(arc(0.30, 0.24, 0.18, -30, -270), arc(0.30, 0.60, 0.18, -90, 150)))
        t["T"] = F(0.62, line((0.04, 0.06), (0.58, 0.06)), line((0.31, 0.06), (0.31, 0.78)))
        t["U"] = F(0.66, join(line((0.10, 0.06), (0.10, 0.56)), arc(0.32, 0.56, 0.22, 180, 0), line((0.54, 0.56), (0.54, 0.06))))
        t["V"] = F(0.64, line((0.04, 0.06), (0.30, 0.78), (0.56, 0.06)))
        t["W"] = F(0.80, line((0.02, 0.06), (0.20, 0.78), (0.37, 0.24), (0.54, 0.78), (0.72, 0.06)))
        t["X"] = F(0.62, line((0.06, 0.06), (0.54, 0.78)), line((0.54, 0.06), (0.06, 0.78)))
        t["Y"] = F(0.62, line((0.06, 0.06), (0.30, 0.44)), line((0.54, 0.06), (0.30, 0.44)), line((0.30, 0.44), (0.30, 0.78)))
        t["Z"] = F(0.62, line((0.06, 0.06), (0.54, 0.06), (0.06, 0.78), (0.54, 0.78)))

        // ---- digits (top 0.06, baseline 0.78) ----
        t["0"] = F(0.58, arc(0.28, 0.42, 0.20, 0.36, -90, -450))
        t["1"] = F(0.40, line((0.20, 0.06), (0.20, 0.78)))
        t["2"] = F(0.56, join(arc(0.28, 0.26, 0.18, -150, 40), line((0.42, 0.38), (0.08, 0.78), (0.48, 0.78))))
        t["3"] = F(0.56, join(arc(0.28, 0.24, 0.18, -150, 90), arc(0.28, 0.60, 0.18, -90, 150)))
        t["4"] = F(0.58, line((0.36, 0.06), (0.08, 0.54), (0.50, 0.54)), line((0.38, 0.06), (0.38, 0.78)))
        t["5"] = F(0.56, line((0.46, 0.06), (0.12, 0.06), (0.12, 0.40)),
                   join(line((0.12, 0.40), (0.24, 0.38)), arc(0.28, 0.58, 0.20, -100, 140)))
        t["6"] = F(0.56, join(arc(0.30, 0.42, 0.22, 0.36, -70, -190), arc(0.28, 0.60, 0.18, 180, -180)))
        t["7"] = F(0.54, line((0.08, 0.06), (0.48, 0.06), (0.20, 0.78)))
        t["8"] = F(0.56, join(arc(0.28, 0.24, 0.17, -30, -270), arc(0.28, 0.60, 0.18, -90, 270), arc(0.28, 0.24, 0.17, 90, -30)))
        t["9"] = F(0.56, join(arc(0.28, 0.26, 0.18, 0, -360), line((0.46, 0.26), (0.46, 0.78))))
        // ---- punctuation that shows up in the sentence games ----
        t["."] = F(0.26, dot(0.12, 0.76))
        t["!"] = F(0.30, line((0.14, 0.06), (0.14, 0.58)), dot(0.14, 0.76))
        t["?"] = F(0.50, join(arc(0.26, 0.24, 0.16, -150, 60), line((0.34, 0.38), (0.26, 0.50), (0.26, 0.58))), dot(0.26, 0.76))
        return t
    }()
}
