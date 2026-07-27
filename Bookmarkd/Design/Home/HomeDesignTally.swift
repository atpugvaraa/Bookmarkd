//
//  HomeDesignTally.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Tally** — the streak, and almost nothing else.
///
/// One enormous figure, centred, with the fortnight beneath it as small marks and the book named
/// in a single line at the foot. The only design in the set built around a number.
///
/// Centred composition on purpose: everything in twenty-five designs has been left-aligned, and
/// axial symmetry reads completely differently at a glance — closer to a clock face than a page.
/// Missed days are gaps, never crossings-out.
struct HomeDesignTally: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        DesignCanvas(scrolls: false) {
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                figure
                marks
                    .padding(.top, 40)

                Spacer(minLength: 0)

                if let book = snapshot.active {
                    footer(book)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 124)
        }
    }

    private var figure: some View {
        VStack(spacing: 2) {
            Text("\(snapshot.habit.currentStreak)")
                .font(BookmarkdFont.display(112))
                .foregroundStyle(theme.palette.ink)
                .monospacedDigit()

            Text("days in a row")
                .font(BookmarkdFont.body(15))
                .foregroundStyle(theme.palette.inkMuted)

            Text(encouragement)
                .font(BookmarkdFont.body(13))
                .foregroundStyle(theme.palette.inkMuted.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
    }

    /// No loss-framing, ever. A day under target is quieter, not scolded — the spec makes the
    /// back-off a product principle precisely because punishing streaks are why people quit.
    private var encouragement: String {
        let habit = snapshot.habit
        if habit.metTargetToday {
            return "Today's counted. \(habit.minutesToday) minutes."
        }
        let short = habit.dailyTargetMinutes - habit.minutesToday
        return "\(short) more minutes counts today. Or don't — it keeps."
    }

    /// The fortnight as marks. Present days are filled, today is marked, missed days are simply
    /// absent rather than crossed out.
    private var marks: some View {
        HStack(spacing: 7) {
            ForEach(Array(snapshot.habit.recentDays.prefix(14).reversed().enumerated()), id: \.element.id) { index, day in
                let isToday = index == 13
                Capsule()
                    .fill(
                        day.minutes == 0
                            ? theme.palette.ink.opacity(0.1)
                            : (isToday ? theme.palette.mark : theme.palette.ink.opacity(0.42))
                    )
                    .frame(width: 5, height: day.minutes == 0 ? 14 : 30)
            }
        }
        .frame(height: 30)
    }

    private func footer(_ book: BookProgress) -> some View {
        Button { onSelect(book.book) } label: {
            VStack(spacing: 4) {
                Hairline(opacity: 0.12)
                    .frame(width: 34)
                    .padding(.bottom, 14)

                Text(book.book.title)
                    .font(BookmarkdFont.display(16))
                    .foregroundStyle(theme.palette.ink)
                    .lineLimit(1)

                Text("page \(book.pagesRead) of \(book.pagesTotal)")
                    .font(BookmarkdFont.body(12))
                    .foregroundStyle(theme.palette.inkMuted)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeDesignTally(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .honey)
}
