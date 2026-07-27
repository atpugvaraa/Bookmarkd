//
//  BookSourceTests.swift
//  BookmarkdTests
//

import Testing

@testable import Bookmarkd

@Suite("BookSource")
struct BookSourceTests {
    @Test("kinds sort free, then borrow, then buy")
    func kindOrdering() {
        let kinds: [BookSource.Kind] = [.buy, .free, .borrow]
        #expect(kinds.sorted { $0.sortOrder < $1.sortOrder } == [.free, .borrow, .buy])
    }

    @Test("each kind has a section title")
    func sectionTitles() {
        #expect(BookSource.Kind.free.sectionTitle == "Read free")
        #expect(BookSource.Kind.borrow.sectionTitle == "Borrow")
        #expect(BookSource.Kind.buy.sectionTitle == "Buy")
    }
}
