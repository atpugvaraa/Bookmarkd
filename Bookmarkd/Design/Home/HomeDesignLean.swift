//
//  HomeDesignLean.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Lean** — nothing on this screen is square to the edges.
///
/// The cover, the baseline of the type and the row of other books all sit on the same slight
/// diagonal. Twenty-five designs have been built on a strict horizontal grid; a consistent
/// few degrees of rotation changes the character of a screen more than any amount of colour
/// does, and it is the one compositional move never tried.
///
/// The discipline that keeps it from looking broken: **one angle, used everywhere.** Elements
/// tilted at different amounts read as a bug; elements sharing an axis read as a decision.
struct HomeDesignLean: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme

    /// The single angle the whole screen is built on.
    ///
    /// Started at 4°, which read as a rendering mistake rather than as a decision — too small
    /// to look deliberate, too large to look straight. 8° is unmistakably on purpose.
    private let angle: Double = -8

    var body: some View {
        DesignCanvas(scrolls: false) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 0)

                if let book = snapshot.active {
                    hero(book)
                } else {
                    empty
                }

                Spacer(minLength: 0)

                strip
            }
            .padding(.bottom, 120)
        }
    }

    private func hero(_ book: BookProgress) -> some View {
        Button { onSelect(book.book) } label: {
            HStack(alignment: .bottom, spacing: 20) {
                Cover(book: book.book, width: 132, cornerRadius: 4)

                VStack(alignment: .leading, spacing: 5) {
                    Text(book.book.title)
                        .font(BookmarkdFont.display(22))
                        .foregroundStyle(theme.palette.ink)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    Text(book.book.authorDisplay)
                        .font(BookmarkdFont.body(12))
                        .foregroundStyle(theme.palette.inkMuted)
                        .lineLimit(1)

                    Text("page \(book.pagesRead) · \(book.timeLeftLabel) left")
                        .font(BookmarkdFont.body(12))
                        .foregroundStyle(theme.palette.inkMuted)
                        .padding(.top, 3)
                }
                .padding(.bottom, 6)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 26)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .rotationEffect(.degrees(angle))
    }

    /// The rest of the shelf, running off both edges on the same axis. Deliberately wider than
    /// the screen so the row reads as continuing rather than as a bounded list.
    private var strip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(snapshot.outstanding) { book in
                    Button { onSelect(book.book) } label: {
                        // No titles here — at 64pt wide every one truncated to three letters
                        // and an ellipsis, which is noise rather than information.
                        Cover(book: book.book, width: 64, cornerRadius: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 18)
        }
        .rotationEffect(.degrees(angle))
        // Rotation pulls the corners inside the screen; a little overscale hides the wedges of
        // empty ground it would otherwise leave at both ends.
        .scaleEffect(1.08)
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nothing open")
                .font(BookmarkdFont.display(26))
                .foregroundStyle(theme.palette.ink)
            Text("Pick something and it leans here.")
                .font(BookmarkdFont.body(14))
                .foregroundStyle(theme.palette.inkMuted)
        }
        .padding(.horizontal, 26)
        .rotationEffect(.degrees(angle))
    }
}

#Preview {
    HomeDesignLean(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .cortado)
}
