import Foundation

extension Curriculum {

    static let firstGrade: [Skill] = [

        // ---------- Reading ----------
        Skill(id: "G1-R1", grade: 1, subject: .reading,
              title: "Short and Long Vowels",
              standard: "CA CCSS RF.1.2a",
              activity: "Long vowel or short vowel? Carry each word to its pen!",
              parentTip: "Stretch the vowel: cake says a long A, cat says short a.",
              lesson: .sort(prompt: "Does the vowel say its NAME (long) or its short sound? Carry each word over.",
                            bins: [SortBin("long", "Long (says its name)", "🦒"), SortBin("short", "Short", "🐜")],
                            items: [
                              SortThing("cake", "cake", "long"), SortThing("ride", "ride", "long"),
                              SortThing("rope", "rope", "long"), SortThing("bike", "bike", "long"),
                              SortThing("cat", "cat", "short"), SortThing("pig", "pig", "short"),
                              SortThing("hop", "hop", "short"), SortThing("bed", "bed", "short")
                            ], perRound: 6)),

        Skill(id: "G1-R2", grade: 1, subject: .reading,
              title: "Team Sounds (sh, ch, th)",
              standard: "CA CCSS RF.1.3a",
              activity: "Sh, ch or th? Carry each word to the sound it starts with!",
              parentTip: "sh, ch, th each make one sound from two letters.",
              lesson: .sort(prompt: "Which team sound does it start with? Carry it to that pen.",
                            bins: [SortBin("sh", "sh", "sh"), SortBin("ch", "ch", "ch"), SortBin("th", "th", "th")],
                            items: [
                              SortThing("🚢", "ship", "sh"), SortThing("🐑", "sheep", "sh"), SortThing("👟", "shoe", "sh"),
                              SortThing("🐥", "chick", "ch"), SortThing("🧀", "cheese", "ch"), SortThing("🍒", "cherry", "ch"),
                              SortThing("👍", "thumb", "th"), SortThing("🧵", "thread", "th"), SortThing("3️⃣", "three", "th")
                            ], perRound: 6)),

        Skill(id: "G1-R3", grade: 1, subject: .reading,
              title: "Word-Wall Words",
              standard: "CA CCSS RF.1.3g",
              activity: "Drag the word-wall word into the sentence!",
              parentTip: "A few each day beats all of them at once.",
              lesson: .buildSentence(prompt: "Drag in the word-wall word that finishes the sentence.", lines: [
                SentenceLine("👋", "She", "hello to me.", answer: "said", distractors: ["sed", "sayd"]),
                SentenceLine("👫", "", "are my good friends.", answer: "They", distractors: ["Thay", "Tey"]),
                SentenceLine("❓", "", "is your name?", answer: "What", distractors: ["Wut", "Whut"])
              ])),

        Skill(id: "G1-R4", grade: 1, subject: .reading,
              title: "Read and Answer",
              standard: "CA CCSS RF.1.4",
              activity: "Read the sentence, then drag in the word that answers it!",
              parentTip: "Reading for meaning is the goal. Read it together if he likes.",
              lesson: .buildSentence(prompt: "Read it, then drag in the missing word.", lines: [
                SentenceLine("🐔", "The hen is", "", answer: "red", distractors: ["blue", "green"]),
                SentenceLine("🐷", "A pig can", "fast.", answer: "run", distractors: ["fly", "swim"]),
                SentenceLine("🐮🐮", "I see", "cows.", answer: "two", distractors: ["one", "ten"])
              ])),

        Skill(id: "G1-R5", grade: 1, subject: .reading,
              title: "Question Words",
              standard: "CA CCSS RL.1.1",
              activity: "Good readers ask questions. Match the question word to what it asks!",
              parentTip: "Who/what/where/when help him think about a story.",
              lesson: .match(prompt: "Match the question word to what it asks about.",
                             pairs: [.init("Who", "a person"),
                                     .init("Where", "a place"),
                                     .init("When", "a time"),
                                     .init("What", "a thing")])),

        Skill(id: "G1-R6", grade: 1, subject: .reading,
              title: "Main Idea",
              standard: "CA CCSS RI.1.2",
              activity: "Carry each detail to the big idea it belongs to!",
              parentTip: "Prompt: 'In one breath, what was it about?'",
              lesson: .sort(prompt: "What is each one mostly about? Carry it to the big idea.",
                            bins: [SortBin("dog", "Taking care of a dog", "🐶"), SortBin("plant", "How plants grow", "🌱")],
                            items: [
                              SortThing("🥣", "feed the dog", "dog"), SortThing("🪮", "brush the dog", "dog"),
                              SortThing("🦮", "walk the dog", "dog"),
                              SortThing("🌰", "plant a seed", "plant"), SortThing("☀️", "give it sun", "plant"),
                              SortThing("💧", "give it water", "plant")
                            ], perRound: 6)),

        Skill(id: "G1-R9", grade: 1, subject: .reading,
              title: "Hear It, Read It",
              standard: "CA CCSS RF.1.3g",
              activity: "Read the sentence and drag in the First Grade word that fits!",
              parentTip: "Sight words by ear and eye. Read the three choices with him and ask which one Leo said.",
              lesson: .buildSentence(prompt: "Read it. Drag in the word that fits.", lines: [
                SentenceLine("🐔", "The hens", "in the barn.", answer: "were", distractors: ["where", "wear"]),
                SentenceLine("🚜", "We can ride", "lunch.", answer: "after", distractors: ["every", "again"]),
                SentenceLine("🐶", "Can you play", "?", answer: "again", distractors: ["after", "could"]),
                SentenceLine("🌅", "I feed the goats", "day.", answer: "every", distractors: ["when", "were"]),
                SentenceLine("🐴", "I wish I", "ride a horse.", answer: "could", distractors: ["cold", "cloud"]),
                SentenceLine("🌙", "We sleep", "it is dark.", answer: "when", distractors: ["went", "were"])
              ])),

        Skill(id: "G1-R8", grade: 1, subject: .reading,
              title: "Word Builder",
              standard: "CA CCSS RF.K.3 / L.1.2",
              activity: "Build farm words like pig and hen one letter at a time. Leo reads each one back!",
              parentTip: "Say each sound as he taps it, then blend them: p, i, g, pig.",
              lesson: .story(id: "word-builder")),

        Skill(id: "G1-R7", grade: 1, subject: .reading,
              title: "Blends",
              standard: "CA CCSS RF.1.2b",
              activity: "Carry each picture to the blend it starts with!",
              parentTip: "Unlike team sounds, you hear both letters in a blend.",
              lesson: .sort(prompt: "Which blend does it start with? Carry it to that pen.",
                            bins: [SortBin("st", "st", "st"), SortBin("fr", "fr", "fr"), SortBin("cl", "cl", "cl")],
                            items: [
                              SortThing("⭐️", "star", "st"), SortThing("🛑", "stop", "st"),
                              SortThing("🐸", "frog", "fr"), SortThing("🍟", "fries", "fr"),
                              SortThing("👏", "clap", "cl"), SortThing("🕰️", "clock", "cl"), SortThing("🤡", "clown", "cl")
                            ], perRound: 6)),

        // ---------- Writing (hands-on) ----------
        Skill(id: "G1-W1", grade: 1, subject: .writing,
              title: "Build a Sentence",
              standard: "CA CCSS L.1.2b",
              activity: "Tap the words in order to build a sentence that makes sense!",
              parentTip: "It starts with a capital and ends with a period. Point that out.",
              lesson: .order(prompt: "Tap the words in order to make a sentence.",
                             items: ["The", "hen", "ran", "fast."])),

        Skill(id: "G1-W2", grade: 1, subject: .writing,
              title: "Spot the Opinion",
              standard: "CA CCSS W.1.1",
              activity: "Fact or opinion? Carry each one to its pen!",
              parentTip: "A fact can be checked; an opinion is a feeling or favorite.",
              lesson: .sort(prompt: "Is it a FACT anyone can check, or an OPINION someone feels? Carry it over.",
                            bins: [SortBin("fact", "Fact", "🔎"), SortBin("opinion", "Opinion", "💭")],
                            items: [
                              SortThing("🐐", "A goat has four legs.", "fact"), SortThing("🏠", "The barn is red.", "fact"),
                              SortThing("☀️", "Summer is warm.", "fact"),
                              SortThing("🐐", "Goats are the best animal!", "opinion"), SortThing("🎨", "Red is the prettiest color.", "opinion"),
                              SortThing("🏖️", "Summer is the most fun season.", "opinion")
                            ], perRound: 6)),

        Skill(id: "G1-W3", grade: 1, subject: .writing,
              title: "Put the Story in Order",
              standard: "CA CCSS W.1.3",
              activity: "A story happens in order. Tap the parts first to last!",
              parentTip: "Sequencing words: first, then, next, last.",
              lesson: .order(prompt: "Tap the story parts in order.",
                             items: ["First we woke up,", "then we fed the hens,",
                                     "next we found eggs,", "last we ate breakfast."])),

        // ---------- Math ----------
        Skill(id: "G1-M1", grade: 1, subject: .math,
              title: "Count to 120",
              standard: "CA CCSS 1.NBT.1",
              activity: "Put the big numbers in counting order!",
              parentTip: "Starting mid-count is the real skill.",
              lesson: .order(prompt: "Count on past 100. Put the numbers in order.",
                             items: ["98", "99", "100", "101", "102", "103"])),

        Skill(id: "G1-M2", grade: 1, subject: .math,
              title: "Add Within 20",
              standard: "CA CCSS 1.OA.6",
              activity: "Add the numbers and type your answer!",
              parentTip: "Any strategy that gets there is a good one.",
              lesson: .numberPad([
                NumberProblem("8 + 5 = ?", 13,
                    visual: Array(repeating: "🔵", count: 8) + ["➕"] + Array(repeating: "🟠", count: 5)),
                NumberProblem("9 + 6 = ?", 15,
                    visual: Array(repeating: "🔵", count: 9) + ["➕"] + Array(repeating: "🟠", count: 6)),
                NumberProblem("7 + 7 = ?", 14,
                    visual: Array(repeating: "🔵", count: 7) + ["➕"] + Array(repeating: "🟠", count: 7))
              ])),

        Skill(id: "G1-M3", grade: 1, subject: .math,
              title: "Subtract Within 20",
              standard: "CA CCSS 1.OA.6",
              activity: "Take away and type what's left!",
              parentTip: "Counting up or counting back both work.",
              lesson: .numberPad([
                NumberProblem("14 - 6 = ?", 8),
                NumberProblem("17 - 8 = ?", 9),
                NumberProblem("18 - 6 = ?", 12)
              ])),

        Skill(id: "G1-M4", grade: 1, subject: .math,
              title: "Story Problems",
              standard: "CA CCSS 1.OA.1",
              activity: "See the story: some come, some go away. Tap how many!",
              parentTip: "He solves it by looking, not reading. Add and subtract within 20.",
              lesson: .story(id: "word-problems")),

        Skill(id: "G1-M5", grade: 1, subject: .math,
              title: "Tens and Ones",
              standard: "CA CCSS 1.NBT.2",
              activity: "Numbers are made of tens and ones. Solve each one!",
              parentTip: "Bundles of ten straws make this real.",
              lesson: .numberPad([
                NumberProblem("3 tens and 4 ones = ?", 34),
                NumberProblem("2 tens and 7 ones = ?", 27),
                NumberProblem("How many ones in 1 ten?", 10)
              ])),

        Skill(id: "G1-M6", grade: 1, subject: .math,
              title: "Compare Numbers",
              standard: "CA CCSS 1.NBT.3",
              activity: "More than 50 or less than 50? Carry each number over!",
              parentTip: "The 'alligator mouth' eats the bigger number.",
              lesson: .sort(prompt: "Look at the TENS. More than 50, or less than 50?",
                            bins: [SortBin("more", "More than 50", "⬆️"), SortBin("less", "Less than 50", "⬇️")],
                            items: [
                              SortThing("54", "fifty-four", "more"), SortThing("70", "seventy", "more"),
                              SortThing("67", "sixty-seven", "more"), SortThing("81", "eighty-one", "more"),
                              SortThing("45", "forty-five", "less"), SortThing("23", "twenty-three", "less"),
                              SortThing("32", "thirty-two", "less"), SortThing("19", "nineteen", "less")
                            ], perRound: 6)),

        Skill(id: "G1-M7", grade: 1, subject: .math,
              title: "Measure with Paperclips",
              standard: "CA CCSS 1.MD.2",
              activity: "Measure by lining up units with no gaps. Solve the measuring puzzle!",
              parentTip: "No gaps and no overlaps is the key rule.",
              lesson: .numberPad([
                NumberProblem("How long is the pencil? Count the clips!", 5, visual: ["📎","📎","📎","📎","📎"]),
                NumberProblem("A carrot is 4 clips, a worm is 1 clip. How many longer is the carrot?", 3),
                NumberProblem("3 clips + 3 clips of length = ? clips", 6)
              ])),

        Skill(id: "G1-M8", grade: 1, subject: .math,
              title: "Tell Time",
              standard: "CA CCSS 1.MD.3",
              activity: "O'clock or half past? Carry each clock to its pen!",
              parentTip: "The short hand is the hour, the long hand is minutes.",
              lesson: .sort(prompt: "Is it o'clock or half past? Carry each clock over.",
                            bins: [SortBin("oclock", "O'clock", "🕛"), SortBin("half", "Half past", "🕧")],
                            items: [
                              SortThing("🕐", "one o'clock", "oclock"), SortThing("🕒", "three o'clock", "oclock"),
                              SortThing("🕖", "seven o'clock", "oclock"),
                              SortThing("🕜", "half past one", "half"), SortThing("🕞", "half past three", "half"),
                              SortThing("🕢", "half past seven", "half")
                            ], perRound: 6)),

        Skill(id: "G1-M9", grade: 1, subject: .math,
              title: "Tally and Count",
              standard: "CA CCSS 1.MD.4",
              activity: "Tally marks count in groups. Solve the counting puzzle!",
              parentTip: "Four lines and a slash makes a group of five.",
              lesson: .numberPad([
                NumberProblem("4 chickens + 3 goats = how many animals?", 7),
                NumberProblem("A group of tally marks (a 5) plus 2 more = ?", 7),
                NumberProblem("6 dogs, 2 run away. How many left?", 4)
              ])),

        Skill(id: "G1-M10", grade: 1, subject: .math,
              title: "Halves and Fourths",
              standard: "CA CCSS 1.G.3",
              activity: "Halves or fourths? Carry each one to its pen!",
              parentTip: "Sharing a snack equally makes this real.",
              lesson: .sort(prompt: "Two equal parts, or four? Carry each one over.",
                            bins: [SortBin("half", "Halves (2 parts)", "🌗"), SortBin("fourth", "Fourths (4 parts)", "🍕")],
                            items: [
                              SortThing("🍊", "an orange cut in half", "half"), SortThing("🥪", "a sandwich cut in 2", "half"),
                              SortThing("🍎", "an apple cut in half", "half"),
                              SortThing("🥧", "a pie cut in 4", "fourth"), SortThing("🧇", "a waffle cut in 4", "fourth"),
                              SortThing("🍫", "a bar cut in 4", "fourth")
                            ], perRound: 6)),

        // ---------- Science ----------
        Skill(id: "G1-S1", grade: 1, subject: .science,
              title: "Light and Sound",
              standard: "CA NGSS 1-PS4",
              activity: "Makes sound or makes light? Carry each one over!",
              parentTip: "Let him feel his throat hum to feel a vibration.",
              lesson: .sort(prompt: "Does it make SOUND or LIGHT? Carry each one over.",
                            bins: [SortBin("sound", "Sound", "🔊"), SortBin("light", "Light", "💡")],
                            items: [
                              SortThing("🥁", "drum", "sound"), SortThing("🔔", "bell", "sound"), SortThing("🎸", "guitar", "sound"),
                              SortThing("🔦", "flashlight", "light"), SortThing("🕯️", "candle", "light"), SortThing("☀️", "sun", "light")
                            ], perRound: 6)),

        Skill(id: "G1-S2", grade: 1, subject: .science,
              title: "Plant and Animal Parts",
              standard: "CA NGSS 1-LS1-1",
              activity: "Body parts have jobs. Match the part to what it does!",
              parentTip: "Walk the farm and let him be the tour guide after.",
              lesson: .match(prompt: "Match the part to its job.",
                             pairs: [.init("Roots", "drink water"),
                                     .init("Wings", "help fly"),
                                     .init("Ears", "hear sounds"),
                                     .init("Leaves", "catch sunlight")])),

        Skill(id: "G1-S3", grade: 1, subject: .science,
              title: "Sky Patterns",
              standard: "CA NGSS 1-ESS1-1",
              activity: "Day sky or night sky? Carry each one over!",
              parentTip: "A few nights of moon drawings show the pattern.",
              lesson: .sort(prompt: "Do we see it in the DAY sky or the NIGHT sky?",
                            bins: [SortBin("day", "Day", "🌞"), SortBin("night", "Night", "🌙")],
                            items: [
                              SortThing("☀️", "the sun", "day"), SortThing("🌈", "a rainbow", "day"), SortThing("🌤️", "white clouds", "day"),
                              SortThing("🌕", "the moon", "night"), SortThing("⭐️", "stars", "night"), SortThing("🦉", "an owl flying", "night")
                            ], perRound: 6)),

        // ---------- Life Skills ----------
        Skill(id: "G1-L1", grade: 1, subject: .life,
              title: "Today's Date",
              standard: "CA Calendar",
              activity: "A date has a month, day, and year. Put a date in order!",
              parentTip: "A wall calendar he can point to helps.",
              lesson: .order(prompt: "Put a date in the right order.",
                             items: ["Month", "Day", "Year"])),

        Skill(id: "G1-L2", grade: 1, subject: .life,
              title: "Know Your Coins",
              standard: "CA CCSS 1 (Money)",
              activity: "Coins are worth different amounts. Match each coin to its value!",
              parentTip: "Real coins to hold make the values stick.",
              lesson: .match(prompt: "Match the coin to how much it's worth.",
                             pairs: [.init("Penny", "1 cent"),
                                     .init("Nickel", "5 cents"),
                                     .init("Dime", "10 cents"),
                                     .init("Quarter", "25 cents")])),

        Skill(id: "G1-L3", grade: 1, subject: .life,
              title: "Calm-Down Game",
              standard: "CA SEL",
              activity: "Helps you calm down, or not? Carry each one over!",
              parentTip: "Knowing the tools when calm makes them easier to use later.",
              lesson: .sort(prompt: "Does it help you calm down? Carry each one over.",
                            bins: [SortBin("calm", "Helps me calm", "😌"), SortBin("not", "Not helpful", "🙅")],
                            items: [
                              SortThing("🌬️", "slow belly breaths", "calm"), SortThing("🛋️", "a quiet spot", "calm"),
                              SortThing("🧸", "hug a soft toy", "calm"),
                              SortThing("📣", "yell louder", "not"), SortThing("🧱", "throw things", "not"),
                              SortThing("👊", "hit something", "not")
                            ], perRound: 6))
    ]
}

