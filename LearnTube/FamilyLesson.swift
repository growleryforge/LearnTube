import SwiftUI

extension Stories {
    /// The scaffold for learning ADDITION to 10, built on Gabriel's family of
    /// 10 (7 cats + 2 dogs + Gabriel). Each level teaches one small idea, the
    /// easiest first, and asks several freshly-generated questions so repeating
    /// the lesson builds real mastery instead of memorizing one set of answers.
    /// There is no subtraction and nothing goes above 10.
    static let additionLevels: [AdditionLevel] = [
        AdditionLevel(skill: "How many?",     concept: .count,      rounds: 3),
        AdditionLevel(skill: "One more",      concept: .plusOne,    rounds: 3),
        AdditionLevel(skill: "Put together",  concept: .countAll,   rounds: 3),
        AdditionLevel(skill: "Count on",      concept: .countOn,    rounds: 3),
        AdditionLevel(skill: "Two parts",     concept: .numberBond, rounds: 3),
        AdditionLevel(skill: "Make 10",       concept: .makeTen,    rounds: 3)
    ]

    static let familyMath = StoryContent(
        id: "family-add",
        title: "Gabriel's Family of 10",
        author: "Maddy Turley",
        covers: "Adding up to 10, one easy step at a time: counting, adding one more, putting two groups together, counting on, number bonds, and making 10. Brand-new questions every time you play.",
        darkPages: true,
        // No intro pages — tapping the thumbnail drops Gabriel straight into
        // the first counting game. The family (his cats and dogs) shows up
        // throughout the questions themselves.
        pages: [],
        // One clean game, Shape Detective style: two groups of pets, tap the
        // total. Six rounds; "Game X of 6" advances.
        games: (1...6).map { _ in
            StoryGame(skill: "How many in all?",
                      activity: .familyAdd(FamilyAddLevel(skill: "How many in all?", rounds: 1)))
        }
    )
}

extension Stories {
    /// Sort the farm animals into groups, then count each group. Built on the
    /// real farm: 25 chickens, 10 sheep, 7 cats, 2 dogs. Each round draws a
    /// small, countable handful in those same proportions so the sorting and
    /// the counting both stay within reach.
    static let farmSort = StoryContent(
        id: "farm-sort",
        title: "Sort the Farm Animals",
        author: "Maddy Turley",
        covers: "Sort the farm animals into their groups (chickens, sheep, cats, and dogs), then see how many are in each. Builds sorting into categories and counting each group (CA CCSS K.MD.B.3).",
        darkPages: true,
        pages: [],
        // Three separate sorts so the "Game X of 3" counter advances as he goes.
        games: (1...3).map { _ in
            StoryGame(skill: "Sort & count",
                      activity: .sortCount(SortLevel(skill: "Sort & count", rounds: 1)))
        }
    )
}

extension Stories {
    /// Name and describe 2D shapes: circle, square, triangle, rectangle,
    /// hexagon (CA CCSS K.G.2). Tap the matching shape; each correct answer
    /// states the describing fact. Fresh shapes and prompts every play.
    static let shapesLesson = StoryContent(
        id: "shapes",
        title: "Shape Detective",
        author: "Maddy Turley",
        covers: "Name and describe flat shapes: circle, square, triangle, rectangle, and hexagon. Find each shape by its name or by how many sides it has (CA CCSS K.G.2).",
        darkPages: true,
        pages: [],
        // Five separate shape questions so the "Game X of 5" counter advances.
        games: (1...5).map { _ in
            StoryGame(skill: "Name the shape",
                      activity: .shapes(ShapeLevel(skill: "Name the shape", rounds: 1)))
        }
    )
}

extension Stories {
    /// Spot a shape no matter its size or orientation (CA CCSS K.G.2). Tap every
    /// triangle/circle/etc. in a jumble where they appear big, small, and turned.
    static let shapeSpotLesson = StoryContent(
        id: "shape-spot",
        title: "Shape Spotter",
        author: "Maddy Turley",
        covers: "Find every triangle, circle, square, rectangle, or hexagon, even when it is big, small, or turned. Names shapes no matter their size or which way they face (CA CCSS K.G.2).",
        darkPages: true,
        pages: [],
        // Four rounds, each a different shape to hunt; "Game X of 4" advances.
        games: (1...4).map { _ in
            StoryGame(skill: "Spot the shape",
                      activity: .shapeSpot(ShapeSpotLevel(skill: "Spot the shape", rounds: 1)))
        }
    )
}

extension Stories {
    /// Find letters by name ("Find the B!") or by sound ("Which says /b/?").
    /// Builds letter recognition and letter sounds (CA CCSS RF.K.1d, RF.K.3a).
    static let letterDetective = StoryContent(
        id: "letter-detective",
        title: "Letter Detective",
        author: "Maddy Turley",
        covers: "Find letters by their name or by the sound they make. Each letter shows its big and little form, and every answer gives the sound and a key word (CA CCSS RF.K).",
        darkPages: true,
        pages: [],
        // Six letters per play; "Game X of 6" advances.
        games: (1...6).map { _ in
            StoryGame(skill: "Letter Detective",
                      activity: .letters(LetterLevel(skill: "Letter Detective", rounds: 1)))
        }
    )
}

extension Stories {
    /// Observe and describe different kinds of weather (CA NGSS K-ESS2-1). Spot
    /// the weather by name ("Which is sunny?") or by what it does ("Which has
    /// thunder?"), with a describing fact and what to wear for each.
    static let weatherWatch = StoryContent(
        id: "weather-watch",
        title: "Weather Detective",
        author: "Maddy Turley",
        covers: "Look at the weather and name it: sunny, rainy, cloudy, snowy, windy, or stormy. Find it by name or by what it does, and learn what to wear (CA NGSS K-ESS2-1).",
        darkPages: true,
        pages: [],
        // Five weather questions; "Game X of 5" advances.
        games: (1...5).map { _ in
            StoryGame(skill: "Weather Detective",
                      activity: .weather(WeatherLevel(skill: "Weather Detective", rounds: 1)))
        }
    )
}

extension Stories {
    /// Match a numeral to a quantity (CA CCSS K.CC.4/5). Count a group of dots
    /// and tap the number, or read a number and tap the group that shows it.
    static let numberDetective = StoryContent(
        id: "number-detective",
        title: "Number Detective",
        author: "Maddy Turley",
        covers: "Count the dots and find the number, or read the number and find the matching group. Connects numbers to how many (CA CCSS K.CC.4-5).",
        darkPages: true,
        pages: [],
        // Six number puzzles; "Game X of 6" advances.
        games: (1...6).map { _ in
            StoryGame(skill: "Number Detective",
                      activity: .numbers(NumberLevel(skill: "Number Detective", rounds: 1)))
        }
    )
}

extension Stories {
    /// Identify major national symbols like the U.S. flag (CA HSS K.2).
    static let americanSymbols = StoryContent(
        id: "american-symbols",
        title: "American Symbols",
        author: "Maddy Turley",
        covers: "Find the U.S. flag, the Statue of Liberty, the bald eagle, the Liberty Bell, and the White House, and learn a little about each (CA HSS K.2).",
        darkPages: true,
        pages: [],
        games: (1...5).map { _ in
            StoryGame(skill: "American Symbols",
                      activity: .symbols(SymbolLevel(skill: "American Symbols", rounds: 1)))
        }
    )

