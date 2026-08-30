import SwiftUI

// MARK: - Story model

struct StoryPage: Identifiable {
    let id = UUID()
    let scene: StoryScene
    let text: String
}

/// One answer choice: an emoji plus a label.
struct StoryChoice: Identifiable, Hashable {
    let id = UUID()
    let emoji: String
    let label: String
    let correct: Bool
}

/// A question that shows the relevant story picture above it, plus a short
/// "re-teach" of the idea. `prompts` holds several wordings; one is chosen at
/// random each play so the answer can't be memorized by position or phrasing.
struct StoryQuestion: Identifiable {
    let id = UUID()
    let scene: StoryScene
    let teach: String
    let prompts: [String]
    let choices: [StoryChoice]
    /// Optional emoji "picture" shown above the question. When set, it replaces
    /// the fixed scene art so the things on screen match the numbers being asked
    /// (e.g. ["🐱","🐱","🐱","➕","🐶","🐶"] for 3 cats + 2 dogs).
    var visual: [String] = []
}

/// One step in a put-in-order game: an emoji plus a label.
struct OrderStep: Identifiable, Hashable {
    let id = UUID()
    let emoji: String
    let label: String
}

/// A story game: an emoji quiz, a put-in-order game, or a reused engine.
enum StoryActivity {
    case quiz([StoryQuestion])
    case order(prompt: String, steps: [OrderStep])   // steps given in correct order
    case lesson(Lesson)
    case addition(AdditionLevel)                     // procedural addition (fresh each play)
    case sortCount(SortLevel)                        // sort animals into groups, count each
    case shapes(ShapeLevel)                          // name & describe 2D shapes
    case shapeSpot(ShapeSpotLevel)                   // spot a shape at any size/orientation
    case letters(LetterLevel)                        // find letters by name or sound
    case weather(WeatherLevel)                       // observe & describe weather
    case numbers(NumberLevel)                        // match a numeral to a quantity
    case symbols(SymbolLevel)                        // identify national symbols
    case helpers(HelperLevel)                        // identify community helpers
    case holidays(HolidayLevel)                      // know what holidays celebrate
    case familyMembers(FamilyMemberLevel)            // name family members & roles
    case patterns(PatternLevel)                      // what comes next (patterns)
    case rhymes(RhymeLevel)                          // words that rhyme
    case geo(GeoLevel)                               // 2D flat vs 3D solid shapes
    case living(LivingLevel)                         // sort plants & animals by traits
    case compare(CompareLevel)                       // bigger/smaller, taller, heavier
    case build(BuildLevel)                           // compose simple shapes into a picture
    case critterCount(CritterCountLevel)             // "how many?" - count critters, tap the number
    case familyAdd(FamilyAddLevel)                   // "how many in all?" - add two groups, tap the total
    case wordProblem(WordProblemLevel)               // visual add/subtract story problems within 20
    case pushPull(PushPullLevel)                     // push or pull (forces)
    case needs(NeedsLevel)                           // what living things need
    case position(PosLevel)                          // position words: on top / under / next to
    case sight(SightLevel)                           // high-frequency sight words
    case numberOrder(NumOrderLevel)                  // number order & compare
    case animalHomes(AnimalHomeLevel)                // which animal lives where
    case legs(LegsLevel)                             // how many legs
    case coverings(CoverLevel)                       // fur / feathers / scales
    case eats(EatLevel)                              // what animals eat
    case teen(TeenLevel)                             // teen numbers: ten and some more
    case baby(BabyLevel)                             // baby animals look like parents
    case alive(LiveLevel)                            // living or not living
    case dayNight(DNLevel)                            // day or night animals
    case make5(Make5Level)                            // make 5
    case whichMore(MoreLevel)                         // which group has more
    case egg(EggLevel)                                // egg or not
    case wild(WildLevel)                              // wild or pet
    case make10(Make10Level)                          // make ten with a missing part
    case takeAway(TakeAwayLevel)                      // subtraction within 10
    case doubles(DoublesLevel)                        // doubles facts
    case ordinal(OrdinalLevel)                        // first, second, third
    case beginningSound(SoundLevel)                   // letter-sound match
    case lifeCycle(CycleLevel)                        // living things grow & change
    case countTens(TensLevel)                         // count by tens
    case fastSlow(SpeedLevel)                         // fast or slow animals
    case sinkFloat(FloatLevel)                        // sink or float
    case letterCase(CaseLevel)                        // big & little letters
    case fiveSenses(SenseLevel)                       // five senses
    case opposites(OppLevel)                          // word opposites
}

