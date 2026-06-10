//
//  HomeFeature.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 10/06/26.
//

import SwiftUI
import ComposableArchitecture

struct HomeFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var currentlyReading: [ShelfEntry] = []
        var recentlyAdded: [ShelfEntry] = []
        var selectedBook: BookDetailFeature.State?
    }
    
    @CasePathable
    enum Action: Sendable {
        case onAppear
        case entriesLoaded([ShelfEntry])
        case bookTapped(Book)
        case bookDetail(BookDetailFeature.Action)
        case detailDismissed
    }
    
    @Dependency(\.shelfClient) var shelfClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let entries = await shelfClient.loadAll()
                    await send(.entriesLoaded(entries))
                }
                
            case let .entriesLoaded(entries):
                state.currentlyReading = entries.filter { $0.status == .reading }
                state.recentlyAdded = Array(
                    entries.sorted { $0.dateAdded > $1.dateAdded }.prefix(10)
                )
                return .none
                
            case let .bookTapped(book):
                state.selectedBook = BookDetailFeature.State(book: book)
                return .none
                
            case .bookDetail:
                return .none
                
            case .detailDismissed:
                state.selectedBook = nil
                return .run { send in
                    let entries = await shelfClient.loadAll()
                    await send(.entriesLoaded(entries))
                }
            }
        }
        .ifLet(\.selectedBook, action: \.bookDetail) {
            BookDetailFeature()
        }
    }
}
