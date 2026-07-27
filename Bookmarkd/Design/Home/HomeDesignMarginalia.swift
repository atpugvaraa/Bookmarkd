//
//  HomeDesignMarginalia.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Marginalia** — your handwriting, not the app's.
///
/// The content here is what *you* wrote: notes and page numbers you left behind, with the book
/// as the smaller context beside them. A narrow left column carries the page numbers the way a
/// margin does; the notes hang in the wider column beside it.
///
/// This is the only design where the app is a record of your thinking rather than a report on
/// your behaviour. It also gives Home something no other screen has — a reason to come back
/// when you are *not* about to read.
struct HomeDesignMarginalia: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme

    private let marginWidth: CGFloat = 46

    private var annotated: [BookProgress] {
        let ordered = (snapshot.active.map { [$0] } ?? []) + snapshot.outstanding
        return ordered.filter { !$0.notes.isEmpty }
    }

    var body: some View {
        DesignCanvas(horizontalMargin: 20) {
            VStack(alignment: .leading, spacing: 34) {
                header

                if annotated.isEmpty {
                    empty
                } else {
                    ForEach(annotated) { book in
                        entry(book)
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("What you've written")
                .font(BookmarkdFont.display(24))
                .foregroundStyle(theme.palette.ink)
            Text("\(annotated.reduce(0) { $0 + $1.notes.count }) notes across \(annotated.count) books")
                .font(BookmarkdFont.body(12))
                .foregroundStyle(theme.palette.inkMuted)
        }
        .padding(.leading, marginWidth)
    }

    private func entry(_ book: BookProgress) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { onSelect(book.book) } label: {
                HStack(spacing: 12) {
                    Color.clear.frame(width: marginWidth - 12, height: 1)
                    Cover(book: book.book, width: 26, cornerRadius: 2, isRaised: false)
                    Text(book.book.title)
                        .font(BookmarkdFont.display(15))
                        .foregroundStyle(theme.palette.ink)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.bottom, 12)

            ForEach(book.notes, id: \.page) { note in
                HStack(alignment: .top, spacing: 12) {
                    // The margin: page numbers in their own narrow column, right-aligned
                    // against the text the way they sit on a real page.
                    Text("\(note.page)")
                        .font(BookmarkdFont.body(11))
                        .foregroundStyle(theme.palette.inkMuted)
                        .frame(width: marginWidth - 12, alignment: .trailing)
                        .padding(.top, 3)

                    Text(note.text)
                        .font(BookmarkdFont.body(15))
                        .foregroundStyle(theme.palette.ink.opacity(0.88))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 9)

                if note.page != book.notes.last?.page {
                    Hairline(opacity: 0.08)
                        .padding(.leading, marginWidth)
                }
            }
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nothing written down yet")
                .font(BookmarkdFont.display(20))
                .foregroundStyle(theme.palette.ink)
            Text("Notes you leave while reading collect here.")
                .font(BookmarkdFont.body(14))
                .foregroundStyle(theme.palette.inkMuted)
        }
        .padding(.leading, marginWidth)
    }
}

#Preview {
    HomeDesignMarginalia(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .cortado)
}
