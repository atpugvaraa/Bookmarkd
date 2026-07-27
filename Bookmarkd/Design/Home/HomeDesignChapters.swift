//
//  HomeDesignChapters.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Chapters** — the library sorted by how close each book is to being done.
///
/// Not by status, not by date added, not alphabetically. "One sitting left", "halfway", "just
/// started", "not opened" — because the habit being built is *finishing things*, and a shelf
/// ordered by how much is left tells you where the next win is.
///
/// Every other design has organised the library by what the app knows. This one organises it by
/// what would actually help.
struct HomeDesignChapters: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme

    private struct Group: Identifiable {
        let id: String
        let title: String
        let note: String
        let books: [BookProgress]
    }

    /// The order is the argument: closest to done at the top.
    private var groups: [Group] {
        let live = snapshot.books.filter { $0.status != .completed && $0.status != .dropped }
        func bucket(_ range: Range<Double>) -> [BookProgress] {
            live.filter { $0.pagesTotal > 0 && range.contains($0.fraction) }
                .sorted { $0.fraction > $1.fraction }
        }
        return [
            Group(id: "close", title: "One sitting left",
                  note: "under an hour each", books: bucket(0.75..<1.01)),
            Group(id: "half", title: "Past halfway",
                  note: "the hard part is behind you", books: bucket(0.4..<0.75)),
            Group(id: "started", title: "Just started",
                  note: "keep the thread", books: bucket(0.01..<0.4)),
            Group(id: "new", title: "Not opened",
                  note: "no pressure", books: bucket(0..<0.01)),
        ].filter { !$0.books.isEmpty }
    }

    var body: some View {
        DesignCanvas(horizontalMargin: 18) {
            VStack(alignment: .leading, spacing: 18) {
                header

                ForEach(groups) { group in
                    section(group)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Closest first")
                .font(BookmarkdFont.display(26))
                .foregroundStyle(theme.palette.ink)
            Text("\(snapshot.habit.currentStreak) day streak · \(snapshot.finished.count) finished")
                .font(BookmarkdFont.body(12))
                .foregroundStyle(theme.palette.inkMuted)
        }
        .padding(.horizontal, 6)
    }

    private func section(_ group: Group) -> some View {
        SoftCard(padding: 16) {
            VStack(alignment: .leading, spacing: 13) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(group.title)
                        .font(BookmarkdFont.display(17))
                        .foregroundStyle(theme.palette.ink)
                    Text(group.note)
                        .font(BookmarkdFont.body(11))
                        .foregroundStyle(theme.palette.inkMuted)
                    Spacer(minLength: 0)
                    Text("\(group.books.count)")
                        .font(BookmarkdFont.body(11))
                        .foregroundStyle(theme.palette.inkMuted)
                }

                ForEach(group.books) { book in
                    Button { onSelect(book.book) } label: { row(book) }
                        .buttonStyle(.plain)
                }
            }
        }
    }

    private func row(_ book: BookProgress) -> some View {
        HStack(spacing: 11) {
            Cover(book: book.book, width: 30, cornerRadius: 3, isRaised: false)

            VStack(alignment: .leading, spacing: 1) {
                Text(book.book.title)
                    .font(BookmarkdFont.body(14))
                    .foregroundStyle(theme.palette.ink)
                    .lineLimit(1)
                Text(book.book.authorDisplay)
                    .font(BookmarkdFont.body(10))
                    .foregroundStyle(theme.palette.inkMuted)
                    .lineLimit(1)
            }

            Spacer(minLength: 6)

            // What is *left*, not what is done — the whole point of the ordering.
            Text(book.pagesLeft > 0 ? "\(book.pagesLeft) to go" : "done")
                .font(BookmarkdFont.body(11))
                .foregroundStyle(theme.palette.inkMuted)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    HomeDesignChapters(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .amber)
}
