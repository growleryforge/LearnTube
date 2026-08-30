import SwiftUI

// MARK: - Farm story characters (vector, render everywhere)

struct HenView: View {
    var size: CGFloat = 120
    var body: some View {
        let s = size
        ZStack {
            // body
            Ellipse().fill(.white)
                .overlay(Ellipse().stroke(Color(white: 0.85), lineWidth: 1))
                .frame(width: s * 0.8, height: s * 0.62).offset(y: s * 0.12)
            // tail
            Triangle().fill(.white).overlay(Triangle().stroke(Color(white: 0.85), lineWidth: 1))
                .frame(width: s * 0.3, height: s * 0.34)
                .rotationEffect(.degrees(-35)).offset(x: -s * 0.36, y: -s * 0.02)
            // head
            Circle().fill(.white).overlay(Circle().stroke(Color(white: 0.85), lineWidth: 1))
                .frame(width: s * 0.4, height: s * 0.4).offset(x: s * 0.22, y: -s * 0.18)
            // comb
            HStack(spacing: s * 0.015) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle().fill(Color(red: 0.9, green: 0.2, blue: 0.2)).frame(width: s * 0.1, height: s * 0.1)
                }
            }.offset(x: s * 0.22, y: -s * 0.38)
            // wattle
            Capsule().fill(Color(red: 0.9, green: 0.2, blue: 0.2)).frame(width: s * 0.07, height: s * 0.12)
                .offset(x: s * 0.30, y: -s * 0.04)
            // beak
            Triangle().fill(Color(red: 0.95, green: 0.65, blue: 0.15))
                .frame(width: s * 0.12, height: s * 0.09).rotationEffect(.degrees(90))
                .offset(x: s * 0.42, y: -s * 0.16)
            // eye
            Circle().fill(.black).frame(width: s * 0.05, height: s * 0.05).offset(x: s * 0.26, y: -s * 0.22)
            // wing
            Ellipse().fill(Color(white: 0.92)).frame(width: s * 0.3, height: s * 0.22).offset(x: -s * 0.02, y: s * 0.12)
            // legs
            HStack(spacing: s * 0.12) {
                Capsule().fill(Color(red: 0.95, green: 0.65, blue: 0.15)).frame(width: s * 0.025, height: s * 0.12)
                Capsule().fill(Color(red: 0.95, green: 0.65, blue: 0.15)).frame(width: s * 0.025, height: s * 0.12)
            }.offset(y: s * 0.42)
        }
        .frame(width: size, height: size)
    }
}

struct RoosterView: View {
    var size: CGFloat = 120
    var sleeping: Bool = false
    var body: some View {
        let s = size
        ZStack {
            // colorful tail
            ForEach(0..<3, id: \.self) { i in
                let colors = [Color(red: 0.2, green: 0.6, blue: 0.5),
                              Color(red: 0.3, green: 0.5, blue: 0.85),
                              Color(red: 0.95, green: 0.6, blue: 0.2)]
                Capsule().fill(colors[i])
                    .frame(width: s * 0.12, height: s * 0.5)
                    .rotationEffect(.degrees(Double(-55 + i * 18)))
                    .offset(x: -s * 0.34, y: -s * 0.12)
            }
            // body
            Ellipse().fill(Color(red: 0.78, green: 0.36, blue: 0.22))
                .frame(width: s * 0.7, height: s * 0.6).offset(y: s * 0.14)
            // head
            Circle().fill(Color(red: 0.85, green: 0.45, blue: 0.28))
                .frame(width: s * 0.4, height: s * 0.4).offset(x: s * 0.24, y: -s * 0.2)
            // big comb
            HStack(spacing: s * 0.015) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule().fill(Color(red: 0.9, green: 0.18, blue: 0.18))
                        .frame(width: s * 0.09, height: s * (0.12 + CGFloat(i % 2) * 0.06))
                }
            }.offset(x: s * 0.24, y: -s * 0.42)
            // wattle
            Capsule().fill(Color(red: 0.9, green: 0.18, blue: 0.18)).frame(width: s * 0.09, height: s * 0.16)
                .offset(x: s * 0.32, y: -s * 0.04)
            // beak
            Triangle().fill(Color(red: 0.95, green: 0.7, blue: 0.15))
                .frame(width: s * 0.13, height: s * 0.1).rotationEffect(.degrees(90))
                .offset(x: s * 0.45, y: -s * 0.18)
            // eye (open, or closed when sleeping)
            if sleeping {
                Capsule().fill(.black).frame(width: s * 0.08, height: s * 0.02).offset(x: s * 0.27, y: -s * 0.23)
                Text("z").font(.system(size: s * 0.16, weight: .black, design: .rounded))
                    .foregroundStyle(.black.opacity(0.55)).offset(x: s * 0.46, y: -s * 0.42)
            } else {
                Circle().fill(.black).frame(width: s * 0.05, height: s * 0.05).offset(x: s * 0.28, y: -s * 0.24)
            }
            // legs
            HStack(spacing: s * 0.12) {
                Capsule().fill(Color(red: 0.95, green: 0.7, blue: 0.15)).frame(width: s * 0.03, height: s * 0.13)
                Capsule().fill(Color(red: 0.95, green: 0.7, blue: 0.15)).frame(width: s * 0.03, height: s * 0.13)
            }.offset(y: s * 0.44)
        }
        .frame(width: size, height: size)
    }
}