    /// Identify helpers in the school and wider community (CA HSS K.3).
    static let communityHelpers = StoryContent(
        id: "community-helpers",
        title: "Community Helpers",
        author: "Maddy Turley",
        covers: "Meet the people who help us: firefighters, police officers, doctors, teachers, farmers, chefs, and builders. Find each helper and learn what they do (CA HSS K.3).",
        darkPages: true,
        pages: [],
        games: (1...5).map { _ in
            StoryGame(skill: "Community Helpers",
                      activity: .helpers(HelperLevel(skill: "Community Helpers", rounds: 1)))
        }
    )

    /// Know what major holidays celebrate (CA HSS K.1).
    static let holidaysLesson = StoryContent(
        id: "holidays",
        title: "Holidays",
        author: "Maddy Turley",
        covers: "Learn what our holidays celebrate: Thanksgiving, the Fourth of July, MLK Day, New Year's Day, Valentine's Day, and Halloween (CA HSS K.1).",
        darkPages: true,
        pages: [],
        // One game with rounds inside, so "Let's meet the holidays" shows once.
        games: [StoryGame(skill: "Holidays",
                          activity: .holidays(HolidayLevel(skill: "Holidays", rounds: 6)))]
    )

    /// Name family members and describe their roles at home (CA HSS K.3 / SEL).
    /// Celebrates that families come in all kinds, and this is Gabriel's.
    static let myFamily = StoryContent(
        id: "my-family",
        title: "My Family",
        author: "Maddy Turley",
        covers: "Families come in all kinds! Meet Gabriel's family, his two moms Mommy and Maddy plus the cats and dogs, and learn what everyone does at home (CA HSS K.3).",
        darkPages: true,
        pages: [
            StoryPage(scene: .family,
                      text: "Families come in all kinds! 💛 A mom and a dad, two moms, two dads, or grandparents."),
            StoryPage(scene: .family,
                      text: "This is YOUR family! 🦁 Maddy the Lion, Mommy the Lioness, and you, the Lion Cub! Plus your cats and dogs. 🐱🐶")
        ],
        games: (1...6).map { _ in
            StoryGame(skill: "My Family",
                      activity: .familyMembers(FamilyMemberLevel(skill: "My Family", rounds: 1)))
        }
    )

    /// Recognize and extend repeating patterns (CA K).
    static let patternsLesson = StoryContent(
        id: "patterns",
        title: "What Comes Next?",
        author: "Maddy Turley",
        covers: "Look at the repeating color pattern and tap the color that comes next. Builds pattern thinking, an early math skill.",
        darkPages: true,
        pages: [],
        games: (1...6).map { _ in
            StoryGame(skill: "What Comes Next?",
                      activity: .patterns(PatternLevel(skill: "What Comes Next?", rounds: 1)))
        }
    )

    /// Recognize rhyming words (CA CCSS RF.K.2a).
    static let rhymeLesson = StoryContent(
        id: "rhyme-time",
        title: "Rhyme Time",
        author: "Maddy Turley",
        covers: "Find the word that rhymes! Cat and hat, dog and frog. Builds the rhyming sound skill that powers reading (CA CCSS RF.K.2a).",
        darkPages: true,
        pages: [],
        games: (1...6).map { _ in
            StoryGame(skill: "Rhyme Time",
                      activity: .rhymes(RhymeLevel(skill: "Rhyme Time", rounds: 1)))
        }
    )

    /// Identify shapes as flat (2D) or solid (3D) - CA CCSS K.G.3.
    static let flatSolidLesson = StoryContent(
        id: "flat-or-solid",
        title: "Flat or Solid?",
        author: "Maddy Turley",
        covers: "Some shapes are flat, like a circle you draw. Some are solid, like a ball you hold. Tell flat (2D) from solid (3D) shapes (CA CCSS K.G.3).",
        darkPages: true,
        pages: [],
        // One game with the rounds inside, so the teaching screen shows once.
        games: [StoryGame(skill: "Flat or Solid?",
                          activity: .geo(GeoLevel(skill: "Flat or Solid?", rounds: 6)))]
    )

    /// Sort plants and animals by what you can observe (CA NGSS K life science).
    static let livingThingsLesson = StoryContent(
        id: "plant-or-animal",
        title: "Plant or Animal?",
        author: "Maddy Turley",
        covers: "Sort living things by what you can see: which is a plant, which is an animal, which can fly, and which lives in water (CA NGSS K).",
        darkPages: true,
        pages: [],
        games: (1...6).map { _ in
            StoryGame(skill: "Plant or Animal?",
                      activity: .living(LivingLevel(skill: "Plant or Animal?", rounds: 1)))
        }
    )

    /// Describe and compare measurable attributes (CA CCSS K.MD.1-2).
    static let compareLesson = StoryContent(
        id: "bigger-smaller",
        title: "Bigger or Smaller?",
        author: "Maddy Turley",
        covers: "Compare two things: which is bigger or smaller, taller or shorter, heavier or lighter? Describes and compares size, height, and weight (CA CCSS K.MD.1-2).",
        darkPages: true,
        pages: [],
        games: (1...6).map { _ in
            StoryGame(skill: "Bigger or Smaller?",
                      activity: .compare(CompareLevel(skill: "Bigger or Smaller?", rounds: 1)))
        }
    )

    /// Compose simple shapes to form a larger shape (CA CCSS K.G.6). A picture
    /// is built from simple shapes with one piece missing; he taps the shape
    /// that fills the gap.
    static let buildShapeLesson = StoryContent(
        id: "build-shape",
        title: "Build a Shape",
        author: "Maddy Turley",
        covers: "Put simple shapes together to make a picture - a triangle and a square make a house! Finish each picture by tapping the missing shape (CA CCSS K.G.6).",
        darkPages: true,
        pages: [],
        // One game with the rounds inside, so the teaching screen shows once.
        games: [StoryGame(skill: "Build a Shape",
                          activity: .build(BuildLevel(skill: "Build a Shape", rounds: 6)))]
    )

    /// Visual add & subtract story problems within 20 (CA CCSS 1.OA.1). The
    /// situation is acted out - some arrive, some are crossed out - so he can
    /// solve it without reading.
    static let storyProblems = StoryContent(
        id: "word-problems",
        title: "Story Problems",
        author: "Maddy Turley",
        covers: "Solve add and subtract story problems you can see: some come, some go away. Find the answer within 20 (CA CCSS 1.OA.1).",
        darkPages: true,
        pages: [],
        games: [StoryGame(skill: "Story Problems",
                          activity: .wordProblem(WordProblemLevel(skill: "Story Problems", rounds: 6)))]
    )

