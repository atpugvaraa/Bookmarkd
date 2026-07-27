//
//  BuyLinksTests.swift
//  BookmarkdTests
//

import Foundation
import Testing

@testable import Bookmarkd

@Suite("BuyLinks")
struct BuyLinksTests {
    @Test("produces one borrow row per Internet Archive identifier, then the buy rows")
    func borrowAndBuy() {
        var book = Book.stub(id: "/works/OL1W", title: "Normal People", authors: ["Sally Rooney"])
        book.iaIdentifiers = ["normalpeople0000roon_o9w7"]

        let sources = BuyLinks.sources(for: book)
        let borrow = sources.filter { $0.kind == .borrow }
        let buy = sources.filter { $0.kind == .buy }

        #expect(borrow.count == 1)
        #expect(borrow.first?.linkURL.absoluteString
                == "https://archive.org/details/normalpeople0000roon_o9w7")
        #expect(buy.map(\.sourceName) == ["Amazon.in", "Flipkart", "Quick commerce"])
    }

    @Test("a book with no archive identifiers still gets buy links")
    func noIdentifiers() {
        let book = Book.stub(id: "/works/OL2W", title: "Dune", authors: ["Frank Herbert"])
        let sources = BuyLinks.sources(for: book)

        #expect(!sources.contains { $0.kind == .borrow })
        #expect(sources.filter { $0.kind == .buy }.count == 3)
    }

    @Test("titles with spaces are percent-encoded")
    func encodesQuery() {
        let book = Book.stub(id: "/works/OL3W", title: "The Palace of Illusions", authors: [])
        let amazon = BuyLinks.sources(for: book).first { $0.sourceName == "Amazon.in" }
        #expect(amazon?.linkURL.absoluteString.contains("The%20Palace%20of%20Illusions") == true)
    }

    @Test("an ISBN is preferred over the title when one is known")
    func prefersISBN() {
        var book = Book.stub(id: "/works/OL4W", title: "Normal People", authors: ["Sally Rooney"])
        book.isbns = ["9780571334650"]
        let amazon = BuyLinks.sources(for: book).first { $0.sourceName == "Amazon.in" }
        #expect(amazon?.linkURL.absoluteString == "https://www.amazon.in/s?k=9780571334650")
    }

    @Test("carries no affiliate tag")
    func noAffiliateTag() {
        let book = Book.stub(id: "/works/OL5W", title: "Dune", authors: [])
        for source in BuyLinks.sources(for: book) {
            #expect(!source.linkURL.absoluteString.contains("tag="))
        }
    }
}
