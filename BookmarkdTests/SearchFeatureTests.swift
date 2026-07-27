//
//  SearchFeatureTests.swift
//  BookmarkdTests
//

import ComposableArchitecture
import Foundation
import Testing

@testable import Bookmarkd

@Suite("Search")
@MainActor
struct SearchFeatureTests {
    private static func page(_ ids: [String], numFound: Int) -> SearchPage {
        SearchPage(books: ids.map { Book.stub(id: $0) }, numFound: numFound)
    }

    @Test("typing waits out the debounce before hitting the network")
    func debouncesTyping() async {
        let clock = TestClock()
        let calls = LockIsolated(0)
        let store = withShelf {
            TestStore(initialState: SearchFeature.State()) {
                SearchFeature()
            } withDependencies: {
                $0.continuousClock = clock
                $0.openLibraryClient.search = { _, _ in
                    calls.withValue { $0 += 1 }
                    return Self.page(["/works/OL1W"], numFound: 1)
                }
            }
        }

        await store.send(.view(.queryChanged("du"))) {
            $0.query = "du"
            $0.isLoading = true
        }

        await clock.advance(by: .milliseconds(299))
        #expect(calls.value == 0)

        await clock.advance(by: .milliseconds(1))
        await store.receive(\.searchResponse.success) {
            $0.results = [.stub(id: "/works/OL1W")]
            $0.numFound = 1
            $0.isLoading = false
            $0.hasSearched = true
        }
        #expect(calls.value == 1)
    }

    @Test("a keystroke inside the debounce window cancels the previous request")
    func laterKeystrokeCancelsEarlier() async {
        let clock = TestClock()
        let queries = LockIsolated<[String]>([])
        let store = withShelf {
            TestStore(initialState: SearchFeature.State()) {
                SearchFeature()
            } withDependencies: {
                $0.continuousClock = clock
                $0.openLibraryClient.search = { query, _ in
                    queries.withValue { $0.append(query) }
                    return Self.page(["/works/OL1W"], numFound: 1)
                }
            }
        }

        await store.send(.view(.queryChanged("du"))) {
            $0.query = "du"
            $0.isLoading = true
        }
        await clock.advance(by: .milliseconds(200))

        await store.send(.view(.queryChanged("dune"))) { $0.query = "dune" }
        await clock.advance(by: .milliseconds(300))

        await store.receive(\.searchResponse.success) {
            $0.results = [.stub(id: "/works/OL1W")]
            $0.numFound = 1
            $0.isLoading = false
            $0.hasSearched = true
        }
        // Only the final query reached the network.
        #expect(queries.value == ["dune"])
    }

    @Test("clearing the query wipes results and cancels any in-flight search")
    func clearingQueryResets() async {
        let clock = TestClock()
        let store = withShelf {
            TestStore(
                initialState: SearchFeature.State(
                    results: [.stub()],
                    hasSearched: true,
                    numFound: 1
                )
            ) {
                SearchFeature()
            } withDependencies: {
                $0.continuousClock = clock
                $0.openLibraryClient.search = { _, _ in Self.page([], numFound: 0) }
            }
        }

        await store.send(.view(.queryChanged("  "))) {
            $0.query = "  "
            $0.results = []
            $0.hasSearched = false
            $0.numFound = 0
        }

        // Nothing fires even after the debounce would have elapsed.
        await clock.advance(by: .seconds(1))
    }

    @Test("submitting searches immediately without waiting for the debounce")
    func submitSkipsDebounce() async {
        let clock = TestClock()
        let store = withShelf {
            TestStore(initialState: SearchFeature.State(query: "dune")) {
                SearchFeature()
            } withDependencies: {
                $0.continuousClock = clock
                $0.openLibraryClient.search = { _, _ in Self.page(["/works/OL1W"], numFound: 1) }
            }
        }

        await store.send(.view(.searchSubmitted)) { $0.isLoading = true }
        await store.receive(\.searchResponse.success) {
            $0.results = [.stub(id: "/works/OL1W")]
            $0.numFound = 1
            $0.isLoading = false
            $0.hasSearched = true
        }
    }

    @Test("a failed search presents an alert instead of an empty-results message")
    func failurePresentsAlert() async {
        struct Boom: Error {}
        let clock = TestClock()
        let store = withShelf {
            TestStore(initialState: SearchFeature.State(query: "dune")) {
                SearchFeature()
            } withDependencies: {
                $0.continuousClock = clock
                $0.openLibraryClient.search = { _, _ in throw Boom() }
            }
        }

        await store.send(.view(.searchSubmitted)) { $0.isLoading = true }
        await store.receive(\.searchResponse.failure) {
            $0.isLoading = false
            $0.hasSearched = true
            $0.alert = .searchFailed(Boom())
        }
        #expect(store.state.alert != nil)
    }

    @Test("reaching the last row appends the next page")
    func paginationAppends() async {
        let clock = TestClock()
        let requestedPages = LockIsolated<[Int]>([])
        let store = withShelf {
            TestStore(
                initialState: SearchFeature.State(
                    query: "dune",
                    results: [.stub(id: "/works/OL1W")],
                    hasSearched: true,
                    numFound: 2
                )
            ) {
                SearchFeature()
            } withDependencies: {
                $0.continuousClock = clock
                $0.openLibraryClient.search = { _, page in
                    requestedPages.withValue { $0.append(page) }
                    return Self.page(["/works/OL2W"], numFound: 2)
                }
            }
        }

        await store.send(.view(.resultAppeared("/works/OL1W"))) { $0.isLoadingPage = true }
        await store.receive(\.nextPageResponse.success) {
            $0.results = [.stub(id: "/works/OL1W"), .stub(id: "/works/OL2W")]
            $0.page = 2
            $0.isLoadingPage = false
        }

        #expect(requestedPages.value == [2])
        // Everything is loaded now, so scrolling again does nothing.
        #expect(!store.state.canLoadMore)
        await store.send(.view(.resultAppeared("/works/OL2W")))
    }

    @Test("a row that is not the last one does not trigger pagination")
    func onlyLastRowPaginates() async {
        let store = withShelf {
            TestStore(
                initialState: SearchFeature.State(
                    query: "dune",
                    results: [.stub(id: "/works/OL1W"), .stub(id: "/works/OL2W")],
                    hasSearched: true,
                    numFound: 50
                )
            ) {
                SearchFeature()
            }
        }

        // The client has no stub, so any request would report an unimplemented dependency.
        await store.send(.view(.resultAppeared("/works/OL1W")))
    }
}
