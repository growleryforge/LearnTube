import Foundation

extension Curriculum {

    static let firstGrade: [Skill] = [

        // ---------- Reading ----------
        Skill(id: "G1-R1", grade: 1, subject: .reading,
              title: "Short and Long Vowels",
              standard: "CA CCSS RF.1.2a",
              activity: "Long vowels say their name. Tap the word with the long vowel sound!",
              parentTip: "Stretch the vowel: cake says a long A, cat says short a.",
              lesson: .quiz([
                Question("Which has a LONG a (says 'a')?", correct: "cake", wrong: ["cat", "hat"]),
                Question("Which has a LONG i (says 'i')?", correct: "ride", wrong: ["pig", "hit"]),
                Question("Which has a SHORT o?", correct: "hop", wrong: ["rope", "boat"])
              ])),

        Skill(id: "G1-R2", grade: 1, subject: .reading,
              title: "Team Sounds (sh, ch, th)",
              standard: "CA CCSS RF.1.3a",
              activity: "Two letters, one sound. Tap the word that starts with the team sound!",
              parentTip: "sh, ch, th each make one sound from two letters.",
              lesson: .quiz([
                Question("Starts with SH", correct: "ship", wrong: ["sip", "tip"]),
                Question("Starts with CH", correct: "chin", wrong: ["tin", "win"]),
                Question("Starts with TH", correct: "that", wrong: ["hat", "bat"])
              ])),

        Skill(id: "G1-R3", grade: 1, subject: .reading,
              title: "Word-Wall Words",
              standard: "CA CCSS RF.1.3g",
              activity: "Tricky words you just have to know. Tap the right spelling!",
              parentTip: "A few each day beats all of them at once.",
              lesson: .quiz([
                Question("Which spells  SAID?", correct: "said", wrong: ["sed", "sayd"]),
                Question("Which spells  THEY?", correct: "they", wrong: ["thay", "tey"]),
                Question("Which spells  WHAT?", correct: "what", wrong: ["wut", "whut"])
              ])),

        Skill(id: "G1-R4", grade: 1, subject: .reading,
              title: "Read and Answer",
              standard: "CA CCSS RF.1.4",
              activity: "Read each little sentence, then tap the answer!",
              parentTip: "Reading for meaning is the goal. Read it together if he likes.",
              lesson: .quiz([
                Question("'The hen is red.'  What color is the hen?", correct: "Red", wrong: ["Blue", "Green"]),
                Question("'A pig can run.'  What can the pig do?", correct: "Run", wrong: ["Fly", "Swim"]),
                Question("'I see two cows.'  How many cows?", correct: "Two", wrong: ["One", "Ten"])
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
              activity: "The main idea is what it's mostly about. Tap the best main idea!",
              parentTip: "Prompt: 'In one breath, what was it about?'",
              lesson: .quiz([
                Question("A book about feeding, brushing, and walking a dog is mostly about...",
                         correct: "Taking care of a dog", wrong: ["The color red", "Riding bikes"]),
                Question("A book about seeds, sun, and water growing a plant is mostly about...",
                         correct: "How plants grow", wrong: ["Going to the moon", "Baking a cake"])
              ])),

        Skill(id: "G1-R7", grade: 1, subject: .reading,
              title: "Blends",
              standard: "CA CCSS RF.1.2b",
              activity: "Blends keep both sounds. Tap the word that starts with the blend!",
              parentTip: "Unlike team sounds, you hear both letters in a blend.",
              lesson: .quiz([
                Question("Starts with ST", correct: "stop", wrong: ["top", "sop"]),
                Question("Starts with FR", correct: "frog", wrong: ["fog", "rog"]),
                Question("Starts with CL", correct: "clap", wrong: ["cap", "lap"])
              ])),

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
              activity: "An opinion tells what YOU think. Tap the opinion sentence!",
              parentTip: "A fact can be checked; an opinion is a feeling or favorite.",
              lesson: .quiz([
                Question("Which one is an OPINION?", correct: "Goats are the best animal!", wrong: ["A goat has four legs.", "Goats eat hay."]),
                Question("Which one is an OPINION?", correct: "Red is the prettiest color.", wrong: ["The barn is red.", "Apples can be red."]),
                Question("Which one is an OPINION?", correct: "Summer is the most fun season.", wrong: ["Summer is warm.", "Summer comes after spring."])
              ])),

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
              activity: "Numbers keep going past 100. Tap what comes next!",
              parentTip: "Starting mid-count is the real skill.",
              lesson: .quiz([
                Question("What comes after 99?", correct: "100", wrong: ["110", "90"]),
                Question("What comes after 109?", correct: "110", wrong: ["120", "200"]),
                Question("What comes after 119?", correct: "120", wrong: ["121", "110"])
              ])),

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
                NumberProblem("20 - 10 = ?", 10)
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
              activity: "Which number is bigger? Tap the right one!",
              parentTip: "The 'alligator mouth' eats the bigger number.",
              lesson: .quiz([
                Question("Which is BIGGER?", correct: "54", wrong: ["45"]),
                Question("Which is SMALLER?", correct: "23", wrong: ["32"]),
                Question("Which is BIGGER?", correct: "70", wrong: ["67"])
              ])),

