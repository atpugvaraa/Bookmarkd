//
//  HomeDesignBands.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Bands** — the library as stripes of colour, edge to edge.
///
/// One full-width band per book, in its own warm tint, title set inside it. No covers, no cards,
/// no margins — the bands touch each other and run off both sides of the screen, so the page
/// reads as a block of colour before it reads as a list.
///
/// Band *height* carries how far in you are: a book you have barely started is a thin stripe, a
/// book you are nearly through is a thick one. Progress becomes the proportion of the screen a
/// book occupies, which is a thing you feel rather than read.
struct HomeDesignBands: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme

    private var books: [BookProgress] {
        let ordered = (snapshot.active.map { [$0] } ?? []) + snapshot.outstanding
        return ordered
    }

    var body: some View {
        DesignCanvas(scrolls: false) {
            ScrollView {
                VStack(spacing: 0) {
                    header

                    ForEach(books) { book in
                        Button { onSelect(book.book) } label: { band(book) }
                            .buttonStyle(.plain)
                    }

                    if !snapshot.finished.isEmpty {
                        finishedStrip
                    }
                }
                .padding(.bottom, 118)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(books.count) open")
                .font(BookmarkdFont.display(26))
                .foregroundStyle(theme.palette.ink)
            Spacer()
            Text("\(snapshot.habit.minutesToday) min today")
                .font(BookmarkdFont.body(12))
                .foregroundStyle(theme.palette.inkMuted)
        }
        .padding(.horizontal, 22)
        .padding(.top, 56)
        .padding(.bottom, 22)
    }

    /// Height is progress: 62pt at nothing read, 132pt at finished.
    private func band(_ book: BookProgress) -> some View {
        Band(tint: book.warmTint, height: 62 + 70 * book.fraction) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(book.book.title)
                        .font(BookmarkdFont.display(17))
                        .lineLimit(1)
                    Text(book.book.authorDisplay)
                        .font(BookmarkdFont.body(11))
                        .opacity(0.65)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Text(book.hasStarted ? "\(Int(book.fraction * 100))%" : "—")
                    .font(BookmarkdFont.body(12))
                    .opacity(0.7)
                    .monospacedDigit()
            }
            .foregroundStyle(theme.palette.ink)
            .padding(.horizontal, 22)
        }
    }

    /// Finished books get one thin band between them all — done is done, and it should not take
    /// up the same room as the things still waiting.
    private var finishedStrip: some View {
        Band(tint: theme.palette.ink.opacity(0.07), height: 46) {
            HStack(spacing: 8) {
                Text("\(snapshot.finished.count) finished")
                    .font(BookmarkdFont.body(12))
                    .foregroundStyle(theme.palette.inkMuted)
                Spacer(minLength: 0)
                ForEach(snapshot.finished.prefix(6)) { book in
                    Circle()
                        .fill(book.warmTint)
                        .frame(width: 9, height: 9)
                }
            }
            .padding(.horizontal, 22)
        }
    }
}

#Preview {
    HomeDesignBands(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .latte)
}
