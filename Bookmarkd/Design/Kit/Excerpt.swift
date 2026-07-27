//
//  Excerpt.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// Words from the book itself, set as display type.
///
/// The app has never once shown a line of the actual writing — twenty designs all displayed
/// metadata *about* books. A sentence from the thing you are trying to read is the most
/// persuasive content on the screen and it costs nothing: it already arrives on the work
/// response as `description`.
struct Excerpt: View {
    let text: String
    var size: CGFloat = 22
    var lineLimit: Int = 6

    @Environment(\.theme) private var theme

    var body: some View {
        Text(trimmed)
            .font(BookmarkdFont.display(size))
            .lineSpacing(size * 0.32)
            .foregroundStyle(theme.palette.ink)
            .lineLimit(lineLimit)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Open Library descriptions often carry a trailing source credit after a rule, and the
    /// first sentence is usually the only part worth setting large.
    private var trimmed: String {
        let body = text
            .components(separatedBy: "----------")[0]
            .components(separatedBy: "\r\n")[0]
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return body.isEmpty ? text : body
    }
}

/// A full-width horizontal stripe of colour carrying its own content.
///
/// The building block for the designs that are made of bands rather than of rows — a band is
/// the colour first and the container second, which is what separates it from a list row.
struct Band<Content: View>: View {
    var tint: Color
    var height: CGFloat
    var radius: CGFloat = 0
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: height)
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

/// A warm tint per book, stable across launches.
///
/// Deliberately not `hashValue`: Swift seeds string hashing per process, so anything derived
/// from it changes colour every launch and a library never starts to feel like *yours*. The
/// avalanche step matters — every id shares the `/works/OL…W` prefix, and taking a remainder
/// straight off the raw sum put most of a shelf on two colours.
func stableFingerprint(_ id: String) -> UInt32 {
    let raw = id.unicodeScalars.reduce(UInt32(7)) { $0 &* 31 &+ $1.value }
    var mixed = raw
    mixed ^= mixed >> 16
    mixed = mixed &* 0x7feb_352d
    mixed ^= mixed >> 15
    return mixed
}

extension BookProgress {
    /// One of six warm tints. Inside the cream/caramel family on purpose — the point is a warm
    /// set, and a saturated hue would break the palette the designs exist to show.
    var warmTint: Color {
        let warm: [UInt32] = [0xD9BE7E, 0xC7A67E, 0xE0C9A6, 0xB8996F, 0xE6D3AE, 0xC2A98A]
        return Color(hex: warm[Int(stableFingerprint(id) % UInt32(warm.count))])
    }

    /// A small, stable tilt in degrees, so anything hand-placed never lines up perfectly.
    func tilt(_ range: ClosedRange<Double>) -> Double {
        let span = range.upperBound - range.lowerBound
        return range.lowerBound + Double(stableFingerprint(id) % 1000) / 1000 * span
    }

    /// A line about the book, for the designs that lead with words.
    ///
    /// `Book` has no description — Open Library returns one on the *work* response and
    /// `BookDetail` deliberately does not persist it — so this reads the design-lab stand-in
    /// until that is wired through.
    var blurb: String? { SampleExcerpts.blurbs[id] }

    /// The reader's own margin notes.
    var notes: [(page: Int, text: String)] { SampleExcerpts.notes[id] ?? [] }
}
