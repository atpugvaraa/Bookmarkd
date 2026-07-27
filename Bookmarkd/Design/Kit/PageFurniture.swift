//
//  PageFurniture.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

// The parts of a printed page that are not the text: the running head at the top, the folio at
// the foot, the small label that opens a section. Borrowed as app chrome — the vocabulary is
// typographic, so unlike the previous rounds it cannot slide into drawing an object.

/// The line across the top of a book's page: title on one side, where you are on the other.
struct RunningHead: View {
    let leading: String
    let trailing: String

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: 7) {
            HStack {
                Text(leading)
                Spacer()
                Text(trailing)
            }
            .font(BookmarkdFont.body(10))
            .kerning(1.7)
            .textCase(.uppercase)
            .foregroundStyle(theme.palette.inkMuted)

            Hairline()
        }
    }
}

/// The page number at the foot, centred between rules.
///
/// It counts something worth counting rather than the scroll position — books finished, most
/// usefully, which is the only number in the app that only ever goes up.
struct Folio: View {
    let text: String

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: 10) {
            Hairline(opacity: 0.12).frame(width: 26)
            Text(text)
                .font(BookmarkdFont.body(11))
                .foregroundStyle(theme.palette.inkMuted)
            Hairline(opacity: 0.12).frame(width: 26)
        }
        .frame(maxWidth: .infinity)
    }
}

/// The small caps label that opens a section.
struct SectionLabel: View {
    let text: String

    @Environment(\.theme) private var theme

    var body: some View {
        Text(text)
            .font(BookmarkdFont.body(10))
            .kerning(1.7)
            .textCase(.uppercase)
            .foregroundStyle(theme.palette.inkMuted)
    }
}
