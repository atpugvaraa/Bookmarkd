//
//  SoftCard.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// A raised surface with a warm shadow.
///
/// The previous round used hairlines for every boundary, which on a flat tan produced five
/// screens that read as documents. Depth is one of the few things the eye registers before it
/// reads anything, so it is a real way for designs to differ — and a warm-tinted shadow is what
/// separates "cozy" from the grey drop-shadow every app ships with.
struct SoftCard<Content: View>: View {
    var radius: CGFloat?
    var padding: CGFloat = 18
    /// Off for a card that should sit flat against the ground.
    var isRaised: Bool = true
    @ViewBuilder var content: () -> Content

    @Environment(\.theme) private var theme

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: radius ?? theme.shape.cardCornerRadius, style: .continuous)
                    .fill(theme.palette.surface)
            )
            // Tinted with the palette's own deep brown rather than black: a neutral shadow on a
            // cream ground reads as grey and drains the warmth the palette exists for.
            .shadow(
                color: theme.palette.ink.opacity(isRaised ? 0.13 : 0),
                radius: isRaised ? 18 : 0,
                y: isRaised ? 8 : 0
            )
    }
}

/// A pill. Status, counts, anything small and self-contained.
struct Chip: View {
    let text: String
    var isFilled: Bool = false

    @Environment(\.theme) private var theme

    var body: some View {
        Text(text)
            .font(BookmarkdFont.body(11))
            .foregroundStyle(isFilled ? theme.palette.onAccent : theme.palette.inkMuted)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background {
                if isFilled {
                    Capsule().fill(theme.palette.accent)
                } else {
                    Capsule().fill(theme.palette.ink.opacity(0.07))
                }
            }
    }
}