// MARK: - Stretch games (almost first grade, still winnable)
//
// A step up from the warm-ups: bigger numbers (add/take-away to 10, number
// sequences) and real one-sentence reading — the sophistication of First Grade
// but scaffolded so he still wins. Grade 0 (Kindergarten tier) so they live
// alongside K on the Progress tab, and they use the teach-after-2 engines.
extension Curriculum {
    static let stretch: [Skill] = [
        Skill(id: "ST-M1", grade: 0, subject: .math,
              title: "Big Apple Add-Up",
              standard: "Stretch · CCSS K.OA / 1.OA",
              activity: "Bigger groups now! Put them together and count them all.",
              parentTip: "Same idea as Add to 5, just larger. Counting on from the bigger group is the next step.",
              lesson: .numberGen(.add, rounds: 4, boost: 1)),

        Skill(id: "ST-M2", grade: 0, subject: .math,
              title: "Ten Fish, Some Swim Off",
              standard: "Stretch · CCSS K.OA / 1.OA",
              activity: "Bigger numbers. Some go away — count what's left!",
              parentTip: "Start from 10 and count back. Fingers help: put some down, count what's up.",
              lesson: .numberGen(.takeAway, rounds: 4, boost: 1)),

        Skill(id: "ST-M3", grade: 0, subject: .math,
              title: "Which Number Hid?",
              standard: "Stretch · CCSS K.CC",
              activity: "Numbers go in order. Carry each number to the line it fills!",
              parentTip: "Count out loud together to hear which number was skipped.",
              lesson: .sort(prompt: "Each line is missing a number. Carry the number to its line.",
                            bins: [SortBin("a", "7, 8, ?, 10", "❓"), SortBin("b", "3, 4, 5, ?", "❓"),
                                   SortBin("c", "12, 13, ?, 15", "❓"), SortBin("d", "17, ?, 19, 20", "❓")],
                            items: [
                              SortThing("9", "nine", "a"), SortThing("6", "six", "b"),
                              SortThing("14", "fourteen", "c"), SortThing("18", "eighteen", "d")
                            ], perRound: 4)),

        Skill(id: "ST-M4", grade: 0, subject: .math,
              title: "Twin Bunnies",
              standard: "Stretch · CCSS 1.OA",
              activity: "Two groups the SAME size. Count them all!",
              parentTip: "Doubles are easy to remember and make bigger adding faster: 4 and 4 is 8.",
              lesson: .numberGen(.doubles, rounds: 4)),

        Skill(id: "ST-M5", grade: 0, subject: .math,
              title: "Fill the Nest",
              standard: "Stretch · CCSS K.OA / 1.OA",
              activity: "The nest holds 10 eggs. Count the EMPTY spots to fill it!",
              parentTip: "Ten spots, some have a chick. He counts the empty boxes — the amount needed to make ten. Concrete counting, no mental math.",
              lesson: .numberGen(.makeTen, rounds: 4)),

        Skill(id: "ST-M6", grade: 0, subject: .math,
              title: "Three Little Groups",
              standard: "Stretch · CCSS 1.OA",
              activity: "Three little groups. Put them together and count all!",
              parentTip: "Adding three numbers is a first-grade step. Count every object, group by group.",
              lesson: .numberGen(.addThree, rounds: 4)),

        Skill(id: "ST-R1", grade: 0, subject: .reading,
              title: "Read Along with Leo",
              standard: "Stretch · CCSS RF.1 / RL.1",
              activity: "Read the little sentence, then drag in the word that belongs!",
              parentTip: "He reads one short sentence and answers who or what. That's real comprehension.",
              lesson: .buildSentence(prompt: "Look at the picture. Drag in the word that finishes the sentence.", lines: [
                SentenceLine("🐱", "The", "is big.", answer: "cat", distractors: ["dog", "sun"]),
                SentenceLine("🐶", "A", "can run.", answer: "dog", distractors: ["cat", "bird"]),
                SentenceLine("☀️", "The", "is hot.", answer: "sun", distractors: ["snow", "dog"]),
                SentenceLine("🐞", "I see a", "bug.", answer: "red", distractors: ["blue", "green"])
              ])),

        Skill(id: "ST-R2", grade: 0, subject: .reading,
              title: "Finish the Story",
              standard: "Stretch · CCSS RF.1",
              activity: "Carry the missing word into the sentence and make it make sense!",
              parentTip: "Read the whole sentence with each choice and hear which one sounds right.",
              lesson: .buildSentence(prompt: "A word is missing. Drag the right one into the gap.", lines: [
                SentenceLine("🐶", "I", "the dog.", answer: "see", distractors: ["sun", "sit"]),
                SentenceLine("🏞️", "We", "to the park.", answer: "go", distractors: ["got", "gum"]),
                SentenceLine("🐦", "The bird can", "", answer: "fly", distractors: ["fix", "fun"]),
                SentenceLine("🎂", "I", "a big cake.", answer: "like", distractors: ["lake", "lip"]),
                SentenceLine("🐱", "The cat is", "the mat.", answer: "on", distractors: ["up", "if"]),
                SentenceLine("☀️", "The sun is", "today.", answer: "hot", distractors: ["hat", "hop"])
              ]))
    ]
}

