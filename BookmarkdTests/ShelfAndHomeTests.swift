//
//  ShelfAndHomeTests.swift
//  BookmarkdTests
//

import ComposableArchitecture
import Foundation
import Testing

@testable import Bookmarkd

@Suite("Shelf")
@MainActor
struct ShelfFeatureTests {
    private let reading = ShelfEntry.stub(
        book: .stub(id: "/works/OL1W", title: "Reading"), status: .reading, addedOffset: 30
    )
    private let completed = ShelfEntry.stub(
        book: .stub(id: "/works/OL2W", title: "Completed"), status: .completed, addedOffset: 20
    )
    private let dropped = ShelfEntry.stub(
        book: .stub(id: "/works/OL3W", title: "Dropped"), status: .dropped, addedOffset: 10
    )

    @Test("no filter shows every entry, most recently updated first")
    func noFilterShowsEverything() {
        withShelf([dropped, completed, reading]) {
            let state = ShelfFeature.State()
            #expect(state.filteredEntries.map(\.id) == [reading.id, completed.id, dropped.id])
        }
    }

    @Test("a filter narrows to that status only")
    func filterNarrows() async {
        let store = withShelf([reading, completed, dropped]) {
            TestStore(initialState: ShelfFeature.State()) { ShelfFeature() }
        }

        await store.send(.view(.filterChanged(.completed))) {
            $0.selectedFilter = .completed
        }
        #expect(store.state.filteredEntries.map(\.id) == [completed.id])

        await store.send(.view(.filterChanged(nil))) {
            $0.selectedFilter = nil
        }
        #expect(store.state.filteredEntries.count == 3)
    }

    @Test("tapping a book pushes the detail screen onto the stack")
    func tappingPushesDetail() async {
        let book = Book.stub()
        let store = withShelf {
            TestStore(initialState: ShelfFeature.State()) { ShelfFeature() }
        }

        await store.send(.view(.bookTapped(book))) {
            $0.path[id: 0] = .bookDetail(BookDetailFeature.State(book: book))
        }

        #expect(store.state.path.count == 1)
        await store.send(.path(.popFrom(id: 0))) { $0.path[id: 0] = nil }
    }
}

@Suite("Home")
@MainActor
struct HomeFeatureTests {
    @Test("currently reading contains only entries with the reading status")
    func currentlyReadingFiltersByStatus() {
        let reading = ShelfEntry.stub(book: .stub(id: "/works/OL1W"), status: .reading)
        let done = ShelfEntry.stub(book: .stub(id: "/works/OL2W"), status: .completed)

        withShelf([reading, done]) {
            let state = HomeFeature.State()
            #expect(state.currentlyReading.map(\.id) == [reading.id])
        }
    }

    @Test("recently added sorts newest first and caps at ten")
    func recentlyAddedSortsAndCaps() {
        let entries = (0..<15).map { index in
            ShelfEntry.stub(
                book: .stub(id: "/works/OL\(index)W"),
                status: .planToRead,
                addedOffset: TimeInterval(index)
            )
        }

        withShelf(entries) {
            let state = HomeFeature.State()
            #expect(state.recentlyAdded.count == 10)
            // Highest offset (newest) first.
            #expect(state.recentlyAdded.first?.id == "/works/OL14W")
            #expect(state.recentlyAdded.last?.id == "/works/OL5W")
        }
    }

    @Test("home is empty only when the shelf is empty")
    func isEmptyTracksShelf() {
        withShelf {
            #expect(HomeFeature.State().isEmpty)
        }
        withShelf([.stub()]) {
            #expect(!HomeFeature.State().isEmpty)
        }
    }
}
