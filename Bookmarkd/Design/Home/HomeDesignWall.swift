//
//  HomeDesignWall.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Wall** — every book you own as a small square, four across, no words.
///
/// Tap one and it names itself; until then the screen is pure pattern. Each square is tinted by
/// the book and filled from the bottom by how far in you are, so the wall shows the shape of a
/// whole library at a glance — mostly empty squares means a shelf of good intentions, mostly
/// full ones means a year of finishing things.
///
/// The point is the aggregate. Every other design shows you books one at a time; this one shows
/// you the collection as a single object.
struct HomeDesignWall: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme
    @State private var revealed: String?

    // Three across, not four: at four the squares were small enough that the wall read as
    // texture on the ground rather than as a collection of things.
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 9), count: 3)

    var body: some View {
        DesignCanvas(horizontalMargin: 18) {
            VStack(alignment: .leading, spacing: 16) {
                header

                LazyVGrid(columns: columns, spacing: 7) {
                    ForEach(snapshot.books) { book in
                        square(book)
                    }
                }

                caption
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(snapshot.books.count) books")
                .font(BookmarkdFont.display(26))
                .foregroundStyle(theme.palette.ink)
            Text("\(snapshot.finished.count) finished · \(snapshot.outstanding.count) waiting · \(snapshot.habit.currentStreak) day streak")
                .font(BookmarkdFont.body(12))
                .foregroundStyle(theme.palette.inkMuted)
        }
        .padding(.horizontal, 4)
    }

    private func square(_ book: BookProgress) -> some View {
        Button {
            // First tap names it, second opens it — the pattern is the design, so a title has
            // to be asked for rather than pre-empting it.
            if revealed == book.id {
                onSelect(book.book)
            } else {
                withAnimation(.snappy(duration: 0.2)) { revealed = book.id }
            }
        } label: {
            ZStack(alignment: .bottom) {
                // Deeper than the ground, not lighter. On a caramel ground the pale version of
                // these tints disappeared entirely and the wall read as an empty screen.
                Rectangle().fill(theme.palette.ink.opacity(0.07))

                Rectangle()
                    .fill(book.warmTint)
                    .brightness(-0.06)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .scaleEffect(y: max(0.04, book.fraction), anchor: .bottom)

                if book.status == .completed {
                    // Finished books get a mark rather than a full square, so a wall of
                    // completions is visibly different from a wall of half-read ones.
                    Circle()
                        .fill(theme.palette.mark.opacity(0.75))
                        .frame(width: 8, height: 8)
                        .padding(7)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }

                if revealed == book.id {
                    Text(book.book.title)
                        .font(BookmarkdFont.body(10))
                        .foregroundStyle(theme.palette.ink)
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                        .padding(5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(theme.palette.background.opacity(0.86))
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: theme.shape.cardCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var caption: some View {
        Text(revealed == nil
             ? "Tap a square to see what it is."
             : "Tap again to open it.")
            .font(BookmarkdFont.body(12))
            .foregroundStyle(theme.palette.inkMuted)
            .padding(.horizontal, 4)
            .padding(.top, 2)
    }
}

#Preview {
    HomeDesignWall(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .caramel)
}
