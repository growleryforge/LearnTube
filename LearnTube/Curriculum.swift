import SwiftUI

// MARK: - Subjects

enum Subject: String, Codable, CaseIterable, Identifiable {
    case reading, writing, math, science, life
    var id: String { rawValue }

    var title: String {
        switch self {
        case .reading: return "Reading"
        case .writing: return "Writing"
        case .math: return "Math"
        case .science: return "Science"
        case .life: return "Life Skills"
        }
    }

    var emoji: String {
        switch self {
        case .reading: return "📖"
        case .writing: return "✏️"
        case .math: return "🔢"
        case .science: return "🔬"
        case .life: return "🌻"
        }
    }

    /// SF Symbol used for the subject badge (always renders, unlike emoji).
    var icon: String {
        switch self {
        case .reading: return "book.fill"
        case .writing: return "pencil.and.outline"
        case .math: return "number.square.fill"
        case .science: return "leaf.fill"
        case .life: return "heart.fill"
        }
    }

    var color: Color {
        switch self {
        case .reading: return Color(red: 0.36, green: 0.51, blue: 0.90)
        case .writing: return Color(red: 0.85, green: 0.45, blue: 0.55)
        case .math:    return Color(red: 0.30, green: 0.62, blue: 0.47)
        case .science: return Color(red: 0.55, green: 0.42, blue: 0.78)
        case .life:    return Color(red: 0.92, green: 0.66, blue: 0.25)
        }
    }
}

// MARK: - Skill

struct Skill: Identifiable, Hashable {
    let id: String          // stable id, e.g. "K-M1"
    let grade: Int          // 0 = Kindergarten, 1..12
    let subject: Subject
    let title: String       // short name of the skill
    let standard: String    // CA standard code
    let activity: String    // the "video description" hook
    let parentTip: String   // a gentle, PDA-aware note for Paige
    let lesson: Lesson      // the interactive content Gabriel completes on screen

    /// A fun, YouTube-style duration badge. Not a real timer - just flavor - so
    /// it's a stable pseudo-value per lesson (varied, not collision-prone like
    /// the old id.count formula that made everything read "9:49").
    var duration: String {
        let seed = id.unicodeScalars.reduce(0) { $0 &+ Int($1.value) &* 17 }
        let mins = 3 + (seed % 6)        // 3...8 minutes
        let secs = (seed / 6) % 60       // 0...59 seconds
        return String(format: "%d:%02d", mins, secs)
    }

    /// Stable pseudo "view count" so cards feel like YouTube.
    var viewCount: String {
        let n = (abs(id.hashValue) % 900) + 12
        return n > 99 ? "\(n)K views" : "\(n)0 views"
    }

    static func == (lhs: Skill, rhs: Skill) -> Bool { lhs.id == rhs.id }
    func hash(into h: inout Hasher) { h.combine(id) }
}

// MARK: - Grade

struct Grade: Identifiable {
    let number: Int
    let name: String
    var skills: [Skill]
    var isSeeded: Bool { !skills.isEmpty }
    var id: Int { number }
}

// MARK: - Curriculum

enum Curriculum {

    static let gradeNames: [Int: String] = [
        -2: "Warm-Ups",
        -1: "TK",
        0: "Kindergarten", 1: "1st Grade", 2: "2nd Grade", 3: "3rd Grade",
        4: "4th Grade", 5: "5th Grade", 6: "6th Grade", 7: "7th Grade",
        8: "8th Grade", 9: "9th Grade", 10: "10th Grade", 11: "11th Grade",
        12: "12th Grade"
    ]

