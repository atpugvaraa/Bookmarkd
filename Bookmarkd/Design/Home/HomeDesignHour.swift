//
//  HomeDesignHour.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Hour** — the screen changes with the clock.
///
/// A morning that offers you ten minutes with coffee is a different proposition from an evening
/// that offers you thirty before bed. The suggestion, the wording and the warmth of the light
/// all move through the day; a dial around the suggested length is the only shape on screen.
///
/// Every other design is the same at 7am and 11pm. This one argues that a habit lives at a time
/// of day, not on a shelf — which is the actual finding behind the book the sample library is
/// built around.
struct HomeDesignHour: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme

    /// Driven by the real clock so it changes through the day on a device. `-designHour 21`
    /// pins it for screenshots, since a screenshot taken at 10am cannot show the evening.
    private var hour: Int {
        if let index = ProcessInfo.processInfo.arguments.firstIndex(of: "-designHour"),
           index + 1 < ProcessInfo.processInfo.arguments.count,
           let forced = Int(ProcessInfo.processInfo.arguments[index + 1]) {
            return forced
        }
        return Calendar.current.component(.hour, from: Date())
    }

    private struct Slot {
        let greeting: String
        let pitch: String
        let minutes: Int
        let warmth: Double
    }

    private var slot: Slot {
        switch hour {
        case 5..<11:
            Slot(greeting: "Morning", pitch: "Ten minutes with the coffee.", minutes: 10, warmth: 0.16)
        case 11..<15:
            Slot(greeting: "Midday", pitch: "A quarter of an hour is a chapter.", minutes: 15, warmth: 0.1)
        case 15..<19:
            Slot(greeting: "Afternoon", pitch: "Twenty minutes before the day closes.", minutes: 20, warmth: 0.2)
        case 19..<23:
            Slot(greeting: "Evening", pitch: "Thirty minutes, nothing else to do.", minutes: 30, warmth: 0.34)
        default:
            Slot(greeting: "Late", pitch: "Ten minutes, then sleep.", minutes: 10, warmth: 0.42)
        }
    }

    var body: some View {
        DesignCanvas(scrolls: false) {
            ZStack {
                // The light shifts with the hour: cooler at midday, deeper towards the evening.
                RadialGradient(
                    colors: [
                        theme.palette.material.opacity(slot.warmth),
                        theme.palette.background.opacity(0),
                    ],
                    center: .init(x: 0.5, y: 0.36),
                    startRadius: 20,
                    endRadius: 420
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    dial
                    words.padding(.top, 34)
                    Spacer(minLength: 0)
                    if let book = snapshot.active { footer(book) }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 126)
            }
        }
    }

    /// A ring carrying the suggested length, with today's progress drawn round it.
    private var dial: some View {
        let done = min(1, Double(snapshot.habit.minutesToday) / Double(max(1, slot.minutes)))

        return ZStack {
            Circle()
                .stroke(theme.palette.ink.opacity(0.1), lineWidth: 8)

            Circle()
                .trim(from: 0, to: done)
                .stroke(
                    done >= 1 ? theme.palette.mark : theme.palette.accent,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: -2) {
                Text("\(slot.minutes)")
                    .font(BookmarkdFont.display(58))
                    .foregroundStyle(theme.palette.ink)
                Text("minutes")
                    .font(BookmarkdFont.body(13))
                    .foregroundStyle(theme.palette.inkMuted)
            }
        }
        .frame(width: 194, height: 194)
    }

    private var words: some View {
        VStack(spacing: 7) {
            Text(slot.greeting)
                .font(BookmarkdFont.display(25))
                .foregroundStyle(theme.palette.ink)

            Text(slot.pitch)
                .font(BookmarkdFont.body(15))
                .foregroundStyle(theme.palette.inkMuted)
                .multilineTextAlignment(.center)
        }
    }

    private func footer(_ book: BookProgress) -> some View {
        Button { onSelect(book.book) } label: {
            HStack(spacing: 12) {
                Cover(book: book.book, width: 34, cornerRadius: 4)
                VStack(alignment: .leading, spacing: 1) {
                    Text(book.book.title)
                        .font(BookmarkdFont.body(14))
                        .foregroundStyle(theme.palette.ink)
                        .lineLimit(1)
                    Text("page \(book.pagesRead)")
                        .font(BookmarkdFont.body(11))
                        .foregroundStyle(theme.palette.inkMuted)
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .background(
                Capsule().fill(theme.palette.surface.opacity(0.8))
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeDesignHour(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .amber)
}
