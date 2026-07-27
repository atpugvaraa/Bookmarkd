//
//  Rule.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// A hairline. The structural device these designs use instead of boxes and cards.
struct Hairline: View {
    var opacity: Double = 0.18
    var weight: CGFloat = 0.75

    @Environment(\.theme) private var theme

    var body: some View {
        Rectangle()
            .fill(theme.palette.ink.opacity(opacity))
            .frame(height: weight)
    }
}

/// The row of dots between an entry and its page number in a book's index.
///
/// Takes whatever width is left over, which is what makes a column of figures line up without
/// anyone hard-coding a width for the label.
struct LeaderDots: View {
    @Environment(\.theme) private var theme

    var body: some View {
        Line()
            .stroke(
                theme.palette.ink.opacity(0.32),
                style: StrokeStyle(lineWidth: 1.4, dash: [1.4, 4])
            )
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
}

/// Label, leader, figure — an index entry, and the shape most of the habit numbers take.
struct StatLine: View {
    let label: String
    let value: String
    var note: String?
    var isMarked: Bool = false

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(BookmarkdFont.display(17))
                    .lineLimit(1)
                if let note {
                    Text(note)
                        .font(BookmarkdFont.body(11))
                        .foregroundStyle(theme.palette.inkMuted)
                        .lineLimit(1)
                }
            }
            .layoutPriority(1)

            LeaderDots()
                .offset(y: -3)

            Text(value)
                .font(BookmarkdFont.display(19))
                .foregroundStyle(isMarked ? theme.palette.mark : theme.palette.ink)
                .layoutPriority(1)
        }
        .foregroundStyle(theme.palette.ink)
    }
}

/// One horizontal rule, so a leader can stretch to fill its row.
struct Line: SwiftUI.Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
