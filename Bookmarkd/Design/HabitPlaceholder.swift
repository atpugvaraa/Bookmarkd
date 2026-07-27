//
//  HabitPlaceholder.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import Foundation

/// Stand-in for the habit engine, which is not built yet.
///
/// Home is the screen the habit engine lives on, so designing it without a streak, a session
/// button or a completion projection would mean designing a shelf browser and redoing it
/// later. Every habit element in every design reads from *this one value* — when real
/// `ReadingSession` data lands, it is a data swap in one file rather than a redesign.
nonisolated struct HabitPlaceholder: Equatable, Sendable {
    struct Day: Equatable, Sendable, Identifiable {
        let id: Int
        var date: Date
        var minutes: Int
        var endPage: Int?
        /// Books read on this day, for the log-style designs.
        var bookTitle: String?
    }

    var currentStreak: Int
    var minutesToday: Int
    var dailyTargetMinutes: Int
    /// At the current pace, days left in the active book.
    var daysToFinishAtCurrentPace: Int
    /// Days left if the daily target were met every day — the encouragement line.
    var daysToFinishAtTarget: Int
    var recentDays: [Day]

    var metTargetToday: Bool { minutesToday >= dailyTargetMinutes }

    var progressTowardTarget: Double {
        guard dailyTargetMinutes > 0 else { return 0 }
        return min(1, Double(minutesToday) / Double(dailyTargetMinutes))
    }

    static let sample: HabitPlaceholder = {
        let reference = Date(timeIntervalSince1970: 1_785_000_000)
        // The first six days must all be non-zero, because `currentStreak` says six. The Stamp
        // Card draws one square per day and a card showing eight stamps under the words "6 in a
        // row" makes the design impossible to judge — the eye goes to the contradiction.
        let minutes = [22, 30, 35, 18, 25, 41, 0, 12, 30, 27, 19, 33, 24, 16]
        // Kept consistent with `SampleLibrary.activeEntry` — Atomic Habits at page 210.
        // A log that disagrees with the book pinned above it makes a design impossible to
        // judge, because the eye goes to the contradiction rather than the layout.
        let titles = [
            "Atomic Habits", "Atomic Habits", "Atomic Habits", "Normal People", "Atomic Habits",
            "The Palace of Illusions", nil, "Atomic Habits", "Atomic Habits", "Atomic Habits",
            "Normal People", "The Palace of Illusions", "Atomic Habits", "Atomic Habits",
        ]
        var page = 210
        let days: [Day] = minutes.indices.map { index in
            let readMinutes = minutes[index]
            let endPage: Int? = readMinutes > 0 ? page : nil
            if readMinutes > 0 { page -= max(4, readMinutes / 2) }
            return Day(
                id: index,
                date: reference.addingTimeInterval(-Double(index) * 86_400),
                minutes: readMinutes,
                endPage: endPage,
                bookTitle: titles[index]
            )
        }

        return HabitPlaceholder(
            currentStreak: 6,
            minutesToday: 22,
            dailyTargetMinutes: 20,
            daysToFinishAtCurrentPace: 14,
            daysToFinishAtTarget: 5,
            recentDays: days
        )
    }()
}
