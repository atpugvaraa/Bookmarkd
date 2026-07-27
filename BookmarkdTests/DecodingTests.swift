//
//  DecodingTests.swift
//  BookmarkdTests
//

import Foundation
import Testing

@testable import Bookmarkd

@Suite("Decoding")
struct DecodingTests {
    /// Open Library returns a work description in two different shapes depending on the record.
    @Test("a description decodes whether it is a plain string or a keyed value")
    func descriptionDecodesBothShapes() throws {
        let plain = try JSONDecoder().decode(
            DescriptionValue.self,
            from: Data(#""just a string""#.utf8)
        )
        #expect(plain.text == "just a string")

        let keyed = try JSONDecoder().decode(
            DescriptionValue.self,
            from: Data(#"{"type": "/type/text", "value": "wrapped"}"#.utf8)
        )
        #expect(keyed.text == "wrapped")
    }

    /// Shelf entries written before the extra fields existed must still load.
    @Test("a book persisted by an older build still decodes")
    func oldBookJSONStillDecodes() throws {
        let json = """
        {
          "id": "/works/OL20150260W",
          "title": "Normal People",
          "authors": ["Sally Rooney"],
          "firstPublishYear": 2018
        }
        """
        let book = try JSONDecoder().decode(Book.self, from: Data(json.utf8))

        #expect(book.title == "Normal People")
        #expect(book.pageCount == nil)
        #expect(book.isbns == nil)
        #expect(book.ebookAccess == nil)
        #expect(!book.isFreeToRead)
    }

    @Test("a shelf entry persisted by an older build still decodes")
    func oldShelfEntryJSONStillDecodes() throws {
        let json = """
        [{
          "id": "/works/OL20150260W",
          "book": {
            "id": "/works/OL20150260W",
            "title": "Normal People",
            "authors": ["Sally Rooney"]
          },
          "status": "Reading",
          "dateAdded": 774000000,
          "dateUpdated": 774000000
        }]
        """
        let entries = try JSONDecoder().decode([ShelfEntry].self, from: Data(json.utf8))

        #expect(entries.count == 1)
        #expect(entries[0].status == .reading)
        #expect(entries[0].book.pageCount == nil)
    }

    @Test("only public-access books are marked free to read")
    func freeToReadReflectsEbookAccess() {
        #expect(Book.stub(id: "/works/OL1W").isFreeToRead == false)

        var free = Book.stub(id: "/works/OL2W")
        free.ebookAccess = "public"
        #expect(free.isFreeToRead)

        var borrowable = Book.stub(id: "/works/OL3W")
        borrowable.ebookAccess = "borrowable"
        #expect(!borrowable.isFreeToRead)
    }
}