    /// The concepts currently live in the app. When non-empty, Home shows ONLY
    /// these (in order). Add more ids here as new concepts are approved.
    static let liveStops: [String] = [
        // ===== Warm-Ups — quick, heavily-taught wins that bridge toward First
        // Grade (teen numbers, add/take-away to 5, blending, sight words). They
        // lead the feed, teach first, and still earn YouTube time like any game.
        "WU-M1", "WU-M4", "WU-M5", "WU-M6", "WU-M2", "WU-M3", "WU-R1", "WU-R2", "WU-R3",
        // ===== Transitional Kindergarten — the gentle on-ramp, shown first =====
        // Patterns (TK-M5) pulled for now — he taps the last item every time, the
        // concept isn't landing yet. Still in the app to bring back later.
        "TK-M1", "TK-M2", "TK-M3", "TK-M4", "TK-M6", "TK-C1",
        "TK-R1", "TK-R2", "TK-R3",
        "TK-S1", "TK-S2", "TK-S3", "TK-L1",
        // NEW — concrete "count what you see" number games, in his winning style,
        // up top so he sees them first (replace the abstract skip-counting).
        "K-NUM1", "K-NUM2", "K-NUM3", "K-NUM4",
        // Animals & nature (K science) — the animal-emoji games first
        "K-S18", "K-S19", "K-S21", "K-S20", "K-S22", "K-S23",
        "K-S6", "K-MATH12", "K-S7", "K-S8", "K-S9", "K-S12", "K-S13", "K-S10", "K-S11",
        "K-S2", "K-S3", "K-S4", "K-S14", "K-S15", "K-S16", "K-S17",
        // Abstract K math (symbolic add/subtract, place value, MATH11-type) is
        // pulled — it was mostly losses. His math is the concrete count-and-add
        // games above and in Warm-Ups/Stretch. K math stays in the app for later.
        // Reading & letters (the long story K-STORY1 pulled — too much at once)
        "K-R14", "K-R15", "K-R9", "K-R3", "K-R10", "K-R11", "K-R5", "K-R6", "K-R12", "K-R13", "K-R7", "K-R8",
        // Writing — trace letters with a finger
        "K-W1", "K-W2", "K-W3",
        // Life & social (Name Your Feelings drag + Days-of-Week ordering pulled —
        // both too hard; TK "Happy or Sad?" covers feelings gently now)
        "K-SS1", "K-SS2", "K-SS3", "K-SS4", "K-L3", "K-M5",
        // Stretch — almost first grade, still winnable (add/take-away to 10,
        // number sequences, one-sentence reading). The next challenge up.
        "ST-M1", "ST-M2", "ST-M4", "ST-M5", "ST-M6", "ST-M3", "ST-R1", "ST-R2",
        // Bridge to First Grade — the number-entry math ladder, ordered
        // confidence-first (±1, doubles, teen build) then forward into real
        // First-Grade work (count on, make ten, add/subtract within 20, ten
        // more/less). All concrete numberPad games in his winning style, and
        // graded First Grade so the Progress tab shows him moving up.
        "BR-M1", "BR-M2", "BR-M3", "BR-M4", "BR-M5", "BR-M6", "BR-M7", "BR-M8", "BR-M9"
        // The rest of First grade is still NOT in his daily feed yet — he's still
        // working through TK and Kindergarten, and serving First Grade games
        // (add/subtract within 20, long stories) just piled up losses. When he's
        // ready, add the G1 IDs back here. The First Grade games still exist and
        // still show full progress on the Progress tab.
    ]

