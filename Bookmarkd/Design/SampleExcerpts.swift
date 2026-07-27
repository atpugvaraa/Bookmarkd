//
//  SampleExcerpts.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import Foundation

/// Stand-in blurbs and notes for the designs that put *words* on screen.
///
/// Open Library returns a `description` on the work response, and `BookDetail` already holds
/// it — but it is deliberately not persisted, so it is not on `Book` and not in the shelf. The
/// designs that lead with text need something to set while that wiring is done, and this is it.
///
/// Written here rather than lifted from the books: quoting real opening lines of in-copyright
/// novels into the repository is not something a design placeholder needs to do, and the spec's
/// sourcing rule is about exactly this kind of care.
nonisolated enum SampleExcerpts {
    /// Keyed by Open Library work key, matching `SampleLibrary`.
    static let blurbs: [String: String] = [
        "/works/OL17930368W": "You do not rise to the level of your goals. You fall to the level of your systems.",
        "/works/OL20150260W": "Two people who cannot leave each other alone, across four years of getting it wrong.",
        "/works/OL1926995W": "The Mahabharata retold by the woman at the centre of it, who was never asked.",
        "/works/OL20832477W": "In a Tokyo basement café, the coffee lets you revisit one moment — until it goes cold.",
        "/works/OL5819456W": "A girl in wartime Germany steals books, and Death rather likes her for it.",
        "/works/OL264877W": "A name given in a hurry, carried for a lifetime between two countries.",
        "/works/OL66554W": "A truth universally acknowledged, and five daughters it inconveniences.",
        "/works/OL1168083W": "A man begins to keep a diary, which is the most dangerous thing he could do.",
        "/works/OL32525579W": "A student decides some people are exempt from the rules, then tests it.",
        "/works/OL20884585W": "Tehran, 1953: two teenagers meet in a stationery shop the week before everything changes.",
        "/works/OL731663W": "An architect who would rather build nothing than build something compromised.",
        "/works/OL102749W": "One man's grudge against a whale, and everyone unlucky enough to sail with him.",
    ]

    /// What a reader's own margin notes would look like, for the designs where your writing —
    /// not the book's — is the content.
    static let notes: [String: [(page: Int, text: String)]] = [
        "/works/OL17930368W": [
            (73, "The two-minute rule is the only bit I've actually managed to keep."),
            (142, "Environment over willpower. Moved the book to the kitchen table."),
            (210, "\"Every action is a vote for the person you wish to become.\""),
        ],
        "/works/OL20150260W": [
            (44, "Nobody in this book can say the thing they mean."),
            (148, "The email chapter. Ouch."),
        ],
        "/works/OL1926995W": [
            (96, "Panchaali gets a voice and immediately uses it on everyone."),
        ],
    ]
}
