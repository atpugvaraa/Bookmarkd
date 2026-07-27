//
//  HomeDesignTwoUp.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Two Up** — this one and the next one. Nothing else exists.
///
/// Two covers, side by side, large. The book you are in and the book that follows it. No shelf,
/// no counts, no sections, no scroll.
///
/// The reasoning is the same one that makes a reading list unhelpful: someone who does not read
/// is not stalled for lack of options. Showing eleven books is showing eleven things they have
/// not done. Two is a decision; eleven is a guilt trip.
struct HomeDesignTwoUp: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme

    private var now: BookProgress? { snapshot.active }

    /// Whatever is nearest to finished among the rest — the easiest next win.
    private var next: BookProgress? {
        snapshot.outstanding
            .filter { $0.pagesTotal > 0 }
            .max { lhs, rhs in lhs.fraction < rhs.fraction }
    }

    var body: some View {
        DesignCanvas(scrolls: false) {
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                HStack(alignment: .top, spacing: 18) {
                    column(now, label: "Now", isLead: true)
                    column(next, label: "Next", isLead: false)
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 0)

                Text("\(snapshot.habit.minutesToday) of \(snapshot.habit.dailyTargetMinutes) minutes today · \(snapshot.habit.currentStreak) day streak")
                    .font(BookmarkdFont.body(12))
                    .foregroundStyle(theme.palette.inkMuted)
                    .padding(.bottom, 132)
            }
        }
    }

    @ViewBuilder
    private func column(_ book: BookProgress?, label: String, isLead: Bool) -> some View {
        if let book {
            Button { onSelect(book.book) } label: {
                VStack(alignment: .leading, spacing: 12) {
                    Text(label)
                        .font(BookmarkdFont.body(10))
                        .kerning(1.8)
                        .textCase(.uppercase)
                        .foregroundStyle(theme.palette.inkMuted)

                    // The lead book is drawn larger and lifted; the runner-up sits flatter and
                    // lower, so which one is "now" is legible before either title is read.
                    Cover(
                        book: book.book,
                        width: isLead ? 150 : 122,
                        cornerRadius: 4,
                        isRaised: isLead
                    )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(book.book.title)
                            .font(BookmarkdFont.display(isLead ? 17 : 15))
                            .foregroundStyle(theme.palette.ink)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)

                        Text(book.book.authorDisplay)
                            .font(BookmarkdFont.body(11))
                            .foregroundStyle(theme.palette.inkMuted)
                            .lineLimit(1)

                        Text(book.hasStarted
                             ? "page \(book.pagesRead) · \(book.timeLeftLabel) left"
                             : "\(book.pagesTotal) pages")
                            .font(BookmarkdFont.body(11))
                            .foregroundStyle(theme.palette.inkMuted.opacity(0.85))
                            .padding(.top, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, isLead ? 0 : 26)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text(label)
                    .font(BookmarkdFont.body(10))
                    .kerning(1.8)
                    .textCase(.uppercase)
                    .foregroundStyle(theme.palette.inkMuted)
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(theme.palette.ink.opacity(0.16), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .frame(height: (isLead ? 150 : 122) * 1.5)
                Text("Nothing lined up")
                    .font(BookmarkdFont.body(12))
                    .foregroundStyle(theme.palette.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, isLead ? 0 : 26)
        }
    }
}

#Preview {
    HomeDesignTwoUp(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .amber)
}
