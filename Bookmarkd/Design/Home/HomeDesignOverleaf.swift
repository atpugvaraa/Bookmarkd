//
//  HomeDesignOverleaf.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Overleaf** — the cover fills the screen and the page slides up over it.
///
/// The artwork sits fixed behind, parallaxing slowly; everything else rides on a sheet that
/// starts two-thirds down and travels over it as you scroll. Depth is the whole idea — two
/// planes moving at different speeds, which no other design in the set has.
///
/// The cover is never scrimmed or blurred into wallpaper: it stays the picture, and the sheet
/// covers it rather than dimming it.
struct HomeDesignOverleaf: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        DesignCanvas(scrolls: false) {
            if let book = snapshot.active {
                ZStack(alignment: .top) {
                    backdrop(book)
                    sheet(book)
                }
            } else {
                empty
            }
        }
    }

    /// Fixed behind everything, drifting at half speed.
    private func backdrop(_ book: BookProgress) -> some View {
        // Starts below the status bar rather than under it. A scrim strong enough to keep the
        // clock legible over a pale jacket also greys out the top third of the artwork, and the
        // artwork is the reason this design exists.
        GeometryReader { proxy in
            CoverFill(book: book.book)
                .frame(height: proxy.size.height * 0.72)
                .clipped()
        }
    }

    private func sheet(_ book: BookProgress) -> some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    // The window onto the artwork. Scrolling pulls the sheet up over it.
                    Color.clear
                        .frame(height: proxy.size.height * 0.52)

                    VStack(alignment: .leading, spacing: 22) {
                        Capsule()
                            .fill(theme.palette.ink.opacity(0.16))
                            .frame(width: 36, height: 4)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)

                        Button { onSelect(book.book) } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(book.book.title)
                                    .font(BookmarkdFont.display(28))
                                    .foregroundStyle(theme.palette.ink)
                                    .lineLimit(3)
                                Text(book.book.authorDisplay)
                                    .font(BookmarkdFont.body(14))
                                    .foregroundStyle(theme.palette.inkMuted)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if let blurb = book.blurb {
                            Excerpt(text: blurb, size: 17, lineLimit: 4)
                                .opacity(0.85)
                        }

                        progress(book)

                        rest
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 128)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 26,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 26,
                            style: .continuous
                        )
                        .fill(theme.palette.background)
                        .shadow(color: .black.opacity(0.2), radius: 22, y: -8)
                        .ignoresSafeArea(edges: .bottom)
                    )
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func progress(_ book: BookProgress) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(theme.palette.ink.opacity(0.12))
                    Capsule()
                        .fill(theme.palette.accent)
                        .frame(width: max(4, proxy.size.width * book.fraction))
                }
            }
            .frame(height: 5)

            HStack {
                Text("page \(book.pagesRead) of \(book.pagesTotal)")
                Spacer()
                Text("\(book.timeLeftLabel) left")
            }
            .font(BookmarkdFont.body(12))
            .foregroundStyle(theme.palette.inkMuted)
        }
    }

    private var rest: some View {
        let others = snapshot.outstanding
        return Group {
            if !others.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Hairline(opacity: 0.12)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 11) {
                            ForEach(others) { book in
                                Button { onSelect(book.book) } label: {
                                    Cover(book: book.book, width: 56, cornerRadius: 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nothing open")
                .font(BookmarkdFont.display(28))
                .foregroundStyle(theme.palette.ink)
            Text("Start a book and it fills this screen.")
                .font(BookmarkdFont.body(14))
                .foregroundStyle(theme.palette.inkMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 30)
    }
}

#Preview {
    HomeDesignOverleaf(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .amber)
}
