//
//  BookDetailFeatureTests.swift
//  BookmarkdTests
//

import ComposableArchitecture
import Foundation
import Testing

@testable import Bookmarkd

@Suite("Book Detail")
@MainActor
struct BookDetailFeatureTests {
    private func makeStore(
        book: Book = .stub(),
        shelf: [ShelfEntry] = []
    ) -> TestStoreOf<BookDetailFeature> {
        // Dependencies come from the surrounding withShelf scope; re-preparing them on the
        // store would swap in a second, empty in-memory file system.
        withShelf(shelf) {
            TestStore(initialState: BookDetailFeature.State(book: book)) {
                BookDetailFeature()
            }
        }
    }

    @Test("selecting a status adds a book that is not on the shelf yet")
    func addsNewEntry() async {
        let book = Book.stub()
        let store = makeStore(book: book)
        #expect(store.state.shelfStatus == nil)

        await store.send(.view(.statusSelected(.reading))) {
            $0.$shelf.withLock {
                $0 = [ShelfEntry(book: book, status: .reading, now: testNow)]
            }
        }

        #expect(store.state.shelfStatus == .reading)
    }

    @Test("selecting a status updates an existing entry rather than duplicating it")
    func updatesExistingEntry() async {
        let book = Book.stub()
        let existing = ShelfEntry.stub(book: book, status: .planToRead, addedOffset: -1000)
        let store = makeStore(book: book, shelf: [existing])

        await store.send(.view(.statusSelected(.completed))) {
            var updated = existing
            updated.status = .completed
            updated.dateUpdated = testNow
            $0.$shelf.withLock { $0 = [updated] }
        }

        #expect(store.state.shelf.count == 1)
        // dateAdded is preserved; only dateUpdated moves.
        #expect(store.state.shelf[id: book.id]?.dateAdded == existing.dateAdded)
        #expect(store.state.shelf[id: book.id]?.dateUpdated == testNow)
    }

    @Test("removing takes the book off the shelf")
    func removesEntry() async {
        let book = Book.stub()
        let store = makeStore(book: book, shelf: [.stub(book: book, status: .reading)])

        await store.send(.view(.removeTapped)) {
            $0.$shelf.withLock { $0 = [] }
        }

        #expect(store.state.shelfStatus == nil)
    }

    @Test("removing one book leaves the others alone")
    func removesOnlyTheSelectedBook() async {
        let book = Book.stub(id: "/works/OL1W")
        let other = Book.stub(id: "/works/OL2W", title: "Another Book")
        let otherEntry = ShelfEntry.stub(book: other, status: .completed)
        let store = makeStore(book: book, shelf: [.stub(book: book), otherEntry])

        await store.send(.view(.removeTapped)) {
            $0.$shelf.withLock { $0 = [otherEntry] }
        }

        #expect(store.state.shelf.map(\.id) == [other.id])
    }
}