    /// Push or pull (CA NGSS K-PS2-1).
    static let pushPullLesson = StoryContent(
        id: "push-pull", title: "Push or Pull?", author: "Maddy Turley",
        covers: "Things move when we push or pull them. Look at each one and tap how it moves (CA NGSS K-PS2-1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Push or Pull?", activity: .pushPull(PushPullLevel(skill: "Push or Pull?", rounds: 6)))]
    )

    /// What living things need (CA NGSS K-LS1-1).
    static let needsLesson = StoryContent(
        id: "living-needs", title: "What They Need", author: "Maddy Turley",
        covers: "Plants and animals need food, water, and sunlight to live. Tap what each one needs (CA NGSS K-LS1-1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "What They Need", activity: .needs(NeedsLevel(skill: "What They Need", rounds: 6)))]
    )

    /// Position words: on top, under, next to (CA CCSS K.G.1).
    static let positionLesson = StoryContent(
        id: "position-words", title: "Where Is It?", author: "Maddy Turley",
        covers: "Describe where things are: on top, under, or next to. Tap the picture that matches (CA CCSS K.G.1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Where Is It?", activity: .position(PosLevel(skill: "Where Is It?", rounds: 6)))]
    )

    /// High-frequency sight words (CA CCSS RF.K.3c).
    static let sightLesson = StoryContent(
        id: "sight-words", title: "Star Words", author: "Maddy Turley",
        covers: "Read the words that pop up everywhere: the, and, see, my, like. Find the matching word (CA CCSS RF.K.3c).",
        darkPages: true, pages: [],
        games: (1...6).map { _ in
            StoryGame(skill: "Star Words", activity: .sight(SightLevel(skill: "Star Words", rounds: 1)))
        }
    )

    /// Number order and comparison (CA CCSS K.CC.4-6).
    static let numberOrderLesson = StoryContent(
        id: "number-order", title: "More or Less", author: "Maddy Turley",
        covers: "What comes next when we count, and which number is more or less? Tap the right number (CA CCSS K.CC.4-6).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "More or Less", activity: .numberOrder(NumOrderLevel(skill: "More or Less", rounds: 6)))]
    )

    /// Animals and where they live (CA NGSS K-ESS3-1).
    static let animalHomesLesson = StoryContent(
        id: "animal-homes", title: "Animal Homes", author: "Maddy Turley",
        covers: "Animals live in different places: the farm, the ocean, cold snowy places, and the jungle. Match each animal to its home (CA NGSS K-ESS3-1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Animal Homes", activity: .animalHomes(AnimalHomeLevel(skill: "Animal Homes", rounds: 6)))]
    )

    /// How many legs (CA CCSS K.CC.4 counting).
    static let legsLesson = StoryContent(
        id: "animal-legs", title: "How Many Legs?", author: "Maddy Turley",
        covers: "Count an animal's legs: birds have 2, dogs have 4, bugs have 6, spiders have 8. Counting to tell how many (CA CCSS K.CC.4).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "How Many Legs?", activity: .legs(LegsLevel(skill: "How Many Legs?", rounds: 6)))]
    )

    /// Animal body coverings (CA NGSS 1-LS1-1).
    static let coveringsLesson = StoryContent(
        id: "animal-coverings", title: "Fur, Feathers, Scales", author: "Maddy Turley",
        covers: "Animals are covered in fur, feathers, or scales. Sort each animal by its body covering (CA NGSS 1-LS1-1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Fur, Feathers, Scales", activity: .coverings(CoverLevel(skill: "Fur, Feathers, Scales", rounds: 6)))]
    )

    /// What animals eat (CA NGSS K-LS1).
    static let eatsLesson = StoryContent(
        id: "animal-eats", title: "What Do Animals Eat?", author: "Maddy Turley",
        covers: "Every animal eats to live. Match each animal to the food it eats (CA NGSS K-LS1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "What Do Animals Eat?", activity: .eats(EatLevel(skill: "What Do Animals Eat?", rounds: 6)))]
    )

    /// Teen numbers are ten and some more (CA CCSS K.NBT.1).
    static let teenLesson = StoryContent(
        id: "teen-numbers", title: "Teen Numbers", author: "Maddy Turley",
        covers: "Teen numbers are a ten and some more: 13 is ten and three. Count the group of ten plus the extra ones (CA CCSS K.NBT.1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Teen Numbers", activity: .teen(TeenLevel(skill: "Teen Numbers", rounds: 6)))]
    )

    /// Young animals look like their parents (CA NGSS 1-LS3-1).
    static let babyLesson = StoryContent(
        id: "baby-animals", title: "Baby Animals", author: "Maddy Turley",
        covers: "Baby animals look like their parents, just smaller. Match each parent to its baby (CA NGSS 1-LS3-1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Baby Animals", activity: .baby(BabyLevel(skill: "Baby Animals", rounds: 6)))]
    )

    /// Living or not living (CA NGSS K, characteristics of living things).
    static let livingNotLesson = StoryContent(
        id: "living-not", title: "Alive or Not?", author: "Maddy Turley",
        covers: "Living things grow, eat, and move. Tell what's alive (animals and plants) from what's not (toys and rocks) - CA NGSS K.",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Alive or Not?", activity: .alive(LiveLevel(skill: "Alive or Not?", rounds: 6)))]
    )

    /// Day or night animals (animal behavior / day-night patterns).
    static let dayNightLesson = StoryContent(
        id: "day-night", title: "Day or Night?", author: "Maddy Turley",
        covers: "Some animals are awake at night, like owls and bats; others in the day, like bees. Match each animal to when it's awake (CA NGSS day & night patterns).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Day or Night?", activity: .dayNight(DNLevel(skill: "Day or Night?", rounds: 6)))]
    )

    /// Make five with a missing part (CA CCSS K.OA.4).
    static let make5Lesson = StoryContent(
        id: "make-5", title: "Make 5", author: "Maddy Turley",
        covers: "Find how many more make 5: 3 and 2, 4 and 1. Building the number 5 with two parts (CA CCSS K.OA.4).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Make 5", activity: .make5(Make5Level(skill: "Make 5", rounds: 6)))]
    )

    /// Compare two groups (CA CCSS K.CC.6).
    static let whichMoreLesson = StoryContent(
        id: "which-more", title: "Which Has More?", author: "Maddy Turley",
        covers: "Count two groups of animals and tap the one with more (or fewer). Comparing quantities (CA CCSS K.CC.6).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Which Has More?", activity: .whichMore(MoreLevel(skill: "Which Has More?", rounds: 6)))]
    )

    /// Which animals hatch from eggs (CA NGSS K life science).
    static let eggLesson = StoryContent(
        id: "egg-or-not", title: "Egg or Not?", author: "Maddy Turley",
        covers: "Some animals hatch from eggs (hens, turtles, fish); others are born (puppies, calves). Sort animals by how they have young (CA NGSS K).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Egg or Not?", activity: .egg(EggLevel(skill: "Egg or Not?", rounds: 6)))]
    )

    /// Pets vs wild animals (classifying animals).
    static let wildLesson = StoryContent(
        id: "wild-or-pet", title: "Wild or Pet?", author: "Maddy Turley",
        covers: "Pets live with people, like dogs and cats. Wild animals live on their own, like lions. Sort each animal (CA NGSS K).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Wild or Pet?", activity: .wild(WildLevel(skill: "Wild or Pet?", rounds: 6)))]
    )

    /// Make ten with a missing part (CA CCSS K.OA.4).
    static let make10Lesson = StoryContent(
        id: "make-10", title: "Make 10", author: "Maddy Turley",
        covers: "Some animals are here. Find how many more make ten (CA CCSS K.OA.4).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Make 10", activity: .make10(Make10Level(skill: "Make 10", rounds: 6)))]
    )

    /// Subtraction within 10 by taking away (CA CCSS K.OA.1).
    static let takeAwayLesson = StoryContent(
        id: "take-away", title: "Take Away", author: "Maddy Turley",
        covers: "Some animals hop away. Count how many are left (CA CCSS K.OA.1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Take Away", activity: .takeAway(TakeAwayLevel(skill: "Take Away", rounds: 6)))]
    )

    /// Doubles facts (CA CCSS 1.OA.6).
    static let doublesLesson = StoryContent(
        id: "doubles", title: "Doubles", author: "Maddy Turley",
        covers: "A double is a number and itself. 2 and 2 makes 4 (CA CCSS 1.OA.6).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Doubles", activity: .doubles(DoublesLevel(skill: "Doubles", rounds: 6)))]
    )

    /// Ordinal numbers — first, second, third (CA CCSS K.CC.4).
    static let ordinalLesson = StoryContent(
        id: "ordinals", title: "First, Second, Third", author: "Maddy Turley",
        covers: "Count from the front to find each place — first, second, third (CA CCSS K.CC.4).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Ordinal Numbers", activity: .ordinal(OrdinalLevel(skill: "Ordinal Numbers", rounds: 6)))]
    )

    /// Beginning sounds — letter-sound match (CA CCSS RF.K.3).
    static let soundLesson = StoryContent(
        id: "beginning-sounds", title: "Beginning Sounds", author: "Maddy Turley",
        covers: "Every word starts with a sound. Match the animal to its first letter (CA CCSS RF.K.3).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Beginning Sounds", activity: .beginningSound(SoundLevel(skill: "Beginning Sounds", rounds: 6)))]
    )

    /// Life cycle — living things grow and change (CA NGSS 1-LS1).
    static let lifeCycleLesson = StoryContent(
        id: "life-cycle", title: "Growing Up", author: "Maddy Turley",
        covers: "Living things grow and change. An egg becomes a caterpillar becomes a butterfly (CA NGSS 1-LS1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Life Cycle", activity: .lifeCycle(CycleLevel(skill: "Life Cycle", rounds: 6)))]
    )

    /// Skip counting by tens (CA CCSS K.CC.1).
    static let countTensLesson = StoryContent(
        id: "count-tens", title: "Count by 10s", author: "Maddy Turley",
        covers: "Skip count by tens: 10, 20, 30, 40 (CA CCSS K.CC.1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Count by 10s", activity: .countTens(TensLevel(skill: "Count by 10s", rounds: 6)))]
    )

    /// Fast or slow animals (comparing motion).
    static let fastSlowLesson = StoryContent(
        id: "fast-slow", title: "Fast or Slow", author: "Maddy Turley",
        covers: "Some animals are fast, some are slow. Sort each one (CA NGSS K-PS2).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Fast or Slow", activity: .fastSlow(SpeedLevel(skill: "Fast or Slow", rounds: 6)))]
    )

    /// Sink or float (CA NGSS 2-PS1).
    static let sinkFloatLesson = StoryContent(
        id: "sink-float", title: "Sink or Float", author: "Maddy Turley",
        covers: "Some things float on water, some sink. Predict each one (CA NGSS 2-PS1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Sink or Float", activity: .sinkFloat(FloatLevel(skill: "Sink or Float", rounds: 6)))]
    )

    /// Match uppercase to lowercase letters (CA CCSS RF.K.1d).
    static let letterCaseLesson = StoryContent(
        id: "letter-case", title: "Big & Little Letters", author: "Maddy Turley",
        covers: "Match each big letter to its little letter (CA CCSS RF.K.1d).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Big & Little Letters", activity: .letterCase(CaseLevel(skill: "Big & Little Letters", rounds: 6)))]
    )

    /// The five senses (CA NGSS K).
    static let fiveSensesLesson = StoryContent(
        id: "five-senses", title: "Five Senses", author: "Maddy Turley",
        covers: "See, hear, smell, taste, and touch — your five senses (CA NGSS K).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Five Senses", activity: .fiveSenses(SenseLevel(skill: "Five Senses", rounds: 6)))]
    )

    /// Opposite words (CA CCSS L.K.5b).
    static let oppositesLesson = StoryContent(
        id: "opposites", title: "Opposites", author: "Maddy Turley",
        covers: "Opposites are totally different — big/little, hot/cold (CA CCSS L.K.5b).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Opposites", activity: .opposites(OppLevel(skill: "Opposites", rounds: 6)))]
    )
}

