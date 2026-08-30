import SwiftUI

// MARK: - Mascot (a cartoon Gabriel that hosts the games)

enum MascotMood { case idle, happy, cheer, oops }

struct Mascot: View {
    var mood: MascotMood = .idle
    var size: CGFloat = 120
    @State private var bob = false

    // Leo the Lion Cub — Gabriel's little host. Warm golden coat, soft caramel
    // mane, cream muzzle. Same moods drive the eyes and mouth below.
    private let coat = Color(red: 0.97, green: 0.80, blue: 0.47)
    private let mane = Color(red: 0.86, green: 0.56, blue: 0.29)
    private let cream = Color(red: 0.99, green: 0.94, blue: 0.85)
    private let nose = Color(red: 0.45, green: 0.28, blue: 0.22)

    var body: some View {
        let s = size
        ZStack {
            // little body/chest peeking below the head
            Ellipse().fill(coat).frame(width: s * 0.5, height: s * 0.4).offset(y: s * 0.5)
            // soft cub mane — a ring of little tufts behind the face
            ForEach(0..<11, id: \.self) { i in
                let a = Double(i) / 11.0 * 2.0 * .pi
                Circle().fill(mane)
                    .frame(width: s * 0.24, height: s * 0.24)
                    .offset(x: CGFloat(cos(a)) * s * 0.33, y: CGFloat(sin(a)) * s * 0.33)
            }
            // ears (with inner ear) peeking above the face
            Group {
                Circle().fill(coat).frame(width: s * 0.26, height: s * 0.26).offset(x: -s * 0.25, y: -s * 0.24)
                Circle().fill(coat).frame(width: s * 0.26, height: s * 0.26).offset(x: s * 0.25, y: -s * 0.24)
                Circle().fill(mane.opacity(0.7)).frame(width: s * 0.12, height: s * 0.12).offset(x: -s * 0.25, y: -s * 0.23)
                Circle().fill(mane.opacity(0.7)).frame(width: s * 0.12, height: s * 0.12).offset(x: s * 0.25, y: -s * 0.23)
            }
            // a little top tuft (cubs have one)
            Capsule().fill(mane).frame(width: s * 0.08, height: s * 0.16).offset(y: -s * 0.34)
            // face
            Circle().fill(coat).frame(width: s * 0.68, height: s * 0.68)
            // cream muzzle
            Ellipse().fill(cream).frame(width: s * 0.44, height: s * 0.34).offset(y: s * 0.13)
            // rosy cheeks
            HStack(spacing: s * 0.36) {
                Circle().fill(Color.pink.opacity(0.35)).frame(width: s * 0.12, height: s * 0.1)
                Circle().fill(Color.pink.opacity(0.35)).frame(width: s * 0.12, height: s * 0.1)
            }.offset(y: s * 0.1)
            // little nose
            Triangle().fill(nose).frame(width: s * 0.1, height: s * 0.08)
                .rotationEffect(.degrees(180)).offset(y: s * 0.02)
            eyes.offset(y: -s * 0.04)
            mouth
        }
        .frame(width: size, height: size)
        .scaleEffect(mood == .cheer ? 1.1 : 1)
        .rotationEffect(.degrees(mood == .oops ? -5 : 0))
        .offset(y: bob ? -4 : 4)
        .animation(.spring(response: 0.35, dampingFraction: 0.5), value: mood)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { bob = true }
        }
    }

    @ViewBuilder private var eyes: some View {
        HStack(spacing: size * 0.2) { eye; eye }
    }

    @ViewBuilder private var eye: some View {
        switch mood {
        case .oops:
            Image(systemName: "xmark").font(.system(size: size * 0.1, weight: .black)).foregroundStyle(.black.opacity(0.75))
        case .cheer, .happy:
            Arc().stroke(.black.opacity(0.8), style: StrokeStyle(lineWidth: size * 0.03, lineCap: .round))
                .frame(width: size * 0.13, height: size * 0.09)
        case .idle:
            ZStack {
                Circle().fill(.white).frame(width: size * 0.13, height: size * 0.14)
                Circle().fill(.black).frame(width: size * 0.07, height: size * 0.07)
            }
        }
    }

    @ViewBuilder private var mouth: some View {
        switch mood {
        case .cheer:
            Ellipse().fill(.black.opacity(0.78)).frame(width: size * 0.16, height: size * 0.13).offset(y: size * 0.22)
        case .oops:
            SmileShape(curl: -0.5).stroke(.black.opacity(0.7), style: .init(lineWidth: size * 0.035, lineCap: .round))
                .frame(width: size * 0.2, height: size * 0.08).offset(y: size * 0.24)
        default:
            SmileShape(curl: 0.6).stroke(.black.opacity(0.7), style: .init(lineWidth: size * 0.035, lineCap: .round))
                .frame(width: size * 0.24, height: size * 0.1).offset(y: size * 0.22)
        }
    }
}

// MARK: - Play scene background (sky + rolling hills + sun)

