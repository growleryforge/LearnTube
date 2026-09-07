import SwiftUI

// MARK: - The Farm Writing Club
//
// Finger tracing is the one thing that has visibly moved Gabriel's writing:
// Doosy traced the first letter for him, he worked out the rest, plowed through
// every tracing game in the app, and then wrote on the whiteboard. So this is a
// full ladder of it, every rung an animal:
//
//   1. pre-writing strokes  (top-to-bottom, left-to-right, circle, cross,
//      diagonals, then waves, zigzags, loops, spirals for fluency: the motor
//      patterns every letter is built from, in the order OTs teach them)
//   2. lowercase letters by stroke family, each starting an animal's name
//   3. capital letters that start animals he cares about
//   4. whole animal names, letter by letter
//   5. numbers, each one counting a group of animals
//
// Titles read like episodes, not worksheets. The standard lives on the skill.

extension Curriculum {

    static let writingClub: [Skill] = [

        // ================= 1. Pre-writing strokes =================
        Skill(id: "TW-S1", grade: 0, subject: .writing,
              title: "Giraffe Neck Slide",
              standard: "Pre-writing · vertical stroke (CA PLF)",
              activity: "Slide your finger down the giraffe's neck to the leaf. Top to bottom!",
              parentTip: "The top-to-bottom line is the first handwriting stroke. Starting at the top matters more than being straight.",
              lesson: .traceScene(prompt: "Top to bottom!", steps: [
                TraceStep("Slide down the giraffe's neck to the leaf!", .down, from: "🦒", to: "🍃"),
                TraceStep("The monkey drops down to the banana!", .down, from: "🐒", to: "🍌"),
                TraceStep("The spider lowers down to her web!", .down, from: "🕷️", to: "🕸️"),
                TraceStep("The squirrel climbs down to the acorn!", .down, from: "🐿️", to: "🌰")
              ])),

        Skill(id: "TW-S2", grade: 0, subject: .writing,
              title: "Worm Walk",
              standard: "Pre-writing · horizontal stroke (CA PLF)",
              activity: "Walk the worm across to the apple. Left to right, like reading!",
              parentTip: "Left-to-right lines are the second stroke, and the direction we read and write in.",
              lesson: .traceScene(prompt: "Left to right!", steps: [
                TraceStep("Walk the worm to the apple!", .across, from: "🐛", to: "🍎"),
                TraceStep("The turtle plods over to the lettuce!", .across, from: "🐢", to: "🥬"),
                TraceStep("March the ant to the cookie!", .across, from: "🐜", to: "🍪"),
                TraceStep("The snail slides to the strawberry!", .across, from: "🐌", to: "🍓")
              ])),

        Skill(id: "TW-S3", grade: 0, subject: .writing,
              title: "Round the Nest",
              standard: "Pre-writing · circle (CA PLF)",
              activity: "Walk the hen all the way around her nest. Start at the top and go left!",
              parentTip: "Starting a circle at the top and going left (counter-clockwise) is exactly how c, o, a, d and g begin.",
              lesson: .traceScene(prompt: "Round and round!", steps: [
                TraceStep("Walk the hen around her nest to the egg!", .circle, from: "🐔", to: "🥚"),
                TraceStep("The bee circles the flower!", .circle, from: "🐝", to: "🌻"),
                TraceStep("The puppy chases his tail all the way round!", .circle, from: "🐶", to: "🦴"),
                TraceStep("The kitten rolls the yarn in a circle!", .circle, from: "🐱", to: "🧶")
              ])),

        Skill(id: "TW-S4", grade: 0, subject: .writing,
              title: "Duck Pond Wave",
              standard: "Pre-writing · curves (CA PLF)",
              activity: "Help the duck swim the waves across the pond!",
              parentTip: "Smooth up-and-down curves are the motion inside m, n, u and w. Slow and wavy beats fast and wobbly.",
              lesson: .traceScene(prompt: "Ride the waves!", steps: [
                TraceStep("Help the duck swim the waves to the lily pad!", .wave, from: "🦆", to: "🪷"),
                TraceStep("The fish wiggles over to the coral!", .wave, from: "🐟", to: "🪸"),
                TraceStep("The frog bobs across to the log!", .wave, from: "🐸", to: "🪵"),
                TraceStep("The dolphin surfs to the island!", .wave, from: "🐬", to: "🏝️")
              ])),

        Skill(id: "TW-S5", grade: 0, subject: .writing,
              title: "Fence Hop",
              standard: "Pre-writing · diagonals (CA PLF)",
              activity: "The goat hops over every fence post to reach the hay!",
              parentTip: "Sharp up-and-down diagonals build v, w, z and the sides of A and M. Points, not curves.",
              lesson: .traceScene(prompt: "Hop the fence!", steps: [
                TraceStep("The goat hops the fence posts to the hay!", .zigzag, from: "🐐", to: "🌾"),
                TraceStep("The bunny zigzags to the carrot!", .zigzag, from: "🐰", to: "🥕"),
                TraceStep("The kangaroo bounds over to the cactus!", .zigzag, from: "🦘", to: "🌵"),
                TraceStep("The horse jumps the fences to the finish!", .zigzag, from: "🐎", to: "🏁")
              ])),

        Skill(id: "TW-S6", grade: 0, subject: .writing,
              title: "Over the Barn",
              standard: "Pre-writing · arc (CA PLF)",
              activity: "The bird flies up and over the barn in one big hump!",
              parentTip: "One smooth hump, left to right, is the top of h, m, n and r.",
              lesson: .traceScene(prompt: "Up and over!", steps: [
                TraceStep("The chick flies up and over to the tree!", .arc, from: "🐤", to: "🌳"),
                TraceStep("The eagle soars over to the mountain!", .arc, from: "🦅", to: "⛰️"),
                TraceStep("The butterfly floats over to the tulip!", .arc, from: "🦋", to: "🌷"),
                TraceStep("The bee hums over to the honey!", .arc, from: "🐝", to: "🍯")
              ])),

        Skill(id: "TW-S7", grade: 0, subject: .writing,
              title: "Bee Loops",
              standard: "Pre-writing · loops (CA PLF)",
              activity: "The bee loops and loops on her way to the flower!",
              parentTip: "Loops are the hardest pre-writing shape and the start of e and l. It's fine if they overlap.",
              lesson: .traceScene(prompt: "Loop-de-loop!", steps: [
                TraceStep("The bee loops her way to the flower!", .loops, from: "🐝", to: "🌸"),
                TraceStep("The butterfly loops to the daisy!", .loops, from: "🦋", to: "🌼"),
                TraceStep("The ladybug loops to the clover!", .loops, from: "🐞", to: "🍀"),
                TraceStep("The dove loops up to the cloud!", .loops, from: "🕊️", to: "☁️")
              ])),

        Skill(id: "TW-S8", grade: 0, subject: .writing,
              title: "Snail Spiral",
              standard: "Pre-writing · spiral (CA PLF)",
              activity: "Follow the snail round and round into the middle of his shell!",
              parentTip: "A spiral is a circle that keeps going. It builds the wrist control for small round letters.",
              lesson: .traceScene(prompt: "Round and in!", steps: [
                TraceStep("Follow the snail into the middle of his shell!", .spiral, from: "🐌", to: "💤"),
                TraceStep("The hedgehog curls up into a ball!", .spiral, from: "🦔", to: "🍄"),
                TraceStep("The snake coils round and round!", .spiral, from: "🐍", to: "🪨"),
                TraceStep("The puppy turns round and round for a nap!", .spiral, from: "🐶", to: "🛏️")
              ])),

        Skill(id: "TW-S9", grade: 0, subject: .writing,
              title: "Chicken Crossing",
              standard: "Pre-writing · cross and diagonals (CA PLF)",
              activity: "Why did the chicken cross the road? To trace a plus sign!",
              parentTip: "The cross (down, then across) and the two diagonals are the strokes behind t, x, k and the capitals.",
              lesson: .traceScene(prompt: "Cross it!", steps: [
                TraceStep("The chicken crosses the road: down, then across!", .cross, from: "🐔", to: "🐣"),
                TraceStep("The squirrel slides down the branch to the acorn!", .diagonalDown, from: "🐿️", to: "🌰"),
                TraceStep("The goat climbs up the hill to the top!", .diagonalUp, from: "🐐", to: "⛰️"),
                TraceStep("The fox and the rooster cross paths!", .xMark, from: "🦊", to: "🐓")
              ])),

        Skill(id: "TW-S10", grade: 0, subject: .writing,
              title: "Pig Pen Shapes",
              standard: "Pre-writing · square, triangle, circle (CA PLF)",
              activity: "Build the pig a pen, a shark a fin, and the sheep a moon. Trace the shapes!",
              parentTip: "Square and triangle are the last pre-writing shapes. Corners take a stop-and-turn; cheer the corners.",
              lesson: .traceScene(prompt: "Trace the shape!", steps: [
                TraceStep("Build the pig a square pen!", .square, from: "🐷", to: "🌽"),
                TraceStep("Trace the shark's pointy fin!", .triangle, from: "🦈", to: "🌊"),
                TraceStep("The sheep walks a circle round the moon!", .circle, from: "🐑", to: "🌙"),
                TraceStep("Zig the zebra over to the grass!", .zigzag, from: "🦓", to: "🌿")
              ])),

        // ================= 2. Lowercase letters by stroke family =================
        Skill(id: "TW-L1", grade: 0, subject: .writing,
              title: "Cat Curls",
              standard: "CA CCSS L.K.1a · lowercase c o a d g",
              activity: "The round letters all start like a c. Trace the first letter of each animal!",
              parentTip: "c, o, a, d and g all begin with the same counter-clockwise curl from the top. That's why they're grouped.",
              lesson: .traceScene(prompt: "Curl like a c!", steps: [
                TraceStep("c is for cat! Start at the top and curl left.", .glyph("c"), from: "🐱", word: "cat"),
                TraceStep("o is for owl! Curl all the way round.", .glyph("o"), from: "🦉", word: "owl"),
                TraceStep("a is for ant! Curl round, then a short line down.", .glyph("a"), from: "🐜", word: "ant"),
                TraceStep("d is for dog! Curl round, then a tall line down.", .glyph("d"), from: "🐶", word: "dog"),
                TraceStep("g is for goat! Curl round, then a tail under.", .glyph("g"), from: "🐐", word: "goat")
              ])),

        Skill(id: "TW-L2", grade: 0, subject: .writing,
              title: "Lion Lines",
              standard: "CA CCSS L.K.1a · lowercase l i t k b h",
              activity: "Tall straight letters, top to bottom. Trace the first letter of each animal!",
              parentTip: "These all start with the top-to-bottom line from Giraffe Neck Slide. Line first, then the extra bit.",
              lesson: .traceScene(prompt: "Tall and straight!", steps: [
                TraceStep("l is for lion! One tall line down.", .glyph("l"), from: "🦁", word: "lion"),
                TraceStep("i is for iguana! A short line and a dot.", .glyph("i"), from: "🦎", word: "iguana"),
                TraceStep("t is for turtle! A tall line, then cross it.", .glyph("t"), from: "🐢", word: "turtle"),
                TraceStep("b is for bear! Tall line down, then a belly.", .glyph("b"), from: "🐻", word: "bear"),
                TraceStep("h is for horse! Tall line down, then a hump.", .glyph("h"), from: "🐴", word: "horse"),
                TraceStep("k is for kangaroo! Tall line, then a kick.", .glyph("k"), from: "🦘", word: "kangaroo")
              ])),

        Skill(id: "TW-L3", grade: 0, subject: .writing,
              title: "Monkey Humps",
              standard: "CA CCSS L.K.1a · lowercase m n r p u",
              activity: "Hump letters! Down, then up and over. Trace the first letter of each animal!",
              parentTip: "m, n and r are the Over the Barn hump with a line first. u is the hump upside down.",
              lesson: .traceScene(prompt: "Up and over!", steps: [
                TraceStep("m is for monkey! Down, hump, hump.", .glyph("m"), from: "🐵", word: "monkey"),
                TraceStep("n is for newt! Down, then one hump.", .glyph("n"), from: "🦎", word: "newt"),
                TraceStep("r is for rabbit! Down, then a little hook.", .glyph("r"), from: "🐰", word: "rabbit"),
                TraceStep("p is for pig! Down under the line, then a belly.", .glyph("p"), from: "🐷", word: "pig"),
                TraceStep("u is for unicorn! Down, curve, and up.", .glyph("u"), from: "🦄", word: "unicorn")
              ])),

        Skill(id: "TW-L4", grade: 0, subject: .writing,
              title: "Zebra Zigzags",
              standard: "CA CCSS L.K.1a · lowercase v w x y z",
              activity: "Pointy letters made of slants! Trace the first letter of each animal!",
              parentTip: "These are Fence Hop diagonals. Points at the bottom, not curves.",
              lesson: .traceScene(prompt: "Pointy!", steps: [
                TraceStep("z is for zebra! Across, slant down, across.", .glyph("z"), from: "🦓", word: "zebra"),
                TraceStep("v is for vulture! Slant down, slant up.", .glyph("v"), from: "🦅", word: "vulture"),
                TraceStep("w is for whale! Down, up, down, up.", .glyph("w"), from: "🐋", word: "whale"),
                TraceStep("y is for yak! Slant down, then a long slant under.", .glyph("y"), from: "🐃", word: "yak"),
                TraceStep("x is for ox! Two slants that cross.", .glyph("x"), from: "🐂", word: "ox")
              ])),

        Skill(id: "TW-L5", grade: 0, subject: .writing,
              title: "Snake Curves",
              standard: "CA CCSS L.K.1a · lowercase s e f j",
              activity: "Curvy letters that slither! Trace the first letter of each animal!",
              parentTip: "The wiggly ones. s is a Duck Pond Wave standing up; e is one Bee Loop.",
              lesson: .traceScene(prompt: "Slither!", steps: [
                TraceStep("s is for snake! Curve one way, then the other.", .glyph("s"), from: "🐍", word: "snake"),
                TraceStep("e is for elephant! Across, then curl round.", .glyph("e"), from: "🐘", word: "elephant"),
                TraceStep("f is for fox! Hook at the top, line down, cross.", .glyph("f"), from: "🦊", word: "fox"),
                TraceStep("j is for jellyfish! Line down, hook, and a dot.", .glyph("j"), from: "🪼", word: "jellyfish")
              ])),

        // ================= 3. Capitals for animals he loves =================
        Skill(id: "TW-L6", grade: 0, subject: .writing,
              title: "Big Animal Letters",
              standard: "CA CCSS L.K.1a · capitals",
              activity: "BIG letters for big animals! Trace the capital that starts each one.",
              parentTip: "Capitals are all top-to-bottom lines, circles and slants: the pre-writing strokes, assembled.",
              lesson: .traceScene(prompt: "Big letters!", steps: [
                TraceStep("L is for Lion!", .glyph("L"), from: "🦁", word: "Lion"),
                TraceStep("P is for Parrot!", .glyph("P"), from: "🦜", word: "Parrot"),
                TraceStep("D is for Duck!", .glyph("D"), from: "🦆", word: "Duck"),
                TraceStep("G is for Goat!", .glyph("G"), from: "🐐", word: "Goat"),
                TraceStep("H is for Hen!", .glyph("H"), from: "🐔", word: "Hen"),
                TraceStep("C is for Cow!", .glyph("C"), from: "🐮", word: "Cow")
              ])),

        // ================= 4. Whole animal names =================
        Skill(id: "TW-W1", grade: 0, subject: .writing,
              title: "Write cow and pig",
              standard: "CA CCSS L.K.1a / W.K.2",
              activity: "Write two whole farm words, one letter at a time!",
              parentTip: "A whole word is a big step from single letters. Say each letter with him, then read the word back together.",
              lesson: .traceScene(prompt: "Write the word!", steps: [
                TraceStep("c-o-w. Trace the c!", .glyph("c"), from: "🐮", word: "cow"),
                TraceStep("Now the o!", .glyph("o"), from: "🐮", word: "cow"),
                TraceStep("And the w. That spells cow!", .glyph("w"), from: "🐮", word: "cow"),
                TraceStep("p-i-g. Trace the p!", .glyph("p"), from: "🐷", word: "pig"),
                TraceStep("Now the i!", .glyph("i"), from: "🐷", word: "pig"),
                TraceStep("And the g. That spells pig!", .glyph("g"), from: "🐷", word: "pig")
              ])),

        Skill(id: "TW-W2", grade: 0, subject: .writing,
              title: "Write duck and hen",
              standard: "CA CCSS L.K.1a / W.K.2",
              activity: "Two more farm words to write, letter by letter!",
              parentTip: "duck has the tricky ck ending. Two letters, one sound.",
              lesson: .traceScene(prompt: "Write the word!", steps: [
                TraceStep("d-u-c-k. Trace the d!", .glyph("d"), from: "🦆", word: "duck"),
                TraceStep("Now the u!", .glyph("u"), from: "🦆", word: "duck"),
                TraceStep("Now the c!", .glyph("c"), from: "🦆", word: "duck"),
                TraceStep("And the k. That spells duck!", .glyph("k"), from: "🦆", word: "duck"),
                TraceStep("h-e-n. Trace the h!", .glyph("h"), from: "🐔", word: "hen"),
                TraceStep("Now the e!", .glyph("e"), from: "🐔", word: "hen"),
                TraceStep("And the n. That spells hen!", .glyph("n"), from: "🐔", word: "hen")
              ])),

        Skill(id: "TW-W3", grade: 0, subject: .writing,
              title: "Write lion cub",
              standard: "CA CCSS L.K.1a / W.K.2",
              activity: "Write the two words that mean YOU: lion cub!",
              parentTip: "He calls himself a lion cub. Writing his own name for himself is the most motivating word there is.",
              lesson: .traceScene(prompt: "Write lion cub!", steps: [
                TraceStep("l-i-o-n. Trace the l!", .glyph("l"), from: "🦁", word: "lion"),
                TraceStep("Now the i!", .glyph("i"), from: "🦁", word: "lion"),
                TraceStep("Now the o!", .glyph("o"), from: "🦁", word: "lion"),
                TraceStep("And the n. That spells lion!", .glyph("n"), from: "🦁", word: "lion"),
                TraceStep("c-u-b. Trace the c!", .glyph("c"), from: "🦁", word: "cub"),
                TraceStep("Now the u!", .glyph("u"), from: "🦁", word: "cub"),
                TraceStep("And the b. Lion cub!", .glyph("b"), from: "🦁", word: "cub")
              ])),

        Skill(id: "TW-W4", grade: 0, subject: .writing,
              title: "Write parrot",
              standard: "CA CCSS L.K.1a / W.K.2",
              activity: "A long word for a talking bird. Write parrot, letter by letter!",
              parentTip: "Six letters is a real word. Notice the double r together.",
              lesson: .traceScene(prompt: "Write parrot!", steps: [
                TraceStep("p-a-r-r-o-t. Trace the p!", .glyph("p"), from: "🦜", word: "parrot"),
                TraceStep("Now the a!", .glyph("a"), from: "🦜", word: "parrot"),
                TraceStep("Now an r!", .glyph("r"), from: "🦜", word: "parrot"),
                TraceStep("And another r!", .glyph("r"), from: "🦜", word: "parrot"),
                TraceStep("Now the o!", .glyph("o"), from: "🦜", word: "parrot"),
                TraceStep("And the t. That spells parrot!", .glyph("t"), from: "🦜", word: "parrot")
              ])),

        Skill(id: "TW-W5", grade: 0, subject: .writing,
              title: "Write goat and dog",
              standard: "CA CCSS L.K.1a / W.K.2",
              activity: "Two more animals to write!",
              parentTip: "goat has a vowel team (oa). Just trace it; the reading comes later.",
              lesson: .traceScene(prompt: "Write the word!", steps: [
                TraceStep("g-o-a-t. Trace the g!", .glyph("g"), from: "🐐", word: "goat"),
                TraceStep("Now the o!", .glyph("o"), from: "🐐", word: "goat"),
                TraceStep("Now the a!", .glyph("a"), from: "🐐", word: "goat"),
                TraceStep("And the t. That spells goat!", .glyph("t"), from: "🐐", word: "goat"),
                TraceStep("d-o-g. Trace the d!", .glyph("d"), from: "🐶", word: "dog"),
                TraceStep("Now the o!", .glyph("o"), from: "🐶", word: "dog"),
                TraceStep("And the g. That spells dog!", .glyph("g"), from: "🐶", word: "dog")
              ])),

        // ================= 5. Numbers that count animals =================
        Skill(id: "TW-N1", grade: 0, subject: .writing,
              title: "Count and Write 1-5",
              standard: "CA CCSS K.CC.3",
              activity: "Count the animals, then write the number!",
              parentTip: "Writing the numeral right after counting ties the symbol to the amount.",
              lesson: .traceScene(prompt: "Write the number!", steps: [
                TraceStep("1 lion! Write the 1.", .glyph("1"), from: "🦁", word: "1 lion"),
                TraceStep("2 ducks! Write the 2.", .glyph("2"), from: "🦆", word: "2 ducks"),
                TraceStep("3 chicks! Write the 3.", .glyph("3"), from: "🐤", word: "3 chicks"),
                TraceStep("4 goats! Write the 4.", .glyph("4"), from: "🐐", word: "4 goats"),
                TraceStep("5 pigs! Write the 5.", .glyph("5"), from: "🐷", word: "5 pigs")
              ])),

        Skill(id: "TW-N2", grade: 0, subject: .writing,
              title: "Count and Write 6-10",
              standard: "CA CCSS K.CC.3",
              activity: "Bigger herds, bigger numbers. Write each one!",
              parentTip: "10 is two glyphs; he traces the 1 and then the 0.",
              lesson: .traceScene(prompt: "Write the number!", steps: [
                TraceStep("6 bees! Write the 6.", .glyph("6"), from: "🐝", word: "6 bees"),
                TraceStep("7 fish! Write the 7.", .glyph("7"), from: "🐟", word: "7 fish"),
                TraceStep("8 sheep! Write the 8.", .glyph("8"), from: "🐑", word: "8 sheep"),
                TraceStep("9 cows! Write the 9.", .glyph("9"), from: "🐮", word: "9 cows"),
                TraceStep("10 hens! Write the 1...", .glyph("1"), from: "🐔", word: "10 hens"),
                TraceStep("...and the 0. Ten!", .glyph("0"), from: "🐔", word: "10 hens")
              ]))
    ]
}
