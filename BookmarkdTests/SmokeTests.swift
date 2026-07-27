//
//  SmokeTests.swift
//  BookmarkdTests
//

import Testing
@testable import Bookmarkd

@Suite("Smoke")
struct SmokeTests {
    @Test("test target is wired up and can see the app module")
    func testTargetIsWiredUp() {
        let book = Book(
            id: "/works/OL1W",
            title: "Title",
            authors: ["A", "B"],
            coverURL: nil,
            firstPublishYear: nil
        )
        #expect(book.authorDisplay == "A, B")
    }
}