struct StoryGame: Identifiable {
    let id = UUID()
    let skill: String
    let activity: StoryActivity
}

struct StoryContent {
    let id: String
    let title: String
    let author: String
    let covers: String
    var darkPages: Bool = false   // true = dark reading cards (for non-storybook lessons)
    let pages: [StoryPage]
    let games: [StoryGame]
}

// Concise helpers (used by all lessons)
func sc(_ emoji: String, _ label: String, _ ok: Bool = false) -> StoryChoice {
    StoryChoice(emoji: emoji, label: label, correct: ok)
}
func sq(_ scene: StoryScene, _ teach: String, _ prompts: [String], _ choices: [StoryChoice]) -> StoryQuestion {
    StoryQuestion(scene: scene, teach: teach, prompts: prompts, choices: choices)
}
/// Like `sq`, but with an emoji picture that matches the numbers in the question.
func sqv(_ visual: [String], _ teach: String, _ prompts: [String], _ choices: [StoryChoice]) -> StoryQuestion {
    StoryQuestion(scene: .family, teach: teach, prompts: prompts, choices: choices, visual: visual)
}

enum Stories {
    static func story(id: String) -> StoryContent? {
        switch id {
        case sunSleptIn.id: return sunSleptIn
        case countingCritters.id: return countingCritters
        case familyMath.id: return familyMath
        case farmSort.id: return farmSort
        case shapesLesson.id: return shapesLesson
        case shapeSpotLesson.id: return shapeSpotLesson
        case letterDetective.id: return letterDetective
        case weatherWatch.id: return weatherWatch
        case numberDetective.id: return numberDetective
        case americanSymbols.id: return americanSymbols
        case communityHelpers.id: return communityHelpers
        case holidaysLesson.id: return holidaysLesson
        case myFamily.id: return myFamily
        case patternsLesson.id: return patternsLesson
        case rhymeLesson.id: return rhymeLesson
        case flatSolidLesson.id: return flatSolidLesson
        case livingThingsLesson.id: return livingThingsLesson
        case compareLesson.id: return compareLesson
        case buildShapeLesson.id: return buildShapeLesson
        case storyProblems.id: return storyProblems
        case pushPullLesson.id: return pushPullLesson
        case needsLesson.id: return needsLesson
        case positionLesson.id: return positionLesson
        case sightLesson.id: return sightLesson
        case numberOrderLesson.id: return numberOrderLesson
        case animalHomesLesson.id: return animalHomesLesson
        case legsLesson.id: return legsLesson
        case coveringsLesson.id: return coveringsLesson
        case eatsLesson.id: return eatsLesson
        case teenLesson.id: return teenLesson
        case babyLesson.id: return babyLesson
        case livingNotLesson.id: return livingNotLesson
        case dayNightLesson.id: return dayNightLesson
        case make5Lesson.id: return make5Lesson
        case whichMoreLesson.id: return whichMoreLesson
        case eggLesson.id: return eggLesson
        case wildLesson.id: return wildLesson
        case make10Lesson.id: return make10Lesson
        case takeAwayLesson.id: return takeAwayLesson
        case doublesLesson.id: return doublesLesson
        case ordinalLesson.id: return ordinalLesson
        case soundLesson.id: return soundLesson
        case lifeCycleLesson.id: return lifeCycleLesson
        case countTensLesson.id: return countTensLesson
        case fastSlowLesson.id: return fastSlowLesson
        case sinkFloatLesson.id: return sinkFloatLesson
        case letterCaseLesson.id: return letterCaseLesson
        case fiveSensesLesson.id: return fiveSensesLesson
        case oppositesLesson.id: return oppositesLesson
        case syllablesLesson.id: return syllablesLesson
        case animalGroupsLesson.id: return animalGroupsLesson
        case animalSoundsLesson.id: return animalSoundsLesson
        case seasonsLesson.id: return seasonsLesson
        case moveHowLesson.id: return moveHowLesson
        case countBy5Lesson.id: return countBy5Lesson
        case countBy2Lesson.id: return countBy2Lesson
        case babyNamesLesson.id: return babyNamesLesson
        case plantPartsLesson.id: return plantPartsLesson
        case hotColdLesson.id: return hotColdLesson
        case countCrittersLesson.id: return countCrittersLesson
        case addAllLesson.id: return addAllLesson
        case countBy2ShoesLesson.id: return countBy2ShoesLesson
        case countBy5HandsLesson.id: return countBy5HandsLesson
        default: return nil
        }
    }

