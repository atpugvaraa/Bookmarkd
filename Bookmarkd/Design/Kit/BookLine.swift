//
//  BookLine.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// One book as a single row.
///
/// Four of the ten rejected designs each wrote their own version of this and they drifted apart
/// — different type sizes, different progress maths, one of them silently unreadable. It lives
/// here once so a design chooses a *variant* rather than reinventing the row.
struct BookLine: View {
    enum Trailing: Equatable {
        /// `210/322`, for the designs that talk in pages.
        case pages
        /// `4h 20m`, for the designs that talk in time.
        case timeLeft
        /// A short hairline whose fill is the progress. No numbers.
        case rule
        case none
    }

    let book: BookProgress
    var trailing: Trailing = .pages
    /// Cover width, or `nil` for a text-only row.
    var coverWidth: CGFloat?
    var titleSize: CGFloat = 15
    var showsAuthor: Bool = true

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: 11) {
            if let coverWidth {
                Cover(book: book.book, width: coverWidth, isRaised: false)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(book.book.title)
                    .font(BookmarkdFont.display(titleSize))
                    .lineLimit(1)
                if showsAuthor {
                    Text(book.book.authorDisplay)
                        .font(BookmarkdFont.body(titleSize * 0.74))
                        .foregroundStyle(theme.palette.inkMuted)
                        .lineLimit(1)
                }
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            trailingView
        }
        .foregroundStyle(theme.palette.ink)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var trailingView: some View {
        switch trailing {
        case .pages:
            // A book with no pages logged says so, rather than claiming page zero.
            Text(book.pagesTotal > 0 && book.hasStarted
                 ? "\(book.pagesRead)/\(book.pagesTotal)"
                 : "—")
                .font(BookmarkdFont.body(12))
                .foregroundStyle(theme.palette.inkMuted)
                .monospacedDigit()

        case .timeLeft:
            Text(book.pagesTotal > 0 ? book.timeLeftLabel : "—")
                .font(BookmarkdFont.body(12))
                .foregroundStyle(theme.palette.inkMuted)
                .monospacedDigit()

        case .rule:
            ZStack(alignment: .leading) {
                Capsule().fill(theme.palette.ink.opacity(0.14))
                Capsule()
                    .fill(theme.palette.ink.opacity(0.55))
                    .frame(width: max(0, 44 * book.fraction))
            }
            .frame(width: 44, height: 2)

        case .none:
            EmptyView()
        }
    }
}
