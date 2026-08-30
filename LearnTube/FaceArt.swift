import SwiftUI

/// Expressive vector faces for the feelings game. Drawn (not emoji) so they
/// look identical and distinct in the simulator and on the iPad.
enum FaceExpr: String, CaseIterable, Hashable {
    case happy, sad, angry, scared, sleepy, calm, excited, surprised
    case silly, proud, shy, worried, bored, love, grumpy
    case crying, laughing, cool, nervous, sick, confused

    var word: String {
        switch self {
        case .happy: return "Happy"
        case .sad: return "Sad"
        case .angry: return "Angry"
        case .scared: return "Scared"
        case .sleepy: return "Sleepy"
        case .calm: return "Calm"
        case .excited: return "Excited"
        case .surprised: return "Surprised"
        case .silly: return "Silly"
        case .proud: return "Proud"
        case .shy: return "Shy"
        case .worried: return "Worried"
        case .bored: return "Bored"
        case .love: return "Love"
        case .grumpy: return "Grumpy"
        case .crying: return "Crying"
        case .laughing: return "Laughing"
        case .cool: return "Cool"
        case .nervous: return "Nervous"
        case .sick: return "Sick"
        case .confused: return "Confused"
        }
    }

    /// The real emoji for this feeling (used in the feelings game).
    var emoji: String {
        switch self {
        case .happy: return "😀"
        case .sad: return "😢"
        case .angry: return "😠"
        case .scared: return "😨"
        case .sleepy: return "😴"
        case .calm: return "😌"
        case .excited: return "🤩"
        case .surprised: return "😲"
        case .silly: return "😜"
        case .proud: return "😊"
        case .shy: return "😳"
        case .worried: return "😟"
        case .bored: return "😐"
        case .love: return "😍"
        case .grumpy: return "😤"
        case .crying: return "😭"
        case .laughing: return "😂"
        case .cool: return "😎"
        case .nervous: return "😬"
        case .sick: return "🤒"
        case .confused: return "😕"
        }
    }

    var base: Color {
        switch self {
        case .scared: return Color(red: 0.78, green: 0.90, blue: 0.78)
        case .angry, .grumpy: return Color(red: 1.0, green: 0.74, blue: 0.45)
        case .sick: return Color(red: 0.72, green: 0.86, blue: 0.55)
        default: return Color(red: 1.0, green: 0.84, blue: 0.30)
        }
    }
}

struct FaceEmoji: View {
    let expr: FaceExpr
    var size: CGFloat = 64

    var body: some View {
        ZStack {
            Circle().fill(RadialGradient(colors: [expr.base.opacity(1), expr.base.opacity(0.82)],
                                         center: .init(x: 0.4, y: 0.35), startRadius: 1, endRadius: size * 0.6))
            blush
            brows
            eyes
            mouth
            extras
        }
        .frame(width: size, height: size)
    }

    private var s: CGFloat { size }

    // MARK: eyes
    @ViewBuilder private var eyes: some View {
        Group {
            if expr == .cool {
                Capsule().fill(.black).frame(width: s * 0.52, height: s * 0.15)
            } else {
                HStack(spacing: s * 0.20) { eye(left: true); eye(left: false) }
            }
        }
        .offset(y: -s * 0.08)
    }

