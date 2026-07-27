//
//  DesignLab.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import ComposableArchitecture
import SwiftUI

/// Where a design sits in the space of possible designs.
///
/// Twenty Home designs were built across four rounds and every one was rejected — not because
/// any single screen was badly made, but because each round produced five variations of one
/// idea. That is a real, checkable property rather than a matter of taste: two designs that
/// lead with the same thing, in the same composition, at the same imagery scale, on the same
/// ground, with the same shapes *are the same design*.
///
/// So every design declares its coordinate and `HomeDesign.collisions` reports any pair sharing
/// more than two of the five axes. Gallery and Deck in round 4 shared four.
nonisolated struct Coordinate: Equatable, Sendable {
    enum Lead: String, Sendable {
        case question, excerpt, subject, notes, habit, projection
        case time, library, oneBook, pair, ambience, proximity
    }

    enum Composition: String, Sendable {
        case bottomAnchored, singleColumn, bands, centred, denseGrid
        case layered, diagonal, halves, pair, radial, chain, twoColumn
    }

    enum Imagery: String, Sendable {
        case none, thumbnail, large, fullBleed, abstract
    }

    enum Form: String, Sendable {
        case sharpFlat, softFlat, softRaised, roundFloating
    }

    var lead: Lead
    var composition: Composition
    var imagery: Imagery
    var ground: String
    var form: Form

    /// How many of the five axes two designs have in common.
    func overlap(with other: Coordinate) -> Int {
        var shared = 0
        if lead == other.lead { shared += 1 }
        if composition == other.composition { shared += 1 }
        if imagery == other.imagery { shared += 1 }
        if ground == other.ground { shared += 1 }
        if form == other.form { shared += 1 }
        return shared
    }
}

