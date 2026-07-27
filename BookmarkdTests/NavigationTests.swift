//
//  NavigationTests.swift
//  BookmarkdTests
//

import ComposableArchitecture
import Foundation
import Testing

@testable import Bookmarkd

/// Guards the bug this navigation rewrite fixed: before, tapping a book only flipped an
/// optional and no screen was ever presented. These assert the stack actually changes.
///
/// Pushes are asserted with `path[id:]` rather than `path.append`, because appending inside
/// the closure would draw a second `StackElementID` from the generator and never match.
@Suite("Navigation")
@MainActor
struct NavigationTests {
    @Test("tapping a book on Home pushes the detail route")
    func homePushesDetail() async {
        let book = Book.stub()
        let store = withShelf {
            TestStore(initialState: HomeFeature.State()) { HomeFeature() }
        }

        await store.send(.view(.bookTapped(book))) {
            $0.path[id: 0] = .bookDetail(BookDetailFeature.State(book: book))
        }

        #expect(store.state.path.count == 1)
        // A pushed element keeps an effect alive until popped, so pop before finishing.
        await store.send(.path(.popFrom(id: 0))) { $0.path[id: 0] = nil }
    }

    @Test("the detail screen's back button pops itself off the stack")
    func detailPopsItself() async {
        let book = Book.stub()
        let store = withShelf {
            TestStore(initialState: HomeFeature.State()) { HomeFeature() }
        }

        await store.send(.view(.bookTapped(book))) {
            $0.path[id: 0] = .bookDetail(BookDetailFeature.State(book: book))
        }

        await store.send(.path(.element(id: 0, action: .bookDetail(.view(.backTapped)))))
        await store.receive(\.path.popFrom) {
            $0.path[id: 0] = nil
        }

        #expect(store.state.path.isEmpty)
    }

    @Test("a status set on a pushed detail screen is visible to the shelf immediately")
    func sharedShelfCrossesTheStack() async {
        let book = Book.stub()
        let store = withShelf {
            TestStore(initialState: ShelfFeature.State()) { ShelfFeature() }
        }

        await store.send(.view(.bookTapped(book))) {
            $0.path[id: 0] = .bookDetail(BookDetailFeature.State(book: book))
        }

        await store.send(
            .path(.element(id: 0, action: .bookDetail(.view(.statusSelected(.reading)))))
        ) {
            $0.$shelf.withLock {
                $0 = [ShelfEntry(book: book, status: .reading, now: testNow)]
            }
        }

        // No reload action was needed for the parent to see the change.
        #expect(store.state.filteredEntries.map(\.id) == [book.id])
        #expect(store.state.shelf[id: book.id]?.status == .reading)
        await store.send(.path(.popFrom(id: 0))) { $0.path[id: 0] = nil }
    }
}