    @ViewBuilder private func eye(left: Bool) -> some View {
        switch expr {
        case .happy, .calm, .proud:
            Arc().stroke(.black.opacity(0.8), style: .init(lineWidth: s * 0.035, lineCap: .round))
                .frame(width: s * 0.14, height: s * 0.09)
        case .sleepy, .bored:
            Capsule().fill(.black.opacity(0.75)).frame(width: s * 0.14, height: s * 0.035)
        case .scared, .surprised:
            ZStack {
                Circle().fill(.white).frame(width: s * 0.17, height: s * 0.18)
                Circle().fill(.black).frame(width: s * 0.08, height: s * 0.08)
            }
        case .love:
            HeartShape().fill(Color(red: 0.95, green: 0.3, blue: 0.4)).frame(width: s * 0.16, height: s * 0.16)
        case .excited:
            StarShape(points: 5).fill(.black.opacity(0.8)).frame(width: s * 0.15, height: s * 0.15)
        case .silly:
            if left { Capsule().fill(.black.opacity(0.8)).frame(width: s * 0.13, height: s * 0.035) }
            else { Circle().fill(.black).frame(width: s * 0.1, height: s * 0.1) }
        case .shy:
            Circle().fill(.black).frame(width: s * 0.08, height: s * 0.08)
        case .laughing:
            Arc().stroke(.black.opacity(0.8), style: .init(lineWidth: s * 0.035, lineCap: .round))
                .frame(width: s * 0.14, height: s * 0.09)
        case .crying, .sick:
            Capsule().fill(.black.opacity(0.75)).frame(width: s * 0.14, height: s * 0.035)
        case .confused:
            if left {
                ZStack {
                    Circle().fill(.white).frame(width: s * 0.16, height: s * 0.17)
                    Circle().fill(.black).frame(width: s * 0.08, height: s * 0.08)
                }
            } else {
                Circle().fill(.black).frame(width: s * 0.1, height: s * 0.1)
            }
        default:
            Circle().fill(.black).frame(width: s * 0.1, height: s * 0.1)
        }
    }

    // MARK: brows
    @ViewBuilder private var brows: some View {
        if expr == .angry || expr == .grumpy {
            HStack(spacing: s * 0.18) {
                Capsule().fill(.black.opacity(0.8)).frame(width: s * 0.18, height: s * 0.04).rotationEffect(.degrees(18))
                Capsule().fill(.black.opacity(0.8)).frame(width: s * 0.18, height: s * 0.04).rotationEffect(.degrees(-18))
            }.offset(y: -s * 0.24)
        } else if expr == .worried || expr == .nervous || expr == .confused {
            HStack(spacing: s * 0.18) {
                Capsule().fill(.black.opacity(0.7)).frame(width: s * 0.16, height: s * 0.035).rotationEffect(.degrees(-16))
                Capsule().fill(.black.opacity(0.7)).frame(width: s * 0.16, height: s * 0.035).rotationEffect(.degrees(16))
            }.offset(y: -s * 0.25)
        }
    }

    // MARK: mouth
    @ViewBuilder private var mouth: some View {
        switch expr {
        case .happy, .excited, .proud, .silly:
            SmileShape(curl: 1).stroke(.black.opacity(0.8), style: .init(lineWidth: s * 0.045, lineCap: .round))
                .frame(width: s * 0.34, height: s * 0.18).offset(y: s * 0.22)
        case .love:
            SmileShape(curl: 0.7).stroke(.black.opacity(0.8), style: .init(lineWidth: s * 0.045, lineCap: .round))
                .frame(width: s * 0.3, height: s * 0.15).offset(y: s * 0.22)
        case .calm, .shy:
            SmileShape(curl: 0.4).stroke(.black.opacity(0.75), style: .init(lineWidth: s * 0.04, lineCap: .round))
                .frame(width: s * 0.24, height: s * 0.1).offset(y: s * 0.22)
        case .sad, .worried, .grumpy:
            SmileShape(curl: -0.7).stroke(.black.opacity(0.8), style: .init(lineWidth: s * 0.045, lineCap: .round))
                .frame(width: s * 0.3, height: s * 0.15).offset(y: s * 0.27)
        case .angry:
            SmileShape(curl: -0.6).stroke(.black.opacity(0.8), style: .init(lineWidth: s * 0.05, lineCap: .round))
                .frame(width: s * 0.3, height: s * 0.15).offset(y: s * 0.27)
        case .scared, .surprised:
            Ellipse().fill(.black.opacity(0.8)).frame(width: s * 0.16, height: s * 0.2).offset(y: s * 0.25)
        case .sleepy:
            Ellipse().fill(.black.opacity(0.7)).frame(width: s * 0.1, height: s * 0.13).offset(y: s * 0.24)
        case .bored:
            Capsule().fill(.black.opacity(0.7)).frame(width: s * 0.24, height: s * 0.035).offset(y: s * 0.24)
        case .laughing:
            Ellipse().fill(.black.opacity(0.8)).frame(width: s * 0.24, height: s * 0.18).offset(y: s * 0.2)
        case .cool:
            SmileShape(curl: 0.8).stroke(.black.opacity(0.8), style: .init(lineWidth: s * 0.045, lineCap: .round))
                .frame(width: s * 0.34, height: s * 0.18).offset(y: s * 0.22)
        case .crying:
            SmileShape(curl: -0.7).stroke(.black.opacity(0.8), style: .init(lineWidth: s * 0.045, lineCap: .round))
                .frame(width: s * 0.3, height: s * 0.15).offset(y: s * 0.27)
        case .nervous, .confused, .sick:
            Capsule().fill(.black.opacity(0.7)).frame(width: s * 0.18, height: s * 0.035).offset(y: s * 0.25)
        }
    }

