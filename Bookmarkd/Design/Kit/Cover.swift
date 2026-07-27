//
//  Cover.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import Kingfisher
import SwiftUI

/// The one way a book cover gets drawn.
///
/// Kingfisher rather than `AsyncImage`: covers repeat across search, home and shelf, so caching
/// matters, and `CLAUDE.md` makes it the rule. All five designs of the previous round reached
/// for `AsyncImage` independently — one component is what stops that happening a third time.
struct Cover: View {
    let book: Book
    var width: CGFloat
    /// Books are close enough to 2:3 that anything else visibly crops the title off the art.
    var ratio: CGFloat = 1.5
    var cornerRadius: CGFloat = 3
    /// Lifted off the page. Off for flat, editorial designs.
    var isRaised: Bool = true

    @Environment(\.theme) private var theme

    private var height: CGFloat { width * ratio }

    var body: some View {
        KFImage(book.coverURL)
            .resizable()
            .placeholder { _ in placeholder }
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: .black.opacity(isRaised ? 0.26 : 0),
                radius: isRaised ? width * 0.09 : 0,
                x: isRaised ? 2 : 0,
                y: isRaised ? width * 0.05 : 0
            )
    }

    /// A cover that never loaded still has to say which book it is, or a shelf of missing art
    /// becomes a shelf of identical rectangles.
    private var placeholder: some View {
        Rectangle()
            .fill(theme.palette.ink.opacity(0.14))
            .overlay {
                Text(book.title)
                    .font(BookmarkdFont.body(min(11, width * 0.16)))
                    .foregroundStyle(theme.palette.ink.opacity(0.55))
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .padding(4)
            }
    }
}

/// A cover that fills whatever space it is handed, with **no size of its own**.
///
/// `Cover` takes an explicit width, which is right for rows and grids and wrong for a
/// full-bleed hero — asking it for a screen-sized width makes it a screen-sized *child*, and a
/// child wider than its parent drags every sibling off the edge. Use this inside `.background`
/// or a sized container, where it cannot influence layout at all.
struct CoverFill: View {
    let book: Book

    @Environment(\.theme) private var theme

    var body: some View {
        KFImage(book.coverURL)
            .resizable()
            .placeholder { _ in theme.palette.material.opacity(0.5) }
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
    }
}