        Skill(id: "G1-M7", grade: 1, subject: .math,
              title: "Measure with Paperclips",
              standard: "CA CCSS 1.MD.2",
              activity: "Measure by lining up units with no gaps. Solve the measuring puzzle!",
              parentTip: "No gaps and no overlaps is the key rule.",
              lesson: .numberPad([
                NumberProblem("A pencil is 5 paperclips long. How many clips?", 5),
                NumberProblem("A carrot is 4 clips, a worm is 2 clips. How many longer is the carrot?", 2),
                NumberProblem("3 clips + 3 clips of length = ? clips", 6)
              ])),

        Skill(id: "G1-M8", grade: 1, subject: .math,
              title: "Tell Time",
              standard: "CA CCSS 1.MD.3",
              activity: "Read the clock to the hour and half hour. Tap the time!",
              parentTip: "The short hand is the hour, the long hand is minutes.",
              lesson: .quiz([
                Question("Both hands on 12 means...", correct: "12 o'clock", wrong: ["6 o'clock", "Half past 1"]),
                Question("Short hand on 3, long hand on 12", correct: "3:00", wrong: ["12:03", "3:30"]),
                Question("Long hand on 6 means it's...", correct: "Half past the hour", wrong: ["O'clock", "Almost midnight"])
              ])),

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
              activity: "Equal parts have fancy names. Tap the right one!",
              parentTip: "Sharing a snack equally makes this real.",
              lesson: .quiz([
                Question("Cut into 2 equal parts =", correct: "Halves", wrong: ["Fourths", "Thirds"]),
                Question("Cut into 4 equal parts =", correct: "Fourths", wrong: ["Halves", "Twos"]),
                Question("Which is BIGGER, one half or one fourth?", correct: "One half", wrong: ["One fourth"])
              ])),

        // ---------- Science ----------
        Skill(id: "G1-S1", grade: 1, subject: .science,
              title: "Light and Sound",
              standard: "CA NGSS 1-PS4",
              activity: "Sound comes from vibrations, shadows come from light. Tap what's true!",
              parentTip: "Let him feel his throat hum to feel a vibration.",
              lesson: .quiz([
                Question("What makes a sound?", correct: "Something vibrating", wrong: ["Something still", "A picture"]),
                Question("A shadow is made when something blocks...", correct: "Light", wrong: ["Water", "Wind"]),
                Question("Pluck a rubber band. It makes sound because it...", correct: "Vibrates", wrong: ["Freezes", "Glows"])
              ])),

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
              activity: "The sky changes in patterns. Tap what's true about the sky!",
              parentTip: "A few nights of moon drawings show the pattern.",
              lesson: .quiz([
                Question("In the morning, the sun is in the...", correct: "Sky, rising in the east", wrong: ["Ground", "Ocean only"]),
                Question("At night we usually see the...", correct: "Moon and stars", wrong: ["Sun", "Rainbow"]),
                Question("The sun seems to move across the sky during the...", correct: "Day", wrong: ["Night", "Winter only"])
              ])),

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
              activity: "Big feelings need calm tools. Tap the healthy choice!",
              parentTip: "Knowing the tools when calm makes them easier to use later.",
              lesson: .quiz([
                Question("A good way to calm down is...", correct: "Take slow belly breaths", wrong: ["Yell louder", "Throw things"]),
                Question("If you feel mad, you can...", correct: "Go to a quiet spot", wrong: ["Hit something", "Stomp on toys"]),
                Question("Slow breathing helps you feel...", correct: "Calm", wrong: ["Angry", "Grumpy"])
              ]))
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
              title: "Add to 10",
              standard: "Stretch · CCSS K.OA / 1.OA",
              activity: "Bigger groups now! Put them together and count them all.",
              parentTip: "Same idea as Add to 5, just larger. Counting on from the bigger group is the next step.",
              lesson: .numberPad([
                NumberProblem("4 🍎 and 3 🍎. How many in all?", 7, visual: ["🍎","🍎","🍎","🍎","➕","🍎","🍎","🍎"]),
                NumberProblem("5 ⭐️ and 4 ⭐️. How many in all?", 9, visual: ["⭐️","⭐️","⭐️","⭐️","⭐️","➕","⭐️","⭐️","⭐️","⭐️"]),
                NumberProblem("6 🐟 and 2 🐟. How many in all?", 8, visual: ["🐟","🐟","🐟","🐟","🐟","🐟","➕","🐟","🐟"]),
                NumberProblem("5 🍪 and 5 🍪. How many in all?", 10, visual: ["🍪","🍪","🍪","🍪","🍪","➕","🍪","🍪","🍪","🍪","🍪"])
              ])),

        Skill(id: "ST-M2", grade: 0, subject: .math,
              title: "Take Away from 10",
              standard: "Stretch · CCSS K.OA / 1.OA",
              activity: "Bigger numbers. Some go away — count what's left!",
              parentTip: "Start from 10 and count back. Fingers help: put some down, count what's up.",
              lesson: .numberPad([
                NumberProblem("8 🍌, eat 2. How many are left?", 6, visual: ["🍌","🍌","🍌","🍌","🍌","🍌"]),
                NumberProblem("10 🍇, eat 4. How many are left?", 6, visual: ["🍇","🍇","🍇","🍇","🍇","🍇"]),
                NumberProblem("7 🐠, 3 swim away. How many are left?", 4, visual: ["🐠","🐠","🐠","🐠"]),
                NumberProblem("9 🍎, give 5 away. How many are left?", 4, visual: ["🍎","🍎","🍎","🍎"])
              ])),

        Skill(id: "ST-M3", grade: 0, subject: .math,
              title: "What's Missing?",
              standard: "Stretch · CCSS K.CC",
              activity: "Numbers go in order. Tap the one that's missing!",
              parentTip: "Count out loud together to hear which number was skipped.",
              lesson: .quiz([
                Question("7, 8, __, 10", correct: "9", wrong: ["6", "11"]),
                Question("3, 4, 5, __", correct: "6", wrong: ["7", "2"]),
                Question("12, 13, __, 15", correct: "14", wrong: ["11", "16"]),
                Question("17, 18, __, 20", correct: "19", wrong: ["16", "21"])
              ])),

        Skill(id: "ST-M4", grade: 0, subject: .math,
              title: "Doubles",
              standard: "Stretch · CCSS 1.OA",
              activity: "Two groups the SAME size. Count them all!",
              parentTip: "Doubles are easy to remember and make bigger adding faster: 4 and 4 is 8.",
              lesson: .numberPad([
                NumberProblem("2 🐶 and 2 🐶. Double!", 4, visual: ["🐶","🐶","➕","🐶","🐶"]),
                NumberProblem("3 🐱 and 3 🐱. Double!", 6, visual: ["🐱","🐱","🐱","➕","🐱","🐱","🐱"]),
                NumberProblem("4 🐰 and 4 🐰. Double!", 8, visual: ["🐰","🐰","🐰","🐰","➕","🐰","🐰","🐰","🐰"]),
                NumberProblem("5 🐥 and 5 🐥. Double!", 10, visual: ["🐥","🐥","🐥","🐥","🐥","➕","🐥","🐥","🐥","🐥","🐥"])
              ])),

        Skill(id: "ST-M5", grade: 0, subject: .math,
              title: "Make 10",
              standard: "Stretch · CCSS K.OA / 1.OA",
              activity: "The nest holds 10 eggs. Count the EMPTY spots to fill it!",
              parentTip: "Ten spots, some have a chick. He counts the empty boxes — the amount needed to make ten. Concrete counting, no mental math.",
              lesson: .numberPad([
                // He counts the empty ⬜ boxes (a real thing on screen), which IS
                // the amount that makes ten. No imagining the missing part.
                NumberProblem("The nest holds 10. Count the empty ⬜ spots!", 3, visual: ["🐤","🐤","🐤","🐤","🐤","🐤","🐤","⬜","⬜","⬜"]),
                NumberProblem("The nest holds 10. Count the empty ⬜ spots!", 4, visual: ["🐤","🐤","🐤","🐤","🐤","🐤","⬜","⬜","⬜","⬜"]),
                NumberProblem("The nest holds 10. Count the empty ⬜ spots!", 2, visual: ["🐤","🐤","🐤","🐤","🐤","🐤","🐤","🐤","⬜","⬜"]),
                NumberProblem("The nest holds 10. Count the empty ⬜ spots!", 5, visual: ["🐤","🐤","🐤","🐤","🐤","⬜","⬜","⬜","⬜","⬜"])
              ])),

        Skill(id: "ST-M6", grade: 0, subject: .math,
              title: "Add Three Groups",
              standard: "Stretch · CCSS 1.OA",
              activity: "Three little groups. Put them together and count all!",
              parentTip: "Adding three numbers is a first-grade step. Count every object, group by group.",
              lesson: .numberPad([
                NumberProblem("1 🍎 and 2 🍎 and 1 🍎?", 4, visual: ["🍎","➕","🍎","🍎","➕","🍎"]),
                NumberProblem("2 🐶 and 1 🐶 and 2 🐶?", 5, visual: ["🐶","🐶","➕","🐶","➕","🐶","🐶"]),
                NumberProblem("2 ⭐️ and 2 ⭐️ and 2 ⭐️?", 6, visual: ["⭐️","⭐️","➕","⭐️","⭐️","➕","⭐️","⭐️"]),
                NumberProblem("3 🐥 and 1 🐥 and 3 🐥?", 7, visual: ["🐥","🐥","🐥","➕","🐥","➕","🐥","🐥","🐥"])
              ])),

        Skill(id: "ST-R1", grade: 0, subject: .reading,
              title: "Read a Sentence",
              standard: "Stretch · CCSS RF.1 / RL.1",
              activity: "Read the little sentence, then answer about it!",
              parentTip: "He reads one short sentence and answers who or what. That's real comprehension.",
              lesson: .quiz([
                Question("The cat is big. Who is big?", correct: "cat", wrong: ["dog", "sun"]),
                Question("A dog can run. What can run?", correct: "dog", wrong: ["cat", "hat"]),
                Question("The sun is hot. What is hot?", correct: "sun", wrong: ["ice", "dog"]),
                Question("I see a red bug. What color is it?", correct: "red", wrong: ["blue", "big"])
              ])),

        Skill(id: "ST-R2", grade: 0, subject: .reading,
              title: "Finish the Sentence",
              standard: "Stretch · CCSS RF.1",
              activity: "Pick the word that makes the sentence make sense!",
              parentTip: "Read the whole sentence with each choice and hear which one sounds right.",
              lesson: .quiz([
                Question("I ___ the dog.", correct: "see", wrong: ["sun", "sit"]),
                Question("We ___ to the park.", correct: "go", wrong: ["got", "gum"]),
                Question("The bird can ___.", correct: "fly", wrong: ["fix", "fun"]),
                Question("I ___ a big cake.", correct: "like", wrong: ["lake", "lip"])
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
              lesson: .numberPad([
                NumberProblem("1 🐶 and 1 🐶. How many in all?", 2, visual: ["🐶","➕","🐶"]),
                NumberProblem("2 🐱 and 1 🐱. How many in all?", 3, visual: ["🐱","🐱","➕","🐱"]),
                NumberProblem("2 🐰 and 2 🐰. How many in all?", 4, visual: ["🐰","🐰","➕","🐰","🐰"]),
                NumberProblem("3 🐥 and 2 🐥. How many in all?", 5, visual: ["🐥","🐥","🐥","➕","🐥","🐥"])
              ])),

        Skill(id: "WU-M2", grade: -2, subject: .math,
              title: "Take Away to 5",
              standard: "Warm-Up · CCSS K.OA",
              activity: "Some go away. Count the ones that are LEFT!",
              parentTip: "Use snacks: start with a few, eat one, count what's left. That's subtracting.",
              lesson: .numberPad([
                NumberProblem("2 🍪, eat 1. How many are left?", 1, visual: ["🍪"]),
                NumberProblem("3 🍎, eat 1. How many are left?", 2, visual: ["🍎","🍎"]),
                NumberProblem("4 🍌, give 2 away. How many are left?", 2, visual: ["🍌","🍌"]),
                NumberProblem("5 🍇, eat 1. How many are left?", 4, visual: ["🍇","🍇","🍇","🍇"])
              ])),

        Skill(id: "WU-M3", grade: -2, subject: .math,
              title: "Teen Numbers",
              standard: "Warm-Up · CCSS K.NBT",
              activity: "A teen number is 10 and some more. Count them all!",
              parentTip: "Ten and 3 more is 13. Seeing the ten first makes the big numbers easy.",
              lesson: .numberPad([
                NumberProblem("10 and 1 more. How many?", 11, visual: ["🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔴"]),
                NumberProblem("10 and 2 more. How many?", 12, visual: ["🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔴","🔴"]),
                NumberProblem("10 and 3 more. How many?", 13, visual: ["🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔴","🔴","🔴"]),
                NumberProblem("10 and 5 more. How many?", 15, visual: ["🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔵","🔴","🔴","🔴","🔴","🔴"])
              ])),

        Skill(id: "WU-M4", grade: -2, subject: .math,
              title: "Count to 10",
              standard: "Warm-Up · CCSS K.CC",
              activity: "Point to each one and count. How many in all?",
              parentTip: "Touch one object per number word, all the way to ten.",
              lesson: .numberPad([
                NumberProblem("Count the 🐤!", 6, visual: ["🐤","🐤","🐤","🐤","🐤","🐤"]),
                NumberProblem("Count the 🐟!", 8, visual: ["🐟","🐟","🐟","🐟","🐟","🐟","🐟","🐟"]),
                NumberProblem("Count the ⭐️!", 10, visual: ["⭐️","⭐️","⭐️","⭐️","⭐️","⭐️","⭐️","⭐️","⭐️","⭐️"]),
                NumberProblem("Count the 🐝!", 7, visual: ["🐝","🐝","🐝","🐝","🐝","🐝","🐝"])
              ])),

        Skill(id: "WU-M5", grade: -2, subject: .math,
              title: "Animal Add",
              standard: "Warm-Up · CCSS K.OA",
              activity: "More animals come! Put them together and count them all.",
              parentTip: "Act it out with his toy animals: a few here, a few more, count them all.",
              lesson: .numberPad([
                NumberProblem("3 🦆 in the pond. 2 more come. How many now?", 5, visual: ["🦆","🦆","🦆","➕","🦆","🦆"]),
                NumberProblem("2 🐰 hop. 3 more hop over. How many?", 5, visual: ["🐰","🐰","➕","🐰","🐰","🐰"]),
                NumberProblem("4 🐥 and 3 more 🐥. How many?", 7, visual: ["🐥","🐥","🐥","🐥","➕","🐥","🐥","🐥"]),
                NumberProblem("5 🐟 and 4 🐟 join them. How many?", 9, visual: ["🐟","🐟","🐟","🐟","🐟","➕","🐟","🐟","🐟","🐟"])
              ])),

        Skill(id: "WU-M6", grade: -2, subject: .math,
              title: "Animal Take-Away",
              standard: "Warm-Up · CCSS K.OA",
              activity: "Some animals leave! Count the ones that are LEFT.",
              parentTip: "Line up his animals, walk a few away, count who stays.",
              lesson: .numberPad([
                NumberProblem("5 🦆 swim. 2 swim away. How many left?", 3, visual: ["🦆","🦆","🦆"]),
                NumberProblem("4 🐰 hop. 1 hops away. How many left?", 3, visual: ["🐰","🐰","🐰"]),
                NumberProblem("6 🐟 swim. 3 swim off. How many left?", 3, visual: ["🐟","🐟","🐟"]),
                NumberProblem("7 🐥 peck. 2 run off. How many left?", 5, visual: ["🐥","🐥","🐥","🐥","🐥"])
              ])),

        Skill(id: "WU-R1", grade: -2, subject: .reading,
              title: "Blend It",
              standard: "Warm-Up · CCSS RF.K.2",
              activity: "Say each sound, then push them together into a word!",
              parentTip: "Stretch it slow — c...a...t — then fast: cat! That's blending.",
              lesson: .quiz([
                // Answer is a PICTURE, never the word — he has to blend the
                // sounds into a word and know what it means, not match letters.
                Question("Blend it:  c - a - t", correct: "🐱", wrong: ["🐶", "🐟"]),
                Question("Blend it:  d - o - g", correct: "🐶", wrong: ["🐱", "🐷"]),
                Question("Blend it:  p - i - g", correct: "🐷", wrong: ["🐔", "🐝"]),
                Question("Blend it:  s - u - n", correct: "☀️", wrong: ["🌙", "⭐️"])
              ])),

        Skill(id: "WU-R2", grade: -2, subject: .reading,
              title: "Beginning Sounds",
              standard: "Warm-Up · CCSS RF.K.3",
              activity: "Every word starts with a sound. Tap the letter it starts with!",
              parentTip: "Say the word slowly and stretch the first sound: mmmoon starts with m.",
              lesson: .quiz([
                Question("🐶 Dog starts with...", correct: "d", wrong: ["b", "m"]),
                Question("🐱 Cat starts with...", correct: "c", wrong: ["s", "t"]),
                Question("🌙 Moon starts with...", correct: "m", wrong: ["n", "w"]),
                Question("🐷 Pig starts with...", correct: "p", wrong: ["b", "d"])
              ])),

        Skill(id: "WU-R3", grade: -2, subject: .reading,
              title: "Rhyme Time",
              standard: "Warm-Up · CCSS RF.K.2",
              activity: "Rhyming words end the same. Tap the one that rhymes!",
              parentTip: "Cat, hat, bat all end in -at. Make silly rhymes together.",
              lesson: .quiz([
                // Two choices, clear word families: the rhyme shares the exact
                // ending, the other word sounds nothing alike.
                Question("Which word rhymes with CAT?  (…at)", correct: "hat", wrong: ["dog"]),
                Question("Which word rhymes with DOG?  (…og)", correct: "log", wrong: ["cat"]),
                Question("Which word rhymes with SUN?  (…un)", correct: "bun", wrong: ["dog"]),
                Question("Which word rhymes with PIG?  (…ig)", correct: "wig", wrong: ["cup"])
              ]))
    ]
}