struct GoatView: View {
    var size: CGFloat = 120
    var body: some View {
        let s = size
        let tan = Color(red: 0.86, green: 0.80, blue: 0.70)
        ZStack {
            // body
            Capsule().fill(tan).frame(width: s * 0.6, height: s * 0.42).offset(y: s * 0.2)
            // horns
            ForEach(0..<2, id: \.self) { i in
                Capsule().fill(Color(white: 0.55))
                    .frame(width: s * 0.06, height: s * 0.22)
                    .rotationEffect(.degrees(i == 0 ? -18 : 18))
                    .offset(x: s * (i == 0 ? -0.1 : 0.1), y: -s * 0.36)
            }
            // ears
            ForEach(0..<2, id: \.self) { i in
                Ellipse().fill(tan).frame(width: s * 0.22, height: s * 0.1)
                    .rotationEffect(.degrees(i == 0 ? 20 : -20))
                    .offset(x: s * (i == 0 ? -0.22 : 0.22), y: -s * 0.16)
            }
            // face
            Ellipse().fill(tan).frame(width: s * 0.42, height: s * 0.46).offset(y: -s * 0.16)
            // muzzle
            Ellipse().fill(.white).frame(width: s * 0.26, height: s * 0.2).offset(y: -s * 0.05)
            // nostrils
            HStack(spacing: s * 0.07) {
                Circle().fill(.black.opacity(0.6)).frame(width: s * 0.025, height: s * 0.025)
                Circle().fill(.black.opacity(0.6)).frame(width: s * 0.025, height: s * 0.025)
            }.offset(y: -s * 0.04)
            // eyes
            HStack(spacing: s * 0.14) {
                Circle().fill(.black).frame(width: s * 0.05, height: s * 0.05)
                Circle().fill(.black).frame(width: s * 0.05, height: s * 0.05)
            }.offset(y: -s * 0.2)
            // beard
            Triangle().fill(.white).frame(width: s * 0.1, height: s * 0.12)
                .rotationEffect(.degrees(180)).offset(y: s * 0.08)
        }
        .frame(width: size, height: size)
    }
}

