//
//  FontChoice.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import ComposableArchitecture
import SwiftUI

/// Which faces the app is currently set in.
///
/// Stored as PostScript names because that is what `Font.custom` resolves; an empty string
/// means the system rounded face, which stays available as a control to judge against.
///
/// `BookmarkdFont` is a plain `enum` called from inside view bodies, so it reads these values
/// straight from `UserDefaults` rather than through a property wrapper. Observation is handled
/// at the root instead — `ContentView` keys the whole tab tree on `fingerprint`, so choosing a
/// face rebuilds every screen at once.
enum FontChoice {
    static let displayKey = "fontDisplay"
    static let bodyKey = "fontBody"

    static var displayName: String? { UserDefaults.standard.string(forKey: displayKey) }
    static var bodyName: String? { UserDefaults.standard.string(forKey: bodyKey) }

    /// Changes whenever either role changes, so it can drive a view identity.
    static var fingerprint: String { "\(displayName ?? "-")|\(bodyName ?? "-")" }

    /// The two roles a face can be assigned to in the lab.
    nonisolated enum Role: String, CaseIterable, Identifiable, Sendable {
        case display
        case body

        var id: String { rawValue }

        var title: String {
            switch self {
            case .display: "Display"
            case .body: "Body"
            }
        }

        var storageKey: String {
            switch self {
            case .display: FontChoice.displayKey
            case .body: FontChoice.bodyKey
            }
        }
    }
}

extension SharedKey where Self == AppStorageKey<String>.Default {
    /// PostScript name of the display face, or empty for system rounded.
    static var displayFontName: Self {
        Self[.appStorage(FontChoice.displayKey), default: ""]
    }

    /// PostScript name of the body face, or empty for system rounded.
    static var bodyFontName: Self {
        Self[.appStorage(FontChoice.bodyKey), default: ""]
    }
}
