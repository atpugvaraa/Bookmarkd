//
//  BookDetailLoadingTests.swift
//  BookmarkdTests
//

import ComposableArchitecture
import Foundation
import Testing

@testable import Bookmarkd

@Suite("Book Detail loading")
@MainActor
struct BookDetailLoadingTests {
    // `onAppear` now also fans out to the source clients, and those responses race the detail
    // response. These tests are about detail loading, so they stub the sources to silence and
    // assert non-exhaustively rather than encoding an arbitrary action order.

    @Test("appearing loads the description and subjects")
    func loadsDetail() async {
        let detail = BookDetail(description: "A novel.", subjects: ["Fiction", "Ireland"])
        let store = withShelf {
            TestStore(initialState: BookDetailFeature.State(book: .stub())) {
                BookDetailFeature()
            } withDependencies: {
                $0.openLibraryClient.work = { _ in detail }
                $0.gutendexClient.find = { _ in [] }
                $0.standardEbooksClient.find = { _ in [] }
            }
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.view(.onAppear))
        await store.skipReceivedActions()
        await store.finish()

        #expect(store.state.detail == detail)
        #expect(!store.state.isLoadingDetail)
    }

    @Test("a failed detail fetch leaves the screen usable and shows no alert")
    func failedDetailDegradesQuietly() async {
        struct Boom: Error {}
        let store = withShelf {
            TestStore(initialState: BookDetailFeature.State(book: .stub())) {
                BookDetailFeature()
            } withDependencies: {
                $0.openLibraryClient.work = { _ in throw Boom() }
                $0.gutendexClient.find = { _ in [] }
                $0.standardEbooksClient.find = { _ in [] }
            }
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.view(.onAppear))
        await store.skipReceivedActions()
        await store.finish()

        #expect(store.state.detail == nil)
        #expect(!store.state.isLoadingDetail)

        // The shelf controls still work.
        await store.send(.view(.statusSelected(.reading)))
        #expect(store.state.shelfStatus == .reading)
    }

    @Test("the detail is fetched once, not on every appearance")
    func fetchesOnce() async {
        let calls = LockIsolated(0)
        let store = withShelf {
            TestStore(initialState: BookDetailFeature.State(book: .stub())) {
                BookDetailFeature()
            } withDependencies: {
                $0.openLibraryClient.work = { _ in
                    calls.withValue { $0 += 1 }
                    return BookDetail(description: "A novel.")
                }
                $0.gutendexClient.find = { _ in [] }
                $0.standardEbooksClient.find = { _ in [] }
            }
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.view(.onAppear))
        await store.skipReceivedActions()
        await store.finish()
        #expect(store.state.detail == BookDetail(description: "A novel."))

        await store.send(.view(.onAppear))
        await store.finish()
        #expect(calls.value == 1)
    }

    @Test("the metadata line only includes what is known")
    func metadataLineOmitsMissingValues() {
        withShelf {
            let full = BookDetailFeature.State(
                book: Book(
                    id: "/works/OL1W",
                    title: "A Book",
                    authors: [],
                    firstPublishYear: 2018,
                    pageCount: 304,
                    editionCount: 27
                )
            )
            #expect(full.metadataLine == "304 pages · 27 editions · 2018")

            let sparse = BookDetailFeature.State(
                book: Book(id: "/works/OL2W", title: "A Book", authors: [], editionCount: 1)
            )
            #expect(sparse.metadataLine == "1 edition")

            let bare = BookDetailFeature.State(
                book: Book(id: "/works/OL3W", title: "A Book", authors: [])
            )
            #expect(bare.metadataLine == nil)
        }
    }
}