struct PlayScene<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.65, green: 0.85, blue: 0.98),
                                    Color(red: 0.86, green: 0.95, blue: 0.86)],
                           startPoint: .top, endPoint: .bottom)
            // sun
            Circle().fill(Color(red: 1.0, green: 0.86, blue: 0.30))
                .frame(width: 70, height: 70).offset(x: 120, y: -150).opacity(0.9)
            // hills
            Hills().fill(Color(red: 0.42, green: 0.74, blue: 0.42))
                .frame(height: 120).frame(maxHeight: .infinity, alignment: .bottom).opacity(0.55)
            content
        }
    }
}

// MARK: - Drawn objects

struct Egg: View {
    var hatched = false
    var body: some View {
        ZStack {
            if hatched {
                ChickFace()
            } else {
                Ellipse()
                    .fill(LinearGradient(colors: [.white, Color(red: 0.93, green: 0.90, blue: 0.83)],
                                         startPoint: .top, endPoint: .bottom))
                    .overlay(Ellipse().stroke(Color(red: 0.80, green: 0.74, blue: 0.62), lineWidth: 1.5))
            }
        }
    }
}

struct ChickFace: View {
    var body: some View {
        ZStack {
            Circle().fill(Color(red: 1.0, green: 0.84, blue: 0.28))
            HStack(spacing: 7) {
                Circle().fill(.black).frame(width: 5, height: 5)
                Circle().fill(.black).frame(width: 5, height: 5)
            }.offset(y: -3)
            Triangle().fill(Color(red: 0.95, green: 0.55, blue: 0.12))
                .frame(width: 8, height: 6).rotationEffect(.degrees(180)).offset(y: 6)
        }
    }
}

struct AppleArt: View {
    var body: some View {
        ZStack {
            Circle().fill(LinearGradient(colors: [Color(red: 0.95, green: 0.28, blue: 0.28),
                                                  Color(red: 0.78, green: 0.13, blue: 0.16)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
            Capsule().fill(Color(red: 0.45, green: 0.30, blue: 0.16))
                .frame(width: 4, height: 12).offset(y: -22)
            Ellipse().fill(Color(red: 0.36, green: 0.66, blue: 0.36))
                .frame(width: 16, height: 9).rotationEffect(.degrees(-30)).offset(x: 10, y: -20)
            Circle().fill(.white.opacity(0.4)).frame(width: 10, height: 10).offset(x: -9, y: -8)
        }
    }
}

struct StarArt: View {
    var body: some View {
        StarShape(points: 5)
            .fill(LinearGradient(colors: [Color(red: 1.0, green: 0.86, blue: 0.30),
                                          Color(red: 0.98, green: 0.66, blue: 0.10)],
                                 startPoint: .top, endPoint: .bottom))
    }
}

/// A drawn 2D shape used as a picture answer in shape lessons.
struct ShapeGlyph: View {
    let name: String
    var color: Color = Theme.green
    var body: some View {
        Group {
            switch name.lowercased() {
            case "circle": Circle().fill(color)
            case "square": RoundedRectangle(cornerRadius: 6).fill(color).aspectRatio(1, contentMode: .fit)
            case "triangle": Triangle().fill(color)
            case "rectangle": RoundedRectangle(cornerRadius: 6).fill(color).aspectRatio(1.7, contentMode: .fit)
            case "sphere": Circle().fill(RadialGradient(colors: [.white, color], center: .init(x: 0.35, y: 0.3), startRadius: 1, endRadius: 40))
            case "cube": RoundedRectangle(cornerRadius: 6).fill(color).aspectRatio(1, contentMode: .fit)
            case "cylinder": Capsule().fill(color)
            case "cone": Triangle().fill(color)
            default: Circle().fill(color)
            }
        }
    }
}

// MARK: - Confetti

struct Confetti: View {
    @State private var go = false
    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<26, id: \.self) { i in
                    let x = CGFloat.random(in: 0...geo.size.width)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colors[i % colors.count])
                        .frame(width: 9, height: 14)
                        .position(x: x, y: go ? geo.size.height + 20 : -20)
                        .rotationEffect(.degrees(go ? Double.random(in: 180...540) : 0))
                        .animation(.easeIn(duration: Double.random(in: 0.9...1.6)), value: go)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { go = true }
    }
}

// MARK: - Shapes

struct Triangle: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}

struct Arc: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.maxY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.maxY),
                       control: CGPoint(x: r.midX, y: r.minY - r.height))
        return p
    }
}

struct Hills: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.midY))
        p.addQuadCurve(to: CGPoint(x: r.width * 0.5, y: r.midY),
                       control: CGPoint(x: r.width * 0.25, y: r.minY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.midY),
                       control: CGPoint(x: r.width * 0.75, y: r.maxY * 0.1))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}

struct StarShape: Shape {
    var points: Int = 5
    func path(in r: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: r.midX, y: r.midY)
        let outer = min(r.width, r.height) / 2
        let inner = outer * 0.42
        let step = .pi / Double(points)
        var angle = -Double.pi / 2
        for i in 0..<(points * 2) {
            let rad = (i % 2 == 0) ? outer : inner
            let pt = CGPoint(x: c.x + CGFloat(cos(angle)) * rad, y: c.y + CGFloat(sin(angle)) * rad)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            angle += step
        }
        p.closeSubpath()
        return p
    }
}
