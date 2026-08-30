import SwiftUI

enum Theme {
    // YouTube-style dark palette
    static let bg = Color(red: 0.055, green: 0.055, blue: 0.055)      // #0F0F0F
    static let surface = Color(red: 0.13, green: 0.13, blue: 0.13)    // #212121
    static let surfaceHi = Color(red: 0.20, green: 0.20, blue: 0.20)  // hover/active
    // Primary accent. The kid build wears YouTube red; the grown-up Admin
    // build wears USC Cardinal (#990000) so the two apps are easy to tell
    // apart. Everything that uses Theme.red / redGradient follows this.
    #if PARENT
    static let red = Color(red: 0.60, green: 0.0, blue: 0.0)          // USC Cardinal #990000 (parent Mac)
    static let redDeep = Color(red: 0.45, green: 0.0, blue: 0.0)
    #else
    static let red = Color(red: 1.0, green: 0.0, blue: 0.0)           // #FF0000 (Gabriel's devices)
    static let redDeep = Color(red: 0.80, green: 0.0, blue: 0.0)
    #endif
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.67, green: 0.67, blue: 0.67) // #AAAAAA
    static let gold = Color(red: 1.0, green: 0.80, blue: 0.0)         // USC Gold #FFCC00
    static let green = Color(red: 0.18, green: 0.78, blue: 0.44)
    // "Needs a look" alert styling. Cardinal red is too dark to read on the
    // black background, so we use a bright rose ink on a soft pink fill — clearly
    // the "stop / red" message, but legible on dark and on the light pill.
    static let alertInk = Color(red: 1.0, green: 0.36, blue: 0.44)    // readable rose-red
    static let alertFill = Color(red: 1.0, green: 0.80, blue: 0.84)   // soft pink
    // USC brand colors, always available (cardinal follows Theme.red in Admin).
    static let cardinal = Color(red: 0.60, green: 0.0, blue: 0.0)     // #990000
    static let uscGold = Color(red: 1.0, green: 0.80, blue: 0.0)      // #FFCC00

    static var redGradient: LinearGradient {
        LinearGradient(colors: [red, redDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension View {
    /// Standard YouTube-ish card surface.
    func ytSurface(_ radius: CGFloat = 14) -> some View {
        self.background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

/// Big tappable answer / action button.
struct YTButtonStyle: ButtonStyle {
    var background: AnyShapeStyle
    var foreground: Color = .white
    var radius: CGFloat = 14
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// A reusable "thumbnail" that stands in for a video preview: a subject-colored
/// gradient with a big play triangle, an icon, and a duration badge.
struct LessonThumbnail: View {
    let skill: Skill
    var height: CGFloat = 200
    var done: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [skill.subject.color.opacity(0.95),
                                    skill.subject.color.opacity(0.55)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: skill.subject.icon)
                .font(.system(size: height * 0.42, weight: .bold))
                .foregroundStyle(.white.opacity(0.18))
            // play button
            ZStack {
                Circle().fill(.black.opacity(0.45)).frame(width: 64, height: 64)
                Image(systemName: done ? "checkmark" : "play.fill")
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(.white)
                    .offset(x: done ? 0 : 2)
            }
            // duration badge
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(done ? "WATCHED" : skill.duration)
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(done ? Theme.green : .black.opacity(0.78))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(8)
                }
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
