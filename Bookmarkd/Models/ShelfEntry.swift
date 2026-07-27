//
//  ShelfEntry.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 14/06/26.
//

import Foundation

// nonisolated: the target defaults to MainActor isolation, but shared file storage
// needs these conformances to be usable off the main actor.
nonisolated struct ShelfEntry: Identifiable, Equatable, Codable, Sendable {
    let id: String          // same as book.id, so one book = one entry
    var book: Book
    var status: ShelfStatus
    var currentPage: Int?
    var totalPages: Int?
    var dateAdded: Date
    var dateUpdated: Date
    
    /// - Parameter now: injected rather than read from the clock so shelf edits are testable.
    init(book: Book, status: ShelfStatus, now: Date) {
        self.id = book.id
        self.book = book
        self.status = status
        self.currentPage = nil
        self.totalPages = nil
        self.dateAdded = now
        self.dateUpdated = now
    }
}