// MARK: - Transitional Kindergarten (TK)
//
// The pre-K year, built to Gabriel's strengths: counting, patterns, shapes,
// letters, and animals (his special interest) come first and concrete. The
// social-emotional pieces are kept light and picture-based, since those are the
// harder asks for him. Everything is short, uses the teach-after-2 engines
// (quiz / number pad) or tap-to-count, and sits AHEAD of Kindergarten (grade -1)
// so it shows first as a gentle on-ramp.
extension Curriculum {
    /// Warm-Ups: short, heavily-scaffolded wins that build the exact skills he
    /// needs before First Grade will click — teen-number sense and add/take-away
    /// to 5 (for math within 20), and blending, beginning sounds, and rhyming
    /// (for reading). Every one teaches first, reveals the answer after two
    /// misses, and earns YouTube time like any other game.
    static let warmUps: [Skill] = [
        Skill(id: "WU-M1", grade: -2, subject: .math,
              title: "Add to 5",
              standard: "Warm-Up · CCSS K.OA",
              activity: "Put the two groups together and count them ALL!",
              parentTip: "Point to every object and count from one — that's what adding is.",
              lesson: .numberGen(.add, rounds: 4)),

        Skill(id: "WU-M2", grade: -2, subject: .math,
              title: "Take Away to 5",
              standard: "Warm-Up · CCSS K.OA",
              activity: "Some go away. Count the ones that are LEFT!",
              parentTip: "Use snacks: start with a few, eat one, count what's left. That's subtracting.",
              lesson: .numberGen(.takeAway, rounds: 4)),

        Skill(id: "WU-M3", grade: -2, subject: .math,
              title: "Teen Numbers",
              standard: "Warm-Up · CCSS K.NBT",
              activity: "A teen number is 10 and some more. Count them all!",
              parentTip: "Ten and 3 more is 13. Seeing the ten first makes the big numbers easy.",
              lesson: .numberGen(.teen, rounds: 4)),

        Skill(id: "WU-M4", grade: -2, subject: .math,
              title: "Count to 10",
              standard: "Warm-Up · CCSS K.CC",
              activity: "Point to each one and count. How many in all?",
              parentTip: "Touch one object per number word, all the way to ten.",
              lesson: .numberGen(.count, rounds: 4)),

        Skill(id: "WU-M5", grade: -2, subject: .math,
              title: "Animal Add-Up!",
              standard: "Warm-Up · CCSS K.OA",
              activity: "More animals come! Put them together and count them all.",
              parentTip: "Act it out with his toy animals: a few here, a few more, count them all.",
              lesson: .numberGen(.add, rounds: 4)),

        Skill(id: "WU-M6", grade: -2, subject: .math,
              title: "Ducks Swim Away!",
              standard: "Warm-Up · CCSS K.OA",
              activity: "Some animals leave! Count the ones that are LEFT.",
              parentTip: "Line up his animals, walk a few away, count who stays.",
              lesson: .numberGen(.takeAway, rounds: 4)),

        Skill(id: "WU-R1", grade: -2, subject: .reading,
              title: "Blend It",
              standard: "Warm-Up · CCSS RF.K.2",
              activity: "Say each sound, push them together, then carry the sounds to the picture!",
              parentTip: "Stretch it slow — c...a...t — then fast: cat! That's blending.",
              lesson: .sort(prompt: "Say the sounds, blend them, and carry them to the picture they make.",
                            bins: [SortBin("cat", "", "🐱"), SortBin("dog", "", "🐶"),
                                   SortBin("pig", "", "🐷"), SortBin("sun", "", "☀️")],
                            items: [
                              SortThing("c a t", "c, a, t", "cat"), SortThing("d o g", "d, o, g", "dog"),
                              SortThing("p i g", "p, i, g", "pig"), SortThing("s u n", "s, u, n", "sun")
                            ], perRound: 4)),

        Skill(id: "WU-R2", grade: -2, subject: .reading,
              title: "Sort the First Sounds",
              standard: "Warm-Up · CCSS RF.K.3",
              activity: "Every word starts with a sound. Drag each one to its letter!",
              parentTip: "Say the word slowly and stretch the first sound: mmmoon starts with m.",
              lesson: .sort(prompt: "Listen to the word. Drag it to the letter it starts with.",
                            bins: [SortBin("d", "d", "d"), SortBin("c", "c", "c"),
                                   SortBin("m", "m", "m"), SortBin("p", "p", "p")],
                            items: [
                              SortThing("🐶", "dog", "d"), SortThing("🦆", "duck", "d"),
                              SortThing("🚪", "door", "d"), SortThing("🥁", "drum", "d"),
                              SortThing("🐱", "cat", "c"), SortThing("🐮", "cow", "c"),
                              SortThing("🚗", "car", "c"), SortThing("🥤", "cup", "c"),
                              SortThing("🌙", "moon", "m"), SortThing("🐭", "mouse", "m"),
                              SortThing("🥛", "milk", "m"), SortThing("🗺️", "map", "m"),
                              SortThing("🐷", "pig", "p"), SortThing("🖊️", "pen", "p"),
                              SortThing("🍐", "pear", "p"), SortThing("🍕", "pizza", "p")
                            ])),

        Skill(id: "WU-R3", grade: -2, subject: .reading,
              title: "Rhyme Families",
              standard: "Warm-Up · CCSS RF.K.2",
              activity: "Rhyming words end the same. Drag each word to its rhyme family!",
              parentTip: "Cat, hat, bat all end in -at. Make silly rhymes together.",
              lesson: .sort(prompt: "Every word lands in the family it rhymes with. Drag it home!",
                            bins: [SortBin("at", "…at  like cat", "🐱"),
                                   SortBin("og", "…og  like dog", "🐶"),
                                   SortBin("ig", "…ig  like pig", "🐷")],
                            items: [
                              SortThing("🎩", "hat", "at"), SortThing("🦇", "bat", "at"),
                              SortThing("🐀", "rat", "at"), SortThing("🧉", "mat", "at"),
                              SortThing("🪵", "log", "og"), SortThing("🐸", "frog", "og"),
                              SortThing("🐗", "hog", "og"), SortThing("🌫️", "fog", "og"),
                              SortThing("💇", "wig", "ig"), SortThing("⛏️", "dig", "ig"),
                              SortThing("🌿", "twig", "ig"), SortThing("🫒", "fig", "ig")
                            ]))
    ]
}