struct DogView: View {  // Bodhi (default) or Kona (pass a coat color)
    var size: CGFloat = 120
    var coat: Color = Color(red: 0.72, green: 0.52, blue: 0.34)
    var ears: Color = Color(red: 0.55, green: 0.38, blue: 0.24)
    var body: some View {
        let s = size
        let brown = coat
        let dark = ears
        ZStack {
            // body
            Capsule().fill(brown).frame(width: s * 0.6, height: s * 0.4).offset(y: s * 0.22)
            // ears (floppy)
            ForEach(0..<2, id: \.self) { i in
                Ellipse().fill(dark).frame(width: s * 0.16, height: s * 0.32)
                    .offset(x: s * (i == 0 ? -0.24 : 0.24), y: -s * 0.12)
            }
            // head
            Circle().fill(brown).frame(width: s * 0.46, height: s * 0.46).offset(y: -s * 0.14)
            // snout
            Ellipse().fill(Color(red: 0.85, green: 0.70, blue: 0.52)).frame(width: s * 0.26, height: s * 0.2).offset(y: -s * 0.04)
            // nose
            Ellipse().fill(.black).frame(width: s * 0.1, height: s * 0.07).offset(y: -s * 0.1)
            // eyes
            HStack(spacing: s * 0.16) {
                Circle().fill(.black).frame(width: s * 0.055, height: s * 0.055)
                Circle().fill(.black).frame(width: s * 0.055, height: s * 0.055)
            }.offset(y: -s * 0.2)
            // tongue
            Capsule().fill(Color(red: 0.95, green: 0.45, blue: 0.5)).frame(width: s * 0.07, height: s * 0.1).offset(y: s * 0.04)
            // collar
            Capsule().fill(Color(red: 0.2, green: 0.55, blue: 0.85)).frame(width: s * 0.34, height: s * 0.05).offset(y: s * 0.08)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Props

struct MoonArt: View {
    var size: CGFloat = 60
    var body: some View {
        Circle().fill(Color(red: 0.97, green: 0.95, blue: 0.78))
            .overlay(Circle().fill(Color(red: 0.9, green: 0.88, blue: 0.66)).frame(width: size * 0.22, height: size * 0.22).offset(x: size * 0.18, y: -size * 0.1))
            .frame(width: size, height: size)
    }
}

struct HayArt: View {
    var size: CGFloat = 100
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6).fill(Color(red: 0.92, green: 0.78, blue: 0.36))
            VStack(spacing: size * 0.12) {
                ForEach(0..<3, id: \.self) { _ in
                    Rectangle().fill(Color(red: 0.80, green: 0.65, blue: 0.26)).frame(height: 2)
                }
            }.padding(.horizontal, size * 0.1)
        }
        .frame(width: size, height: size * 0.6)
    }
}

// MARK: - Scenes

enum StoryScene: Hashable {
    case title, nightWake, problem, pasture, barn, hayloft, sunrise
    case counting   // original counting critters
    case family     // Gabriel and his pet siblings (real photos)
}

/// A pet/person photo cropped into a clean circular avatar (no white box).
struct PetAvatar: View {
    let imageName: String
    var size: CGFloat = 84
    var body: some View {
        Image(imageName)
            .resizable().scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(.white, lineWidth: size * 0.04))
            .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
    }
}

