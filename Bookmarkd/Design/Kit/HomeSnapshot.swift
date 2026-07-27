//
//  HomeSnapshot.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import Foundation

// Everything a Home design needs, as plain values.
//
// Deliberately no ComposableArchitecture import anywhere in `Design/Kit/` — a design that
// reaches into a store is welded to today's feature shape, which is what made the first ten
// designs expensive to iterate on and impossible to preview. `HomeView` builds one of these
// from the store and hands it down; the designs never see TCA at all.

/// One book plus everything a design might want to say about its progress.
///
/// Computed once, here. Two designs that each worked out "pages left" for themselves could
/// disagree, and a screen that contradicts itself is impossible to judge.
nonisolated struct BookProgress: Identifiable, Equatable, Sendable {
    let book: Book
    var status: ShelfStatus
    var pagesRead: Int
    var pagesTotal: Int
    /// When this book was last touched — designs use it to pick "the active one".
    var updatedAt: Date

    var id: String { book.id }

    var pagesLeft: Int { max(0, pagesTotal - pagesRead) }

    /// 0 when the total is unknown, so a missing page count reads as "not started" rather
    /// than dividing by zero.
    var fraction: Double {
        guard pagesTotal > 0 else { return 0 }
        return min(1, Double(pagesRead) / Double(pagesTotal))
    }

    var hasStarted: Bool { pagesRead > 0 }

    /// Reading time left, at a middling 45 pages an hour.
    ///
    /// A real pace lands with the habit engine; until then every design that talks in time
    /// talks through this one number, so they cannot drift apart.
    var minutesLeft: Int { Int((Double(pagesLeft) / 45 * 60).rounded()) }

    /// "4h 20m", or "35m" under an hour.
    var timeLeftLabel: String {
        let minutes = minutesLeft
        guard minutes >= 60 else { return "\(minutes)m" }
        let hours = minutes / 60
        let rest = minutes % 60
        return rest == 0 ? "\(hours)h" : "\(hours)h \(rest)m"
    }

    init(entry: ShelfEntry) {
        book = entry.book
        status = entry.status
        pagesRead = entry.currentPage ?? 0
        pagesTotal = entry.totalPages ?? entry.book.pageCount ?? 0
        updatedAt = entry.dateUpdated
    }
}

/// The whole screen's data, in one value.
nonisolated struct HomeSnapshot: Equatable, Sendable {
    var books: [BookProgress]
    var habit: HabitPlaceholder

    /// The book Home foregrounds: most recently touched of the ones being read.
    var active: BookProgress? {
        books.filter { $0.status == .reading }.max { $0.updatedAt < $1.updatedAt }
    }

    var reading: [BookProgress] { books.filter { $0.status == .reading } }
    var upNext: [BookProgress] { books.filter { $0.status == .planToRead } }
    var setAside: [BookProgress] { books.filter { $0.status == .onHold || $0.status == .dropped } }
    var finished: [BookProgress] { books.filter { $0.status == .completed } }

    /// Still owed: everything unfinished and not abandoned, minus whatever is on top.
    var outstanding: [BookProgress] {
        books.filter { $0.id != active?.id && $0.status != .completed && $0.status != .dropped }
    }

    var isEmpty: Bool { books.isEmpty }

    init(entries: [ShelfEntry], habit: HabitPlaceholder = .sample) {
        books = entries.map(BookProgress.init(entry:))
        self.habit = habit
    }

    /// For `#Preview` and for judging a design against a full library rather than an empty one.
    static let sample = HomeSnapshot(entries: SampleLibrary.entries)
}
