//
//  HomeDesignLamp.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Lamp** — warmth from light rather than from layout.
///
/// A pool of warm light falls from above onto a deeper caramel ground. What is inside the pool
/// is the book you are reading; what is outside it fades into the ground and is quieter for it.
///
/// This is the only design in the set that is not built from blocks of colour or arrangements of
/// type — the composition *is* the falloff. A café is cozy because of how it is lit, not because
/// of how its furniture is arranged, and none of twenty-five designs has tried that.
///
/// It also needs the deepest ground in the family: light only reads as light if there is
/// somewhere darker for it to fall away to.
struct HomeDesignLamp: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        DesignCanvas(scrolls: false) {
            ZStack {
                glow

                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    if let book = snapshot.active {
                        lit(book)
                    } else {
                        empty
                    }

                    Spacer(minLength: 0)

                    shadowed
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 122)
            }
        }
    }

    /// The light itself: an ellipse of warm cream falling from above the top edge, blurred wide
    /// so the edge of the pool is never a visible boundary.
    private var glow: some View {
        // A plain radial gradient filling the whole screen. Two earlier attempts drew a sized,
        // blurred, offset `Ellipse` and both rendered as flat ground: a shape given an explicit
        // frame and then re-framed by its parent has nowhere to put its overflow, so the light
        // vanished. A gradient has no size of its own and therefore cannot fail to fill.
        RadialGradient(
            // Explicit stops, not an even spread. Evenly spaced colours put the bright core
            // inside the first ~100pt — entirely behind the cover — so the visible screen was
            // all outer falloff and the light never read. The core is now held out to 0.42,
            // and the outer stop goes *deeper than the ground* so there is a real vignette for
            // the pool to fall away into.
            stops: [
                .init(color: Color(hex: 0xFFFAF0), location: 0),
                .init(color: Color(hex: 0xFDF2DD), location: 0.42),
                .init(color: Color(hex: 0xE9D3AC), location: 0.72),
                .init(color: Color(hex: 0xC0A377), location: 1),
            ],
            center: UnitPoint(x: 0.5, y: 0.32),
            startRadius: 0,
            endRadius: 560
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    /// Inside the pool.
    private func lit(_ book: BookProgress) -> some View {
        Button { onSelect(book.book) } label: {
            VStack(spacing: 20) {
                Cover(book: book.book, width: 146, cornerRadius: 4)
                    .shadow(color: .black.opacity(0.3), radius: 26, y: 16)

                VStack(spacing: 6) {
                    Text(book.book.title)
                        .font(BookmarkdFont.display(23))
                        .foregroundStyle(theme.palette.ink)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    Text(book.book.authorDisplay)
                        .font(BookmarkdFont.body(13))
                        .foregroundStyle(theme.palette.inkMuted)

                    Text("page \(book.pagesRead) of \(book.pagesTotal) · \(book.timeLeftLabel) left")
                        .font(BookmarkdFont.body(12))
                        .foregroundStyle(theme.palette.inkMuted.opacity(0.85))
                        .padding(.top, 4)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// Outside the pool: everything else, dimmed by distance from the light rather than by a
    /// smaller type size.
    private var shadowed: some View {
        VStack(spacing: 14) {
            Text("\(snapshot.habit.minutesToday) of \(snapshot.habit.dailyTargetMinutes) minutes · \(snapshot.habit.currentStreak) day streak")
                .font(BookmarkdFont.body(12))
                .foregroundStyle(theme.palette.ink.opacity(0.4))

            HStack(spacing: 10) {
                ForEach(snapshot.outstanding.prefix(6)) { book in
                    Button { onSelect(book.book) } label: {
                        Cover(book: book.book, width: 40, cornerRadius: 3, isRaised: false)
                            .opacity(0.42)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var empty: some View {
        VStack(spacing: 8) {
            Text("Nothing lit")
                .font(BookmarkdFont.display(26))
                .foregroundStyle(theme.palette.ink)
            Text("Pick a book and it sits under the lamp.")
                .font(BookmarkdFont.body(14))
                .foregroundStyle(theme.palette.inkMuted)
        }
    }
}

#Preview {
    HomeDesignLamp(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .mocha)
}