extension Curriculum {
    static let transitionalK: [Skill] = [

        // ---------- Math (concrete counting — his winning style) ----------
        Skill(id: "TK-M1", grade: -1, subject: .math,
              title: "Count to 3",
              standard: "CA PLF Math",
              activity: "Point and count each one: 1, 2, 3. Tap all 3 chicks!",
              parentTip: "Touch one object per number word — that one-to-one touch is the whole skill.",
              lesson: .count(target: 3, symbol: "🐤", prompt: "Tap all 3 chicks!")),

        Skill(id: "TK-M2", grade: -1, subject: .math,
              title: "Count to 5",
              standard: "CA PLF Math",
              activity: "Count each star as you tap it: 1, 2, 3, 4, 5!",
              parentTip: "Counting on fingers or real toys makes this stick.",
              lesson: .count(target: 5, symbol: "⭐️", prompt: "Tap all 5 stars!")),

        Skill(id: "TK-M3", grade: -1, subject: .math,
              title: "How Many Chicks?",
              standard: "CA PLF Math",
              activity: "Count the animals, then tap the number that says how many.",
              parentTip: "The LAST number he counts is the answer — that's cardinality.",
              lesson: .numberGen(.count, rounds: 5)),

        Skill(id: "TK-M4", grade: -1, subject: .math,
              title: "Bigger or Smaller",
              standard: "CA PLF Math",
              activity: "Big animals in one pen, little ones in the other!",
              parentTip: "Compare real things around the house — the bigger cup, the smaller spoon.",
              lesson: .sort(prompt: "Is it BIG or little? Carry it to its pen.",
                            bins: [SortBin("big", "Big", "🐘"), SortBin("small", "Little", "🐭")],
                            items: [
                              SortThing("🐘", "elephant", "big"), SortThing("🐋", "whale", "big"),
                              SortThing("🐻", "bear", "big"), SortThing("🐴", "horse", "big"),
                              SortThing("🦒", "giraffe", "big"), SortThing("🐄", "cow", "big"),
                              SortThing("🐜", "ant", "small"), SortThing("🐝", "bee", "small"),
                              SortThing("🐁", "mouse", "small"), SortThing("🐛", "caterpillar", "small"),
                              SortThing("🐞", "ladybug", "small"), SortThing("🐤", "chick", "small")
                            ], perRound: 6)),

        Skill(id: "TK-M5", grade: -1, subject: .math,
              title: "What Comes Next?",
              standard: "CA PLF Math",
              activity: "Finish the pattern by putting the pieces in order!",
              parentTip: "Make patterns with blocks or snacks: red, blue, red, blue...",
              // Simple ABAB patterns only — two choices, both of which are IN the
              // pattern (no foreign third option, no hard AAB), so it's about
              // "what comes back around" and not a lucky guess. QuizPlayer shows
              // the answer in green after two misses, so he learns the pattern.
              lesson: .order(prompt: "Make the pattern: red, blue, red, blue. Tap them in order.",
                             items: ["🔴", "🔵", "🔴", "🔵", "🔴", "🔵"])),

        // ---------- Shapes & colors ----------
        Skill(id: "TK-M6", grade: -1, subject: .math,
              title: "Find the Shape",
              standard: "CA PLF Math",
              activity: "Shapes have names. Drag each thing to the shape it is!",
              parentTip: "Hunt for circles and squares around the house together.",
              lesson: .sort(prompt: "What shape is it? Drag each one to its shape.",
                            bins: [SortBin("circle", "Circle", "🔵"), SortBin("square", "Square", "🟦"),
                                   SortBin("triangle", "Triangle", "🔺")],
                            items: [
                              SortThing("⚽️", "ball", "circle"), SortThing("🍪", "cookie", "circle"),
                              SortThing("🕐", "clock", "circle"), SortThing("🪙", "coin", "circle"),
                              SortThing("🪟", "window", "square"), SortThing("📦", "box", "square"),
                              SortThing("🧇", "waffle", "square"), SortThing("🖼️", "picture frame", "square"),
                              SortThing("🍕", "pizza slice", "triangle"), SortThing("⛰️", "mountain", "triangle"),
                              SortThing("🎄", "fir tree", "triangle"), SortThing("📐", "set square", "triangle")
                            ], perRound: 9)),

        Skill(id: "TK-C1", grade: -1, subject: .math,
              title: "Colors",
              standard: "CA PLF Math",
              activity: "Each colour has a name. Drag everything into its colour bin!",
              parentTip: "Name colors of his toys and clothes through the day.",
              lesson: .sort(prompt: "Tidy up by colour. Drag each thing into the bin that matches.",
                            bins: [SortBin("red", "Red", "🔴"), SortBin("blue", "Blue", "🔵"),
                                   SortBin("green", "Green", "🟢"), SortBin("yellow", "Yellow", "🟡")],
                            items: [
                              SortThing("🍎", "apple", "red"), SortThing("🍓", "strawberry", "red"),
                              SortThing("🌹", "rose", "red"), SortThing("🚒", "fire engine", "red"),
                              SortThing("🫐", "blueberry", "blue"), SortThing("🐳", "whale", "blue"),
                              SortThing("👖", "jeans", "blue"), SortThing("🧊", "ice", "blue"),
                              SortThing("🐸", "frog", "green"), SortThing("🥦", "broccoli", "green"),
                              SortThing("🌳", "tree", "green"), SortThing("🐛", "caterpillar", "green"),
                              SortThing("🍌", "banana", "yellow"), SortThing("🌻", "sunflower", "yellow"),
                              SortThing("🐥", "chick", "yellow"), SortThing("🧀", "cheese", "yellow")
                            ])),

        // ---------- Reading & letters ----------
        Skill(id: "TK-R1", grade: -1, subject: .reading,
              title: "Big and Little Letters",
              standard: "CA PLF Language",
              activity: "Every BIG letter has a little partner. Match them up!",
              parentTip: "B and b are partners, A and a are partners. Spot pairs on signs together.",
              lesson: .match(prompt: "Match the big letter to its little partner.",
                             pairs: [.init("B", "b"), .init("A", "a"),
                                     .init("S", "s"), .init("M", "m")])),

        Skill(id: "TK-R2", grade: -1, subject: .reading,
              title: "First Sounds",
              standard: "CA PLF Language",
              activity: "Every word starts with a sound. Drag each one to its letter!",
              parentTip: "Say the word slowly and stretch the first sound: mmmoon.",
              lesson: .sort(prompt: "Listen to the word. Which letter does it start with?",
                            bins: [SortBin("d", "D", "D"), SortBin("b", "B", "B"), SortBin("p", "P", "P")],
                            items: [
                              SortThing("🐶", "dog", "d"), SortThing("🦆", "duck", "d"),
                              SortThing("🥁", "drum", "d"), SortThing("🚪", "door", "d"),
                              SortThing("🐻", "bear", "b"), SortThing("⚽️", "ball", "b"),
                              SortThing("🐝", "bee", "b"), SortThing("🛏️", "bed", "b"),
                              SortThing("🐷", "pig", "p"), SortThing("🖊️", "pen", "p"),
                              SortThing("🍐", "pear", "p"), SortThing("🍕", "pizza", "p")
                            ], perRound: 6)),

        Skill(id: "TK-R3", grade: -1, subject: .reading,
              title: "Sort the Rhymes",
              standard: "CA PLF Language",
              activity: "Rhyming words sound the same at the end. Drag each word home!",
              parentTip: "Sing rhyming songs — the ear for rhyme comes before reading.",
              lesson: .sort(prompt: "Words that rhyme go home together. Cat or dog?",
                            bins: [SortBin("at", "…at  like cat", "🐱"),
                                   SortBin("og", "…og  like dog", "🐶")],
                            items: [
                              SortThing("🎩", "hat", "at"), SortThing("🦇", "bat", "at"),
                              SortThing("🐀", "rat", "at"), SortThing("🧉", "mat", "at"),
                              SortThing("🪵", "log", "og"), SortThing("🐸", "frog", "og"),
                              SortThing("🐗", "hog", "og"), SortThing("🌫️", "fog", "og")
                            ], perRound: 6)),

        // ---------- Science & animals (his special interest) ----------
        Skill(id: "TK-S1", grade: -1, subject: .science,
              title: "Which Animal?",
              standard: "CA PLF Science",
              activity: "You know your animals! Carry each one to its group.",
              parentTip: "Let him be the expert — he can name more than you'd think.",
              lesson: .sort(prompt: "Dog, cat, bird or fish? Carry each one to its group.",
                            bins: [SortBin("dog", "Dogs", "🐶"), SortBin("cat", "Cats", "🐱"),
                                   SortBin("bird", "Birds", "🐦"), SortBin("fish", "Fish", "🐟")],
                            items: [
                              SortThing("🐕", "dog", "dog"), SortThing("🐩", "poodle", "dog"),
                              SortThing("🦮", "guide dog", "dog"),
                              SortThing("🐈", "cat", "cat"), SortThing("🐈‍⬛", "black cat", "cat"),
                              SortThing("🐓", "rooster", "bird"), SortThing("🦆", "duck", "bird"),
                              SortThing("🦉", "owl", "bird"), SortThing("🦜", "parrot", "bird"),
                              SortThing("🐠", "clownfish", "fish"), SortThing("🐡", "pufferfish", "fish"),
                              SortThing("🦈", "shark", "fish")
                            ], perRound: 6)),

        Skill(id: "TK-S2", grade: -1, subject: .science,
              title: "Where Do They Live?",
              standard: "CA PLF Science",
              activity: "Every animal has a home. Match each animal to where it lives!",
              parentTip: "Talk about where your farm animals sleep and live.",
              lesson: .match(prompt: "Match the animal to its home.",
                             pairs: [.init("🐦", "🪺 nest"),
                                     .init("🐟", "🌊 water"),
                                     .init("🐝", "🍯 hive"),
                                     .init("🐶", "🏠 house")])),

        Skill(id: "TK-S3", grade: -1, subject: .science,
              title: "Who's the Baby?",
              standard: "CA PLF Science",
              activity: "Baby animals have special names. Carry each baby to its grown-up!",
              parentTip: "A puppy, a kitten, a calf, a chick — name the babies on the farm.",
              lesson: .sort(prompt: "Carry each baby to its grown-up.",
                            bins: [SortBin("dog", "Dog", "🐕"), SortBin("cat", "Cat", "🐈"),
                                   SortBin("cow", "Cow", "🐄"), SortBin("hen", "Hen", "🐔")],
                            items: [
                              SortThing("🐶", "puppy", "dog"), SortThing("🐱", "kitten", "cat"),
                              SortThing("🐮", "calf", "cow"), SortThing("🐣", "chick", "hen"),
                              SortThing("🐥", "chick", "hen")
                            ], perRound: 5)),

        // ---------- Life & feelings (kept light and picture-based) ----------
        Skill(id: "TK-L1", grade: -1, subject: .life,
              title: "Happy or Sad?",
              standard: "CA PLF Social-Emotional",
              activity: "Faces show feelings. Carry each face to its feeling!",
              parentTip: "Reading faces is hard for him, so this keeps it to two very different faces and one clear feeling. Make the face yourself as you name it: big smile for happy, frown for sad.",
              lesson: .sort(prompt: "Happy, sad or mad? Carry each face to its feeling.",
                            bins: [SortBin("happy", "Happy", "😀"), SortBin("sad", "Sad", "😢"),
                                   SortBin("mad", "Mad", "😠")],
                            items: [
                              SortThing("😄", "this face", "happy"), SortThing("😁", "this face", "happy"),
                              SortThing("😭", "this face", "sad"), SortThing("😞", "this face", "sad"),
                              SortThing("😡", "this face", "mad"), SortThing("😤", "this face", "mad")
                            ], perRound: 6))
    ]
}

