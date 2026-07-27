//
//  Theme.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import SwiftUI

/// A complete visual language: colour, type, and shape.
///
/// Screens read these tokens rather than hard-coded values, so a new look is a new value and
/// not a new copy of every view. Designs are free to lay out however they like — the tokens
/// exist so five very different layouts still feel like one app.
nonisolated struct Theme: Identifiable, Equatable, Sendable {
    struct Palette: Equatable, Sendable {
        var background: Color
        /// Cards, chips, rows — one step off the background.
        var surface: Color
        var ink: Color
        var inkMuted: Color
        /// Buttons and selected states.
        var accent: Color
        /// Text drawn on top of `accent`.
        var onAccent: Color
        /// Warm wood, paper grain, table top — the "physical" designs lean on this.
        var material: Color
        /// The single hue that means "today". One accent, one job: a colour that marks two
        /// different things marks nothing. Never used for decoration.
        var mark: Color
    }

    struct Shape: Equatable, Sendable {
        var cardCornerRadius: CGFloat
        var controlCornerRadius: CGFloat
    }

    let id: String
    let name: String
    var palette: Palette
    var shape: Shape
}

extension Theme {
    /// Today's shipped look: warm tan paper, dark brown ink. The baseline every Home design
    /// is judged against, so the comparison is about layout rather than colour.
    static let paperDaylight = Theme(
        id: "paperDaylight",
        name: "Paper Daylight",
        palette: Palette(
            background: Color(red: 0.784, green: 0.659, blue: 0.510),   // #C8A882
            surface: Color(red: 0.831, green: 0.722, blue: 0.596),      // #D4B898
            ink: Color(red: 0.184, green: 0.125, blue: 0.082),          // #2F2015
            inkMuted: Color(red: 0.353, green: 0.267, blue: 0.188),     // #5A4430
            accent: Color(red: 0.184, green: 0.125, blue: 0.082),
            onAccent: Color(red: 0.784, green: 0.659, blue: 0.510),
            material: Color(red: 0.478, green: 0.333, blue: 0.208),     // #7A5535 warm wood
            // #3A6B35 — the green already used in spec.html's own stylesheet, so the app and
            // its spec agree on what "done" looks like.
            mark: Color(red: 0.227, green: 0.420, blue: 0.208)
        ),
        shape: Shape(cardCornerRadius: 10, controlCornerRadius: 12)
    )
}

// MARK: - The light family
//
// Every one of the fifteen rejected Home designs used `paperDaylight`. `#C8A882` is a mid-tone,
// and the brief is lighter than that — "warm and cozy like a coffee made well, sort of lighter
// shades like cream or lighter shades of brown". These grounds all sit two to three steps up
// from the tan, and none of them is pure white.
//
// Each carries its own `Shape` as well as its own palette, because corner radius is one of the
// few things the eye reads instantly — a 28pt radius and a 6pt radius are visibly different
// designs before a single word is read.

extension Color {
    /// `Color(hex: 0xFBF7F0)` — palettes are only reviewable if the values are readable.
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension Theme {
    /// Warm cream with caramel mid-tones. The middle of the family.
    static let latte = Theme(
        id: "latte",
        name: "Latte",
        palette: Palette(
            background: Color(hex: 0xF2E5D0),
            surface: Color(hex: 0xE7D5B8),
            ink: Color(hex: 0x4A3421),
            inkMuted: Color(hex: 0x85694A),
            accent: Color(hex: 0x8C5A34),
            onAccent: Color(hex: 0xFBF3E6),
            material: Color(hex: 0xC7A67E),
            mark: Color(hex: 0x4A7A3E)
        ),
        shape: Shape(cardCornerRadius: 14, controlCornerRadius: 14)
    )

    /// Golden. The brightest ground of the family.
    static let honey = Theme(
        id: "honey",
        name: "Honey",
        palette: Palette(
            background: Color(hex: 0xF7E9C8),
            surface: Color(hex: 0xEEDCAC),
            ink: Color(hex: 0x4A3618),
            inkMuted: Color(hex: 0x8A6E3C),
            accent: Color(hex: 0xB07C2E),
            onAccent: Color(hex: 0xFFF8E7),
            material: Color(hex: 0xD9BE7E),
            mark: Color(hex: 0x5A7A34)
        ),
        shape: Shape(cardCornerRadius: 18, controlCornerRadius: 16)
    )

    /// Closest to the shipped tan but a step lighter, with the highest ink contrast — the
    /// palette that keeps hard edges legible.
    static let cortado = Theme(
        id: "cortado",
        name: "Cortado",
        palette: Palette(
            background: Color(hex: 0xE7D6BE),
            surface: Color(hex: 0xDBC7A8),
            ink: Color(hex: 0x2E1F14),
            inkMuted: Color(hex: 0x6B5340),
            accent: Color(hex: 0x6F4522),
            onAccent: Color(hex: 0xF4E9D8),
            material: Color(hex: 0xB8996F),
            mark: Color(hex: 0x3A6B35)
        ),
        shape: Shape(cardCornerRadius: 6, controlCornerRadius: 6)
    )

    /// Mid-warm, softly rounded. Sits between latte and caramel.
    static let amber = Theme(
        id: "amber",
        name: "Amber",
        palette: Palette(
            background: Color(hex: 0xEFDDBB),
            surface: Color(hex: 0xE4CEA4),
            ink: Color(hex: 0x402C18),
            inkMuted: Color(hex: 0x7C6040),
            accent: Color(hex: 0x9A6127),
            onAccent: Color(hex: 0xFBF1DC),
            material: Color(hex: 0xC9A671),
            mark: Color(hex: 0x4A7A3E)
        ),
        shape: Shape(cardCornerRadius: 22, controlCornerRadius: 20)
    )

    /// Deeper and browner. The set needs grounds you can put light *on top of*, and the pale
    /// end of the family cannot do that.
    static let caramel = Theme(
        id: "caramel",
        name: "Caramel",
        palette: Palette(
            background: Color(hex: 0xDFC9A6),
            surface: Color(hex: 0xD2B98F),
            ink: Color(hex: 0x33210F),
            inkMuted: Color(hex: 0x6E5334),
            accent: Color(hex: 0x7A4A1E),
            onAccent: Color(hex: 0xF6EAD3),
            material: Color(hex: 0xB08E5C),
            mark: Color(hex: 0x3F6B33)
        ),
        shape: Shape(cardCornerRadius: 10, controlCornerRadius: 10)
    )

    /// The deepest of the warm family — still a long way from dark, but with enough body that a
    /// pool of light or a pale card reads against it.
    static let mocha = Theme(
        id: "mocha",
        name: "Mocha",
        palette: Palette(
            background: Color(hex: 0xD9C2A0),
            surface: Color(hex: 0xCBB086),
            ink: Color(hex: 0x2C1B0C),
            inkMuted: Color(hex: 0x664B2C),
            accent: Color(hex: 0x6B3E17),
            onAccent: Color(hex: 0xF5E8CF),
            material: Color(hex: 0xA6834F),
            mark: Color(hex: 0x3A6B35)
        ),
        shape: Shape(cardCornerRadius: 30, controlCornerRadius: 28)
    )
}

extension EnvironmentValues {
    @Entry var theme: Theme = .paperDaylight
}