    /// A short, kid-friendly lesson shown on a teaching card BEFORE each game,
    /// so every game teaches the idea first instead of just testing it. Falls
    /// back to the skill's `activity` line for anything not listed here.
    static let teachNotes: [String: String] = [
        // ----- First grade -----
        "G1-R1": "Long vowels say their own name, like the A in CAKE. Short vowels are quick, like the a in CAT. Listen for the name!",
        "G1-R2": "Some letters team up to make ONE sound: SH says shhh, CH says choo-choo, TH says this. Two letters, one sound.",
        "G1-R3": "Some words we just KNOW by sight, like 'said' and 'the'. You don't sound them out, you just remember them.",
        "G1-R4": "Good readers stop and think. Read the sentence, then answer what happened in it.",
        "G1-R5": "Asking words: WHO is a person, WHERE is a place, WHEN is a time, WHY is a reason.",
        "G1-R6": "The main idea is what the story is MOSTLY about. Ask yourself: what's the big thing here?",
        "G1-R7": "In a blend you hear each letter, but they slide together fast, like S+T in STOP or B+L in BLUE.",
        "G1-W1": "A sentence has a naming part (who) and an action part (does what). It starts with a capital and ends with a period.",
        "G1-W2": "A FACT is true for everyone. An OPINION is what someone feels, like 'I think ice cream is best'.",
        "G1-W3": "Stories go in order: first, next, then, last. Put the parts in the order they happened.",
        "G1-M1": "Numbers keep going past 100! After 119 comes 120. Keep counting up and don't stop at 100.",
        "G1-M2": "Adding puts groups together to get MORE. 8 + 5 means start at 8 and count up 5 more.",
        "G1-M3": "Subtracting means taking AWAY. 14 − 6 means start at 14 and count back 6.",
        "G1-M5": "A two-digit number has tens and ones. In 34, the 3 means 3 tens (30) and the 4 means 4 ones.",
        "G1-M6": "The > sign is like a hungry mouth that eats the BIGGER number. 54 > 45.",
        "G1-M7": "To measure length, line up units end to end, like paperclips, and count how many fit.",
        "G1-M8": "On a clock the SHORT hand shows the hour, the LONG hand shows minutes. Long hand on 12 means o'clock!",
        "G1-M9": "Tally marks count by ones: one line for each thing. The 5th mark crosses the group so you can count by 5s.",
        "G1-M10": "Halves are 2 EQUAL parts. Fourths are 4 EQUAL parts. Equal means all the same size.",
        "G1-S1": "We need LIGHT to see. SOUND happens when something shakes, or vibrates, like a drum or a guitar string.",
        "G1-S2": "Every part has a job! Roots drink water, leaves catch sunlight, wings help birds fly, ears help us hear.",
        "G1-S3": "The sun rises in the morning and sets at night. The moon and stars come out at night. It repeats every day.",
        "G1-L1": "A date has a day, a month, and a year. A calendar helps us find what day today is.",
        "G1-L2": "A penny is 1¢, a nickel is 5¢, a dime is 10¢, a quarter is 25¢. Coins are worth different amounts.",
        "G1-L3": "When big feelings come, we can pause and breathe slow. Breathe in like smelling a flower, out like blowing a candle.",
        "G1-M4": "Word problems tell a little story with numbers. Read it, find the numbers, then decide to add or take away.",
        // ----- Newer kindergarten games -----
        "K-R14": "Syllables are the beats in a word. Clap as you say it: el-e-phant has 3 claps!",
        "K-R15": "Baby animals have special names. A baby dog is a puppy, a baby cat is a kitten, a baby cow is a calf.",
        "K-S18": "Animals come in groups: mammals have fur, birds have feathers, fish have fins, insects have 6 legs.",
        "K-S19": "Every animal makes its own sound. A cow says moo, a duck says quack, a sheep says baa.",
        "K-S20": "The year has 4 seasons: spring flowers, hot summer, falling leaves in fall, and cold snowy winter.",
        "K-S21": "Animals move in different ways. Fish swim, birds fly, dogs walk. How does each one get around?",
        "K-S22": "A plant has parts with jobs: roots drink water, the stem holds it up, leaves catch sun, the flower makes seeds.",
        "K-S23": "Some things are HOT, like the sun and fire. Some are COLD, like ice and snow. Be careful with hot things!",
        "K-MATH21": "Counting by 5s is like counting hands: 5, 10, 15, 20. It's a quick way to count.",
        "K-MATH22": "Counting by 2s skips every other number: 2, 4, 6, 8. It's faster than counting by ones!",
        // ----- Writing (finger tracing) -----
        "K-W1": "Your name is special! Follow the dots with your finger to trace each letter of your name.",
        "K-W2": "Capital letters are the BIG letters. Follow the dots with your finger to trace each one.",
        "K-W3": "To label something, you write its first letter. Say the animal, hear the first sound, then trace that letter.",
        // ----- Reading gap-fillers -----
        "K-R3": "Every letter makes a sound. A says 'ah', B says 'buh'. Match the letter to its sound.",
        "K-R5": "To read a word, blend the sounds together: c-a-t makes 'cat'. Slide the sounds into one word.",
        "K-R6": "Star words like see, go, is, like, and 'and' pop up in every sentence. Read the whole sentence and pick the word that makes it make sense.",
        "K-R7": "Stories happen in order. Think about what happened FIRST, then next, then last.",
        "K-R8": "A book has a front cover, and we read the words from left to right, top to bottom.",
        "K-L2": "The week has 7 days in order: Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday.",
        "K-L3": "Being a helper means doing kind things, like cleaning up or helping a friend. Helpers make everyone happy.",
        // ----- Concrete number games (his winning style) -----
        "K-NUM1": "Counting means saying one number for each thing. Point to each animal: 1, 2, 3... The last number is how many!",
        "K-NUM2": "To add, put both groups together and count them ALL. 2 chicks and 2 more chicks — count all of them: 4!",
        "K-NUM3": "Things come in pairs — 2 at a time, like shoes. Count the pairs: 2, 4, 6. That's counting by 2s!",
        "K-NUM4": "One hand has 5 fingers. Count hands by 5s: 5, 10, 15. Each new hand adds 5 more!",
        // ----- Bridge to First Grade (number-entry ladder) -----
        "BR-M1": "One MORE means the very next number. 6 and one more is 7. Count them all and type how many.",
        "BR-M2": "One LESS means the number right before. 7 and one goes away leaves 6. Count what's left.",
        "BR-M3": "Doubles are two groups the SAME size. 7 and 7 is 14. Learn these and big adding gets easy!",
        "BR-M4": "A teen number is a full ten and some more. See the ten, then count on the extras: ten and 4 is 14.",
        "BR-M5": "Counting on is a smart shortcut: start at the BIG number and count up the little one. Start at 12, count 13, 14, 15.",
        "BR-M6": "To make ten, fill every spot. Count the EMPTY boxes — that's how many more you need to reach ten.",
        "BR-M7": "Adding past ten works the same way: put both groups together and count them all, right across ten.",
        "BR-M8": "Taking away from a bigger number: start at the number and count back, or count up from the smaller one.",
        "BR-M9": "Ten more or ten less only changes the TENS. Ten more than 25 is 35. Ten less than 30 is 20."
    ]

    /// All 13 levels (K + grades 1-12). K and 1 are seeded; the rest grow over time.
    static var grades: [Grade] {
        (-2...12).map { n in
            Grade(number: n, name: gradeNames[n] ?? "Grade \(n)", skills: skills(for: n))
        }
    }

    static func skills(for grade: Int) -> [Skill] {
        switch grade {
        case -2: return warmUps
        case -1: return transitionalK
        case 0: return kindergarten + stretch
        case 1: return firstGrade + bridge
        default: return []
        }
    }

    static var allSeededSkills: [Skill] { warmUps + transitionalK + kindergarten + stretch + firstGrade + bridge }

    static func skill(id: String) -> Skill? {
        allSeededSkills.first { $0.id == id }
    }
}