// MARK: - Bridge to First Grade (number-entry math ladder)
//
// Gabriel's strongest, happiest games are the concrete "count what you see and
// type the number" ones (Add to 5/10, Doubles, Animal Add, Take-Away). This is a
// full ladder in exactly that style that carries Kindergarten counting up into
// real First-Grade math: ±1, doubles to 20, teen place value, counting on,
// making ten, and add/subtract within 20. Every game is numberPad (he enters the
// number), teaches first, and reveals the answer in green after two misses.
//
// Graded First Grade (grade 1) so the Progress tab finally shows him moving
// "forward with First" — but each rung is scaffolded and winnable, so it builds
// confidence instead of piling up losses like the un-scaffolded G1 set did.
extension Curriculum {
    static let bridge: [Skill] = [

        // ---- Confidence rung: one more / one less ----
        Skill(id: "BR-M1", grade: 1, subject: .math,
              title: "One More Hops In",
              standard: "Bridge · CCSS K.CC / 1.OA",
              activity: "One more hops in! Count them all and type how many.",
              parentTip: "One more is just the next counting number. 6, then one more is 7. Count up by one.",
              lesson: .numberGen(.oneMore, rounds: 5, boost: 1)),

        Skill(id: "BR-M2", grade: 1, subject: .math,
              title: "One Hops Away",
              standard: "Bridge · CCSS K.CC / 1.OA",
              activity: "One goes away. Count what's LEFT and type it.",
              parentTip: "One less is the number right before it. 7, one less is 6. Count back by one.",
              lesson: .numberGen(.oneLess, rounds: 5, boost: 1)),

        // ---- Doubles to 20 (builds on Stretch Doubles) ----
        Skill(id: "BR-M3", grade: 1, subject: .math,
              title: "Double the Herd",
              standard: "Bridge · CCSS 1.OA.6",
              activity: "Two groups the SAME size. Count them all!",
              parentTip: "Doubles are the easiest facts to memorize and they make bigger adding fast: 7 and 7 is 14.",
              lesson: .numberGen(.doubles, rounds: 5, boost: 1)),

        // ---- Teen numbers as ten-and-some (place value on-ramp) ----
        Skill(id: "BR-M4", grade: 1, subject: .math,
              title: "Ten and Some More",
              standard: "Bridge · CCSS 1.NBT.2",
              activity: "A teen number is a full ten and some more. Count them all!",
              parentTip: "See the ten first, then count on the extras: ten and 4 more is 14. This is how teen numbers work.",
              lesson: .numberGen(.teen, rounds: 5, boost: 1)),

        // ---- Counting on (a real first-grade strategy) ----
        Skill(id: "BR-M5", grade: 1, subject: .math,
              title: "Count On, Cowboy!",
              standard: "Bridge · CCSS 1.OA.5",
              activity: "Start big, then count up a few more. Where do you land?",
              parentTip: "Instead of counting from one, start at the big number and count on: start at 12, count 13, 14, 15. Faster and first-grade smart.",
              lesson: .numberGen(.countOn, rounds: 4)),

        // ---- Make ten (missing addend, kept concrete: count the empties) ----
        Skill(id: "BR-M6", grade: 1, subject: .math,
              title: "Fill the Ten",
              standard: "Bridge · CCSS 1.OA.6",
              activity: "The tank holds 10 fish. Count the empty ⬜ spots to fill it!",
              parentTip: "Ten spots, some already have a fish. He counts the empty boxes — that's how many MORE make ten. Concrete, no mental math.",
              lesson: .numberGen(.makeTen, rounds: 4, boost: 1)),

        // ---- Add within 20 (crossing the ten) ----
        Skill(id: "BR-M7", grade: 1, subject: .math,
              title: "Big Barn Add-Up",
              standard: "Bridge · CCSS 1.OA.6",
              activity: "Bigger groups that cross ten. Put them together and count all!",
              parentTip: "Same as Add to 10, just past ten now. He can make a ten first, or just count them all.",
              lesson: .numberGen(.add, rounds: 5, boost: 2)),

        // ---- Subtract within 20 ----
        Skill(id: "BR-M8", grade: 1, subject: .math,
              title: "Big Take-Away",
              standard: "Bridge · CCSS 1.OA.6",
              activity: "Bigger numbers now. Some go away — count what's left!",
              parentTip: "Start at the big number and count back, or count up from the small one. Either way works.",
              lesson: .numberGen(.takeAway, rounds: 5, boost: 2)),

        // ---- Ten more / ten less (place-value pattern) ----
        Skill(id: "BR-M9", grade: 1, subject: .math,
              title: "Ten More, Ten Less",
              standard: "Bridge · CCSS 1.NBT.5",
              activity: "Ten more or ten less just changes the tens. Type the new number!",
              parentTip: "Ten more than 25 is 35 — only the tens digit goes up by one. Ten less goes down by one ten.",
              lesson: .numberGen(.tenMoreLess, rounds: 5))
    ]
}

