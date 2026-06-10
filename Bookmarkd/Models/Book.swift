//
//  Book.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 09/06/26.
//

import Foundation

struct Book: Identifiable, Equatable, Sendable, Codable {
    let id: String
    var title: String
    var authors: [String]
    var coverURL: URL?
    var firstPublishYear: Int?
    
    var authorDisplay: String {
        authors.joined(separator: ", ")
    }
}
