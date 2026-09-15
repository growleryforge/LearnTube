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
                Question("She ___ hello to me.", correct: "said", wrong: ["sed", "sayd"]),
                Question("___ are my good friends.", correct: "They", wrong: ["Thay", "Tey"]),
                Question("___ is your name?", correct: "What", wrong: ["Wut", "Whut"])
              ])),

        Skill(id: "G1-R4", grade: 1, subject: .reading,
              title: "Read and Answer",
              standard: "CA CCSS RF.1.4",
              activity: "Read each little sentence, then tap the answer!",
              parentTip: "Reading for meaning is the goal. Read it together if he likes.",
              lesson: .quiz([
                Question("'The hen is red.'  What color is the hen?", correct: "🔴", wrong: ["🔵", "🟢"]),
                Question("'A pig can run.'  Can the pig run?", correct: "Yes", wrong: ["No"]),
                Question("'I see two cows.'  How many cows?", correct: "2", wrong: ["1", "10"])
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

        Skill(id: "G1-R9", grade: 1, subject: .reading,
              title: "Hear It, Read It",
              standard: "CA CCSS RF.1.3g",
              activity: "Leo says a First Grade word. Find it among the look-alikes!",
              parentTip: "Sight words by ear and eye. Read the three choices with him and ask which one Leo said.",
              lesson: .story(id: "sight-words-1")),

        Skill(id: "G1-R8", grade: 1, subject: .reading,
              title: "Word Builder",
              standard: "CA CCSS RF.K.3 / L.1.2",
              activity: "Build farm words like pig and hen one letter at a time. Leo reads each one back!",
              parentTip: "Say each sound as he taps it, then blend them: p, i, g, pig.",
              lesson: .story(id: "word-builder")),

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
                NumberProblem("How long is the pencil? Count the clips!", 5, visual: ["📎","📎","📎","📎","📎"]),
                NumberProblem("A carrot is 4 clips, a worm is 1 clip. How many longer is the carrot?", 3),
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
              activity: "Numbers go in order. Tap the one that's missing!",
              parentTip: "Count out loud together to hear which number was skipped.",
              lesson: .quiz([
                Question("7, 8, __, 10", correct: "9", wrong: ["6", "11"]),
                Question("3, 4, 5, __", correct: "6", wrong: ["7", "2"]),
                Question("12, 13, __, 15", correct: "14", wrong: ["11", "16"]),
                Question("17, 18, __, 20", correct: "19", wrong: ["16", "21"])
              ])),

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
              activity: "Read the little sentence, then answer about it!",
              parentTip: "He reads one short sentence and answers who or what. That's real comprehension.",
              lesson: .quiz([
                Question("The cat is big. Who is big?", correct: "🐱", wrong: ["🐶", "☀️"]),
                Question("A dog can run. What can run?", correct: "🐶", wrong: ["🐱", "🐦"]),
                Question("The sun is hot. What is hot?", correct: "☀️", wrong: ["❄️", "🐶"]),
                Question("I see a red bug. What color is it?", correct: "🔴", wrong: ["🔵", "🟢"])
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
              title: "Sort the Rhymes: Three Families",
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
              title: "How Many Chicks?",
              standard: "CA PLF Math",
              activity: "Count the animals, then tap the number that says how many.",
              parentTip: "The LAST number he counts is the answer — that's cardinality.",
              lesson: .numberGen(.count, rounds: 5)),

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
                             pairs: [.init("🐦", "🪺 nest"),
                                     .init("🐟", "🌊 water"),
                                     .init("🐝", "🍯 hive"),
                                     .init("🐶", "🏠 house")])),

        Skill(id: "TK-S3", grade: -1, subject: .science,
              title: "Who's the Baby?",
              standard: "CA PLF Science",
              activity: "Baby animals have special names. Tap the right one!",
              parentTip: "A puppy, a kitten, a calf, a chick — name the babies on the farm.",
              lesson: .quiz([
                Question("A baby dog 🐕 is a...", correct: "🐶 puppy", wrong: ["🐱 kitten", "🐮 calf"]),
                Question("A baby cat 🐈 is a...", correct: "🐱 kitten", wrong: ["🐶 puppy", "🐣 chick"]),
                Question("A baby cow 🐄 is a...", correct: "🐮 calf", wrong: ["🐰 bunny", "🐶 puppy"]),
                Question("A baby hen 🐔 is a...", correct: "🐣 chick", wrong: ["🐱 kitten", "🐮 calf"])
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
              activity: "Which number is bigger (or smaller)? Tap it!",
              parentTip: "Bigger numbers are farther along when you count. 14 comes after 9, so it's more.",
              lesson: .quiz([
                Question("Which is MORE?", correct: "14", wrong: ["9"]),
                Question("Which is LESS?", correct: "8", wrong: ["12"]),
                Question("Which is MORE?", correct: "17", wrong: ["11"]),
                Question("Which is LESS?", correct: "6", wrong: ["10"])
              ])),

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
              activity: "Read the little sentence, then answer yes or no!",
              parentTip: "He reads for meaning and answers yes or no — no word to copy, so he has to understand it.",
              lesson: .quiz([
                Question("The 🐶 runs fast.  Can the dog run?", correct: "Yes", wrong: ["No"]),
                Question("The 🐱 is asleep.  Is the cat awake?", correct: "No", wrong: ["Yes"]),
                Question("The 🐮 eats grass.  Does the cow eat grass?", correct: "Yes", wrong: ["No"]),
                Question("The 🐟 can swim.  Can the fish fly?", correct: "No", wrong: ["Yes"])
              ])),

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