    // MARK: blush + extras
    @ViewBuilder private var blush: some View {
        if expr == .shy || expr == .proud || expr == .love {
            HStack(spacing: s * 0.34) {
                Circle().fill(Color.pink.opacity(0.5)).frame(width: s * 0.13, height: s * 0.13)
                Circle().fill(Color.pink.opacity(0.5)).frame(width: s * 0.13, height: s * 0.13)
            }.offset(y: s * 0.10)
        }
    }

    @ViewBuilder private var extras: some View {
        switch expr {
        case .sad:
            Circle().fill(Color(red: 0.4, green: 0.7, blue: 1.0))
                .frame(width: s * 0.09, height: s * 0.12).offset(x: -s * 0.17, y: s * 0.1)
        case .sleepy:
            Text("z").font(.system(size: s * 0.22, weight: .black, design: .rounded))
                .foregroundStyle(.black.opacity(0.5)).offset(x: s * 0.28, y: -s * 0.26)
        case .love:
            HeartShape().fill(Color(red: 0.95, green: 0.3, blue: 0.4))
                .frame(width: s * 0.12, height: s * 0.12).offset(x: s * 0.3, y: -s * 0.28)
        case .grumpy:
            Capsule().fill(.white.opacity(0.7)).frame(width: s * 0.06, height: s * 0.12)
                .offset(x: s * 0.26, y: -s * 0.12)
        case .crying:
            HStack(spacing: s * 0.24) {
                Capsule().fill(Color(red: 0.4, green: 0.7, blue: 1.0)).frame(width: s * 0.07, height: s * 0.18)
                Capsule().fill(Color(red: 0.4, green: 0.7, blue: 1.0)).frame(width: s * 0.07, height: s * 0.18)
            }.offset(y: s * 0.05)
        case .nervous, .sick:
            Capsule().fill(Color(red: 0.4, green: 0.7, blue: 1.0)).frame(width: s * 0.06, height: s * 0.12)
                .offset(x: s * 0.24, y: -s * 0.06)
        default: EmptyView()
        }
    }
}

// MARK: - Shapes

struct SmileShape: Shape {
    /// curl > 0 smile, < 0 frown, 0 flat.
    var curl: CGFloat = 1
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.midY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.midY),
                       control: CGPoint(x: r.midX, y: r.midY + curl * r.height))
        return p
    }
}

struct HeartShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let w = r.width, h = r.height
        p.move(to: CGPoint(x: w/2, y: h))
        p.addCurve(to: CGPoint(x: 0, y: h*0.3),
                   control1: CGPoint(x: w*0.5, y: h*0.75),
                   control2: CGPoint(x: 0, y: h*0.55))
        p.addArc(center: CGPoint(x: w*0.25, y: h*0.3), radius: w*0.25,
                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addArc(center: CGPoint(x: w*0.75, y: h*0.3), radius: w*0.25,
                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addCurve(to: CGPoint(x: w/2, y: h),
                   control1: CGPoint(x: w, y: h*0.55),
                   control2: CGPoint(x: w*0.5, y: h*0.75))
        p.closeSubpath()
        return p
    }
}