// MARK: - New concept games (batch: reading + animal science, all emoji quizzes)

extension Stories {

    static let syllablesLesson = StoryContent(
        id: "syllables", title: "Syllable Safari", author: "LearnTube",
        covers: "Breaking words into syllables by clapping the beats — an early reading skill (CA CCSS RF.K.2).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Syllable Safari", activity: .quiz([
            sqv(["🐱"], "Clap the name: CAT. Just one clap! 👏",
                ["How many claps in 🐱 CAT?", "Clap 🐱 CAT — how many beats?"],
                [sc("1️⃣","1 clap", true), sc("2️⃣","2 claps"), sc("3️⃣","3 claps")]),
            sqv(["🐶"], "DOG — one clap! 👏",
                ["How many claps in 🐶 DOG?", "Clap 🐶 DOG — how many beats?"],
                [sc("1️⃣","1 clap", true), sc("2️⃣","2 claps"), sc("3️⃣","3 claps")]),
            sqv(["🐰"], "RAB · BIT — two claps! 👏👏",
                ["How many claps in 🐰 RABBIT?", "Clap 🐰 RAB-BIT — how many beats?"],
                [sc("2️⃣","2 claps", true), sc("1️⃣","1 clap"), sc("3️⃣","3 claps")]),
            sqv(["🦒"], "GI · RAFFE — two claps! 👏👏",
                ["How many claps in 🦒 GIRAFFE?", "Clap 🦒 GI-RAFFE — how many beats?"],
                [sc("2️⃣","2 claps", true), sc("1️⃣","1 clap"), sc("3️⃣","3 claps")]),
            sqv(["🐧"], "PEN · GUIN — two claps! 👏👏",
                ["How many claps in 🐧 PENGUIN?", "Clap 🐧 PEN-GUIN — how many beats?"],
                [sc("2️⃣","2 claps", true), sc("1️⃣","1 clap"), sc("3️⃣","3 claps")]),
            sqv(["🐘"], "EL · E · PHANT — three claps! 👏👏👏",
                ["How many claps in 🐘 ELEPHANT?", "Clap 🐘 EL-E-PHANT — how many beats?"],
                [sc("3️⃣","3 claps", true), sc("1️⃣","1 clap"), sc("2️⃣","2 claps")]),
            sqv(["🦋"], "BUT · TER · FLY — three claps! 👏👏👏",
                ["How many claps in 🦋 BUTTERFLY?", "Clap 🦋 BUT-TER-FLY — how many beats?"],
                [sc("3️⃣","3 claps", true), sc("1️⃣","1 clap"), sc("2️⃣","2 claps")]),
            sqv(["🐊"], "CROC · O · DILE — three claps! 👏👏👏",
                ["How many claps in 🐊 CROCODILE?", "Clap 🐊 CROC-O-DILE — how many beats?"],
                [sc("3️⃣","3 claps", true), sc("2️⃣","2 claps"), sc("1️⃣","1 clap")])
        ]))]
    )

    static let animalGroupsLesson = StoryContent(
        id: "animal-groups", title: "Animal Groups", author: "LearnTube",
        covers: "Sorting animals into groups — mammals, birds, fish, reptiles, and bugs — by their traits (CA NGSS K-LS1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Animal Groups", activity: .quiz([
            sqv(["🐕"], "A 🐕 dog has FUR and drank milk as a baby — it is a MAMMAL.",
                ["What group is a 🐕 dog?", "🐕 dogs belong to which group?"],
                [sc("🐻","Mammal", true), sc("🐦","Bird"), sc("🐟","Fish")]),
            sqv(["🦅"], "An 🦅 eagle has FEATHERS and WINGS — it is a BIRD.",
                ["What group is an 🦅 eagle?", "🦅 eagles belong to which group?"],
                [sc("🐦","Bird", true), sc("🐻","Mammal"), sc("🦎","Reptile")]),
            sqv(["🐠"], "A 🐠 fish has FINS and lives underwater — it is a FISH.",
                ["What group is a 🐠 fish?", "🐠 fish belong to which group?"],
                [sc("🐟","Fish", true), sc("🐦","Bird"), sc("🐛","Bug")]),
            sqv(["🐍"], "A 🐍 snake has dry SCALES and is cold-blooded — it is a REPTILE.",
                ["What group is a 🐍 snake?", "🐍 snakes belong to which group?"],
                [sc("🦎","Reptile", true), sc("🐻","Mammal"), sc("🐦","Bird")]),
            sqv(["🐝"], "A 🐝 bee has SIX legs — it is a BUG (an insect).",
                ["What group is a 🐝 bee?", "🐝 bees belong to which group?"],
                [sc("🐛","Bug", true), sc("🐟","Fish"), sc("🦎","Reptile")]),
            sqv(["🐢"], "A 🐢 turtle has SCALES and a shell — it is a REPTILE.",
                ["What group is a 🐢 turtle?", "🐢 turtles belong to which group?"],
                [sc("🦎","Reptile", true), sc("🐟","Fish"), sc("🐻","Mammal")]),
            sqv(["🦆"], "A 🦆 duck has FEATHERS — it is a BIRD, even though it swims!",
                ["What group is a 🦆 duck?", "🦆 ducks belong to which group?"],
                [sc("🐦","Bird", true), sc("🐟","Fish"), sc("🐛","Bug")]),
            sqv(["🐬"], "A 🐬 dolphin lives in water but has no scales and feeds its babies milk — it is a MAMMAL!",
                ["What group is a 🐬 dolphin?", "🐬 dolphins belong to which group?"],
                [sc("🐻","Mammal", true), sc("🐟","Fish"), sc("🦎","Reptile")])
        ]))]
    )

    static let animalSoundsLesson = StoryContent(
        id: "animal-sounds", title: "Animal Sounds", author: "LearnTube",
        covers: "Matching farm and wild animals to the sounds they make — listening and animal knowledge (CA NGSS K-LS1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Animal Sounds", activity: .quiz([
            sqv(["🐄"], "A 🐄 cow says MOO! 🎵",
                ["What does a 🐄 cow say?", "Which sound does a 🐄 cow make?"],
                [sc("🎵","Moo", true), sc("🎵","Woof"), sc("🎵","Quack")]),
            sqv(["🐶"], "A 🐶 dog says WOOF! 🎵",
                ["What does a 🐶 dog say?", "Which sound does a 🐶 dog make?"],
                [sc("🎵","Woof", true), sc("🎵","Meow"), sc("🎵","Moo")]),
            sqv(["🐱"], "A 🐱 cat says MEOW! 🎵",
                ["What does a 🐱 cat say?", "Which sound does a 🐱 cat make?"],
                [sc("🎵","Meow", true), sc("🎵","Oink"), sc("🎵","Baa")]),
            sqv(["🦆"], "A 🦆 duck says QUACK! 🎵",
                ["What does a 🦆 duck say?", "Which sound does a 🦆 duck make?"],
                [sc("🎵","Quack", true), sc("🎵","Neigh"), sc("🎵","Woof")]),
            sqv(["🐷"], "A 🐷 pig says OINK! 🎵",
                ["What does a 🐷 pig say?", "Which sound does a 🐷 pig make?"],
                [sc("🎵","Oink", true), sc("🎵","Baa"), sc("🎵","Meow")]),
            sqv(["🐑"], "A 🐑 sheep says BAA! 🎵",
                ["What does a 🐑 sheep say?", "Which sound does a 🐑 sheep make?"],
                [sc("🎵","Baa", true), sc("🎵","Moo"), sc("🎵","Roar")]),
            sqv(["🦁"], "A 🦁 lion says ROAR! 🎵",
                ["What does a 🦁 lion say?", "Which sound does a 🦁 lion make?"],
                [sc("🎵","Roar", true), sc("🎵","Quack"), sc("🎵","Oink")]),
            sqv(["🐔"], "A 🐔 rooster says COCK-A-DOODLE-DOO to wake the farm! 🎵",
                ["What does a 🐔 rooster say?", "Which sound wakes the whole farm?"],
                [sc("🎵","Cock-a-doodle-doo", true), sc("🎵","Moo"), sc("🎵","Meow")])
        ]))]
    )

    static let seasonsLesson = StoryContent(
        id: "seasons", title: "Four Seasons", author: "LearnTube",
        covers: "The four seasons and the weather and changes that come with each (CA NGSS K-ESS2-1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Four Seasons", activity: .quiz([
            sqv(["🗓️"], "In SPRING, 🌸 flowers bloom and 🐣 baby animals are born.",
                ["When do flowers bloom and babies hatch?", "🌸🐣 — which season is it?"],
                [sc("🌸","Spring", true), sc("❄️","Winter"), sc("🍂","Fall")]),
            sqv(["🗓️"], "In SUMMER it is HOT and sunny — perfect for the 🏖️ beach.",
                ["When is it hot and sunny?", "☀️🏖️ — which season is it?"],
                [sc("☀️","Summer", true), sc("❄️","Winter"), sc("🌸","Spring")]),
            sqv(["🗓️"], "In FALL, leaves turn colors and drop 🍂, and we pick 🎃 pumpkins.",
                ["When do the leaves fall from the trees?", "🍂🎃 — which season is it?"],
                [sc("🍂","Fall", true), sc("☀️","Summer"), sc("🌸","Spring")]),
            sqv(["🗓️"], "In WINTER it is COLD and it can ❄️ snow — time for a ⛄ snowman.",
                ["When is it cold and snowy?", "❄️⛄ — which season is it?"],
                [sc("❄️","Winter", true), sc("☀️","Summer"), sc("🍂","Fall")]),
            sqv(["🗓️"], "🐻 Bears sleep (hibernate) all through the cold WINTER.",
                ["When do bears hibernate?", "Bears sleep through which season?"],
                [sc("❄️","Winter", true), sc("🌸","Spring"), sc("☀️","Summer")]),
            sqv(["🗓️"], "🌻 Sunflowers love the long, hot days of SUMMER.",
                ["When is it hottest, with long sunny days?", "🌻 — which season is it?"],
                [sc("☀️","Summer", true), sc("❄️","Winter"), sc("🍂","Fall")]),
            sqv(["🗓️"], "🌷 Tulips pop up when the snow melts in SPRING.",
                ["When do tulips pop up after the snow melts?", "🌷 — which season is it?"],
                [sc("🌸","Spring", true), sc("🍂","Fall"), sc("☀️","Summer")]),
            sqv(["🗓️"], "🍁 Falling leaves and a 🦃 turkey dinner mean it is FALL.",
                ["When do we see falling leaves and turkeys?", "🦃🍁 — which season is it?"],
                [sc("🍂","Fall", true), sc("❄️","Winter"), sc("🌸","Spring")])
        ]))]
    )

    static let moveHowLesson = StoryContent(
        id: "move-how", title: "Swim, Fly, or Walk?", author: "LearnTube",
        covers: "How different animals move — swimming, flying, or walking on land (CA NGSS K-LS1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Swim, Fly, or Walk?", activity: .quiz([
            sqv(["🐟"], "A 🐟 fish has FINS and SWIMS through the water. 🌊",
                ["How does a 🐟 fish get around?", "🐟 fish move by..."],
                [sc("🌊","Swimming", true), sc("☁️","Flying"), sc("🚶","Walking")]),
            sqv(["🦅"], "An 🦅 eagle has WINGS and FLIES high in the sky. ☁️",
                ["How does an 🦅 eagle get around?", "🦅 eagles move by..."],
                [sc("☁️","Flying", true), sc("🌊","Swimming"), sc("🚶","Walking")]),
            sqv(["🐕"], "A 🐕 dog has four legs and WALKS and runs on land. 🌳",
                ["How does a 🐕 dog get around?", "🐕 dogs move by..."],
                [sc("🚶","Walking", true), sc("☁️","Flying"), sc("🌊","Swimming")]),
            sqv(["🦋"], "A 🦋 butterfly has wings and FLIES from flower to flower. 🌸",
                ["How does a 🦋 butterfly get around?", "🦋 butterflies move by..."],
                [sc("☁️","Flying", true), sc("🌊","Swimming"), sc("🚶","Walking")]),
            sqv(["🐬"], "A 🐬 dolphin SWIMS in the ocean with its strong tail. 🌊",
                ["How does a 🐬 dolphin get around?", "🐬 dolphins move by..."],
                [sc("🌊","Swimming", true), sc("☁️","Flying"), sc("🚶","Walking")]),
            sqv(["🐘"], "An 🐘 elephant is big and heavy — it WALKS on land. 🌍",
                ["How does an 🐘 elephant get around?", "🐘 elephants move by..."],
                [sc("🚶","Walking", true), sc("🌊","Swimming"), sc("☁️","Flying")]),
            sqv(["🐦"], "A 🐦 bird flaps its wings and FLIES. ☁️",
                ["How does a 🐦 bird get around?", "🐦 birds move by..."],
                [sc("☁️","Flying", true), sc("🚶","Walking"), sc("🌊","Swimming")]),
            sqv(["🐠"], "A 🐠 clownfish SWIMS around the coral reef. 🌊",
                ["How does a 🐠 fish get around?", "🐠 fish move by..."],
                [sc("🌊","Swimming", true), sc("🚶","Walking"), sc("☁️","Flying")])
        ]))]
    )
}

