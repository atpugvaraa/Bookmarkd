//
//  BookmarkdApp.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 09/06/26.
//

import ComposableArchitecture
import SwiftUI

@main
struct BookmarkdApp: App {
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    init() {
        FontRegistrar.registerBundledFonts()

        #if DEBUG
        // Two Home designs occupying nearly the same coordinate are one design under two
        // names — the failure that sank four rounds of design work. Loud at launch so it
        // cannot reach a screenshot, let alone a review.
        let collisions = HomeDesign.collisions
        for (one, other, shared) in collisions {
            print("[Design] \(one.displayName) and \(other.displayName) share \(shared)/5 axes")
        }
        assert(collisions.isEmpty, "Home designs are too close together — see the log")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: Self.store)
        }
    }
}
