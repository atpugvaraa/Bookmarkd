//
//  ShelfStatus.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 14/06/26.
//

import Foundation

nonisolated enum ShelfStatus: String, CaseIterable, Codable, Sendable {
    case reading = "Reading"
    case completed = "Completed"
    case onHold = "On Hold"
    case dropped = "Dropped"
    case planToRead = "Plan to Read"
    
    var systemImage: String {
        switch self {
        case .reading: return "book.fill"
        case .completed: return "checkmark.circle.fill"
        case .onHold: return "pause.circle.fill"
        case .dropped: return "xmark.circle.fill"
        case .planToRead: return "bookmark.fill"
        }
    }
}
