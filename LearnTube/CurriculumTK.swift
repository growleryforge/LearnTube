import SwiftUI

// MARK: - TK games built from Paige's lesson library
//
// Paige wrote a whole curriculum as web pages (CalArtsSciences): 209 topic
// pages across TK, K and 1st. The teaching, the vocabulary and the examples in
// those pages are the asset, and this is where they land in LearnTube.
//
// What does NOT come across is the SHAPE. Every page ends in multiple choice:
// one right answer and two silly ones. That is exactly the tap-the-answer form
// Gabriel learned to game, and the form the whole September rebuild moved away
// from. So each page is re-cut as something he DOES — carry a thing to a pen,
// put steps in order — using her content, her examples and her wording.
//
// These fill the gaps LearnTube had no answer for at TK: social studies, the
// wider feeling words, the senses, and self-care.

extension Curriculum {

    static let paigeTK: [Skill] = [

        // --- Social studies: nothing at all in LearnTube before this ---------
        // Source: tk_Soc_Helpers.html, "Community Helpers".
        Skill(id: "TK-L2", grade: -1, subject: .life,
              title: "Who Helps?",
              standard: "CA PLF Social Studies (community)",
              activity: "A fire, a scraped knee, a story book. Drag each one to the helper who helps!",
              parentTip: "Helpers he can actually meet. Point them out on a drive: the fire station, the library.",
              lesson: .sort(prompt: "Who would help? Take each one to the right person.",
                            bins: [SortBin("fire", "Firefighter", "🚒"),
                                   SortBin("doc", "Doctor", "👩‍⚕️"),
                                   SortBin("lib", "Librarian", "📚")],
                            items: [
                              SortThing("🔥", "a fire", "fire"),
                              SortThing("🚨", "an alarm", "fire"),
                              SortThing("🧯", "a hose", "fire"),
                              SortThing("🩹", "a scraped knee", "doc"),
                              SortThing("🤒", "feeling sick", "doc"),
                              SortThing("💊", "medicine", "doc"),
                              SortThing("📖", "a story book", "lib"),
                              SortThing("🔖", "a bookmark", "lib"),
                              SortThing("🗂️", "the card file", "lib")
                            ])),

        // --- Feelings, past happy and sad -----------------------------------
        // Source: tk_SEL_Feelings.html, "Feeling Words". TK-L1 only has two
        // feelings; this gives the other faces their names.
        Skill(id: "TK-L3", grade: -1, subject: .life,
              title: "Feeling Words",
              standard: "CA PLF Social-Emotional",
              activity: "Every face has a name. Drag each face to the feeling word!",
              parentTip: "All of them are okay to feel. Naming one is easier than sitting in it.",
              lesson: .sort(prompt: "What is this face feeling? Take it to the word.",
                            bins: [SortBin("happy", "Happy", "😊"),
                                   SortBin("sad", "Sad", "😢"),
                                   SortBin("angry", "Angry", "😠")],
                            items: [
                              SortThing("😄", "a big smile", "happy"),
                              SortThing("🥳", "cheering", "happy"),
                              SortThing("😁", "a grin", "happy"),
                              SortThing("😭", "crying", "sad"),
                              SortThing("🥺", "teary", "sad"),
                              SortThing("😞", "head down", "sad"),
                              SortThing("😡", "very cross", "angry"),
                              SortThing("😤", "steaming", "angry"),
                              SortThing("😾", "a grumpy cat", "angry")
                            ])),

        // --- The five senses ------------------------------------------------
        // Source: tk_Sci_Senses.html, "Using My Senses".
        Skill(id: "TK-S4", grade: -1, subject: .science,
              title: "Which Sense?",
              standard: "CA PLF Science (observation)",
              activity: "Eyes, ears, nose or hands? Drag each thing to the part you'd use!",
              parentTip: "Try it for real: shut your eyes and guess something by smell or touch.",
              lesson: .sort(prompt: "Which part do you use? Take it there.",
                            bins: [SortBin("eyes", "Eyes", "👀"),
                                   SortBin("ears", "Ears", "👂"),
                                   SortBin("nose", "Nose", "👃"),
                                   SortBin("hands", "Hands", "✋")],
                            items: [
                              SortThing("🌈", "a rainbow", "eyes"),
                              SortThing("⭐", "a star", "eyes"),
                              SortThing("🎺", "a trumpet", "ears"),
                              SortThing("🔔", "a bell", "ears"),
                              SortThing("🌸", "a flower", "nose"),
                              SortThing("🍪", "a warm cookie", "nose"),
                              SortThing("🧸", "soft fur", "hands"),
                              SortThing("❄️", "cold ice", "hands")
                            ])),

        // --- Self-care, in order --------------------------------------------
        // Source: tk_Phys_Hands.html, "Washing Hands". Her page asks which
        // things you wash with; the doing version is the sequence itself.
        Skill(id: "TK-L4", grade: -1, subject: .life,
              title: "Wash Your Hands",
              standard: "CA PLF Health & Self-help",
              activity: "Wet, soap, scrub, rinse, dry. Tap them in the right order!",
              parentTip: "Twenty seconds of scrubbing is about one happy birthday, sung badly.",
              lesson: .order(prompt: "What do you do first? Tap them in order.",
                             items: ["💧 Wet", "🧼 Soap", "🫧 Scrub", "🚿 Rinse", "🧻 Dry"]))
    ]
}