/// An original, generic big-eyed critter for the counting lesson.
struct CountPal: View {
    var color: Color
    var size: CGFloat = 90
    var body: some View {
        let s = size
        ZStack {
            // feet
            HStack(spacing: s * 0.18) {
                Capsule().fill(color).frame(width: s * 0.12, height: s * 0.16)
                Capsule().fill(color).frame(width: s * 0.12, height: s * 0.16)
            }.offset(y: s * 0.44)
            // body
            RoundedRectangle(cornerRadius: s * 0.36, style: .continuous)
                .fill(LinearGradient(colors: [color, color.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                .frame(width: s * 0.72, height: s * 0.86)
            // belly
            Ellipse().fill(.white.opacity(0.28)).frame(width: s * 0.4, height: s * 0.5).offset(y: s * 0.12)
            // arms
            HStack(spacing: s * 0.74) {
                Capsule().fill(color).frame(width: s * 0.1, height: s * 0.26)
                Capsule().fill(color).frame(width: s * 0.1, height: s * 0.26)
            }.offset(y: s * 0.05)
            // eyes
            HStack(spacing: s * 0.14) { eye; eye }.offset(y: -s * 0.16)
            // smile
            SmileShape(curl: 0.7).stroke(.black.opacity(0.6), style: .init(lineWidth: s * 0.04, lineCap: .round))
                .frame(width: s * 0.24, height: s * 0.1).offset(y: s * 0.06)
        }
        .frame(width: size, height: size)
    }
    private var eye: some View {
        ZStack {
            Circle().fill(.white).frame(width: size * 0.2, height: size * 0.2)
            Circle().fill(.black).frame(width: size * 0.1, height: size * 0.1)
        }
    }
}

struct StorySceneView: View {
    let scene: StoryScene
    var height: CGFloat = 230

    var body: some View {
        ZStack {
            background
            content
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder private var background: some View {
        switch scene {
        case .title, .pasture, .barn, .hayloft, .counting, .family:
            LinearGradient(colors: [Color(red: 0.65, green: 0.85, blue: 0.98), Color(red: 0.86, green: 0.95, blue: 0.86)],
                           startPoint: .top, endPoint: .bottom)
            Hills().fill(Color(red: 0.42, green: 0.74, blue: 0.42)).frame(height: 70).frame(maxHeight: .infinity, alignment: .bottom)
        case .nightWake, .problem:
            LinearGradient(colors: [Color(red: 0.10, green: 0.12, blue: 0.30), Color(red: 0.20, green: 0.24, blue: 0.45)],
                           startPoint: .top, endPoint: .bottom)
            Hills().fill(Color(red: 0.16, green: 0.30, blue: 0.22)).frame(height: 70).frame(maxHeight: .infinity, alignment: .bottom)
        case .sunrise:
            LinearGradient(colors: [Color(red: 1.0, green: 0.80, blue: 0.45), Color(red: 0.97, green: 0.93, blue: 0.72)],
                           startPoint: .top, endPoint: .bottom)
            Hills().fill(Color(red: 0.50, green: 0.74, blue: 0.40)).frame(height: 70).frame(maxHeight: .infinity, alignment: .bottom)
        }
    }

    @ViewBuilder private var content: some View {
        switch scene {
        case .title:
            VStack {
                HStack(spacing: -6) { RoosterView(size: 88); HenView(size: 74) }
                HStack(spacing: -10) {
                    GoatView(size: 74)
                    DogView(size: 74, coat: Color(red: 0.94, green: 0.84, blue: 0.58),
                            ears: Color(red: 0.84, green: 0.71, blue: 0.44))
                    DogView(size: 74, coat: Color(red: 0.80, green: 0.46, blue: 0.26),
                            ears: Color(red: 0.64, green: 0.34, blue: 0.18))
                }
            }
        case .nightWake:
            MoonArt(size: 52).offset(x: 120, y: -70)
            ForEach(0..<3, id: \.self) { i in StarShape(points: 5).fill(.white.opacity(0.8))
                .frame(width: 10, height: 10).offset(x: CGFloat(-120 + i * 70), y: -75) }
            HenView(size: 110).offset(y: 20)
        case .problem:
            MoonArt(size: 46).offset(x: 130, y: -72)
            HenView(size: 110).offset(y: 20)
        case .pasture:
            HStack(spacing: 8) { HenView(size: 96); GoatView(size: 104) }.offset(y: 14)
        case .barn:
            HStack(spacing: 2) {
                HenView(size: 72); GoatView(size: 76)
                DogView(size: 80, coat: Color(red: 0.94, green: 0.84, blue: 0.58),
                        ears: Color(red: 0.84, green: 0.71, blue: 0.44))
                DogView(size: 80, coat: Color(red: 0.80, green: 0.46, blue: 0.26),
                        ears: Color(red: 0.64, green: 0.34, blue: 0.18))
            }.offset(y: 14)
        case .hayloft:
            VStack(spacing: 0) {
                RoosterView(size: 86, sleeping: true).rotationEffect(.degrees(8))
                HayArt(size: 150)
            }.offset(y: -6)
        case .sunrise:
            Circle().fill(Color(red: 1.0, green: 0.86, blue: 0.30)).frame(width: 80, height: 80).offset(y: 40)
            RoosterView(size: 110).offset(y: -8)
        case .counting:
            HStack(spacing: 4) {
                CountPal(color: Color(red: 0.95, green: 0.45, blue: 0.45), size: 84)
                CountPal(color: Color(red: 0.35, green: 0.62, blue: 0.92), size: 84).offset(y: -6)
                CountPal(color: Color(red: 0.45, green: 0.78, blue: 0.45), size: 84)
                CountPal(color: Color(red: 0.78, green: 0.55, blue: 0.88), size: 84).offset(y: -6)
            }.offset(y: 6)
        case .family:
            VStack(spacing: 5) {
                PetAvatar(imageName: "GabeMascot", size: 60)
                HStack(spacing: 1) {
                    ForEach(["EllieCat", "PistachioCat", "PJCat", "TigerCat", "GrandmaCat", "PixleyCat", "PuffCat"], id: \.self) { name in
                        PetAvatar(imageName: name, size: 33)
                    }
                }
                HStack(spacing: 6) {
                    PetAvatar(imageName: "Bodhi", size: 42)
                    PetAvatar(imageName: "Kona", size: 42)
                }
            }.offset(y: 2)
        }
    }
}


// MARK: - Kittens (Ellie the tortie & Pistachio the grey tabby)

struct CatView: View {
    enum Kind { case pistachio, ellie }
    var kind: Kind
    var size: CGFloat = 90

    var body: some View {
        Image(kind == .ellie ? "EllieCat" : "PistachioCat")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}
