//
//  HomeDesignEpigraph.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Epigraph** — the writing, not the metadata.
///
/// Every design so far has shown facts *about* books: titles, page counts, percentages. This one
/// gives the screen to a line from the book itself, set large, with the book credited beneath it
/// the way an epigraph is credited at the front of a chapter.
///
/// The argument: nothing on a page count makes you want to read. A sentence does. For someone
/// who does not read yet, the most persuasive thing the app owns is the prose.
struct HomeDesignEpigraph: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme

    /// Books with something worth setting, the one in progress first.
    private var quotable: [BookProgress] {
        let ordered = (snapshot.active.map { [$0] } ?? []) + snapshot.outstanding
        return ordered.filter { $0.blurb != nil }
    }

    var body: some View {
        DesignCanvas(horizontalMargin: 28) {
            VStack(alignment: .leading, spacing: 46) {
                ForEach(Array(quotable.enumerated()), id: \.element.id) { index, book in
                    Button { onSelect(book.book) } label: { entry(book, isLead: index == 0) }
                        .buttonStyle(.plain)

                    if index < quotable.count - 1 {
                        Hairline(opacity: 0.14)
                    }
                }
            }
        }
    }

    private func entry(_ book: BookProgress, isLead: Bool) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Excerpt(text: book.blurb ?? "", size: isLead ? 27 : 20)

            HStack(spacing: 12) {
                Cover(book: book.book, width: isLead ? 40 : 30, cornerRadius: 3, isRaised: false)

                VStack(alignment: .leading, spacing: 2) {
                    Text(book.book.title)
                        .font(BookmarkdFont.body(13))
                        .foregroundStyle(theme.palette.ink)
                        .lineLimit(1)
                    Text(book.book.authorDisplay)
                        .font(BookmarkdFont.body(11))
                        .foregroundStyle(theme.palette.inkMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                if isLead, book.hasStarted {
                    Text("p. \(book.pagesRead)")
                        .font(BookmarkdFont.body(11))
                        .foregroundStyle(theme.palette.inkMuted)
                }
            }
            // The credit sits below and quieter, the way it does under an epigraph.
            .padding(.leading, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

#Preview {
    HomeDesignEpigraph(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .latte)
}
