//
//  TestSupport.swift
//  BookmarkdTests
//

import ComposableArchitecture
import Foundation
import Testing

@testable import Bookmarkd

/// A fixed instant so `dateAdded` / `dateUpdated` assertions are exact.
let testNow = Date(timeIntervalSince1970: 1_700_000_000)

extension Book {
    static func stub(
        id: String = "/works/OL1W",
        title: String = "A Book",
        authors: [String] = ["An Author"],
        firstPublishYear: Int? = 2001
    ) -> Book {
        Book(
            id: id,
            title: title,
            authors: authors,
            coverURL: nil,
            firstPublishYear: firstPublishYear
        )
    }
}

extension ShelfEntry {
    static func stub(
        book: Book = .stub(),
        status: ShelfStatus = .reading,
        addedOffset: TimeInterval = 0
    ) -> ShelfEntry {
        var entry = ShelfEntry(book: book, status: status, now: testNow)
        entry.dateAdded = testNow.addingTimeInterval(addedOffset)
        entry.dateUpdated = testNow.addingTimeInterval(addedOffset)
        return entry
    }
}

/// Runs `body` with the shared shelf seeded to `entries`, backed by an in-memory file so
/// tests never touch the real `shelf.json`, and with a frozen clock.
///
/// Build the `TestStore` *inside* this scope and do not re-prepare these dependencies on the
/// store: `FileStorage.inMemory` is a computed property that hands back a brand new file
/// system each time it is read, so overriding it a second time would silently discard the
/// seeded entries.
func withShelf<T>(
    _ entries: [ShelfEntry] = [],
    _ body: () throws -> T
) rethrows -> T {
    let storage = FileStorage.inMemory
    return try withDependencies {
        $0.defaultFileStorage = storage
        $0.date = .constant(testNow)
    } operation: {
        @Shared(.shelf) var shelf: IdentifiedArrayOf<ShelfEntry>
        $shelf.withLock { $0 = IdentifiedArray(uniqueElements: entries) }
        // Design exploration ships with the sample library on by default. Tests must exercise
        // the real shelf, or every Home assertion silently reads twelve fixture books instead.
        @Shared(.usesSampleLibrary) var usesSampleLibrary
        $usesSampleLibrary.withLock { $0 = false }
        return try body()
    }
}

/// Async twin of `withShelf`, for tests that need two stores inside one shared scope —
/// proving the in-memory source cache survives across screen visits, for instance.
func withShelf<T>(
    _ entries: [ShelfEntry] = [],
    _ body: () async throws -> T
) async rethrows -> T {
    let storage = FileStorage.inMemory
    return try await withDependencies {
        $0.defaultFileStorage = storage
        $0.date = .constant(testNow)
    } operation: {
        @Shared(.shelf) var shelf: IdentifiedArrayOf<ShelfEntry>
        $shelf.withLock { $0 = IdentifiedArray(uniqueElements: entries) }
        // Design exploration ships with the sample library on by default. Tests must exercise
        // the real shelf, or every Home assertion silently reads twelve fixture books instead.
        @Shared(.usesSampleLibrary) var usesSampleLibrary
        $usesSampleLibrary.withLock { $0 = false }
        return try await body()
    }
}
