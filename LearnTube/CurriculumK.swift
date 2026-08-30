import Foundation

extension Curriculum {

    static let kindergarten: [Skill] = [

        // ---------- Story Mode ----------
        Skill(id: "K-STORY1", grade: 0, subject: .reading,
              title: "Story: The Day the Sun Slept In",
              standard: "CA CCSS RL.K.1-10",
              activity: "Read a farm story, then play games about it. Stars Bodhi and Kona the dogs!",
              parentTip: "Read it together first. This one story covers all the Kindergarten reading skills.",
              lesson: .story(id: "sun-slept-in")),

        Skill(id: "K-MATH1", grade: 0, subject: .math,
              title: "Counting Critters",
              standard: "CA CCSS K.CC.1-7",
              activity: "Count, compare, and find out how many with the Counting Critters!",
              parentTip: "Covers all the Kindergarten counting and comparing skills.",
              lesson: .story(id: "counting-critters")),

        Skill(id: "K-MATH2", grade: 0, subject: .math,
              title: "Gabriel's Family of 10",
              standard: "CA CCSS K.OA.1-5",
              activity: "Add and take away with Gabriel's 7 cats, 2 dogs, and 1 Gabriel!",
              parentTip: "Addition and subtraction to 10, built on the family of 10.",
              lesson: .story(id: "family-add")),

        Skill(id: "K-MATH3", grade: 0, subject: .math,
              title: "Sort the Farm Animals",
              standard: "CA CCSS K.MD.3",
              activity: "Sort the chickens, sheep, cats, and dogs into their groups, then count how many are in each!",
              parentTip: "Sorting into categories and counting each group. Uses our real farm: lots of chickens, just a couple of dogs.",
              lesson: .story(id: "farm-sort")),

        Skill(id: "K-MATH4", grade: 0, subject: .math,
              title: "Shape Detective",
              standard: "CA CCSS K.G.2",
              activity: "Find the circle, square, triangle, rectangle, and hexagon by name or by how many sides!",
              parentTip: "Naming and describing flat shapes. He learns each shape's name and its number of sides.",
              lesson: .story(id: "shapes")),

        Skill(id: "K-MATH5", grade: 0, subject: .math,
              title: "Shape Spotter",
              standard: "CA CCSS K.G.2",
              activity: "Find every triangle, even the small or turned ones! Spot each shape no matter its size or which way it faces.",
              parentTip: "Naming shapes regardless of size or orientation. A triangle is still a triangle when it is tiny or rotated.",
              lesson: .story(id: "shape-spot")),

        Skill(id: "K-MATH10", grade: 0, subject: .math,
              title: "Build a Shape",
              standard: "CA CCSS K.G.6",
              activity: "Put shapes together to make a picture! A triangle and a square make a house. Tap the missing shape to finish each one.",
              parentTip: "Composing simple shapes into a bigger shape. At home, build pictures from blocks or cut-paper shapes together.",
              lesson: .story(id: "build-shape")),

        Skill(id: "K-MATH11", grade: 0, subject: .math,
              title: "Where Is It?",
              standard: "CA CCSS K.G.1",
              activity: "On top, under, or next to? Tap the picture that matches the words!",
              parentTip: "Position words. Narrate them at home: the cat is ON the chair, the ball is UNDER the table.",
              lesson: .story(id: "position-words")),

        Skill(id: "K-MATH12", grade: 0, subject: .math,
              title: "How Many Legs?",
              standard: "CA CCSS K.CC.4",
              activity: "Count the animal's legs and tap the number! A bird has 2, a dog has 4.",
              parentTip: "Counting to tell how many. Count the legs on your real animals together.",
              lesson: .story(id: "animal-legs")),

        Skill(id: "K-MATH16", grade: 0, subject: .math,
              title: "Make 10",
              standard: "CA CCSS K.OA.4",
              activity: "Some animals are here. Tap how many MORE make 10!",
              parentTip: "Making ten with a missing part. Practice on fingers: 6 and 4 more make 10.",
              lesson: .story(id: "make-10")),

        Skill(id: "K-MATH17", grade: 0, subject: .math,
              title: "Take Away",
              standard: "CA CCSS K.OA.1",
              activity: "Some animals hop away. Count how many are LEFT!",
              parentTip: "Subtraction within 10 by taking away. Act it out with toys or snacks.",
              lesson: .story(id: "take-away")),

        Skill(id: "K-MATH18", grade: 0, subject: .math,
              title: "Doubles",
              standard: "CA CCSS 1.OA.6",
              activity: "Double it! 2 and 2 more makes 4. Tap the total!",
              parentTip: "Doubles facts — quick building blocks for adding. Say them like a chant.",
              lesson: .story(id: "doubles")),

        Skill(id: "K-MATH19", grade: 0, subject: .math,
              title: "First, Second, Third",
              standard: "CA CCSS K.CC.4",
              activity: "Who is first, second, third? Count from the front and tap it!",
              parentTip: "Ordinal numbers. Line up toys and name their places together.",
              lesson: .story(id: "ordinals")),

        Skill(id: "K-R11", grade: 0, subject: .reading,
              title: "Beginning Sounds",
              standard: "CA CCSS RF.K.3",
              activity: "Which animal starts with that letter? Tap the matching sound!",
              parentTip: "Letter-sound matching. Say the animal's name slowly: b-b-bear.",
              lesson: .story(id: "beginning-sounds")),

        Skill(id: "K-S14", grade: 0, subject: .science,
              title: "Growing Up",
              standard: "CA NGSS 1-LS1-1",
              activity: "Living things grow and change! Tap what comes next.",
              parentTip: "Life cycles. Talk about how your animals grow from babies.",
              lesson: .story(id: "life-cycle")),

        Skill(id: "K-MATH20", grade: 0, subject: .math,
              title: "Count by 10s",
              standard: "CA CCSS K.CC.1",
              activity: "Ten, twenty, thirty... tap what comes next when you count by tens!",
              parentTip: "Skip counting by tens. Count in groups of ten together.",
              lesson: .story(id: "count-tens")),

        Skill(id: "K-S15", grade: 0, subject: .science,
              title: "Fast or Slow",
              standard: "CA NGSS K-PS2-1",
              activity: "Is the animal fast or slow? Tap to sort it!",
              parentTip: "Comparing how things move. Talk about fast and slow animals you know.",
              lesson: .story(id: "fast-slow")),

        Skill(id: "K-S16", grade: 0, subject: .science,
              title: "Sink or Float",
              standard: "CA NGSS 2-PS1-1",
              activity: "Will it sink or float? Tap your guess!",
              parentTip: "Predicting sink or float. Try it in the bath or a bowl of water together.",
              lesson: .story(id: "sink-float")),

        Skill(id: "K-R12", grade: 0, subject: .reading,
              title: "Big & Little Letters",
              standard: "CA CCSS RF.K.1d",
              activity: "Find the little letter that matches the big one!",
              parentTip: "Matching uppercase and lowercase. Point them out on signs and books.",
              lesson: .story(id: "letter-case")),

        Skill(id: "K-S17", grade: 0, subject: .science,
              title: "Five Senses",
              standard: "CA NGSS K-LS1",
              activity: "See, hear, smell, taste, touch — tap the part you use!",
              parentTip: "The five senses. Name which sense you're using during the day.",
              lesson: .story(id: "five-senses")),

        Skill(id: "K-R13", grade: 0, subject: .reading,
              title: "Opposites",
              standard: "CA CCSS L.K.5b",
              activity: "What's the opposite? Big and little, hot and cold!",
              parentTip: "Opposite words. Play an opposites game while you walk or cook.",
              lesson: .story(id: "opposites")),

        Skill(id: "K-S6", grade: 0, subject: .science,
              title: "Animal Homes",
              standard: "CA NGSS K-ESS3-1",
              activity: "Where does each animal live? Farm, ocean, cold places, or jungle. Tap the one that fits!",
              parentTip: "Animals and where they live. Talk about where your farm animals live vs. ocean or jungle animals.",
              lesson: .story(id: "animal-homes")),

        Skill(id: "K-S7", grade: 0, subject: .science,
              title: "Fur, Feathers, Scales",
              standard: "CA NGSS 1-LS1-1",
              activity: "Is it covered in fur, feathers, or scales? Tap the animal that matches!",
              parentTip: "Animal body coverings. Feel your animals' fur and feathers together.",
              lesson: .story(id: "animal-coverings")),

        Skill(id: "K-S8", grade: 0, subject: .science,
              title: "What Do Animals Eat?",
              standard: "CA NGSS K-LS1",
              activity: "Every animal eats! Tap the food each animal likes to eat.",
              parentTip: "What animals need to live. Talk about what you feed your animals each day.",
              lesson: .story(id: "animal-eats")),

        Skill(id: "K-R14", grade: 0, subject: .reading,
              title: "Syllable Safari",
              standard: "CA CCSS RF.K.2",
              activity: "Clap out each animal's name and count the beats. Tap how many claps!",
              parentTip: "Breaking words into syllables. Clap names together — RAB-BIT, EL-E-PHANT.",
              lesson: .story(id: "syllables")),

        Skill(id: "K-S18", grade: 0, subject: .science,
              title: "Animal Groups",
              standard: "CA NGSS K-LS1",
              activity: "Mammal, bird, fish, reptile, or bug? Tap the group each animal belongs to!",
              parentTip: "Sorting animals into groups by their traits (fur, feathers, scales, fins, six legs).",
              lesson: .story(id: "animal-groups")),

        Skill(id: "K-S19", grade: 0, subject: .science,
              title: "Animal Sounds",
              standard: "CA NGSS K-LS1",
              activity: "Moo, woof, quack! Tap the sound each animal makes.",
              parentTip: "Animal sounds. Make the sounds together and guess the animal.",
              lesson: .story(id: "animal-sounds")),

        Skill(id: "K-S20", grade: 0, subject: .science,
              title: "Four Seasons",
              standard: "CA NGSS K-ESS2-1",
              activity: "Spring, summer, fall, or winter? Tap the season that matches the picture.",
              parentTip: "The four seasons and their weather. Talk about what changes each season.",
              lesson: .story(id: "seasons")),

        Skill(id: "K-S21", grade: 0, subject: .science,
              title: "Swim, Fly, or Walk?",
              standard: "CA NGSS K-LS1",
              activity: "Does the animal swim, fly, or walk? Tap how each one gets around!",
              parentTip: "How animals move. Point out swimmers, fliers, and walkers when you're outside.",
              lesson: .story(id: "move-how")),

        Skill(id: "K-MATH21", grade: 0, subject: .math,
              title: "Count by 5s",
              standard: "CA CCSS K.CC.1",
              activity: "Count by fives! 5, 10, 15... Tap the number that comes next.",
              parentTip: "Skip counting by 5s. Count hands and fingers together — 5, 10, 15.",
              lesson: .story(id: "count-5s")),

        Skill(id: "K-MATH22", grade: 0, subject: .math,
              title: "Count by 2s",
              standard: "CA CCSS K.CC.1",
              activity: "Count by twos! 2, 4, 6... Tap the number that comes next.",
              parentTip: "Skip counting by 2s. Count pairs — eyes, ears, socks — 2, 4, 6.",
              lesson: .story(id: "count-2s")),

        Skill(id: "K-R15", grade: 0, subject: .reading,
              title: "Baby Animal Names",
              standard: "CA CCSS L.K.5",
              activity: "A baby dog is a puppy! Tap the special name for each baby animal.",
              parentTip: "Animal vocabulary. Quiz each other on baby animal names.",
              lesson: .story(id: "baby-names")),

        Skill(id: "K-S22", grade: 0, subject: .science,
              title: "Parts of a Plant",
              standard: "CA NGSS K-LS1",
              activity: "Roots, stem, leaves, or flower? Tap the part that does each job!",
              parentTip: "Parts of a plant and their jobs. Look at a real plant together.",
              lesson: .story(id: "plant-parts")),

        Skill(id: "K-S23", grade: 0, subject: .science,
              title: "Hot or Cold?",
              standard: "CA NGSS K-PS3",
              activity: "Fire, ice, sun, snow — tap whether each thing is hot or cold!",
              parentTip: "Temperature — hot vs cold. Point out hot and cold things at home.",
              lesson: .story(id: "hot-cold")),

        Skill(id: "K-MATH13", grade: 0, subject: .math,
              title: "Teen Numbers",
              standard: "CA CCSS K.NBT.1",
              activity: "A teen number is ten and some more! Count the ten plus the extras and tap the number.",
              parentTip: "Teen numbers as ten and ones. Build 10 with objects, then add a few more.",
              lesson: .story(id: "teen-numbers")),

        Skill(id: "K-S9", grade: 0, subject: .science,
              title: "Baby Animals",
              standard: "CA NGSS 1-LS3-1",
              activity: "Baby animals look like their parents! Find each animal's baby.",
              parentTip: "Young animals resemble their parents. Look at baby and grown animals together.",
              lesson: .story(id: "baby-animals")),

        Skill(id: "K-S10", grade: 0, subject: .science,
              title: "Alive or Not?",
              standard: "CA NGSS K-LS1",
              activity: "Living things grow, eat, and move! Tap what's alive and what's not.",
              parentTip: "Characteristics of living things. Point out what's alive vs. an object on a walk.",
              lesson: .story(id: "living-not")),

        Skill(id: "K-S11", grade: 0, subject: .science,
              title: "Day or Night?",
              standard: "CA NGSS K-ESS1",
              activity: "Owls and bats wake at night, bees buzz in the day. Tap when each animal is awake!",
              parentTip: "Day and night patterns in animal behavior. Talk about which animals you see when.",
              lesson: .story(id: "day-night")),

        Skill(id: "K-MATH14", grade: 0, subject: .math,
              title: "Make 5",
              standard: "CA CCSS K.OA.4",
              activity: "Some animals are here! Tap how many more make 5.",
              parentTip: "Making 5 from two parts. Use fingers or beans to show 3 and 2 make 5.",
              lesson: .story(id: "make-5")),

        Skill(id: "K-MATH15", grade: 0, subject: .math,
              title: "Which Has More?",
              standard: "CA CCSS K.CC.6",
              activity: "Two groups of animals! Tap the group with more, or with fewer.",
              parentTip: "Comparing groups. Line up two sets of objects and compare which has more.",
              lesson: .story(id: "which-more")),

        Skill(id: "K-S12", grade: 0, subject: .science,
              title: "Egg or Not?",
              standard: "CA NGSS K-LS1",
              activity: "Which animals hatch from eggs? Tap the egg-layers and the ones born live.",
              parentTip: "How animals have young. Hens lay eggs; puppies are born live.",
              lesson: .story(id: "egg-or-not")),

        Skill(id: "K-S13", grade: 0, subject: .science,
              title: "Wild or Pet?",
              standard: "CA NGSS K-LS1",
              activity: "Pets live with us, wild animals live on their own. Tap which is which!",
              parentTip: "Classifying animals. Talk about your pets vs. animals at the zoo.",
              lesson: .story(id: "wild-or-pet")),

        Skill(id: "K-MATH9", grade: 0, subject: .math,
              title: "Bigger or Smaller?",
              standard: "CA CCSS K.MD.2",
              activity: "Compare two things! Which is bigger, taller, or heavier? Which is smaller, shorter, or lighter?",
              parentTip: "Comparing size, height, and weight. Compare real objects around the house together.",
              lesson: .story(id: "bigger-smaller")),

        Skill(id: "K-MATH7", grade: 0, subject: .math,
              title: "What Comes Next?",
              standard: "CA CCSS K (Patterns)",
              activity: "Look at the color pattern and tap what comes next! Red, blue, red, blue...",
              parentTip: "Recognizing and extending patterns. Try clap-stomp body patterns together too.",
              lesson: .story(id: "patterns")),

        Skill(id: "K-MATH8", grade: 0, subject: .math,
              title: "Flat or Solid?",
              standard: "CA CCSS K.G.3",
              activity: "Some shapes are flat like a circle, some are solid like a ball. Tell which is which!",
              parentTip: "Flat (2D) vs solid (3D) shapes. Hold a ball, a box, and a can while you play.",
              lesson: .story(id: "flat-or-solid")),

        Skill(id: "K-S5", grade: 0, subject: .science,
              title: "Plant or Animal?",
              standard: "CA NGSS K-LS1",
              activity: "Sort living things! Which is a plant, which is an animal, which can fly, which lives in water?",
              parentTip: "Sorting plants and animals by observable characteristics. Spot living things together on a walk.",
              lesson: .story(id: "plant-or-animal")),

        Skill(id: "K-R10", grade: 0, subject: .reading,
              title: "Rhyme Time",
              standard: "CA CCSS RF.K.2a",
              activity: "Find the word that rhymes! Cat and hat, dog and frog. Say them out loud!",
              parentTip: "Rhyming is a key reading sound skill. Say the words aloud together to hear the rhyme.",
              lesson: .story(id: "rhyme-time")),

        Skill(id: "K-MATH6", grade: 0, subject: .math,
              title: "Number Detective",
              standard: "CA CCSS K.CC.4",
              activity: "Count the dots and find the number, or read the number and find the group that shows it!",
              parentTip: "Connecting numbers to how many. He counts a group and matches it to the numeral, both directions.",
              lesson: .story(id: "number-detective")),

        // ---------- Reading ----------
        Skill(id: "K-R1", grade: 0, subject: .reading,
              title: "Capital Letter Detective",
              standard: "CA CCSS RF.K.1d",
              activity: "Capital letters are the big ones. Spot the capitals hiding in each row!",
              parentTip: "Big letters start sentences and names. Let him say each one aloud.",
              lesson: .quiz([
                Question("Tap the CAPITAL (big) letter.", correct: "B", wrong: ["b", "d"]),
                Question("Which one is uppercase?", correct: "G", wrong: ["g", "q"]),
                Question("Find the big letter.", correct: "R", wrong: ["r", "n"])
              ])),

        Skill(id: "K-R2", grade: 0, subject: .reading,
              title: "Match the Letter Buddies",
              standard: "CA CCSS RF.K.1d",
              activity: "Every big letter has a little buddy. Tap a letter, then tap its partner!",
              parentTip: "Matching big to small builds letter recognition both ways.",
              lesson: .match(prompt: "Match the big letter to its little buddy.",
                             pairs: [.init("A", "a"), .init("B", "b"),
                                     .init("C", "c"), .init("D", "d")])),

        Skill(id: "K-R3", grade: 0, subject: .reading,
              title: "Letter Sounds Safari",
              standard: "CA CCSS RF.K.3a",
              activity: "Letters make sounds. Hunt for the word that starts with the same sound!",
              parentTip: "Say the sound, not the letter name: /k/, not 'see'.",
              lesson: .quiz([
                Question("Same first sound as CAT  /k/", correct: "Cow", wrong: ["Dog", "Pig"]),
                Question("Same first sound as SUN  /s/", correct: "Sock", wrong: ["Hat", "Map"]),
                Question("Same first sound as HEN  /h/", correct: "Hat", wrong: ["Pig", "Net"])
              ])),

        Skill(id: "K-R4", grade: 0, subject: .reading,
              title: "Barnyard Rhyme Time",
              standard: "CA CCSS RF.K.2a",
              activity: "Rhyming words sound alike at the end. Tap the one that rhymes!",
              parentTip: "Say the words out loud together so he hears the rhyme.",
              lesson: .quiz([
                Question("Rhymes with HEN", correct: "pen", wrong: ["dog", "cup"]),
                Question("Rhymes with CAT", correct: "hat", wrong: ["sun", "pig"]),
                Question("Rhymes with PIG", correct: "wig", wrong: ["cow", "hen"])
              ])),

        Skill(id: "K-R5", grade: 0, subject: .reading,
              title: "Sound It Out",
              standard: "CA CCSS RF.K.2c",
              activity: "Stretch the sounds, then snap them together into a word!",
              parentTip: "Robot-talk the sounds slowly, then blend fast.",
              lesson: .quiz([
                // Answer is a PICTURE, never the word — he blends the sounds
                // into a word and taps what it means, instead of matching letters.
                Question("Blend it:  c - a - t", correct: "🐱", wrong: ["🐶", "🐟"]),
                Question("Blend it:  d - o - g", correct: "🐶", wrong: ["🐱", "🐷"]),
                Question("Blend it:  p - i - g", correct: "🐷", wrong: ["🐔", "🐝"])
              ])),

        Skill(id: "K-R6", grade: 0, subject: .reading,
              title: "Star Words",
              standard: "CA CCSS RF.K.3c",
              activity: "Read the little sentence and pick the star word that fits!",
              parentTip: "Star words (see, go, is, like, and…) show up in every sentence. He reads the whole sentence and picks the word that makes sense — reading, not just matching. Read it aloud together with each choice if he's stuck.",
              // Reading-in-context, NOT shape-matching. The star word is the blank,
              // so he can't tap a look-alike — he has to read the sentence to know
              // which word fits. A picture anchors the meaning. Two choices, and
              // QuizPlayer reveals the answer in green after two misses.
              lesson: .quiz([
                Question("I ___ the 🐶.", correct: "see", wrong: ["go"]),
                Question("We ___ to the 🚜.", correct: "go", wrong: ["is"]),
                Question("The 🐔 ___ here.", correct: "is", wrong: ["and"]),
                Question("I ___ my 🐰.", correct: "like", wrong: ["to"]),
                Question("The 🐷 ___ the 🐮 play.", correct: "and", wrong: ["is"]),
                Question("This snack is ___ me.", correct: "for", wrong: ["up"])
              ])),

        Skill(id: "K-R7", grade: 0, subject: .reading,
              title: "What Happens First?",
              standard: "CA CCSS RL.K.2",
              activity: "Stories happen in order. Put the day in the right order!",
              parentTip: "Sequencing a familiar routine builds story retelling.",
              lesson: .order(prompt: "Put the day in order, first to last.",
                             items: ["Wake up", "Eat breakfast", "Play outside", "Go to bed"])),

        Skill(id: "K-R8", grade: 0, subject: .reading,
              title: "How Books Work",
              standard: "CA CCSS RF.K.1a",
              activity: "Books have a secret map. Show that you know which way the words go!",
              parentTip: "These print rules make reading click.",
              lesson: .quiz([
                Question("Where do we start reading?", correct: "Top left", wrong: ["Bottom right", "The middle"]),
                Question("Which way do the words go?", correct: "Left to right", wrong: ["Right to left", "Up and down"]),
                Question("When a line ends, go to the...", correct: "Next line down", wrong: ["Back of the book", "Same line again"])
              ])),

        Skill(id: "K-R9", grade: 0, subject: .reading,
              title: "Letter Detective",
              standard: "CA CCSS RF.K.1d / RF.K.3a",
              activity: "Find letters by their name or the sound they make. Big and little letters with a sound and a word for each!",
              parentTip: "Letter recognition and letter sounds. Say the sound, not the name: /b/, not 'bee'.",
              lesson: .story(id: "letter-detective")),

        // ---------- Writing (hands-on) ----------
        Skill(id: "K-W1", grade: 0, subject: .writing,
              title: "Write Your Name",
              standard: "CA CCSS L.K.1a",
              activity: "Trace each letter of your name with your finger!",
              parentTip: "Tracing the letters of his name with a finger is real early handwriting.",
              lesson: .trace(prompt: "Trace your name!",
                             items: ["G", "A", "B", "R", "I", "E", "L"])),

        Skill(id: "K-W2", grade: 0, subject: .writing,
              title: "Trace Capital Letters",
              standard: "CA CCSS L.K.1a",
              activity: "Trace each big capital letter with your finger!",
              parentTip: "Forming capital letters by tracing builds handwriting control.",
              lesson: .trace(prompt: "Trace the letters!",
                             items: ["A", "B", "C", "D", "E", "F"])),

        Skill(id: "K-W3", grade: 0, subject: .writing,
              title: "Label the Animal",
              standard: "CA CCSS W.K.2",
              activity: "Labeling is writing the first letter. Trace the starting letter of each animal!",
              parentTip: "Hearing the first sound and writing its letter is early labeling/writing.",
              lesson: .trace(prompt: "Trace the first letter!",
                             items: ["C", "P", "H", "D", "S"])),

        // ---------- Math ----------
        // Concrete "count what you see" number games — built in Gabriel's
        // winning style to attack the number gaps his miss data revealed.
        Skill(id: "K-NUM1", grade: 0, subject: .math,
              title: "Count the Critters",
              standard: "CA CCSS K.CC.4",
              activity: "Count the animals, then type how many!",
              parentTip: "He has to actually count and type the number — no guessing from choices.",
              lesson: .numberPad([
                NumberProblem("How many kittens?", 2, visual: ["🐱","🐱"]),
                NumberProblem("How many puppies?", 3, visual: ["🐶","🐶","🐶"]),
                NumberProblem("How many chicks?", 4, visual: ["🐤","🐤","🐤","🐤"]),
                NumberProblem("How many fish?", 5, visual: ["🐟","🐟","🐟","🐟","🐟"]),
                NumberProblem("How many bees?", 6, visual: ["🐝","🐝","🐝","🐝","🐝","🐝"]),
                NumberProblem("How many cows?", 7, visual: ["🐮","🐮","🐮","🐮","🐮","🐮","🐮"])
              ])),

        Skill(id: "K-NUM2", grade: 0, subject: .math,
              title: "How Many in All?",
              standard: "CA CCSS K.OA.1",
              activity: "Put both groups together, count them ALL, and type it!",
              parentTip: "Adding as 'put together and count all,' then producing the number.",
              lesson: .numberPad([
                NumberProblem("How many chicks in all?", 4, visual: ["🐤","🐤","➕","🐤","🐤"]),
                NumberProblem("How many dogs in all?", 3, visual: ["🐶","➕","🐶","🐶"]),
                NumberProblem("How many apples in all?", 5, visual: ["🍎","🍎","🍎","➕","🍎","🍎"]),
                NumberProblem("How many stars in all?", 5, visual: ["⭐","⭐","⭐","⭐","➕","⭐"]),
                NumberProblem("How many flowers in all?", 6, visual: ["🌸","🌸","🌸","➕","🌸","🌸","🌸"])
              ])),

        Skill(id: "K-NUM3", grade: 0, subject: .math,
              title: "Count by 2s",
              standard: "CA CCSS K.CC.1",
              activity: "Count the pairs 2 at a time, then type how many!",
              parentTip: "Real pairs make the 'skip' visible; typing the total can't be guessed.",
              lesson: .numberPad([
                NumberProblem("One pair of shoes. How many? 2!", 2, visual: ["👟","👟"]),
                NumberProblem("How many shoes? Count by 2s.", 4, visual: ["👟","👟","👟","👟"]),
                NumberProblem("How many socks? 2, 4, 6...", 6, visual: ["🧦","🧦","🧦","🧦","🧦","🧦"]),
                NumberProblem("How many shoes? 2, 4, 6, 8...", 8, visual: ["👟","👟","👟","👟","👟","👟","👟","👟"])
              ])),

        Skill(id: "K-NUM4", grade: 0, subject: .math,
              title: "Count by 5s",
              standard: "CA CCSS K.CC.1",
              activity: "Each hand is 5 fingers. Count by 5s and type it!",
              parentTip: "Hands give him a built-in group of 5; he skip-counts and types the total.",
              lesson: .numberPad([
                NumberProblem("How many fingers? Count by 5s.", 10, visual: ["🖐️","🖐️"]),
                NumberProblem("How many fingers? 5, 10, 15...", 15, visual: ["🖐️","🖐️","🖐️"]),
                NumberProblem("How many fingers? 5, 10, 15, 20...", 20, visual: ["🖐️","🖐️","🖐️","🖐️"])
              ])),

        Skill(id: "K-M1", grade: 0, subject: .math,
              title: "Count to 20",
              standard: "CA CCSS K.CC.1",
              activity: "Tap each animal and count out loud all the way to 20!",
              parentTip: "Counting things he can see keeps it concrete.",
              lesson: .count(target: 20, symbol: "pawprint.fill",
                             prompt: "Tap each paw and count to 20!")),

        Skill(id: "K-M2", grade: 0, subject: .math,
              title: "Count by Tens",
              standard: "CA CCSS K.CC.1",
              activity: "Big numbers zoom by tens. Put them in order!",
              parentTip: "Clap on each ten to add rhythm.",
              lesson: .order(prompt: "Tap the tens in order.",
                             items: ["10", "20", "30", "40", "50", "60", "70", "80", "90", "100"])),

        Skill(id: "K-M3", grade: 0, subject: .math,
              title: "Count the Eggs",
              standard: "CA CCSS K.CC.4",
              activity: "Touch one egg for each number. Count carefully to 10!",
              parentTip: "One tap per number builds one-to-one counting.",
              lesson: .count(target: 10, symbol: "circle.fill",
                             prompt: "Tap each egg as you count to 10!")),

        Skill(id: "K-M4", grade: 0, subject: .math,
              title: "Number Order 0-10",
              standard: "CA CCSS K.CC.3",
              activity: "Numbers have an order too. Line them up from 0 to 10!",
              parentTip: "Recognizing order supports writing the numbers.",
              lesson: .order(prompt: "Tap the numbers in order.",
                             items: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"])),

        Skill(id: "K-M5", grade: 0, subject: .math,
              title: "More or Less",
              standard: "CA CCSS K.CC.4-6",
              activity: "What comes next when we count? Which number is more or less? Tap it!",
              parentTip: "Connect to snacks: 'who has more?' and count up together.",
              lesson: .story(id: "number-order")),

        Skill(id: "K-M6", grade: 0, subject: .math,
              title: "Adding On",
              standard: "CA CCSS K.OA.1",
              activity: "Put groups together to make more. Solve each one!",
              parentTip: "Let him use fingers or beans to check.",
              lesson: .numberPad([
                NumberProblem("3 eggs + 2 eggs = ?", 5),
                NumberProblem("4 + 1 = ?", 5),
                NumberProblem("2 + 2 = ?", 4)
              ])),

        Skill(id: "K-M7", grade: 0, subject: .math,
              title: "Taking Away",
              standard: "CA CCSS K.OA.1",
              activity: "Some go away, and you find what's left. Solve each one!",
              parentTip: "Act it out with carrots and a hungry bunny.",
              lesson: .numberPad([
                NumberProblem("5 carrots - 2 = ?", 3),
                NumberProblem("4 - 1 = ?", 3),
                NumberProblem("5 - 5 = ?", 0)
              ])),

        Skill(id: "K-M8", grade: 0, subject: .math,
              title: "2D Shape Hunt",
              standard: "CA CCSS K.G.2",
              activity: "Flat shapes have names. Tap the right one!",
              parentTip: "Spot these shapes together on a walk.",
              lesson: .quiz([
                Question("Round, with no corners", correct: "Circle", wrong: ["Square", "Triangle"]),
                Question("Has 3 sides", correct: "Triangle", wrong: ["Circle", "Square"]),
                Question("Has 4 equal sides", correct: "Square", wrong: ["Triangle", "Rectangle"])
              ])),

        Skill(id: "K-M9", grade: 0, subject: .math,
              title: "Solid Shapes",
              standard: "CA CCSS K.G.2",
              activity: "Some shapes you can hold. Match the object to its shape!",
              parentTip: "Hold a ball, a box, and a can while you play.",
              lesson: .quiz([
                Question("A ball is shaped like a...", correct: "Sphere", wrong: ["Cube", "Cylinder"]),
                Question("A box is shaped like a...", correct: "Cube", wrong: ["Sphere", "Cone"]),
                Question("A can is shaped like a...", correct: "Cylinder", wrong: ["Cube", "Sphere"])
              ])),

        Skill(id: "K-M10", grade: 0, subject: .math,
              title: "Which One Is Different?",
              standard: "CA CCSS K.MD.3",
              activity: "Sorting means things that belong together. Tap the odd one out!",
              parentTip: "Ask him to explain why it doesn't belong.",
              lesson: .quiz([
                Question("Which is NOT an animal?", correct: "Apple", wrong: ["Cow", "Hen"]),
                Question("Which is NOT a color?", correct: "Dog", wrong: ["Red", "Green"]),
                Question("Which is NOT a shape?", correct: "Banana", wrong: ["Circle", "Square"])
              ])),

        Skill(id: "K-M11", grade: 0, subject: .math,
              title: "What Comes Next?",
              standard: "CA CCSS K (Patterns)",
              activity: "Patterns repeat. Find what comes next in the pattern!",
              parentTip: "Try clap-stomp body patterns too.",
              lesson: .quiz([
                Question("red, blue, red, blue, ___", correct: "red", wrong: ["blue", "green"]),
                Question("sun, moon, sun, moon, ___", correct: "sun", wrong: ["moon", "star"]),
                Question("A, B, A, B, ___", correct: "A", wrong: ["B", "C"])
              ])),

        // ---------- Science ----------
        Skill(id: "K-S1", grade: 0, subject: .science,
              title: "Weather Watcher",
              standard: "CA NGSS K-ESS2-1",
              activity: "Be the weather reporter. Match the weather to what you'd do!",
              parentTip: "Look out the window together first.",
              lesson: .quiz([
                Question("If it's raining, wear a...", correct: "Raincoat", wrong: ["Swimsuit", "Sunglasses only"]),
                Question("Hot sunny day, wear a...", correct: "Sun hat", wrong: ["Heavy coat", "Mittens"]),
                Question("Snow means it is...", correct: "Cold", wrong: ["Hot", "Warm"])
              ])),

        Skill(id: "K-S2", grade: 0, subject: .science,
              title: "What They Need",
              standard: "CA NGSS K-LS1-1",
              activity: "Plants and animals need food, water, and sunlight. Tap what each one needs!",
              parentTip: "Walk to your plants and animals and talk about what they need.",
              lesson: .story(id: "living-needs")),

        Skill(id: "K-S3", grade: 0, subject: .science,
              title: "Push or Pull?",
              standard: "CA NGSS K-PS2-1",
              activity: "Things move when we push or pull. Tap how each one moves!",
              parentTip: "Try it together with a cart, a door, and a wagon afterward.",
              lesson: .story(id: "push-pull")),

        Skill(id: "K-S4", grade: 0, subject: .science,
              title: "Weather Detective",
              standard: "CA NGSS K-ESS2-1",
              activity: "Look at the weather and name it: sunny, rainy, cloudy, snowy, windy, or stormy. Find it by name or by what it does!",
              parentTip: "Observing and describing weather. Look out the window together and name today's weather.",
              lesson: .story(id: "weather-watch")),

        // ---------- Social Studies ----------
        Skill(id: "K-SS1", grade: 0, subject: .life,
              title: "American Symbols",
              standard: "CA HSS K.2",
              activity: "Find the U.S. flag, the Statue of Liberty, the bald eagle, and more! Learn what each one means.",
              parentTip: "Identifying national symbols. Point them out on money, at school, and around town.",
              lesson: .story(id: "american-symbols")),

        Skill(id: "K-SS2", grade: 0, subject: .life,
              title: "Community Helpers",
              standard: "CA HSS K.3",
              activity: "Who puts out fires? Who helps you learn? Find the community helpers and what they do!",
              parentTip: "Identifying helpers in school and the community. Talk about helpers you meet in daily life.",
              lesson: .story(id: "community-helpers")),

        Skill(id: "K-SS3", grade: 0, subject: .life,
              title: "Holidays",
              standard: "CA HSS K.1",
              activity: "What does Thanksgiving celebrate? What about MLK Day? Match each holiday to what it means!",
              parentTip: "Knowing what major holidays celebrate. Connect each to your own family traditions.",
              lesson: .story(id: "holidays")),

        Skill(id: "K-SS4", grade: 0, subject: .life,
              title: "My Family",
              standard: "CA HSS K.3",
              activity: "Meet your family and what everyone does at home! Two moms, Mommy and Maddy, plus all the cats and dogs.",
              parentTip: "Naming family members and their roles. Families come in all kinds; this one celebrates yours.",
              lesson: .story(id: "my-family")),

        // ---------- Life Skills ----------
        Skill(id: "K-L1", grade: 0, subject: .life,
              title: "Name Your Feelings",
              standard: "CA SEL",
              activity: "Drag each face to the feeling it shows. A new mix of feelings every time!",
              parentTip: "No pressure to feel any of these, just to name them. Talk about times he's felt each one.",
              lesson: .faceMatch(exprs: FaceExpr.allCases, perRound: 3)),

        Skill(id: "K-L2", grade: 0, subject: .life,
              title: "Days of the Week",
              standard: "CA SEL / Calendar",
              activity: "The week repeats in order. Put the days in order!",
              parentTip: "A days-of-the-week song helps the order stick.",
              lesson: .order(prompt: "Tap the days in order.",
                             items: ["Sunday", "Monday", "Tuesday", "Wednesday",
                                     "Thursday", "Friday", "Saturday"])),

        Skill(id: "K-L3", grade: 0, subject: .life,
              title: "Be a Helper",
              standard: "CA SEL / Self-help",
              activity: "Good helpers make the farm run. Tap the helpful choice!",
              parentTip: "Talk about real jobs he could pick afterward, his choice.",
              lesson: .quiz([
                Question("A good helper job is...", correct: "Feeding the animals", wrong: ["Breaking toys", "Hiding shoes"]),
                Question("If you spill something, you...", correct: "Help clean it up", wrong: ["Run away", "Blame the dog"]),
                Question("A kind helper word is...", correct: "Please", wrong: ["No way", "Mine"])
              ]))
    ]
}
