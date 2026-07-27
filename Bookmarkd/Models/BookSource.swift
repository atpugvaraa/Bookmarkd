//
//  BookSource.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import Foundation

/// One concrete way to get a book, from one source.
nonisolated struct BookSource: Identifiable, Equatable, Sendable {
    nonisolated enum Kind: String, CaseIterable, Equatable, Sendable {
        case free, borrow, buy

        var sectionTitle: String {
            switch self {
            case .free: "Read free"
            case .borrow: "Borrow"
            case .buy: "Buy"
            }
        }

        var sortOrder: Int {
            switch self {
            case .free: 0
            case .borrow: 1
            case .buy: 2
            }
        }
    }

    /// Namespaced so two sources can never collide: "gutendex:1342".
    let id: String
    var kind: Kind
    /// Shown as the row's leading label: "Project Gutenberg".
    var sourceName: String
    /// The title as *that source* reported it, which may differ from ours.
    var title: String
    /// Right-hand detail: "EPUB", a price, or nil.
    var detail: String?
    var linkURL: URL
}