    static let sunSleptIn = StoryContent(
        id: "sun-slept-in",
        title: "The Day the Sun Slept In",
        author: "Maddy Turley",
        covers: "This story covers all 9 Kindergarten reading skills: key details, beginning-middle-end, characters and setting, new words, story vs. poem, author and illustrator, how pictures help, comparing characters, and reading with interest.",
        darkPages: true,
        pages: [
            StoryPage(scene: .nightWake,
                      text: "🌅 The farm was dark and quiet. Henrietta the 🐔 hen woke up."),
            StoryPage(scene: .problem,
                      text: "\"Where is 🐓 Rooster? He crows to wake the ☀️ sun!\""),
            StoryPage(scene: .pasture,
                      text: "She ran to the 🌱 pasture. 🐐 Maple the goat came to help."),
            StoryPage(scene: .barn,
                      text: "At the 🛖 barn, the 🐕 dogs Bodhi and Kona sniffed for Rooster."),
            StoryPage(scene: .hayloft,
                      text: "They found 🐓 Rooster asleep 😴 in the 🌾 hay. He overslept!"),
            StoryPage(scene: .sunrise,
                      text: "\"Cock-a-doodle-doo! 🐓\" The ☀️ sun came up. The farm woke up. 😊")
        ],
        games: [
            // 1. Key details
            StoryGame(skill: "Key details", activity: .quiz([
                sq(.problem,
                   "🌅 Henrietta the 🐔 hen woke up, but the farm was still 🌙 dark and quiet. Someone special was missing!",
                   ["Who was Henrietta looking for? 🔍",
                    "Henrietta was searching for someone. Who was it?",
                    "Who did Henrietta want to find?"],
                   [sc("🐔", "Rooster", true), sc("🍎", "A snack"), sc("🥚", "Her eggs")]),
                sq(.sunrise,
                   "🐓 Rooster has a BIG job! When he crows, the ☀️ sun comes up and the whole farm 🐮🐷 wakes up.",
                   ["Why does Rooster crow? 🎺",
                    "What is Rooster's special job?",
                    "What does Rooster's crow do?"],
                   [sc("☀️", "To wake the sun", true), sc("🍽️", "To find food"), sc("🎲", "To play")]),
                sq(.hayloft,
                   "🐕 Bodhi sniffed and sniffed and led everyone up high. There was 🐓 Rooster, fast asleep in the 🌾 hay!",
                   ["Where was Rooster hiding? 🔎",
                    "Where did they finally find Rooster?",
                    "Where was Rooster sleeping?"],
                   [sc("🌾", "In the hay loft", true), sc("💧", "In the pond"), sc("🏚️", "Under the barn")])
            ])),
            // 2. Beginning, middle, end
            StoryGame(skill: "Beginning, middle, end", activity: .order(
                prompt: "What happened in the story? Tap them in order.",
                steps: [
                    OrderStep(emoji: "🌙", label: "Henrietta wakes up in the dark"),
                    OrderStep(emoji: "🔍", label: "Her friends help her search"),
                    OrderStep(emoji: "😴", label: "They find Rooster asleep in the hay"),
                    OrderStep(emoji: "☀️", label: "Rooster crows and the sun rises")
                ])),
            // 3. Characters & setting
            StoryGame(skill: "Characters & setting", activity: .quiz([
                sq(.pasture,
                   "🎭 The characters are the WHO of a story. Ours are 🐔 Henrietta, 🐐 Maple, 🐕 Bodhi, and 🐓 Rooster.",
                   ["Who is a character in the story? 🎭",
                    "Which one is a character?",
                    "Pick a character from our story."],
                   [sc("🐐", "Maple the goat", true), sc("🚲", "A bicycle"), sc("☁️", "A cloud")]),
                sq(.title,
                   "🗺️ The setting is the WHERE. Our whole story happens in one place, with a 🛖 barn and a 🌱 pasture.",
                   ["Where does the story happen? 🗺️",
                    "What is the setting of the story?",
                    "Where does our story take place?"],
                   [sc("🚜", "On the farm", true), sc("🏖️", "At the beach"), sc("🚀", "In space")]),
                sq(.hayloft,
                   "🤔 Characters are living things that DO things. The 🌾 hay is just a thing Rooster slept on.",
                   ["Which one is NOT a character? 🚫",
                    "Which one is just a thing, not a character?",
                    "Which of these is NOT alive in the story?"],
                   [sc("🌾", "The hay", true), sc("🐶", "Bodhi"), sc("🐔", "Henrietta")])
            ])),
            // 4. New words
            StoryGame(skill: "New words", activity: .quiz([
                sq(.nightWake,
                   "🌅 Henrietta woke up at DAWN. Dawn is the early morning time when the ☀️ sun first comes up.",
                   ["What does DAWN mean? 🌅", "DAWN is the time when...", "When does dawn happen?"],
                   [sc("☀️", "When the sun comes up", true), sc("🌱", "A grassy field"), sc("🛖", "The top of the barn")]),
                sq(.pasture,
                   "🌱 Henrietta hurried to the PASTURE. A pasture is a big grassy field 🌾 where the animals eat.",
                   ["What does PASTURE mean? 🌱", "A PASTURE is...", "What is a pasture?"],
                   [sc("🌱", "A grassy field", true), sc("☀️", "When the sun comes up"), sc("😴", "Slept too long")]),
                sq(.hayloft,
                   "🛖 They found Rooster in the HAY LOFT. A hay loft is the space up high at the top of the barn, full of 🌾 hay.",
                   ["What does HAY LOFT mean? 🛖", "A HAY LOFT is...", "Where is the hay loft?"],
                   [sc("🛖", "The top of the barn", true), sc("🌱", "A grassy field"), sc("💧", "In the pond")]),
                sq(.hayloft,
                   "😴 Rooster OVERSLEPT! That means he slept too long ⏰ and missed his job of waking the sun.",
                   ["What does OVERSLEPT mean? 😴", "OVERSLEPT means...", "What did Rooster do?"],
                   [sc("😴", "Slept too long", true), sc("🌱", "A grassy field"), sc("🏃", "Ran away fast")])
            ])),
            // 5. Story or poem
            StoryGame(skill: "Story or poem?", activity: .quiz([
                sq(.title,
                   "📖 A story tells what happens. A 🎵 poem is shorter, and the ending words often rhyme, like a little song.",
                   ["What does a poem often do? 🎵",
                    "What is special about a poem?",
                    "A poem usually does this:"],
                   [sc("🎵", "Rhymes", true), sc("📚", "Has chapters"), sc("📜", "Is always long")]),
                sq(.sunrise,
                   "🎶 Listen: 'the sky is 💙 blue, cock-a-doodle-🐓 doo!' Blue and doo rhyme, so it is a poem.",
                   ["\"...sky so blue, cock-a-doodle-doo\" is a... 🎵",
                    "The little rhyme Rooster sings is a...",
                    "A short rhyme like that is called a..."],
                   [sc("🎵", "Poem", true), sc("📖", "Story"), sc("📋", "List")])
            ])),
            // 6. Author & illustrator
            StoryGame(skill: "Author & illustrator", activity: .quiz([
                sq(.title,
                   "✍️ Every book has helpers. The author is the person who thinks up and writes all the 📝 words.",
                   ["The author makes the... ✍️",
                    "An author's job is to make the...",
                    "The author of a book writes the..."],
                   [sc("✍️", "Words", true), sc("🎨", "Pictures"), sc("🎵", "Music")]),
                sq(.title,
                   "🎨 The illustrator is the helper who draws all the 🖼️ pictures that go with the words.",
                   ["The illustrator makes the... 🎨",
                    "An illustrator's job is to make the...",
                    "The illustrator of a book draws the..."],
                   [sc("🎨", "Pictures", true), sc("✍️", "Words"), sc("🍪", "Snacks")]),
                sq(.title,
                   "🌟 Maddy Turley did BOTH jobs — she wrote the ✍️ words AND drew the 🎨 pictures!",
                   ["Maddy did both jobs, so she is the... 🌟",
                    "Maddy wrote AND drew it, so she is the...",
                    "Someone who writes and draws a book is the..."],
                   [sc("🌟", "Author and illustrator", true), sc("👀", "Reader only"), sc("🖨️", "Printer")])
            ])),
            // 7. Pictures help
            StoryGame(skill: "Pictures help", activity: .quiz([
                sq(.nightWake,
                   "🖼️ Pictures help us understand a story. In the first picture, the 🌙 moon and ⭐ stars show it is night.",
                   ["In the first picture, the sky is... 🌙",
                    "What does the first picture tell us about the sky?",
                    "Look at picture one. The sky looks..."],
                   [sc("🌙", "Dark", true), sc("☀️", "Sunny"), sc("🌸", "Pink")]),
                sq(.hayloft,
                   "👀 Look closely at this picture. 🐓 Rooster is lying in the 🌾 hay with his eyes shut. 😴",
                   ["In the hay loft picture, Rooster is... 😴",
                    "What is Rooster doing in this picture?",
                    "The picture shows Rooster..."],
                   [sc("😴", "Asleep", true), sc("🦅", "Flying"), sc("🏊", "Swimming")]),
                sq(.sunrise,
                   "🌅 The last picture is bright and golden. That big yellow circle is the ☀️ sun coming up over the hills.",
                   ["The last picture shows the... ☀️",
                    "What is in the last picture?",
                    "Look at the final picture. It shows the..."],
                   [sc("☀️", "Sun rising", true), sc("🌙", "Moon"), sc("🌧️", "Rain")])
            ])),
            // 8. Compare friends
            StoryGame(skill: "Compare friends", activity: .quiz([
                sq(.barn,
                   "🐕 Bodhi is a dog, and dogs have a super 👃 nose. He used it to follow Rooster's tracks. 🐾",
                   ["How did Bodhi help? 🐾",
                    "What did Bodhi do to help find Rooster?",
                    "Bodhi helped the friends by..."],
                   [sc("👃", "Sniffed the tracks", true), sc("🦅", "Flew up high"), sc("🏊", "Swam across")]),
                sq(.pasture,
                   "🐐 Maple the goat is a good friend. She had no special nose, but she came along to 🔍 help search.",
                   ["How did Maple help? 🐐",
                    "What did Maple do to help?",
                    "Maple was a good friend because she..."],
                   [sc("🐐", "Came along to search", true), sc("🍳", "Cooked dinner"), sc("😴", "Kept sleeping")]),
                sq(.barn,
                   "🤝 Bodhi and Maple are different animals, but they did the same kind thing — they both helped 🐔 Henrietta.",
                   ["Bodhi and Maple BOTH... 🤝",
                    "What did Bodhi AND Maple both do?",
                    "What is the same about Bodhi and Maple?"],
                   [sc("🤝", "Helped Henrietta", true), sc("🙈", "Hid from her"), sc("🐓", "Crowed loudly")])
            ])),
            // 9. Favorite part (every answer is right)
            StoryGame(skill: "Your favorite part", activity: .quiz([
                sq(.sunrise,
                   "🎉 You read the WHOLE story! Good readers have favorite parts, and there is no wrong answer here. 💛",
                   ["Which part did you like best? ⭐",
                    "What was your favorite part of the story?",
                    "Which part did you enjoy the most?"],
                   [sc("🌙", "The night search", true), sc("🐓", "Finding Rooster", true), sc("☀️", "The sunrise", true)])
            ]))
        ]
    )
}
