//
//  HomeDesignHalves.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Halves** — one hard line across the middle of the screen.
///
/// Cover above, edge to edge and uncropped at the top. A solid block of colour below carrying
/// everything else. No rounded corners, no shadow, no gap: the two halves meet at a single
/// straight edge and that edge is the entire composition.
///
/// It is the flattest, hardest-edged thing in the set — deliberately, because every other design
/// this round is soft or rounded, and a set where everything is gentle has no contrast in it.
struct HomeDesignHalves: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        DesignCanvas(scrolls: false) {
            if let book = snapshot.active {
                // Deliberately *not* ignoring the top safe area. Running the jacket under the
                // status bar put the book's own cover type directly behind the clock, and no
                // scrim fixes that on a pale jacket without dirtying the artwork. Bleeding to
                // both sides and the bottom is what makes this read as full-bleed anyway.
                VStack(spacing: 0) {
                    top(book)
                    bottom(book)
                }
            } else {
                empty
            }
        }
    }

    /// The upper half: artwork, uncropped, filling the width.
    private func top(_ book: BookProgress) -> some View {
        Button { onSelect(book.book) } label: {
            CoverFill(book: book.book)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .clipped()
        }
        .buttonStyle(.plain)
    }

    /// The lower half: one flat block, everything left-aligned against the same margin.
    private func bottom(_ book: BookProgress) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(book.book.title)
                    .font(BookmarkdFont.display(26))
                    .foregroundStyle(theme.palette.onAccent)
                    .lineLimit(2)

                Text(book.book.authorDisplay)
                    .font(BookmarkdFont.body(13))
                    .foregroundStyle(theme.palette.onAccent.opacity(0.72))
                    .lineLimit(1)
            }
            .padding(.top, 26)

            Spacer(minLength: 14)

            // Progress as a single hard rule spanning the block, flush to the margins.
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Rectangle().fill(theme.palette.onAccent.opacity(0.24))
                    Rectangle()
                        .fill(theme.palette.onAccent)
                        .frame(width: proxy.size.width * book.fraction)
                }
            }
            .frame(height: 3)

            HStack(alignment: .firstTextBaseline) {
                Text("\(book.pagesRead) / \(book.pagesTotal)")
                    .font(BookmarkdFont.body(12))
                    .monospacedDigit()
                Spacer()
                Text("\(snapshot.habit.minutesToday) min today · \(snapshot.habit.currentStreak) day streak")
                    .font(BookmarkdFont.body(12))
            }
            .foregroundStyle(theme.palette.onAccent.opacity(0.72))
            .padding(.top, 10)
            .padding(.bottom, 118)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.palette.accent)
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nothing open")
                .font(BookmarkdFont.display(26))
                .foregroundStyle(theme.palette.ink)
            Text("Start a book and it takes the top half.")
                .font(BookmarkdFont.body(14))
                .foregroundStyle(theme.palette.inkMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 26)
    }
}

#Preview {
    HomeDesignHalves(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .honey)
}
