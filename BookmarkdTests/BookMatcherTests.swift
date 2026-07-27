//
//  BookMatcherTests.swift
//  BookmarkdTests
//

import Testing

@testable import Bookmarkd

@Suite("BookMatcher")
struct BookMatcherTests {
    private let palace = Book.stub(
        id: "/works/OL20150260W",
        title: "The Palace of Illusions",
        authors: ["Chitra Banerjee Divakaruni"]
    )

    @Test("accepts a longer edition title carrying every target token")
    func acceptsEditionSuffix() {
        #expect(BookMatcher.matches(
            title: "The Palace Of Illusions: 10Th Anniversary Edition",
            authors: [],
            against: palace
        ))
        #expect(BookMatcher.matches(
            title: "The Palace Of Illusions By Chitra Banerjee Divakaruni",
            authors: [],
            against: palace
        ))
    }

    /// Every string here was actually returned by a real quick-commerce search for this book.
    @Test("rejects the junk the same search actually returned")
    func rejectsRealJunk() {
        for junk in [
            "Mangal Bhawan Pooja Chowki Aasan",
            "Marvel Deodorant150 ml",
            "The Namesake",
            "Before The Coffee Gets Cold",
            "1984 - George Orwell (FP-Classics)",
            "Crime And Punishment (Penguin Classics)",
        ] {
            #expect(!BookMatcher.matches(title: junk, authors: [], against: palace), "matched \(junk)")
        }
    }

    @Test("a one-token title needs the author to agree")
    func singleTokenTitleNeedsAuthor() {
        let secret = Book.stub(id: "/works/OL9W", title: "The Secret", authors: ["Rhonda Byrne"])
        // No author from the source, one significant token — too weak, must reject.
        #expect(!BookMatcher.matches(title: "The Secret of Secrets", authors: [], against: secret))
        #expect(!BookMatcher.matches(title: "The Secret", authors: [], against: secret))
        // With a matching author it is safe.
        #expect(BookMatcher.matches(title: "The Secret", authors: ["Rhonda Byrne"], against: secret))
    }

    @Test("handles Gutendex's Last, First author format")
    func lastCommaFirstAuthors() {
        let pride = Book.stub(id: "/works/OL1W", title: "Pride and Prejudice", authors: ["Jane Austen"])
        #expect(BookMatcher.matches(title: "Pride and Prejudice", authors: ["Austen, Jane"], against: pride))
    }

    @Test("a disagreeing author rejects even on an exact title")
    func wrongAuthorRejects() {
        let pride = Book.stub(id: "/works/OL1W", title: "Pride and Prejudice", authors: ["Jane Austen"])
        #expect(!BookMatcher.matches(title: "Pride and Prejudice", authors: ["Seth Grahame-Smith"], against: pride))
    }

    @Test("normalisation drops articles, punctuation and case")
    func normalisation() {
        #expect(BookMatcher.normalizedTitleTokens("The Palace of Illusions!") == ["palace", "illusions"])
        #expect(BookMatcher.normalizedAuthorSurname("Austen, Jane") == "austen")
        #expect(BookMatcher.normalizedAuthorSurname("Jane Austen") == "austen")
    }
}
