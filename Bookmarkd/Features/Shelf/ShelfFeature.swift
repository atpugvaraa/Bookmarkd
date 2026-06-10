//
//  ShelfFeature.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 10/06/26.
//

import SwiftUI
import ComposableArchitecture

struct ShelfFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var entries: [ShelfEntry] = []
        var selectedFilter: ShelfStatus?
        var selectedBook: BookDetailFeature.State?
        
        var filteredEntries: [ShelfEntry] {
            guard let filter = selectedFilter else { return entries }
            return entries.filter { $0.status == filter }
        }
    }
    
    @CasePathable
    enum Action: Sendable {
        case onAppear
        case entriesLoaded([ShelfEntry])
        case filterChanged(ShelfStatus?)
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
                state.entries = entries.sorted { $0.dateUpdated > $1.dateUpdated }
                return .none
                
            case let .filterChanged(filter):
                state.selectedFilter = filter
                return .none
                
            case let .bookTapped(book):
                state.selectedBook = BookDetailFeature.State(book: book)
                return .none
                
            case .bookDetail:
                return .none
                
            case .detailDismissed:
                state.selectedBook = nil
                // reload in case status changed
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
