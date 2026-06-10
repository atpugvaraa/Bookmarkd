//
//  SearchFeature.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 09/06/26.
//

import ComposableArchitecture
import Foundation

struct SearchFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var query = ""
        var results: [Book] = []
        var isLoading = false
        var hasSearched = false
        var selectedBook: BookDetailFeature.State?
    }
    
    @CasePathable
    enum Action: Sendable {
        case queryChanged(String)
        case searchSubmitted
        case searchResponse([Book])
        case searchFailed
        case bookTapped(Book)
        case bookDetail(BookDetailFeature.Action)
        case detailDismissed
    }
    
    @Dependency(\.openLibraryClient) var openLibrary
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .queryChanged(newQuery):
                state.query = newQuery
                if newQuery.isEmpty {
                    state.results = []
                    state.hasSearched = false
                }
                return .none
                
            case .searchSubmitted:
                let query = state.query.trimmingCharacters(in: .whitespaces)
                guard !query.isEmpty else { return .none }
                state.isLoading = true
                return .run { send in
                    do {
                        let books = try await openLibrary.search(query)
                        await send(.searchResponse(books))
                    } catch {
                        await send(.searchFailed)
                    }
                }
                .cancellable(id: "search", cancelInFlight: true)
                
            case let .searchResponse(books):
                state.results = books
                state.isLoading = false
                state.hasSearched = true
                return .none
                
            case .searchFailed:
                state.isLoading = false
                state.hasSearched = true
                return .none
                
            case let .bookTapped(book):
                state.selectedBook = BookDetailFeature.State(book: book)
                return .none
                
            case .bookDetail:
                return .none
                
            case .detailDismissed:
                state.selectedBook = nil
                return .none
            }
        }
        .ifLet(\.selectedBook, action: \.bookDetail) {
            BookDetailFeature()
        }
    }
}