/// The Home screen variants under evaluation.
///
/// `current` is the shipped layout, kept as a baseline. Twenty earlier designs across four
/// rounds were rejected and deleted; what they were and why they failed is in
/// `Design/DESIGN-NOTES.md`, which is the negative prompt. **Read it before adding a case.**
nonisolated enum HomeDesign: String, CaseIterable, Identifiable, Sendable {
    case current

    // The app says something to you.
    case nightcap
    case epigraph
    case marginalia
    case chapters

    // Content the app already has and has never put on screen.
    case subjects
    case twoUp

    // Habit-led.
    case tally
    case plan
    case hour

    // Library-led.
    case bands
    case wall

    // One book, unusual composition.
    case overleaf
    case lean
    case halves

    // Atmosphere.
    case lamp

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .current: "Current (baseline)"
        case .nightcap: "Nightcap"
        case .epigraph: "Epigraph"
        case .marginalia: "Marginalia"
        case .chapters: "Chapters"
        case .subjects: "Subjects"
        case .twoUp: "Two Up"
        case .tally: "Tally"
        case .plan: "Tonight's Plan"
        case .hour: "Hour"
        case .bands: "Bands"
        case .wall: "Wall"
        case .overleaf: "Overleaf"
        case .lean: "Lean"
        case .halves: "Halves"
        case .lamp: "Lamp"
        }
    }

    /// What this design looks like from across the room, in one line. Shown in the lab panel.
    var axis: String {
        switch self {
        case .current: "The shipped layout"
        case .nightcap: "Asks you a question, everything in thumb reach"
        case .epigraph: "The book's own opening lines, set large"
        case .marginalia: "Your notes are the content; the book is context"
        case .chapters: "Grouped by how close each book is to finished"
        case .subjects: "Warm bands, one per topic you read about"
        case .twoUp: "Exactly two books, nothing else"
        case .tally: "The streak as one large figure, centred"
        case .plan: "Tonight as a single chain: minutes → page → date"
        case .hour: "Changes with the clock — morning offers less"
        case .bands: "Every book a full-width stripe of its own colour"
        case .wall: "Four columns of small squares, no text"
        case .overleaf: "Cover full-bleed, content sliding over it"
        case .lean: "Set on a diagonal — nothing is square to the screen"
        case .halves: "Hard split across the middle"
        case .lamp: "A pool of warm light, content sitting inside it"
        }
    }

    var theme: Theme {
        switch self {
        case .current: .paperDaylight
        case .nightcap, .wall: .caramel
        case .epigraph, .bands: .latte
        case .marginalia, .lean: .cortado
        case .chapters, .overleaf: .amber
        case .subjects, .tally, .halves: .honey
        case .twoUp, .plan, .hour: .amber
        case .lamp: .mocha
        }
    }

    var coordinate: Coordinate {
        switch self {
        case .current:
            Coordinate(lead: .library, composition: .singleColumn, imagery: .large, ground: "paperDaylight", form: .softRaised)
        case .nightcap:
            Coordinate(lead: .question, composition: .bottomAnchored, imagery: .none, ground: "caramel", form: .roundFloating)
        case .epigraph:
            Coordinate(lead: .excerpt, composition: .singleColumn, imagery: .thumbnail, ground: "latte", form: .softFlat)
        case .marginalia:
            Coordinate(lead: .notes, composition: .twoColumn, imagery: .none, ground: "cortado", form: .sharpFlat)
        case .chapters:
            Coordinate(lead: .proximity, composition: .bands, imagery: .thumbnail, ground: "amber", form: .softRaised)
        case .subjects:
            Coordinate(lead: .subject, composition: .bands, imagery: .abstract, ground: "honey", form: .roundFloating)
        case .twoUp:
            Coordinate(lead: .pair, composition: .pair, imagery: .large, ground: "amber", form: .softFlat)
        case .tally:
            Coordinate(lead: .habit, composition: .centred, imagery: .none, ground: "honey", form: .softFlat)
        case .plan:
            Coordinate(lead: .projection, composition: .chain, imagery: .thumbnail, ground: "amber", form: .sharpFlat)
        case .hour:
            Coordinate(lead: .time, composition: .radial, imagery: .thumbnail, ground: "amber", form: .roundFloating)
        case .bands:
            Coordinate(lead: .library, composition: .bands, imagery: .none, ground: "latte", form: .sharpFlat)
        case .wall:
            Coordinate(lead: .library, composition: .denseGrid, imagery: .abstract, ground: "caramel", form: .softFlat)
        case .overleaf:
            Coordinate(lead: .oneBook, composition: .layered, imagery: .fullBleed, ground: "amber", form: .softRaised)
        case .lean:
            Coordinate(lead: .oneBook, composition: .diagonal, imagery: .large, ground: "cortado", form: .softRaised)
        case .halves:
            Coordinate(lead: .oneBook, composition: .halves, imagery: .fullBleed, ground: "honey", form: .sharpFlat)
        case .lamp:
            Coordinate(lead: .ambience, composition: .radial, imagery: .large, ground: "mocha", form: .roundFloating)
        }
    }

    /// Every pair sharing more than two axes. Must be empty — a non-empty result means a design
    /// has been built twice under two names, which is the failure this whole type exists to
    /// prevent. Asserted at launch in DEBUG and printed so it cannot be ignored.
    static var collisions: [(HomeDesign, HomeDesign, Int)] {
        var found: [(HomeDesign, HomeDesign, Int)] = []
        let all = allCases
        for (index, one) in all.enumerated() {
            for other in all.dropFirst(index + 1) {
                let shared = one.coordinate.overlap(with: other.coordinate)
                if shared > 2 { found.append((one, other, shared)) }
            }
        }
        return found
    }
}

extension SharedKey where Self == AppStorageKey<String>.Default {
    /// Which Home design is on screen. Persisted so a relaunch lands where you left off.
    static var homeDesign: Self {
        Self[.appStorage("designHome"), default: HomeDesign.current.rawValue]
    }
}

extension SharedKey where Self == AppStorageKey<Bool>.Default {
    /// Show the sample library instead of the real shelf.
    ///
    /// Non-destructive: this only changes which array a view reads. `shelf.json` on disk is
    /// never written to, so a real library is never at risk during design work.
    static var usesSampleLibrary: Self {
        Self[.appStorage("designSampleLibrary"), default: true]
    }

    /// Hides the floating pill so a design can be judged with genuinely zero chrome.
    static var designPillHidden: Self {
        Self[.appStorage("designPillHidden"), default: false]
    }
}