// MARK: - New concept games (batch 2: skip counting, baby names, plants, temperature)

extension Stories {

    static let countBy5Lesson = StoryContent(
        id: "count-5s", title: "Count by 5s", author: "LearnTube",
        covers: "Skip counting by fives — an early counting pattern (CA CCSS K.CC.1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Count by 5s", activity: .quiz([
            sqv(["🖐️"], "One hand has 5 fingers. Count by 5s: 5... what's next?",
                ["Count by 5s: 5, then?", "5, __? Count by fives!"],
                [sc("🖐️","10", true), sc("🖐️","6"), sc("🖐️","15")]),
            sqv(["🖐️","🖐️"], "5, 10... keep counting by 5s!",
                ["5, 10, then?", "What comes after 10 counting by 5s?"],
                [sc("🖐️","15", true), sc("🖐️","11"), sc("🖐️","20")]),
            sqv(["🖐️","🖐️","🖐️"], "5, 10, 15... what's next?",
                ["5, 10, 15, then?", "What comes after 15 counting by 5s?"],
                [sc("🖐️","20", true), sc("🖐️","16"), sc("🖐️","25")]),
            sqv(["🖐️"], "20, 25... what's next?",
                ["20, 25, then?", "What comes after 25 counting by 5s?"],
                [sc("🖐️","30", true), sc("🖐️","26"), sc("🖐️","35")]),
            sqv(["🖐️","🖐️"], "How many fingers on TWO whole hands?",
                ["Two hands — how many fingers in all?", "5 and 5 more makes?"],
                [sc("🖐️","10", true), sc("🖐️","7"), sc("🖐️","2")]),
            sqv(["🖐️","🖐️","🖐️","🖐️"], "5, 10, 15, 20... what's next?",
                ["5, 10, 15, 20, then?", "What comes after 20 counting by 5s?"],
                [sc("🖐️","25", true), sc("🖐️","21"), sc("🖐️","30")]),
            sqv(["🖐️"], "30, 35... what's next?",
                ["30, 35, then?", "What comes after 35 counting by 5s?"],
                [sc("🖐️","40", true), sc("🖐️","36"), sc("🖐️","45")])
        ]))]
    )

    static let countBy2Lesson = StoryContent(
        id: "count-2s", title: "Count by 2s", author: "LearnTube",
        covers: "Skip counting by twos — an early counting pattern (CA CCSS K.CC.1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Count by 2s", activity: .quiz([
            sqv(["👀"], "Eyes come in 2s! Count by 2s: 2... what's next?",
                ["Count by 2s: 2, then?", "2, __? Count by twos!"],
                [sc("👀","4", true), sc("👀","3"), sc("👀","6")]),
            sqv(["👀","👀"], "2, 4... keep counting by 2s!",
                ["2, 4, then?", "What comes after 4 counting by 2s?"],
                [sc("👀","6", true), sc("👀","5"), sc("👀","8")]),
            sqv(["👀","👀","👀"], "2, 4, 6... what's next?",
                ["2, 4, 6, then?", "What comes after 6 counting by 2s?"],
                [sc("👀","8", true), sc("👀","7"), sc("👀","10")]),
            sqv(["👀"], "8, 10... what's next?",
                ["8, 10, then?", "What comes after 10 counting by 2s?"],
                [sc("👀","12", true), sc("👀","11"), sc("👀","20")]),
            sqv(["🐾","🐾"], "A cat has 2 ears. TWO cats have how many ears?",
                ["Two cats — how many ears in all?", "2 and 2 more makes?"],
                [sc("👂","4", true), sc("👂","3"), sc("👂","2")]),
            sqv(["👀","👀","👀","👀"], "2, 4, 6, 8... what's next?",
                ["2, 4, 6, 8, then?", "What comes after 8 counting by 2s?"],
                [sc("👀","10", true), sc("👀","9"), sc("👀","12")]),
            sqv(["👀"], "12, 14... what's next?",
                ["12, 14, then?", "What comes after 14 counting by 2s?"],
                [sc("👀","16", true), sc("👀","15"), sc("👀","20")])
        ]))]
    )

    static let babyNamesLesson = StoryContent(
        id: "baby-names", title: "Baby Animal Names", author: "LearnTube",
        covers: "The special names for baby animals — puppy, kitten, calf, and more (vocabulary, CA CCSS L.K.5).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Baby Animal Names", activity: .quiz([
            sqv(["🍼"], "A baby 🐕 dog is called a PUPPY! 🐶",
                ["What is a baby dog called?", "A baby 🐕 dog is a...?"],
                [sc("🐶","Puppy", true), sc("🐱","Kitten"), sc("🐮","Calf")]),
            sqv(["🍼"], "A baby 🐈 cat is called a KITTEN! 🐱",
                ["What is a baby cat called?", "A baby 🐈 cat is a...?"],
                [sc("🐱","Kitten", true), sc("🐶","Puppy"), sc("🐑","Lamb")]),
            sqv(["🍼"], "A baby 🐄 cow is called a CALF!",
                ["What is a baby cow called?", "A baby 🐄 cow is a...?"],
                [sc("🐮","Calf", true), sc("🐴","Foal"), sc("🐷","Piglet")]),
            sqv(["🍼"], "A baby 🐎 horse is called a FOAL!",
                ["What is a baby horse called?", "A baby 🐎 horse is a...?"],
                [sc("🐴","Foal", true), sc("🐮","Calf"), sc("🐶","Puppy")]),
            sqv(["🍼"], "A baby 🐑 sheep is called a LAMB!",
                ["What is a baby sheep called?", "A baby 🐑 sheep is a...?"],
                [sc("🐑","Lamb", true), sc("🐐","Kid"), sc("🐷","Piglet")]),
            sqv(["🍼"], "A baby 🐔 chicken is called a CHICK! 🐣",
                ["What is a baby chicken called?", "A baby 🐔 chicken is a...?"],
                [sc("🐣","Chick", true), sc("🐴","Foal"), sc("🐮","Calf")]),
            sqv(["🍼"], "A baby 🐸 frog is called a TADPOLE!",
                ["What is a baby frog called?", "A baby 🐸 frog is a...?"],
                [sc("🐟","Tadpole", true), sc("🐛","Caterpillar"), sc("🐣","Chick")]),
            sqv(["🍼"], "A baby 🦘 kangaroo is called a JOEY!",
                ["What is a baby kangaroo called?", "A baby 🦘 kangaroo is a...?"],
                [sc("🦘","Joey", true), sc("🐶","Puppy"), sc("🐱","Kitten")])
        ]))]
    )

    static let plantPartsLesson = StoryContent(
        id: "plant-parts", title: "Parts of a Plant", author: "LearnTube",
        covers: "The parts of a plant — roots, stem, leaves, and flower — and what each does (CA NGSS K-LS1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Parts of a Plant", activity: .quiz([
            sqv(["🪴"], "The ROOTS grow underground and drink up water. 💧",
                ["Which part drinks water underground?", "What is under the soil, drinking water?"],
                [sc("🟤","Roots", true), sc("🌸","Flower"), sc("🍃","Leaves")]),
            sqv(["🪴"], "The STEM holds the plant up tall and carries water to the top.",
                ["Which part holds the plant up?", "What carries water up the plant?"],
                [sc("🟩","Stem", true), sc("🌸","Flower"), sc("🟤","Roots")]),
            sqv(["🪴"], "The LEAVES catch sunlight ☀️ to make food for the plant.",
                ["Which part catches sunlight to make food?", "What uses the sun to make food?"],
                [sc("🍃","Leaves", true), sc("🟤","Roots"), sc("🌸","Flower")]),
            sqv(["🪴"], "The FLOWER is pretty and makes seeds for new plants. 🌱",
                ["Which part makes seeds?", "What part becomes seeds for new plants?"],
                [sc("🌸","Flower", true), sc("🟤","Roots"), sc("🟩","Stem")]),
            sqv(["🪴"], "🐝 Bees visit the FLOWER to help it make seeds.",
                ["Which part do bees visit?", "Where does a bee land on a plant?"],
                [sc("🌸","Flower", true), sc("🟤","Roots"), sc("🍃","Leaves")]),
            sqv(["🪴"], "When you water a plant, the ROOTS drink it up first.",
                ["Water goes into which part first?", "Which part takes in the water?"],
                [sc("🟤","Roots", true), sc("🌸","Flower"), sc("🍃","Leaves")]),
            sqv(["🪴"], "Leaves are usually green and flat to soak up the ☀️ sun.",
                ["Which green, flat part soaks up sun?", "What part is green and catches light?"],
                [sc("🍃","Leaves", true), sc("🟤","Roots"), sc("🟩","Stem")])
        ]))]
    )

    static let hotColdLesson = StoryContent(
        id: "hot-cold", title: "Hot or Cold?", author: "LearnTube",
        covers: "Sorting things by temperature — hot or cold — an early science idea (CA NGSS K-PS3).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Hot or Cold?", activity: .quiz([
            sqv(["🔥"], "🔥 Fire is HOT! Never touch it.",
                ["Is 🔥 fire hot or cold?", "🔥 fire is...?"],
                [sc("🥵","Hot", true), sc("🥶","Cold")]),
            sqv(["❄️"], "❄️ Snow is COLD! Brrr!",
                ["Is ❄️ snow hot or cold?", "❄️ snow is...?"],
                [sc("🥶","Cold", true), sc("🥵","Hot")]),
            sqv(["☀️"], "The ☀️ sun makes a hot, sunny day.",
                ["Is the ☀️ sun hot or cold?", "A bright sunny day is...?"],
                [sc("🥵","Hot", true), sc("🥶","Cold")]),
            sqv(["🍦"], "🍦 Ice cream is COLD and yummy!",
                ["Is 🍦 ice cream hot or cold?", "🍦 ice cream is...?"],
                [sc("🥶","Cold", true), sc("🥵","Hot")]),
            sqv(["☕"], "☕ Hot cocoa warms you up. It is HOT!",
                ["Is ☕ cocoa hot or cold?", "A cup of ☕ cocoa is...?"],
                [sc("🥵","Hot", true), sc("🥶","Cold")]),
            sqv(["🧊"], "🧊 An ice cube is COLD and frozen.",
                ["Is 🧊 ice hot or cold?", "🧊 an ice cube is...?"],
                [sc("🥶","Cold", true), sc("🥵","Hot")]),
            sqv(["🌋"], "🌋 Lava from a volcano is VERY HOT!",
                ["Is 🌋 lava hot or cold?", "🌋 volcano lava is...?"],
                [sc("🥵","Hot", true), sc("🥶","Cold")]),
            sqv(["⛄"], "⛄ A snowman is made of COLD snow.",
                ["Is a ⛄ snowman hot or cold?", "⛄ a snowman is...?"],
                [sc("🥶","Cold", true), sc("🥵","Hot")])
        ]))]
    )
}

