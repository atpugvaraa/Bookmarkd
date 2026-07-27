//
//  HomeDesignNightcap.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Nightcap** — the app asks, you answer.
///
/// Twenty designs displayed data *about* your reading. None of them said anything to you. A
/// coffee shop date is a conversation, and the whole product problem is getting someone who
/// does not read to start tonight — so the screen asks that, in words, and offers two honest
/// answers. "Not tonight" is a real button, because a habit app that only accepts yes is the
/// kind people delete.
///
/// Everything sits in the bottom third where a thumb actually reaches. The top two-thirds is
/// warm empty ground, which is the point: there is one decision here.
struct HomeDesignNightcap: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme
    @State private var answered = false

    var body: some View {
        DesignCanvas(scrolls: false) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 0)

                if let book = snapshot.active {
                    question(book)
                } else {
                    emptyQuestion
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 128)
        }
    }

    private func question(_ book: BookProgress) -> some View {
        VStack(alignment: .leading, spacing: 26) {
            VStack(alignment: .leading, spacing: 10) {
                Text(answered ? "Good. Enjoy it." : "\(snapshot.habit.dailyTargetMinutes) minutes tonight?")
                    .font(BookmarkdFont.display(38))
                    .foregroundStyle(theme.palette.ink)
                    .lineSpacing(-4)
                    .contentTransition(.opacity)

                Text(answered
                     ? "Come back and tell me where you got to."
                     : "You're on page \(book.pagesRead) of \(book.book.title). That's \(pagesTonight(book)) pages if you do.")
                    .font(BookmarkdFont.body(16))
                    .foregroundStyle(theme.palette.inkMuted)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !answered {
                VStack(spacing: 11) {
                    answer("Start reading", isPrimary: true) {
                        withAnimation(.snappy) { answered = true }
                    }
                    // A first-class no. The back-off is a product principle in the spec, not a
                    // courtesy — punishing streak mechanics are why habit apps get deleted.
                    answer("Not tonight", isPrimary: false) {
                        withAnimation(.snappy) { answered = true }
                    }
                }
            }

            Button { onSelect(book.book) } label: {
                Text("Something else →")
                    .font(BookmarkdFont.body(13))
                    .foregroundStyle(theme.palette.inkMuted)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private func pagesTonight(_ book: BookProgress) -> Int {
        max(1, Int(Double(snapshot.habit.dailyTargetMinutes) * 45 / 60))
    }

    private func answer(_ title: String, isPrimary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(BookmarkdFont.display(17))
                .foregroundStyle(isPrimary ? theme.palette.onAccent : theme.palette.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background {
                    if isPrimary {
                        Capsule().fill(theme.palette.accent)
                    } else {
                        Capsule().strokeBorder(theme.palette.ink.opacity(0.22), lineWidth: 1)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var emptyQuestion: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What are we reading?")
                .font(BookmarkdFont.display(38))
                .foregroundStyle(theme.palette.ink)
            Text("Pick one book. It only takes one.")
                .font(BookmarkdFont.body(16))
                .foregroundStyle(theme.palette.inkMuted)
        }
    }
}

#Preview {
    HomeDesignNightcap(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .caramel)
}
