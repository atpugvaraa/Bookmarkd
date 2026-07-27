//
//  SearchFeature.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 09/06/26.
//

import ComposableArchitecture
import Foundation

@Reducer
struct SearchFeature {
    @ObservableState
    struct State: Equatable {
        var query = ""
        var results: [Book] = []
        var isLoading = false
        var isLoadingPage = false
        var hasSearched = false
        var numFound = 0
        var page = 1
        @Presents var alert: AlertState<Never>?
        var path = StackState<BookRoute.State>()

        var canLoadMore: Bool {
            results.count < numFound
        }
    }

    enum Action: ViewAction {
        enum View {
            case queryChanged(String)
            case searchSubmitted
            case resultAppeared(Book.ID)
            case bookTapped(Book)
        }
        case view(View)
        case searchResponse(Result<SearchPage, any Error>)
        case nextPageResponse(Result<SearchPage, any Error>)
        case alert(PresentationAction<Never>)
        case path(StackActionOf<BookRoute>)
    }

    private nonisolated enum CancelID { case search }

    /// Long enough that typing a word does not fire a request per keystroke, short enough that
    /// results feel immediate once you stop.
    private static let debounce = Duration.milliseconds(300)

    @Dependency(\.openLibraryClient) var openLibrary
    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(.queryChanged(query)):
                state.query = query
                guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                    state.results = []
                    state.hasSearched = false
                    state.isLoading = false
                    state.numFound = 0
                    return .cancel(id: CancelID.search)
                }
                state.isLoading = true
                return search(query, page: 1, debounced: true)

            case .view(.searchSubmitted):
                // Submitting from the keyboard should not wait out the debounce.
                let query = state.query.trimmingCharacters(in: .whitespaces)
                guard !query.isEmpty else { return .none }
                state.isLoading = true
                return search(query, page: 1, debounced: false)

            case let .view(.resultAppeared(id)):
                guard id == state.results.last?.id,
                      state.canLoadMore,
                      !state.isLoadingPage,
                      !state.isLoading
                else { return .none }
                state.isLoadingPage = true
                let next = state.page + 1
                let query = state.query.trimmingCharacters(in: .whitespaces)
                return .run { send in
                    await send(.nextPageResponse(Result { try await openLibrary.search(query, next) }))
                }

            case let .searchResponse(.success(page)):
                state.results = page.books
                state.numFound = page.numFound
                state.page = 1
                state.isLoading = false
                state.hasSearched = true
                return .none

            case let .searchResponse(.failure(error)):
                state.isLoading = false
                state.hasSearched = true
                state.alert = .searchFailed(error)
                return .none

            case let .nextPageResponse(.success(page)):
                state.results.append(contentsOf: page.books)
                state.numFound = page.numFound
                state.page += 1
                state.isLoadingPage = false
                return .none

            case .nextPageResponse(.failure):
                // A failed *extra* page is not worth an alert; the results already on screen
                // are still good, and scrolling again retries.
                state.isLoadingPage = false
                return .none

            case let .view(.bookTapped(book)):
                state.path.append(.bookDetail(BookDetailFeature.State(book: book)))
                return .none

            case .alert, .path:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .forEach(\.path, action: \.path)
    }

    private func search(_ query: String, page: Int, debounced: Bool) -> Effect<Action> {
        .run { send in
            if debounced {
                try await clock.sleep(for: Self.debounce)
            }
            await send(.searchResponse(Result { try await openLibrary.search(query, page) }))
        }
        .cancellable(id: CancelID.search, cancelInFlight: true)
    }
}

extension AlertState where Action == Never {
    static func searchFailed(_ error: any Error) -> Self {
        AlertState {
            TextState("Couldn't search")
        } actions: {
            ButtonState { TextState("OK") }
        } message: {
            TextState("\(error.localizedDescription)\n\nCheck your connection and try again.")
        }
    }
}