// MARK: - Concrete number games (built in Gabriel's winning "count what you see"
// style: real objects on screen, count them, small number choices). These
// recast the abstract number work he struggles with into things he can point to.
extension Stories {
    /// Count how many — count each visible object once.
    static let countCrittersLesson = StoryContent(
        id: "count-critters", title: "Count the Critters", author: "LearnTube",
        covers: "Counting how many by counting each object once, up to 10 (CA CCSS K.CC.4-5).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Count the Critters", activity: .quiz([
            sqv(["🐱","🐱"], "Two kittens. Point to each one: 1, 2.",
                ["How many kittens? Count them!", "Count the kittens!"],
                [sc("🔢","2", true), sc("🔢","3"), sc("🔢","1")]),
            sqv(["🐶","🐶","🐶"], "Point to each puppy: 1, 2, 3.",
                ["How many puppies?", "Count the puppies!"],
                [sc("🔢","3", true), sc("🔢","2"), sc("🔢","4")]),
            sqv(["🐤","🐤","🐤","🐤"], "Count each chick: 1, 2, 3, 4.",
                ["How many chicks?", "Count them!"],
                [sc("🔢","4", true), sc("🔢","5"), sc("🔢","3")]),
            sqv(["🐟","🐟","🐟","🐟","🐟"], "Count the fish, one by one, up to 5.",
                ["How many fish?", "Count the fish!"],
                [sc("🔢","5", true), sc("🔢","4"), sc("🔢","6")]),
            sqv(["🐝","🐝","🐝","🐝","🐝","🐝"], "Count each bee: 1 all the way to 6.",
                ["How many bees?", "Count the bees!"],
                [sc("🔢","6", true), sc("🔢","7"), sc("🔢","5")]),
            sqv(["🐮","🐮","🐮","🐮","🐮","🐮","🐮"], "Count the cows, one by one, to 7.",
                ["How many cows?", "Count them all!"],
                [sc("🔢","7", true), sc("🔢","6"), sc("🔢","8")])
        ]))]
    )

    /// Adding = put two groups together and count them all.
    static let addAllLesson = StoryContent(
        id: "add-all", title: "How Many in All?", author: "LearnTube",
        covers: "Adding by putting two groups together and counting them all, within 10 (CA CCSS K.OA.1-2).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "How Many in All?", activity: .quiz([
            sqv(["🐤","🐤","➕","🐤","🐤"], "Put them together and count them ALL: 2 and 2 makes 4.",
                ["How many chicks in all?", "Count them all together!"],
                [sc("🔢","4", true), sc("🔢","3"), sc("🔢","5")]),
            sqv(["🐶","➕","🐶","🐶"], "1 dog and 2 more dogs. Count all 3.",
                ["How many dogs in all?", "Count them!"],
                [sc("🔢","3", true), sc("🔢","2"), sc("🔢","4")]),
            sqv(["🍎","🍎","🍎","➕","🍎","🍎"], "3 apples and 2 more. Count them all to 5.",
                ["How many apples in all?", "Count them all!"],
                [sc("🔢","5", true), sc("🔢","6"), sc("🔢","4")]),
            sqv(["⭐","⭐","⭐","⭐","➕","⭐"], "4 stars and 1 more makes 5.",
                ["How many stars in all?", "Count them!"],
                [sc("🔢","5", true), sc("🔢","4"), sc("🔢","6")]),
            sqv(["🌸","🌸","🌸","➕","🌸","🌸","🌸"], "3 and 3 more. Count them all to 6.",
                ["How many flowers in all?", "Count them all!"],
                [sc("🔢","6", true), sc("🔢","7"), sc("🔢","5")])
        ]))]
    )

    /// Count by 2s made concrete: pairs of shoes/socks you can see and count.
    static let countBy2ShoesLesson = StoryContent(
        id: "count-2-shoes", title: "Count by 2s", author: "LearnTube",
        covers: "Skip-counting by 2s using real pairs you can see and count (CA CCSS K.CC.1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Count by 2s", activity: .quiz([
            sqv(["👟","👟"], "One pair is 2 shoes. Count: 2.",
                ["How many shoes?", "Count them: 2!"],
                [sc("🔢","2", true), sc("🔢","1"), sc("🔢","3")]),
            sqv(["👟","👟","👟","👟"], "Two pairs. Count by 2s: 2, then 4.",
                ["How many shoes? 2, 4...", "Count the shoes!"],
                [sc("🔢","4", true), sc("🔢","3"), sc("🔢","5")]),
            sqv(["🧦","🧦","🧦","🧦","🧦","🧦"], "Three pairs of socks. Count 2, 4, 6.",
                ["How many socks? 2, 4, 6...", "Count them all!"],
                [sc("🔢","6", true), sc("🔢","5"), sc("🔢","7")]),
            sqv(["👟","👟","👟","👟","👟","👟","👟","👟"], "Four pairs. Count 2, 4, 6, 8.",
                ["How many shoes? 2, 4, 6, 8...", "Count by 2s!"],
                [sc("🔢","8", true), sc("🔢","7"), sc("🔢","10")])
        ]))]
    )

    /// Count by 5s made concrete: each hand is 5 fingers.
    static let countBy5HandsLesson = StoryContent(
        id: "count-5-hands", title: "Count by 5s", author: "LearnTube",
        covers: "Skip-counting by 5s using hands — each hand is 5 fingers (CA CCSS K.CC.1).",
        darkPages: true, pages: [],
        games: [StoryGame(skill: "Count by 5s", activity: .quiz([
            sqv(["🖐️"], "One hand has 5 fingers. Count: 5.",
                ["How many fingers on 1 hand?", "Count: 5!"],
                [sc("🔢","5", true), sc("🔢","4"), sc("🔢","10")]),
            sqv(["🖐️","🖐️"], "Two hands. Count by 5s: 5, then 10.",
                ["How many fingers? 5, 10...", "How many on 2 hands?"],
                [sc("🔢","10", true), sc("🔢","6"), sc("🔢","15")]),
            sqv(["🖐️","🖐️","🖐️"], "Three hands. Count 5, 10, 15.",
                ["5, 10, 15... how many?", "How many fingers on 3 hands?"],
                [sc("🔢","15", true), sc("🔢","11"), sc("🔢","20")]),
            sqv(["🖐️","🖐️","🖐️","🖐️"], "Four hands. Count 5, 10, 15, 20.",
                ["How many fingers on 4 hands?", "5, 10, 15, 20!"],
                [sc("🔢","20", true), sc("🔢","16"), sc("🔢","25")])
        ]))]
    )
}
