//
//  HomeDesignSubjects.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// **Subjects** — what you're reading *about*, not what you're reading.
///
/// Warm bands, one per topic, books nested inside them. Open Library already returns `subjects`
/// on every work and the detail screen already renders them as chips, so this is close to free —
/// and `spec.html` flags it as the one thing nothing has been built for:
///
/// > *"if only they … could help me learn more about things that i care about"*
///
/// Every previous Home organised the library by the app's own bookkeeping — status, date, page
/// count. This is the first one organised by the reader's interests.
struct HomeDesignSubjects: View {
    let snapshot: HomeSnapshot
    let onSelect: (Book) -> Void

    @Environment(\.theme) private var theme

    private struct Topic: Identifiable {
        let id: String
        let books: [BookProgress]
        var name: String { id }
    }

    /// Stand-in topics until `BookDetail.subjects` is threaded onto the shelf entry. Real
    /// subjects arrive on the work response; they are simply not persisted yet.
    private static let topicMap: [String: [String]] = [
        "/works/OL17930368W": ["Habits", "Psychology"],
        "/works/OL20150260W": ["Irish fiction", "Love"],
        "/works/OL1926995W": ["Mythology", "India"],
        "/works/OL20832477W": ["Japan", "Time"],
        "/works/OL5819456W": ["War", "Germany"],
        "/works/OL264877W": ["India", "Family"],
        "/works/OL66554W": ["Classics", "Love"],
        "/works/OL1168083W": ["Dystopia", "Classics"],
        "/works/OL32525579W": ["Classics", "Psychology"],
        "/works/OL20884585W": ["Iran", "Love"],
        "/works/OL731663W": ["Architecture", "Philosophy"],
        "/works/OL102749W": ["Classics", "The sea"],
    ]

    private var topics: [Topic] {
        var grouped: [String: [BookProgress]] = [:]
        for book in snapshot.books {
            for topic in Self.topicMap[book.id] ?? [] {
                grouped[topic, default: []].append(book)
            }
        }
        return grouped
            .map { Topic(id: $0.key, books: $0.value) }
            .sorted { ($0.books.count, $1.name) > ($1.books.count, $0.name) }
    }

    var body: some View {
        DesignCanvas(horizontalMargin: 16) {
            VStack(alignment: .leading, spacing: 12) {
                header

                ForEach(topics) { topic in
                    band(topic)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("What you read about")
                .font(BookmarkdFont.display(26))
                .foregroundStyle(theme.palette.ink)
            Text("\(topics.count) subjects across your shelf")
                .font(BookmarkdFont.body(12))
                .foregroundStyle(theme.palette.inkMuted)
        }
        .padding(.horizontal, 6)
        .padding(.bottom, 4)
    }

    /// A topic as a band of its own colour with its books riding inside it. The band is the
    /// colour first and the container second — that is what makes it a band and not a row.
    private func band(_ topic: Topic) -> some View {
        let tint = tintFor(topic.name)

        return VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .firstTextBaseline) {
                Text(topic.name)
                    .font(BookmarkdFont.display(18))
                    .foregroundStyle(theme.palette.ink)
                Spacer()
                Text("\(topic.books.count)")
                    .font(BookmarkdFont.body(12))
                    .foregroundStyle(theme.palette.ink.opacity(0.5))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(topic.books) { book in
                        Button { onSelect(book.book) } label: {
                            Cover(book: book.book, width: 50, cornerRadius: 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: theme.shape.cardCornerRadius, style: .continuous)
                .fill(tint)
        )
    }

    /// Stable warm tint per topic name.
    private func tintFor(_ name: String) -> Color {
        let warm: [UInt32] = [0xE8D3A4, 0xDFC3A0, 0xEADBB4, 0xD8C295, 0xE4CDAE, 0xDCCA9C]
        return Color(hex: warm[Int(stableFingerprint(name) % UInt32(warm.count))])
    }
}

#Preview {
    HomeDesignSubjects(snapshot: .sample, onSelect: { _ in })
        .environment(\.theme, .honey)
}
