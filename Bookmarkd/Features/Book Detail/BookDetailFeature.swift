//
//  BookDetailFeature.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 09/06/26.
//

import SwiftUI
import ComposableArchitecture

struct BookDetailFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var book: Book
        var shelfStatus: ShelfStatus?
    }
    
    @CasePathable
    enum Action: Sendable {
        case onAppear
        case shelfStatusLoaded(ShelfStatus?)
        case statusSelected(ShelfStatus)
        case removeFromShelf
    }
    
    @Dependency(\.shelfClient) var shelfClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let id = state.book.id
                return .run { send in
                    let entry = await shelfClient.entry(id)
                    await send(.shelfStatusLoaded(entry?.status))
                }
                
            case let .shelfStatusLoaded(status):
                state.shelfStatus = status
                return .none
                
            case let .statusSelected(status):
                state.shelfStatus = status
                let book = state.book
                return .run { _ in
                    var entry = ShelfEntry(book: book, status: status)
                    if let existing = await shelfClient.entry(book.id) {
                        entry = existing
                        entry.status = status
                        entry.dateUpdated = Date()
                    }
                    await shelfClient.save(entry)
                }
                
            case .removeFromShelf:
                state.shelfStatus = nil
                let id = state.book.id
                return .run { _ in
                    await shelfClient.remove(id)
                }
            }
        }
    }
}
