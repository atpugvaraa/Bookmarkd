//
//  ShelfEntry.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 14/06/26.
//

import Foundation

struct ShelfEntry: Identifiable, Equatable, Codable, Sendable {
    let id: String          // same as book.id, so one book = one entry
    var book: Book
    var status: ShelfStatus
    var currentPage: Int?
    var totalPages: Int?
    var dateAdded: Date
    var dateUpdated: Date
    
    init(book: Book, status: ShelfStatus) {
        self.id = book.id
        self.book = book
        self.status = status
        self.currentPage = nil
        self.totalPages = nil
        self.dateAdded = Date()
        self.dateUpdated = Date()
    }
}
