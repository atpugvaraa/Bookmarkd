//
//  HomeDesignPlan.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Tonight's Plan** — one causal chain, read left to right.
///
/// `20 minutes → page 230 → done Friday`. The three numbers the habit engine produces, laid out
/// as a sequence where each one causes the next, rather than as three separate figures in three
/// separate boxes.
///
/// This is the spec's projection copy taken literally — *"finish in 2 weeks on your pace? or if
/// you read so and so minutes everyday … finish it in 5 days"* — and the argument is that the
/// causal link is the persuasive part. Three stats in a row state facts; a chain makes a case.
struct HomeDesignPlan: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        DesignCanvas(horizontalMargin: 22) {
            VStack(alignment: .leading, spacing: 30) {
                if let book = snapshot.active {
                    chain(book)
                    comparison(book)
                    others
                } else {
                    empty
                }
            }
        }
    }

    // MARK: - The chain

    private func chain(_ book: BookProgress) -> some View {
        let target = snapshot.habit.dailyTargetMinutes
        let landing = min(book.pagesTotal, book.pagesRead + max(1, Int(Double(target) * 45 / 60)))

        return VStack(alignment: .leading, spacing: 0) {
            Text("Tonight")
                .font(BookmarkdFont.body(10))
                .kerning(1.8)
                .textCase(.uppercase)
                .foregroundStyle(theme.palette.inkMuted)
                .padding(.bottom, 16)

            link(value: "\(target) min", note: "of reading")
            connector
            link(value: "page \(landing)", note: "you'd reach")
            connector
            link(value: dayName(offsetDays: snapshot.habit.daysToFinishAtTarget), note: "you'd finish", isEnd: true)
        }
    }

    /// One step in the chain. Sharp-edged and flat on purpose — this design's whole shape
    /// language is the line, not the container.
    private func link(value: String, note: String, isEnd: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(value)
                .font(BookmarkdFont.display(isEnd ? 34 : 30))
                .foregroundStyle(isEnd ? theme.palette.mark : theme.palette.ink)

            Text(note)
                .font(BookmarkdFont.body(13))
                .foregroundStyle(theme.palette.inkMuted)

            Spacer(minLength: 0)
        }
    }

    /// The rule that carries the eye from one link to the next.
    private var connector: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(theme.palette.ink.opacity(0.28))
                .frame(width: 1, height: 26)
                .padding(.leading, 6)
            Spacer()
        }
    }

    // MARK: - The alternative

    /// What happens if you don't. Stated flatly, without a scold — the point of the design is
    /// the contrast between the two paces, not a warning about one of them.
    private func comparison(_ book: BookProgress) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Hairline(opacity: 0.14)
                .padding(.bottom, 9)

            Text("At the pace you've actually kept, \(book.book.title) takes \(snapshot.habit.daysToFinishAtCurrentPace) days.")
                .font(BookmarkdFont.body(14))
                .foregroundStyle(theme.palette.ink.opacity(0.85))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            Button { onSelect(book.book) } label: {
                HStack(spacing: 9) {
                    Cover(book: book.book, width: 26, cornerRadius: 2, isRaised: false)
                    Text("page \(book.pagesRead) of \(book.pagesTotal)")
                        .font(BookmarkdFont.body(12))
                        .foregroundStyle(theme.palette.inkMuted)
                    Spacer(minLength: 0)
                }
                .padding(.top, 5)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var others: some View {
        let rest = snapshot.outstanding
        return Group {
            if !rest.isEmpty {
                VStack(alignment: .leading, spacing: 9) {
                    Hairline(opacity: 0.14)
                        .padding(.bottom, 4)

                    ForEach(rest) { book in
                        Button { onSelect(book.book) } label: {
                            HStack(spacing: 8) {
                                Text(book.book.title)
                                    .font(BookmarkdFont.body(13))
                                    .foregroundStyle(theme.palette.ink.opacity(0.8))
                                    .lineLimit(1)
                                Spacer(minLength: 6)
                                Text(book.pagesTotal > 0 ? "\(book.timeLeftLabel)" : "—")
                                    .font(BookmarkdFont.body(11))
                                    .foregroundStyle(theme.palette.inkMuted)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No plan yet")
                .font(BookmarkdFont.display(30))
                .foregroundStyle(theme.palette.ink)
            Text("Start a book and the chain has somewhere to point.")
                .font(BookmarkdFont.body(14))
                .foregroundStyle(theme.palette.inkMuted)
        }
    }

    /// Fixed reference date so the projection reads identically in every screenshot; the real
    /// clock arrives with the habit engine.
    private func dayName(offsetDays: Int) -> String {
        Date(timeIntervalSince1970: 1_785_000_000)
            .addingTimeInterval(Double(offsetDays) * 86_400)
            .formatted(.dateTime.weekday(.wide))
    }
}

#Preview {
    HomeDesignPlan(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .amber)
}
