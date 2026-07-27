//
//  StandardEbooksClientTests.swift
//  BookmarkdTests
//

import Foundation
import Testing

@testable import Bookmarkd

@Suite("Standard Ebooks")
struct StandardEbooksClientTests {
    /// The real RDFa shape their public search page returns, trimmed.
    private let html = """
    <ol class="ebooks-list">
    <li typeof="schema:Book" about="/ebooks/jane-austen/pride-and-prejudice">
      <a href="/ebooks/jane-austen/pride-and-prejudice" property="schema:url"></a>
      <p><span property="schema:name">Pride and Prejudice</span></p>
      <p><a property="schema:author" href="/authors/jane-austen">
         <span property="schema:name">Jane Austen</span></a></p>
    </li>
    <li typeof="schema:Book" about="/ebooks/herman-melville/moby-dick">
      <p><span property="schema:name">Moby Dick</span></p>
      <p><a property="schema:author" href="/authors/herman-melville">
         <span property="schema:name">Herman Melville</span></a></p>
    </li>
    </ol>
    """

    @Test("parses the matching entry into a source")
    func parsesMatch() {
        let pride = Book.stub(id: "/works/OL1W", title: "Pride and Prejudice", authors: ["Jane Austen"])
        let sources = StandardEbooksClient.sources(fromHTML: html, for: pride)

        #expect(sources.count == 1)
        #expect(sources.first?.id == "standardebooks:/ebooks/jane-austen/pride-and-prejudice")
        #expect(sources.first?.kind == .free)
        #expect(sources.first?.sourceName == "Standard Ebooks")
        #expect(sources.first?.linkURL.absoluteString
                == "https://standardebooks.org/ebooks/jane-austen/pride-and-prejudice")
    }

    @Test("derives the canonical epub path from a slug")
    func epubURL() {
        #expect(StandardEbooksClient.epubURL(forSlug: "/ebooks/jane-austen/pride-and-prejudice")?.absoluteString
                == "https://standardebooks.org/ebooks/jane-austen/pride-and-prejudice/downloads/jane-austen_pride-and-prejudice.epub")
    }

    @Test("non-matching entries are dropped")
    func dropsNonMatches() {
        let dune = Book.stub(id: "/works/OL9W", title: "Dune", authors: ["Frank Herbert"])
        #expect(StandardEbooksClient.sources(fromHTML: html, for: dune).isEmpty)
    }

    @Test("markup with no results yields nothing rather than throwing")
    func emptyHTML() {
        let pride = Book.stub(id: "/works/OL1W", title: "Pride and Prejudice", authors: ["Jane Austen"])
        #expect(StandardEbooksClient.sources(fromHTML: "<ol></ol>", for: pride).isEmpty)
    }
}
