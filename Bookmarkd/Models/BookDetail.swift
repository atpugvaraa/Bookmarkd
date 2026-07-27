//
//  BookDetail.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import Foundation

/// The extra metadata that only the Open Library *work* endpoint carries.
///
/// Deliberately not persisted with `ShelfEntry`: it is re-fetched when a detail screen opens,
/// so `shelf.json` stays small and never needs migrating when this grows.
nonisolated struct BookDetail: Equatable, Sendable {
    var description: String?
    var subjects: [String]

    init(description: String? = nil, subjects: [String] = []) {
        self.description = description
        self.subjects = subjects
    }
}