// MARK: - First-Grade Readiness bank (a deep, self-sustaining stretch set)
//
// A large, varied bank of winnable first-grade-readiness games so Gabriel has
// weeks of fresh, confidence-building work without new games being added. Heavy
// on his strengths — number entry, concrete counting, and animal story problems
// — with gently scaffolded reading (picture answers, two choices, sight words in
// context) and animal science for variety. Everything is graded First Grade so
// the Progress tab shows him climbing, teaches first, reveals answers after two
// misses, and stays winnable.
extension Curriculum {
    static let readiness: [Skill] = [

        // ============ MATH (number entry + concrete counting) ============
        Skill(id: "FR-M1", grade: 1, subject: .math,
              title: "Count by Tens",
              standard: "Readiness · CCSS 1.NBT.1",
              activity: "Count by tens: 10, 20, 30… Type the next number!",
              parentTip: "Counting by tens is the fast way to count big groups. Only the tens digit changes.",
              lesson: .numberGen(.skipTens, rounds: 4)),

        Skill(id: "FR-M2", grade: 1, subject: .math,
              title: "Count by Fives",
              standard: "Readiness · CCSS 1.NBT.1",
              activity: "Count by fives: 5, 10, 15… Type the next number!",
              parentTip: "Counting by fives is like counting hands. Great for telling time later.",
              lesson: .numberGen(.skipFives, rounds: 4, boost: 1)),

        Skill(id: "FR-M3", grade: 1, subject: .math,
              title: "Count by Twos",
              standard: "Readiness · CCSS 1.NBT.1",
              activity: "Count by twos: 2, 4, 6… Type the next number!",
              parentTip: "Counting by twos skips every other number. Count socks or shoes in twos.",
              lesson: .numberGen(.skipTwos, rounds: 4, boost: 1)),

        Skill(id: "FR-M4", grade: 1, subject: .math,
              title: "Doubles Plus One",
              standard: "Readiness · CCSS 1.OA.6",
              activity: "Almost a double! Do the double, then add one more.",
              parentTip: "6 + 7 is just 6 + 6 and one more. Knowing doubles makes these easy.",
              lesson: .numberGen(.doublesPlusOne, rounds: 4)),

        Skill(id: "FR-M5", grade: 1, subject: .math,
              title: "Tens and Ones",
              standard: "Readiness · CCSS 1.NBT.2",
              activity: "A whole ten (or two!) and some more. Type how many in all.",
              parentTip: "20 and 3 more is 23. See the tens first, then count on the extra ones.",
              lesson: .numberGen(.tensAndOnes, rounds: 4)),

        Skill(id: "FR-M6", grade: 1, subject: .math,
              title: "How Many More?",
              standard: "Readiness · CCSS 1.OA.1",
              activity: "Two groups. Count how many MORE the bigger group has!",
              parentTip: "Line them up and see the extra. Comparing is a kind of subtracting.",
              lesson: .numberGen(.howManyMore, rounds: 4)),

        Skill(id: "FR-M7", grade: 1, subject: .math,
              title: "Barn Story",
              standard: "Readiness · CCSS 1.OA.1",
              activity: "A little story on the farm. Read it, then type the answer!",
              parentTip: "Some come, some go. Act it out with his toy animals if he likes.",
              lesson: .numberPad([
                NumberProblem("6 🐮 in the barn. 3 more come in. How many now?", 9, visual: Array(repeating: "🐮", count: 6) + ["➕"] + Array(repeating: "🐮", count: 3)),
                NumberProblem("10 🐔 pecking. 4 go outside. How many left?", 6, draw: .takeAway(emoji: "🐔", start: 10, gone: 4)),
                NumberProblem("5 🐑 here and 7 🐑 there. How many sheep?", 12, visual: Array(repeating: "🐑", count: 5) + ["➕"] + Array(repeating: "🐑", count: 7)),
                NumberProblem("8 🐷 by the trough. 2 run to the mud. How many left?", 6, draw: .takeAway(emoji: "🐷", start: 8, gone: 2))
              ])),

        Skill(id: "FR-M8", grade: 1, subject: .math,
              title: "Pond Story",
              standard: "Readiness · CCSS 1.OA.1",
              activity: "More animal stories! Read it, then type how many.",
              parentTip: "Pull out the numbers and decide: are we adding more, or taking some away?",
              lesson: .numberPad([
                NumberProblem("9 🦆 on the pond. 5 fly away. How many left?", 4, draw: .takeAway(emoji: "🦆", start: 9, gone: 5)),
                NumberProblem("7 🐴 in the field and 6 more come. How many?", 13, visual: Array(repeating: "🐴", count: 7) + ["➕"] + Array(repeating: "🐴", count: 6)),
                NumberProblem("12 🐝 at the hive. 4 fly off. How many left?", 8, draw: .takeAway(emoji: "🐝", start: 12, gone: 4)),
                NumberProblem("3 🐰, then 4 🐰, then 2 🐰. How many rabbits?", 9, visual: Array(repeating: "🐰", count: 3) + ["➕"] + Array(repeating: "🐰", count: 4) + ["➕"] + Array(repeating: "🐰", count: 2))
              ])),

        Skill(id: "FR-M9", grade: 1, subject: .math,
              title: "Make a Ten!",
              standard: "Readiness · CCSS 1.OA.6",
              activity: "Fill up to ten first, then add the rest. Type the total!",
              parentTip: "9 + 3: give 1 to the 9 to make 10, then 2 more is 12. A big first-grade trick.",
              lesson: .numberPad([
                NumberProblem("9 + 3  (make 10 first!)", 12, draw: .compare(top: "🐤", topCount: 9, bottom: "🐤", bottomCount: 3)),
                NumberProblem("8 + 4  (make 10 first!)", 12, draw: .compare(top: "🐰", topCount: 8, bottom: "🐰", bottomCount: 4)),
                NumberProblem("9 + 5  (make 10 first!)", 14, draw: .compare(top: "🦆", topCount: 9, bottom: "🦆", bottomCount: 5)),
                NumberProblem("8 + 5  (make 10 first!)", 13, draw: .compare(top: "🍎", topCount: 8, bottom: "🍎", bottomCount: 5))
              ])),

        Skill(id: "FR-M10", grade: 1, subject: .math,
              title: "Count On Past Ten",
              standard: "Readiness · CCSS 1.OA.5",
              activity: "Start at the big number and count up a few more!",
              parentTip: "Don't start from one. Start at 16 and count 17, 18, 19.",
              lesson: .numberGen(.countOn, rounds: 4, boost: 1)),

        Skill(id: "FR-M11", grade: 1, subject: .math,
              title: "The Number Before",
              standard: "Readiness · CCSS 1.NBT.1",
              activity: "Which number comes right BEFORE? Type it!",
              parentTip: "The number before is one less. Before 13 is 12. Count backward one step.",
              lesson: .numberGen(.numberBefore, rounds: 4, boost: 1)),

        Skill(id: "FR-M12", grade: 1, subject: .math,
              title: "Count the Pennies",
              standard: "Readiness · CCSS 1.MD / Money",
              activity: "Each penny is 1 cent. Count them and type the cents!",
              parentTip: "A penny is worth 1¢, so counting pennies is just counting. Real coins make it click.",
              lesson: .numberGen(.pennies, rounds: 4)),

        Skill(id: "FR-M13", grade: 1, subject: .math,
              title: "Which Is More?",
              standard: "Readiness · CCSS 1.NBT.3",
              activity: "More than ten or less than ten? Carry each number to its pen!",
              parentTip: "Bigger numbers are farther along when you count. 14 comes after 9, so it's more.",
              lesson: .sort(prompt: "Is it MORE than 10 or LESS than 10? Carry it to its pen.",
                            bins: [SortBin("more", "More than 10", "⬆️"), SortBin("less", "Less than 10", "⬇️")],
                            items: [
                              SortThing("14", "fourteen", "more"), SortThing("17", "seventeen", "more"),
                              SortThing("12", "twelve", "more"), SortThing("19", "nineteen", "more"),
                              SortThing("11", "eleven", "more"), SortThing("16", "sixteen", "more"),
                              SortThing("8", "eight", "less"), SortThing("6", "six", "less"),
                              SortThing("3", "three", "less"), SortThing("9", "nine", "less"),
                              SortThing("5", "five", "less"), SortThing("2", "two", "less")
                            ], perRound: 6)),

        // ----- Gap-fillers: first-grade standards the bank above misses.
        // All number-entry, the style he wins in. Each one turns a new standard
        // into arithmetic he can already do, rather than adding new difficulty.

        Skill(id: "FR-M14", grade: 1, subject: .math,
              title: "Turn-Around Trick",
              standard: "Readiness · CCSS 1.OA.3",
              activity: "8 + 3 or 3 + 8? Same answer! Flip it and see.",
              parentTip: "Adding in either order gives the same total. Every fact he knows is secretly two facts, so this halves what there is to learn.",
              lesson: .numberGen(.turnAround, rounds: 4)),

        Skill(id: "FR-M15", grade: 1, subject: .math,
              title: "Find the Missing Number",
              standard: "Readiness · CCSS 1.OA.8",
              activity: "A number is hiding! Which one finishes it?",
              parentTip: "Ask how many more to get there. Counting up from the smaller number is the easiest way in, and it is the same move as make-a-ten.",
              lesson: .numberGen(.missingAddend, rounds: 4)),

        Skill(id: "FR-M16", grade: 1, subject: .math,
              title: "Add Three Numbers",
              standard: "Readiness · CCSS 1.OA.2",
              activity: "Three numbers at once! Add two, then the last one.",
              parentTip: "Look for a pair that makes ten first. 4 + 6 + 3 is much easier as 10 + 3, and spotting the pair is the real skill.",
              lesson: .numberGen(.addThree, rounds: 4, boost: 1)),

        Skill(id: "FR-M17", grade: 1, subject: .math,
              title: "Tens and Ones Add-Up",
              standard: "Readiness · CCSS 1.NBT.4",
              activity: "Bigger numbers, easy way. Add the ones, or jump by tens.",
              parentTip: "23 + 5 only changes the ones. 40 + 30 only changes the tens. The other part stays exactly where it was.",
              lesson: .numberGen(.addTensOnes, rounds: 4)),

        Skill(id: "FR-M18", grade: 1, subject: .math,
              title: "Think Adding!",
              standard: "Readiness · CCSS 1.OA.4",
              activity: "Taking away? Think adding instead. Same puzzle, easier way.",
              parentTip: "10 - 8 is really eight and how many more make ten. Turning subtraction into addition lets him use facts he already owns instead of counting backward.",
              lesson: .numberGen(.thinkAddition, rounds: 4)),

        // ============ READING (picture answers, two choices) ============
        Skill(id: "FR-R1", grade: 1, subject: .reading,
              title: "Read the Word",
              standard: "Readiness · CCSS RF.1.3",
              activity: "Read each word, then drag the picture that matches it!",
              parentTip: "Sound it out slowly. The pens are words, not pictures, so he truly has to read.",
              lesson: .sort(prompt: "Read the words on the pens, then take each picture to its word.",
                            bins: [SortBin("cat", "cat", "cat"), SortBin("dog", "dog", "dog"),
                                   SortBin("pig", "pig", "pig"), SortBin("sun", "sun", "sun")],
                            items: [
                              SortThing("🐱", "cat", "cat"), SortThing("🐈", "cat", "cat"),
                              SortThing("🐶", "dog", "dog"), SortThing("🐕", "dog", "dog"),
                              SortThing("🐷", "pig", "pig"), SortThing("🐖", "pig", "pig"),
                              SortThing("☀️", "sun", "sun"), SortThing("🌞", "sun", "sun")
                            ])),

        Skill(id: "FR-R2", grade: 1, subject: .reading,
              title: "Read the Word 2",
              standard: "Readiness · CCSS RF.1.3",
              activity: "More words to read! Drag each picture to the word that says it.",
              parentTip: "Three-sound words like hen and fox. Stretch the sounds, then blend.",
              lesson: .sort(prompt: "Read the words, then bring each animal to its own word.",
                            bins: [SortBin("hen", "hen", "hen"), SortBin("fox", "fox", "fox"),
                                   SortBin("bee", "bee", "bee"), SortBin("cow", "cow", "cow")],
                            items: [
                              SortThing("🐔", "hen", "hen"), SortThing("🐓", "hen", "hen"),
                              SortThing("🦊", "fox", "fox"), SortThing("🦊", "fox", "fox"),
                              SortThing("🐝", "bee", "bee"), SortThing("🍯", "bee", "bee"),
                              SortThing("🐮", "cow", "cow"), SortThing("🐄", "cow", "cow")
                            ])),

        Skill(id: "FR-R3", grade: 1, subject: .reading,
              title: "Word Families",
              standard: "Readiness · CCSS RF.1.3",
              activity: "Words in a family end the same. Send each word home to its family!",
              parentTip: "The -ig family: pig, wig, dig. Same ending, just a new first sound.",
              lesson: .sort(prompt: "Same ending, same family. Send each word home.",
                            bins: [SortBin("ig", "-ig", "🐷"), SortBin("op", "-op", "🧹"),
                                   SortBin("ed", "-ed", "🛏️"), SortBin("un", "-un", "☀️")],
                            items: [
                              SortThing("💇", "wig", "ig"), SortThing("⛏️", "dig", "ig"),
                              SortThing("🫒", "fig", "ig"), SortThing("🌿", "twig", "ig"),
                              SortThing("🧹", "mop", "op"), SortThing("🛍️", "shop", "op"),
                              SortThing("🔝", "top", "op"), SortThing("🛑", "stop", "op"),
                              SortThing("🛏️", "bed", "ed"), SortThing("🔴", "red", "ed"),
                              SortThing("🍞", "bread", "ed"), SortThing("🧵", "thread", "ed"),
                              SortThing("🥐", "bun", "un"), SortThing("🏃", "run", "un"),
                              SortThing("🎉", "fun", "un"), SortThing("☀️", "sun", "un")
                            ])),

        Skill(id: "FR-R4", grade: 1, subject: .reading,
              title: "Blends",
              standard: "Readiness · CCSS RF.1.2",
              activity: "Two letters slide together at the start. Drag each one to its blend!",
              parentTip: "In a blend you hear both letters fast: st in star, fr in frog, sn in snake.",
              lesson: .sort(prompt: "Two letters, sliding together. Which blend does it start with?",
                            bins: [SortBin("st", "st", "st"), SortBin("fr", "fr", "fr"),
                                   SortBin("sn", "sn", "sn"), SortBin("tr", "tr", "tr")],
                            items: [
                              SortThing("⭐️", "star", "st"), SortThing("🪜", "stairs", "st"),
                              SortThing("🛑", "stop", "st"), SortThing("🥢", "stick", "st"),
                              SortThing("🐸", "frog", "fr"), SortThing("🍟", "fries", "fr"),
                              SortThing("🍓", "fruit", "fr"), SortThing("🧊", "frost", "fr"),
                              SortThing("🐍", "snake", "sn"), SortThing("🐌", "snail", "sn"),
                              SortThing("❄️", "snow", "sn"), SortThing("👃", "snout", "sn"),
                              SortThing("🌳", "tree", "tr"), SortThing("🚂", "train", "tr"),
                              SortThing("🚚", "truck", "tr"), SortThing("🏆", "trophy", "tr")
                            ])),

        Skill(id: "FR-R5", grade: 1, subject: .reading,
              title: "Team Sounds",
              standard: "Readiness · CCSS RF.1.3",
              activity: "Two letters make ONE sound. Drag each one to its team!",
              parentTip: "sh, ch, and th each make one sound from two letters: ship, chick, thumb.",
              lesson: .sort(prompt: "Two letters, one sound. Which team does it belong to?",
                            bins: [SortBin("sh", "sh", "sh"), SortBin("ch", "ch", "ch"),
                                   SortBin("th", "th", "th")],
                            items: [
                              SortThing("🚢", "ship", "sh"), SortThing("🐑", "sheep", "sh"),
                              SortThing("🐚", "shell", "sh"), SortThing("👟", "shoe", "sh"),
                              SortThing("🐤", "chick", "ch"), SortThing("🧀", "cheese", "ch"),
                              SortThing("🍒", "cherry", "ch"), SortThing("🪑", "chair", "ch"),
                              SortThing("👍", "thumb", "th"), SortThing("🌩️", "thunder", "th"),
                              SortThing("3️⃣", "three", "th"), SortThing("🌵", "thorn", "th")
                            ], perRound: 9)),

        Skill(id: "FR-R6", grade: 1, subject: .reading,
              title: "Finish the Sentence",
              standard: "Readiness · CCSS RF.1.4",
              activity: "Carry the missing word into the sentence and make it make sense!",
              parentTip: "Read the whole sentence with each choice and hear which one sounds right.",
              lesson: .buildSentence(prompt: "Drag the word that finishes the sentence.", lines: [
                SentenceLine("🐟", "The fish can", "", answer: "swim", distractors: ["jump", "sing"]),
                SentenceLine("🐦", "The bird can", "", answer: "fly", distractors: ["sit", "swim"]),
                SentenceLine("❤️", "I", "my mom.", answer: "love", distractors: ["run", "red"]),
                SentenceLine("🏚️", "We", "to the barn.", answer: "go", distractors: ["sun", "got"]),
                SentenceLine("🐴", "The horse can", "", answer: "run", distractors: ["read", "rain"]),
                SentenceLine("🐝", "The bee is", "the flower.", answer: "on", distractors: ["and", "one"])
              ])),

        Skill(id: "FR-R7", grade: 1, subject: .reading,
              title: "Yes or No?",
              standard: "Readiness · CCSS RF.1.4",
              activity: "Is it true, or is it silly? Carry each one to its pen!",
              parentTip: "He reads for meaning and answers yes or no — no word to copy, so he has to understand it.",
              lesson: .sort(prompt: "Listen to each one. True, or silly? Carry it to its pen.",
                            bins: [SortBin("true", "True", "👍"), SortBin("silly", "Silly", "🤪")],
                            items: [
                              SortThing("🐶", "A dog can run.", "true"), SortThing("🐮", "A cow eats grass.", "true"),
                              SortThing("🐟", "A fish can swim.", "true"), SortThing("🐔", "A hen lays eggs.", "true"),
                              SortThing("🐝", "A bee can buzz.", "true"),
                              SortThing("🐷", "A pig can fly.", "silly"), SortThing("🐟", "A fish can climb a tree.", "silly"),
                              SortThing("🐱", "A cat says moo.", "silly"), SortThing("🐴", "A horse lives in the sea.", "silly"),
                              SortThing("🐸", "A frog can drive a car.", "silly")
                            ], perRound: 6)),

        // ============ SCIENCE & WORLD (animal interest, winnable) ============
        Skill(id: "FR-S1", grade: 1, subject: .science,
              title: "Alive or Not?",
              standard: "Readiness · CA NGSS 1-LS",
              activity: "Living things grow and eat. Drag each one into the right pen!",
              parentTip: "Living things need food, water, and air and can grow. Rocks and toys do not.",
              lesson: .sort(prompt: "Alive, or not alive? Drag each one where it goes.",
                            bins: [SortBin("alive", "Alive", "🌱"), SortBin("not", "Not alive", "🪨")],
                            items: [
                              SortThing("🐶", "dog", "alive"), SortThing("🌷", "flower", "alive"),
                              SortThing("🐟", "fish", "alive"), SortThing("🐝", "bee", "alive"),
                              SortThing("🌳", "tree", "alive"), SortThing("🐔", "hen", "alive"),
                              SortThing("🐛", "worm", "alive"), SortThing("🐴", "horse", "alive"),
                              SortThing("🪨", "rock", "not"), SortThing("🚗", "car", "not"),
                              SortThing("⚽️", "ball", "not"), SortThing("🧱", "brick", "not"),
                              SortThing("🥄", "spoon", "not"), SortThing("🪣", "bucket", "not"),
                              SortThing("📗", "book", "not"), SortThing("🪑", "chair", "not")
                            ])),

        Skill(id: "FR-S2", grade: 1, subject: .science,
              title: "Animal Teams",
              standard: "Readiness · CA NGSS 1-LS1",
              activity: "Animals come in groups. Drag each animal to its own team!",
              parentTip: "Mammals have fur, birds have feathers, fish have fins, bugs have six legs.",
              lesson: .sort(prompt: "Put every animal on its team. Fur, feathers, fins or six legs?",
                            bins: [SortBin("mammal", "Fur", "🐕"), SortBin("bird", "Feathers", "🐦"),
                                   SortBin("fish", "Fins", "🐠"), SortBin("bug", "Six legs", "🐞")],
                            items: [
                              SortThing("🐶", "dog", "mammal"), SortThing("🐮", "cow", "mammal"),
                              SortThing("🐰", "rabbit", "mammal"), SortThing("🐴", "horse", "mammal"),
                              SortThing("🐦", "robin", "bird"), SortThing("🦆", "duck", "bird"),
                              SortThing("🐔", "hen", "bird"), SortThing("🦉", "owl", "bird"),
                              SortThing("🐟", "fish", "fish"), SortThing("🐠", "goldfish", "fish"),
                              SortThing("🦈", "shark", "fish"), SortThing("🐡", "pufferfish", "fish"),
                              SortThing("🐝", "bee", "bug"), SortThing("🐞", "ladybug", "bug"),
                              SortThing("🦗", "cricket", "bug"), SortThing("🐜", "ant", "bug")
                            ])),

        Skill(id: "FR-S3", grade: 1, subject: .science,
              title: "Who Eats What?",
              standard: "Readiness · CA NGSS K-LS1",
              activity: "Every animal has a favourite food. Drag the food to the animal!",
              parentTip: "Rabbits love carrots, cows eat grass, bees drink from flowers. Talk about your farm animals.",
              lesson: .sort(prompt: "Feed the animals. Drag each food to the one that eats it.",
                            bins: [SortBin("rabbit", "Rabbit", "🐰"), SortBin("cow", "Cow", "🐮"),
                                   SortBin("dog", "Dog", "🐶"), SortBin("bee", "Bee", "🐝")],
                            items: [
                              SortThing("🥕", "carrot", "rabbit"), SortThing("🥬", "lettuce", "rabbit"),
                              SortThing("🌾", "hay", "cow"), SortThing("🌿", "grass", "cow"),
                              SortThing("🦴", "bone", "dog"), SortThing("🍖", "meat", "dog"),
                              SortThing("🌷", "tulip", "bee"), SortThing("🌼", "daisy", "bee")
                            ])),

        Skill(id: "FR-S4", grade: 1, subject: .science,
              title: "Float or Sink?",
              standard: "Readiness · CA NGSS Physical Science",
              activity: "Some things float, some sink. Drop each one in the pond!",
              parentTip: "Try it in the bathtub! Heavy dense things sink, light things float.",
              lesson: .sort(prompt: "Into the pond! Does it float on top, or sink to the bottom?",
                            bins: [SortBin("float", "Floats", "🫧"), SortBin("sink", "Sinks", "⬇️")],
                            items: [
                              SortThing("🦆", "duck", "float"), SortThing("🍃", "leaf", "float"),
                              SortThing("⛵️", "boat", "float"), SortThing("🍎", "apple", "float"),
                              SortThing("🏀", "ball", "float"), SortThing("🪵", "log", "float"),
                              SortThing("🪶", "feather", "float"), SortThing("🧽", "sponge", "float"),
                              SortThing("🪨", "rock", "sink"), SortThing("🔩", "bolt", "sink"),
                              SortThing("🔑", "key", "sink"), SortThing("🪙", "coin", "sink"),
                              SortThing("🧱", "brick", "sink"), SortThing("🔨", "hammer", "sink"),
                              SortThing("🥄", "spoon", "sink"), SortThing("⚓️", "anchor", "sink")
                            ])),

        Skill(id: "FR-S5", grade: 1, subject: .life,
              title: "Push or Pull? 2",
              standard: "Readiness · CA NGSS K-PS2",
              activity: "We move things by pushing or pulling. Drag each one to the right hand!",
              parentTip: "A push moves something away, a pull brings it closer. Point them out around the house.",
              lesson: .sort(prompt: "Push it away, or pull it closer? Drag each one to the right hand.",
                            bins: [SortBin("push", "Push away", "👋"), SortBin("pull", "Pull closer", "🤏")],
                            items: [
                              SortThing("🛒", "shopping cart", "push"), SortThing("🔔", "doorbell", "push"),
                              SortThing("🚪", "heavy door", "push"), SortThing("🛝", "swing", "push"),
                              SortThing("🧹", "broom", "push"), SortThing("🚲", "bike pedal", "push"),
                              SortThing("🛷", "sled", "pull"), SortThing("🪢", "rope", "pull"),
                              SortThing("🦮", "dog on a leash", "pull"), SortThing("🎣", "fishing line", "pull"),
                              SortThing("🗄️", "drawer", "pull"), SortThing("🪁", "kite string", "pull")
                            ]))
    ]
}
