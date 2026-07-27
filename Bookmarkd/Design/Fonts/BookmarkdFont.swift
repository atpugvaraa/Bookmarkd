//
//  BookmarkdFont.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import SwiftUI

/// The app's type ramp. Every screen reads these rather than naming a face directly, so the
/// choice made in the font lab propagates everywhere at once and no design hard-codes a face.
///
/// The two roles are chosen separately because the winner is likely a pairing: a face with
/// enough character to carry a book title at 28pt is often the wrong one for a 12pt streak
/// label. Until a face is picked, both fall back to the system rounded face.
enum BookmarkdFont {
    /// Headlines, book titles, anything with voice.
    static func display(
        _ size: CGFloat,
        _ weight: Font.Weight = .semibold,
        relativeTo style: Font.TextStyle = .body
    ) -> Font {
        font(named: FontChoice.displayName, size: size, weight: weight, relativeTo: style)
    }

    /// Body copy, labels, anything read in quantity.
    static func body(
        _ size: CGFloat,
        _ weight: Font.Weight = .regular,
        relativeTo style: Font.TextStyle = .body
    ) -> Font {
        font(named: FontChoice.bodyName, size: size, weight: weight, relativeTo: style)
    }

    /// The candidates are single-weight faces, so `weight` only reaches the system fallback.
    /// Asking SwiftUI to fake a bold from a face that has none produces smeared outlines, and
    /// hierarchy in these designs comes from size, colour and spacing instead.
    private static func font(
        named name: String?,
        size: CGFloat,
        weight: Font.Weight,
        relativeTo style: Font.TextStyle
    ) -> Font {
        guard let name, !name.isEmpty else {
            return .system(size: size, weight: weight, design: .rounded)
        }
        return .custom(name, size: size, relativeTo: style)
    }
}
