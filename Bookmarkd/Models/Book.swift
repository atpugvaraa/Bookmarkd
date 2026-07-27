//
//  Book.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 09/06/26.
//

import Foundation

nonisolated struct Book: Identifiable, Equatable, Sendable, Codable {
    /// The Open Library work key, e.g. `/works/OL20150260W`.
    let id: String
    var title: String
    var authors: [String]
    var coverURL: URL?
    var firstPublishYear: Int?

    // Everything below rides along on the search response, so opening a book from the shelf
    // needs no extra request. All optional on purpose: the synthesized decoder treats a
    // missing key as nil for optionals, so shelf entries written by older builds still load.
    var pageCount: Int?
    var isbns: [String]?
    var editionCount: Int?
    /// `no_ebook`, `printdisabled`, `borrowable` or `public`. Kept as a raw string rather than
    /// an enum so an unrecognised value from the API cannot fail decoding of the whole search.
    var ebookAccess: String?
    /// Internet Archive identifiers — the hook for reading a book for free later.
    var iaIdentifiers: [String]?

    var authorDisplay: String {
        authors.joined(separator: ", ")
    }

    /// True when the full text can be read without borrowing.
    var isFreeToRead: Bool {
        ebookAccess == "public"
    }

    init(
        id: String,
        title: String,
        authors: [String],
        coverURL: URL? = nil,
        firstPublishYear: Int? = nil,
        pageCount: Int? = nil,
        isbns: [String]? = nil,
        editionCount: Int? = nil,
        ebookAccess: String? = nil,
        iaIdentifiers: [String]? = nil
    ) {
        self.id = id
        self.title = title
        self.authors = authors
        self.coverURL = coverURL
        self.firstPublishYear = firstPublishYear
        self.pageCount = pageCount
        self.isbns = isbns
        self.editionCount = editionCount
        self.ebookAccess = ebookAccess
        self.iaIdentifiers = iaIdentifiers
    }
}
