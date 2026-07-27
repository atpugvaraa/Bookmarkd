//
//  SourcesFanOutTests.swift
//  BookmarkdTests
//

import ComposableArchitecture
import Foundation
import Testing

@testable import Bookmarkd

@Suite("Sources fan-out")
@MainActor
struct SourcesFanOutTests {
    private func gutenbergSource(_ title: String) -> BookSource {
        BookSource(
            id: "gutendex:1342", kind: .free, sourceName: "Project Gutenberg",
            title: title, detail: "EPUB",
            linkURL: URL(string: "https://www.gutenberg.org/ebooks/1342.html.images")!
        )
    }

    @Test("both clients contribute, and buy links appear without any network")
    func fanOutCollectsEverySource() async {
        let book = Book.stub(id: "/works/OL1W", title: "Pride and Prejudice", authors: ["Jane Austen"])
        let store = withShelf {
            TestStore(initialState: BookDetailFeature.State(book: book)) {
                BookDetailFeature()
            } withDependencies: {
                $0.openLibraryClient.work = { _ in BookDetail(description: "A novel.") }
                $0.gutendexClient.find = { _ in [gutenbergSource("Pride and Prejudice")] }
                $0.standardEbooksClient.find = { _ in [] }
            }
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.view(.onAppear))
        // Exhaustivity is off, so queued actions must be applied before asserting on state.
        await store.skipReceivedActions()
        await store.finish()

        // Three buy links plus the one free source. The stub has no archive identifiers.
        #expect(store.state.sources.filter { $0.kind == .free }.count == 1)
        #expect(store.state.sources.filter { $0.kind == .buy }.count == 3)
        #expect(!store.state.isLoadingSources)
    }

    @Test("one client failing does not remove the other's results")
    func oneFailureDoesNotBlockOthers() async {
        struct Boom: Error {}
        let book = Book.stub(id: "/works/OL1W", title: "Pride and Prejudice", authors: ["Jane Austen"])
        let store = withShelf {
            TestStore(initialState: BookDetailFeature.State(book: book)) {
                BookDetailFeature()
            } withDependencies: {
                $0.openLibraryClient.work = { _ in BookDetail() }
                $0.gutendexClient.find = { _ in [gutenbergSource("Pride and Prejudice")] }
                $0.standardEbooksClient.find = { _ in throw Boom() }
            }
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.view(.onAppear))
        // Exhaustivity is off, so queued actions must be applied before asserting on state.
        await store.skipReceivedActions()
        await store.finish()

        #expect(store.state.sources.contains { $0.sourceName == "Project Gutenberg" })
        #expect(!store.state.isLoadingSources)
    }

    @Test("sections are ordered free, borrow, buy")
    func sectionOrdering() async {
        var book = Book.stub(id: "/works/OL1W", title: "Pride and Prejudice", authors: ["Jane Austen"])
        book.iaIdentifiers = ["prideandprejudice0000aust"]
        let store = withShelf {
            TestStore(initialState: BookDetailFeature.State(book: book)) {
                BookDetailFeature()
            } withDependencies: {
                $0.openLibraryClient.work = { _ in BookDetail() }
                $0.gutendexClient.find = { _ in [gutenbergSource("Pride and Prejudice")] }
                $0.standardEbooksClient.find = { _ in [] }
            }
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.view(.onAppear))
        // Exhaustivity is off, so queued actions must be applied before asserting on state.
        await store.skipReceivedActions()
        await store.finish()

        #expect(store.state.sourcesByKind.map(\.0) == [.free, .borrow, .buy])
    }

    @Test("a second visit serves the cache instead of refetching")
    func cacheAvoidsRefetch() async {
        let calls = LockIsolated(0)
        let book = Book.stub(id: "/works/OL1W", title: "Pride and Prejudice", authors: ["Jane Austen"])

        func makeStore() -> TestStoreOf<BookDetailFeature> {
            let store = TestStore(initialState: BookDetailFeature.State(book: book)) {
                BookDetailFeature()
            } withDependencies: {
                $0.openLibraryClient.work = { _ in BookDetail() }
                $0.gutendexClient.find = { _ in
                    calls.withValue { $0 += 1 }
                    return [gutenbergSource("Pride and Prejudice")]
                }
                $0.standardEbooksClient.find = { _ in [] }
            }
            store.exhaustivity = .off(showSkippedAssertions: false)
            return store
        }

        await withShelf {
            let first = makeStore()
            await first.send(.view(.onAppear))
            await first.skipReceivedActions()
            await first.finish()

            let second = makeStore()
            await second.send(.view(.onAppear))
            await second.skipReceivedActions()
            await second.finish()
            #expect(second.state.sources.contains { $0.kind == .free })
        }

        #expect(calls.value == 1)
    }
}
