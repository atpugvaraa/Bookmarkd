//
//  GutendexClientTests.swift
//  BookmarkdTests
//

import Foundation
import Testing

@testable import Bookmarkd

@Suite("Gutendex")
struct GutendexClientTests {
    /// Trimmed copy of a real Gutendex response, including its "Last, First" author format.
    private let json = Data("""
    {"count":2,"results":[
      {"id":1342,"title":"Pride and Prejudice",
       "authors":[{"name":"Austen, Jane"}],
       "formats":{"application/epub+zip":"https://www.gutenberg.org/ebooks/1342.epub3.images",
                  "text/html":"https://www.gutenberg.org/ebooks/1342.html.images"}},
      {"id":42671,"title":"Pride and Prejudice, a play",
       "authors":[{"name":"Jerome, Helen"}],
       "formats":{"text/html":"https://www.gutenberg.org/ebooks/42671.html.images"}}
    ]}
    """.utf8)

    @Test("keeps only the matching work and links to the readable HTML")
    func filtersToTheMatch() throws {
        let pride = Book.stub(id: "/works/OL1W", title: "Pride and Prejudice", authors: ["Jane Austen"])
        let sources = try GutendexClient.sources(from: json, for: pride)

        #expect(sources.count == 1)
        let source = try #require(sources.first)
        #expect(source.id == "gutendex:1342")
        #expect(source.kind == .free)
        #expect(source.sourceName == "Project Gutenberg")
        #expect(source.detail == "EPUB")
        #expect(source.linkURL.absoluteString == "https://www.gutenberg.org/ebooks/1342.html.images")
    }

    @Test("returns nothing when no result matches")
    func noMatchReturnsEmpty() throws {
        let other = Book.stub(id: "/works/OL2W", title: "Moby Dick", authors: ["Herman Melville"])
        #expect(try GutendexClient.sources(from: json, for: other).isEmpty)
    }

    /// A live search for this title matched six identically-named Gutenberg records. Six
    /// identical rows is noise, so only the best match is kept.
    @Test("collapses duplicate records down to a single row")
    func keepsOnlyTheBestMatch() throws {
        let duplicates = Data("""
        {"count":3,"results":[
          {"id":1342,"title":"Pride and Prejudice","authors":[{"name":"Austen, Jane"}],
           "formats":{"text/html":"https://www.gutenberg.org/ebooks/1342.html.images"}},
          {"id":42671,"title":"Pride and Prejudice","authors":[{"name":"Austen, Jane"}],
           "formats":{"text/html":"https://www.gutenberg.org/ebooks/42671.html.images"}},
          {"id":20686,"title":"Pride and Prejudice, a play founded on Jane Austen's novel",
           "authors":[{"name":"Austen, Jane"}],
           "formats":{"text/html":"https://www.gutenberg.org/ebooks/20686.html.images"}}
        ]}
        """.utf8)
        let pride = Book.stub(id: "/works/OL1W", title: "Pride and Prejudice", authors: ["Jane Austen"])
        let sources = try GutendexClient.sources(from: duplicates, for: pride)

        #expect(sources.count == 1)
        #expect(sources.first?.id == "gutendex:1342")
    }
}
