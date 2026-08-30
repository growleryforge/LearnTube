import SwiftUI

extension Stories {
    /// A Kindergarten Counting & Cardinality lesson starring original critters.
    static let countingCritters = StoryContent(
        id: "counting-critters",
        title: "Counting Critters",
        author: "Maddy Turley",
        covers: "Counting to 100, counting by tens, counting on from any number, reading numbers 0-20, one-to-one counting, how many, and comparing groups and numbers.",
        darkPages: true,
        pages: [],
        // One clean game, Shape Detective style: count the critters, tap the
        // number. Six rounds; "Game X of 6" advances.
        games: (1...6).map { _ in
            StoryGame(skill: "How many?",
                      activity: .critterCount(CritterCountLevel(skill: "How many?", rounds: 1)))
        }
    )
}
