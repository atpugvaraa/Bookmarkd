//
//  SharedKeys.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import ComposableArchitecture
import Foundation

extension SharedKey where Self == FileStorageKey<IdentifiedArrayOf<ShelfEntry>>.Default {
    /// Every shelf entry, persisted to Documents as JSON.
    ///
    /// This is the single source of truth for the shelf: Home, Shelf and Book Detail
    /// all read and write this same value, so an edit on one screen is visible on the
    /// others immediately — no reloading on dismiss.
    static var shelf: Self {
        Self[
            .fileStorage(.documentsDirectory.appending(component: "shelf.json")),
            default: []
        ]
    }
}

extension SharedKey where Self == InMemoryKey<[String: [BookSource]]>.Default {
    /// Source results per `Book.id`, for this launch only.
    ///
    /// In memory rather than on disk: availability and prices go stale, and re-fetching on a
    /// cold start is cheap. This exists to stop a back-and-forth between shelf and detail
    /// from hammering the same endpoints.
    static var sourceCache: Self {
        Self[.inMemory("bookSources"), default: [:]]
    }
}