extension Curriculum {
    static let transitionalK: [Skill] = [

        // ---------- Math (concrete counting — his winning style) ----------
        Skill(id: "TK-M1", grade: -1, subject: .math,
              title: "Tap and Count to 3",
              standard: "CA PLF Math",
              activity: "Point and count each one: 1, 2, 3. Tap all 3 chicks!",
              parentTip: "Touch one object per number word — that one-to-one touch is the whole skill.",
              lesson: .count(target: 3, symbol: "🐤", prompt: "Tap all 3 chicks!")),

        Skill(id: "TK-M2", grade: -1, subject: .math,
              title: "Tap and Count to 5",
              standard: "CA PLF Math",
              activity: "Count each star as you tap it: 1, 2, 3, 4, 5!",
              parentTip: "Counting on fingers or real toys makes this stick.",
              lesson: .count(target: 5, symbol: "⭐️", prompt: "Tap all 5 stars!")),

        Skill(id: "TK-M3", grade: -1, subject: .math,
              title: "How Many?",
              standard: "CA PLF Math",
              activity: "Count the animals, then tap the number that says how many.",
              parentTip: "The LAST number he counts is the answer — that's cardinality.",
              lesson: .numberPad([
                NumberProblem("How many bees?", 3, visual: ["🐝", "🐝", "🐝"]),
                NumberProblem("How many cats?", 5, visual: ["🐱", "🐱", "🐱", "🐱", "🐱"]),
                NumberProblem("How many ducks?", 2, visual: ["🦆", "🦆"]),
                NumberProblem("How many frogs?", 6, visual: ["🐸", "🐸", "🐸", "🐸", "🐸", "🐸"]),
                NumberProblem("How many puppies?", 4, visual: ["🐶", "🐶", "🐶", "🐶"])
              ])),

        Skill(id: "TK-M4", grade: -1, subject: .math,
              title: "Bigger or Smaller",
              standard: "CA PLF Math",
              activity: "One is big, one is little. Tap the BIGGER one!",
              parentTip: "Compare real things around the house — the bigger cup, the smaller spoon.",
              lesson: .quiz([
                Question("Which animal is BIGGER?", correct: "🐘", wrong: ["🐭"]),
                Question("Which one is BIGGER?", correct: "🐋", wrong: ["🐟"]),
                Question("Which one is BIGGER?", correct: "🐻", wrong: ["🐿️"]),
                Question("Which one is SMALLER?", correct: "🐜", wrong: ["🐴"])
              ])),

        Skill(id: "TK-M5", grade: -1, subject: .math,
              title: "What Comes Next?",
              standard: "CA PLF Math",
              activity: "Patterns repeat! See the pattern, then tap what comes next.",
              parentTip: "Make patterns with blocks or snacks: red, blue, red, blue...",
              // Simple ABAB patterns only — two choices, both of which are IN the
              // pattern (no foreign third option, no hard AAB), so it's about
              // "what comes back around" and not a lucky guess. QuizPlayer shows
              // the answer in green after two misses, so he learns the pattern.
              lesson: .quiz([
                Question("🔴 🔵 🔴 🔵 ... what's next?", correct: "🔴", wrong: ["🔵"]),
                Question("⭐️ 🌙 ⭐️ 🌙 ... what's next?", correct: "⭐️", wrong: ["🌙"]),
                Question("🐶 🐱 🐶 🐱 ... what's next?", correct: "🐶", wrong: ["🐱"]),
                Question("🍎 🍌 🍎 🍌 ... what's next?", correct: "🍎", wrong: ["🍌"])
              ])),

        // ---------- Shapes & colors ----------
        Skill(id: "TK-M6", grade: -1, subject: .math,
              title: "Find the Shape",
              standard: "CA PLF Math",
              activity: "Shapes have names. Tap the one that matches!",
              parentTip: "Hunt for circles and squares around the house together.",
              lesson: .quiz([
                Question("Which one is a circle?", correct: "circle", wrong: ["square", "triangle"]),
                Question("Which one is a square?", correct: "square", wrong: ["circle", "triangle"]),
                Question("Which one is a triangle?", correct: "triangle", wrong: ["circle", "square"])
              ])),

        Skill(id: "TK-C1", grade: -1, subject: .math,
              title: "Colors",
              standard: "CA PLF Math",
              activity: "Each color has a name. Tap the right color!",
              parentTip: "Name colors of his toys and clothes through the day.",
              lesson: .quiz([
                Question("Which one is RED?", correct: "🔴", wrong: ["🔵", "🟢"]),
                Question("Which one is BLUE?", correct: "🔵", wrong: ["🔴", "🟡"]),
                Question("Which one is GREEN?", correct: "🟢", wrong: ["🔴", "🔵"]),
                Question("Which one is YELLOW?", correct: "🟡", wrong: ["🟢", "🔴"])
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
              activity: "Every word starts with a sound. Tap the first letter!",
              parentTip: "Say the word slowly and stretch the first sound: mmmoon.",
              lesson: .quiz([
                Question("🐶 Dog starts with...", correct: "D", wrong: ["B", "M"]),
                Question("🐱 Cat starts with...", correct: "C", wrong: ["T", "S"]),
                Question("🐻 Bear starts with...", correct: "B", wrong: ["D", "P"]),
                Question("🐷 Pig starts with...", correct: "P", wrong: ["B", "G"])
              ])),

        Skill(id: "TK-R3", grade: -1, subject: .reading,
              title: "Rhyme Time",
              standard: "CA PLF Language",
              activity: "Rhyming words sound the same at the end. Tap the one that rhymes!",
              parentTip: "Sing rhyming songs — the ear for rhyme comes before reading.",
              lesson: .quiz([
                Question("Which word rhymes with CAT?  (…at)", correct: "hat", wrong: ["dog"]),
                Question("Which word rhymes with DOG?  (…og)", correct: "log", wrong: ["fish"]),
                Question("Which word rhymes with BALL?  (…all)", correct: "wall", wrong: ["pig"]),
                Question("Which word rhymes with BEE?  (…ee)", correct: "tree", wrong: ["cup"])
              ])),

        // ---------- Science & animals (his special interest) ----------
        Skill(id: "TK-S1", grade: -1, subject: .science,
              title: "Which Animal?",
              standard: "CA PLF Science",
              activity: "You know your animals! Tap the one it asks for.",
              parentTip: "Let him be the expert — he can name more than you'd think.",
              lesson: .quiz([
                Question("Which one is a dog?", correct: "🐶", wrong: ["🐱", "🐰"]),
                Question("Which one is a fish?", correct: "🐟", wrong: ["🐦", "🐸"]),
                Question("Which one is a cow?", correct: "🐮", wrong: ["🐷", "🐔"]),
                Question("Which one is a bird?", correct: "🐦", wrong: ["🐝", "🐢"])
              ])),

        Skill(id: "TK-S2", grade: -1, subject: .science,
              title: "Where Do They Live?",
              standard: "CA PLF Science",
              activity: "Every animal has a home. Match each animal to where it lives!",
              parentTip: "Talk about where your farm animals sleep and live.",
              lesson: .match(prompt: "Match the animal to its home.",
                             pairs: [.init("🐦", "nest"),
                                     .init("🐟", "water"),
                                     .init("🐝", "hive"),
                                     .init("🐶", "house")])),

        Skill(id: "TK-S3", grade: -1, subject: .science,
              title: "Baby Animals",
              standard: "CA PLF Science",
              activity: "Baby animals have special names. Tap the right one!",
              parentTip: "A puppy, a kitten, a calf, a chick — name the babies on the farm.",
              lesson: .quiz([
                Question("A baby dog is a...", correct: "puppy", wrong: ["kitten", "calf"]),
                Question("A baby cat is a...", correct: "kitten", wrong: ["puppy", "chick"]),
                Question("A baby cow is a...", correct: "calf", wrong: ["lamb", "puppy"]),
                Question("A baby chicken is a...", correct: "chick", wrong: ["kitten", "calf"])
              ])),

        // ---------- Life & feelings (kept light and picture-based) ----------
        Skill(id: "TK-L1", grade: -1, subject: .life,
              title: "Happy or Sad?",
              standard: "CA PLF Social-Emotional",
              activity: "Faces show feelings. Just two faces — tap the feeling!",
              parentTip: "Reading faces is hard for him, so this keeps it to two very different faces and one clear feeling. Make the face yourself as you name it: big smile for happy, frown for sad.",
              lesson: .quiz([
                // Only two very different faces, basic feelings, strong contrast —
                // built for emotion recognition, not subtle face-reading. No face
                // in the question itself, so he can't just match a hint.
                Question("Which face is happy?", correct: "😀", wrong: ["😢"]),
                Question("Which face is sad?", correct: "😢", wrong: ["😀"]),
                Question("Which face is happy?", correct: "😀", wrong: ["😠"]),
                Question("Which face is mad?", correct: "😠", wrong: ["😀"]),
                Question("Which face is sad?", correct: "😢", wrong: ["😀"])
              ]))
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
              title: "One More",
              standard: "Bridge · CCSS K.CC / 1.OA",
              activity: "One more hops in! Count them all and type how many.",
              parentTip: "One more is just the next counting number. 6, then one more is 7. Count up by one.",
              lesson: .numberPad([
                NumberProblem("6 🐤 and 1 more hops in. How many now?", 7, visual: ["🐤","🐤","🐤","🐤","🐤","🐤","➕","🐤"]),
                NumberProblem("8 🐰 and 1 more. How many now?", 9, visual: ["🐰","🐰","🐰","🐰","🐰","🐰","🐰","🐰","➕","🐰"]),
                NumberProblem("9 🦆 and 1 more. How many now?", 10, visual: ["🦆","🦆","🦆","🦆","🦆","🦆","🦆","🦆","🦆","➕","🦆"]),
                NumberProblem("12 🐟 and 1 more. How many now?", 13),
                NumberProblem("15 🐝 and 1 more. How many now?", 16)
              ])),

        Skill(id: "BR-M2", grade: 1, subject: .math,
              title: "One Less",
              standard: "Bridge · CCSS K.CC / 1.OA",
              activity: "One goes away. Count what's LEFT and type it.",
              parentTip: "One less is the number right before it. 7, one less is 6. Count back by one.",
              lesson: .numberPad([
                NumberProblem("7 🍎, 1 rolls away. How many left?", 6, visual: ["🍎","🍎","🍎","🍎","🍎","🍎"]),
                NumberProblem("10 🐤, 1 wanders off. How many left?", 9, visual: ["🐤","🐤","🐤","🐤","🐤","🐤","🐤","🐤","🐤"]),
                NumberProblem("6 🐶, 1 runs off. How many left?", 5, visual: ["🐶","🐶","🐶","🐶","🐶"]),
                NumberProblem("13 🐟, 1 swims away. How many left?", 12),
                NumberProblem("16 ⭐️, 1 fades. How many left?", 15)
              ])),

        // ---- Doubles to 20 (builds on Stretch Doubles) ----
        Skill(id: "BR-M3", grade: 1, subject: .math,
              title: "Doubles to 20",
              standard: "Bridge · CCSS 1.OA.6",
              activity: "Two groups the SAME size. Count them all!",
              parentTip: "Doubles are the easiest facts to memorize and they make bigger adding fast: 7 and 7 is 14.",
              lesson: .numberPad([
                NumberProblem("5 🐣 and 5 🐣. Double!", 10, visual: ["🐣","🐣","🐣","🐣","🐣","➕","🐣","🐣","🐣","🐣","🐣"]),
                NumberProblem("6 🐟 and 6 🐟. Double!", 12, visual: ["🐟","🐟","🐟","🐟","🐟","🐟","➕","🐟","🐟","🐟","🐟","🐟","🐟"]),
                NumberProblem("7 🐝 and 7 🐝. Double!", 14, visual: ["🐝","🐝","🐝","🐝","🐝","🐝","🐝","➕","🐝","🐝","🐝","🐝","🐝","🐝","🐝"]),
                NumberProblem("8 ⭐️ and 8 ⭐️. Double!", 16),
                NumberProblem("9 🍎 and 9 🍎. Double!", 18)
              ])),

        // ---- Teen numbers as ten-and-some (place value on-ramp) ----
        Skill(id: "BR-M4", grade: 1, subject: .math,
              title: "Ten and Some More",
              standard: "Bridge · CCSS 1.NBT.2",
              activity: "A teen number is a full ten and some more. Count them all!",
              parentTip: "See the ten first, then count on the extras: ten and 4 more is 14. This is how teen numbers work.",
              lesson: .numberPad([
                NumberProblem("10 🥚 and 4 more. How many?", 14, visual: ["🥚","🥚","🥚","🥚","🥚","🥚","🥚","🥚","🥚","🥚","➕","🐤","🐤","🐤","🐤"]),
                NumberProblem("10 🥚 and 2 more. How many?", 12, visual: ["🥚","🥚","🥚","🥚","🥚","🥚","🥚","🥚","🥚","🥚","➕","🐤","🐤"]),
                NumberProblem("10 🥚 and 6 more. How many?", 16),
                NumberProblem("10 🥚 and 8 more. How many?", 18),
                NumberProblem("10 🥚 and 9 more. How many?", 19)
              ])),

        // ---- Counting on (a real first-grade strategy) ----
        Skill(id: "BR-M5", grade: 1, subject: .math,
              title: "Count On",
              standard: "Bridge · CCSS 1.OA.5",
              activity: "Start big, then count up a few more. Where do you land?",
              parentTip: "Instead of counting from one, start at the big number and count on: start at 12, count 13, 14, 15. Faster and first-grade smart.",
              lesson: .numberPad([
                NumberProblem("Start at 10. Count on 3 more. Where do you land?", 13),
                NumberProblem("Start at 15. Count on 2 more. Where do you land?", 17),
                NumberProblem("Start at 12. Count on 4 more. Where do you land?", 16),
                NumberProblem("Start at 8. Count on 5 more. Where do you land?", 13)
              ])),

        // ---- Make ten (missing addend, kept concrete: count the empties) ----
        Skill(id: "BR-M6", grade: 1, subject: .math,
              title: "Fill the Ten",
              standard: "Bridge · CCSS 1.OA.6",
              activity: "The tank holds 10 fish. Count the empty ⬜ spots to fill it!",
              parentTip: "Ten spots, some already have a fish. He counts the empty boxes — that's how many MORE make ten. Concrete, no mental math.",
              lesson: .numberPad([
                NumberProblem("The tank holds 10. Count the empty ⬜ spots!", 4, visual: ["🐟","🐟","🐟","🐟","🐟","🐟","⬜","⬜","⬜","⬜"]),
                NumberProblem("The tank holds 10. Count the empty ⬜ spots!", 3, visual: ["🐟","🐟","🐟","🐟","🐟","🐟","🐟","⬜","⬜","⬜"]),
                NumberProblem("The tank holds 10. Count the empty ⬜ spots!", 6, visual: ["🐟","🐟","🐟","🐟","⬜","⬜","⬜","⬜","⬜","⬜"]),
                NumberProblem("The tank holds 10. Count the empty ⬜ spots!", 1, visual: ["🐟","🐟","🐟","🐟","🐟","🐟","🐟","🐟","🐟","⬜"])
              ])),

        // ---- Add within 20 (crossing the ten) ----
        Skill(id: "BR-M7", grade: 1, subject: .math,
              title: "Add Within 20",
              standard: "Bridge · CCSS 1.OA.6",
              activity: "Bigger groups that cross ten. Put them together and count all!",
              parentTip: "Same as Add to 10, just past ten now. He can make a ten first, or just count them all.",
              lesson: .numberPad([
                NumberProblem("8 🐟 and 5 🐟. How many in all?", 13, visual: ["🐟","🐟","🐟","🐟","🐟","🐟","🐟","🐟","➕","🐟","🐟","🐟","🐟","🐟"]),
                NumberProblem("9 🐤 and 4 🐤. How many in all?", 13, visual: ["🐤","🐤","🐤","🐤","🐤","🐤","🐤","🐤","🐤","➕","🐤","🐤","🐤","🐤"]),
                NumberProblem("7 🐝 and 6 🐝. How many in all?", 13),
                NumberProblem("8 🍎 and 6 🍎. How many in all?", 14),
                NumberProblem("9 ⭐️ and 8 ⭐️. How many in all?", 17)
              ])),

        // ---- Subtract within 20 ----
        Skill(id: "BR-M8", grade: 1, subject: .math,
              title: "Take Away to 20",
              standard: "Bridge · CCSS 1.OA.6",
              activity: "Bigger numbers now. Some go away — count what's left!",
              parentTip: "Start at the big number and count back, or count up from the small one. Either way works.",
              lesson: .numberPad([
                NumberProblem("12 🍇, eat 4. How many are left?", 8, visual: ["🍇","🍇","🍇","🍇","🍇","🍇","🍇","🍇"]),
                NumberProblem("11 🐰, 3 hop away. How many are left?", 8, visual: ["🐰","🐰","🐰","🐰","🐰","🐰","🐰","🐰"]),
                NumberProblem("15 🐟, 6 swim away. How many are left?", 9),
                NumberProblem("16 🐤, 7 hop off. How many are left?", 9),
                NumberProblem("13 🍎, give 5 away. How many are left?", 8)
              ])),

        // ---- Ten more / ten less (place-value pattern) ----
        Skill(id: "BR-M9", grade: 1, subject: .math,
              title: "Ten More, Ten Less",
              standard: "Bridge · CCSS 1.NBT.5",
              activity: "Ten more or ten less just changes the tens. Type the new number!",
              parentTip: "Ten more than 25 is 35 — only the tens digit goes up by one. Ten less goes down by one ten.",
              lesson: .numberPad([
                NumberProblem("20 and 10 more. How many?", 30),
                NumberProblem("40 and 10 more. How many?", 50),
                NumberProblem("15 and 10 more. How many?", 25),
                NumberProblem("30, now ten less. How many?", 20),
                NumberProblem("60, now ten less. How many?", 50)
              ]))
    ]
}
