//
//  SampleLibrary.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import Foundation

/// A believable shelf for judging designs.
///
/// Real titles, real covers, real page counts, spread across every status with several books
/// mid-progress — an empty or progress-less shelf makes every design look identical, and the
/// point of the exercise is to compare them full.
nonisolated enum SampleLibrary {
    /// Work keys, cover IDs and page counts are all real, looked up from Open Library rather
    /// than invented — guessed cover IDs render as an unrelated book, which makes a design
    /// impossible to judge.
    static let entries: [ShelfEntry] = [
        make("/works/OL17930368W", "Atomic Habits", ["James Clear"], 2016, 322, 12539702, .reading, page: 210, daysAgo: 1),
        make("/works/OL20150260W", "Normal People", ["Sally Rooney"], 2018, 304, 8794265, .reading, page: 148, daysAgo: 2),
        make("/works/OL1926995W", "The Palace of Illusions", ["Chitra Banerjee Divakaruni"], 2008, 372, 2412074, .reading, page: 96, daysAgo: 5),
        make("/works/OL20832477W", "Before the Coffee Gets Cold", ["Toshikazu Kawaguchi"], 2019, 240, 10138333, .planToRead, page: nil, daysAgo: 3),
        make("/works/OL5819456W", "The Book Thief", ["Markus Zusak"], 1998, 560, 8153054, .planToRead, page: nil, daysAgo: 9),
        make("/works/OL264877W", "The Namesake", ["Jhumpa Lahiri"], 2003, 250, 12052, .completed, page: 250, daysAgo: 21),
        make("/works/OL66554W", "Pride and Prejudice", ["Jane Austen"], 1813, 351, 14348537, .completed, page: 351, daysAgo: 40),
        make("/works/OL1168083W", "Nineteen Eighty-Four", ["George Orwell"], 1949, 318, 9267242, .completed, page: 318, daysAgo: 65),
        make("/works/OL32525579W", "Crime and Punishment", ["Fyodor Dostoevsky"], 1941, 551, 13116014, .onHold, page: 220, daysAgo: 30),
        make("/works/OL20884585W", "The Stationery Shop", ["Marjan Kamali"], 2019, 320, 10211160, .onHold, page: 64, daysAgo: 47),
        make("/works/OL731663W", "The Fountainhead", ["Ayn Rand"], 1943, 724, 6767765, .dropped, page: 130, daysAgo: 88),
        make("/works/OL102749W", "Moby Dick", ["Herman Melville"], 1851, 452, 10544254, .dropped, page: 41, daysAgo: 120),
    ]

    /// The book the habit designs treat as "the one you're reading".
    static var activeEntry: ShelfEntry {
        entries.first { $0.status == .reading } ?? entries[0]
    }

    private static func make(
        _ id: String,
        _ title: String,
        _ authors: [String],
        _ year: Int,
        _ pages: Int,
        _ coverID: Int,
        _ status: ShelfStatus,
        page: Int?,
        daysAgo: Int
    ) -> ShelfEntry {
        let book = Book(
            id: id,
            title: title,
            authors: authors,
            coverURL: URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-L.jpg"),
            firstPublishYear: year,
            pageCount: pages
        )
        // Fixed reference date so the sample shelf renders identically on every launch.
        let reference = Date(timeIntervalSince1970: 1_785_000_000)
        let when = reference.addingTimeInterval(-Double(daysAgo) * 86_400)

        var entry = ShelfEntry(book: book, status: status, now: when)
        entry.currentPage = page
        entry.totalPages = pages
        return entry
    }
}
