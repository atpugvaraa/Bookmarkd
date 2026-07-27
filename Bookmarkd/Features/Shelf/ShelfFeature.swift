//
//  ShelfFeature.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 10/06/26.
//

import ComposableArchitecture

@Reducer
struct ShelfFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.shelf) var shelf
        var selectedFilter: ShelfStatus?
        var path = StackState<BookRoute.State>()

        var filteredEntries: [ShelfEntry] {
            let sorted = shelf.sorted { $0.dateUpdated > $1.dateUpdated }
            guard let filter = selectedFilter else { return sorted }
            return sorted.filter { $0.status == filter }
        }
    }

    enum Action: ViewAction {
        enum View {
            case filterChanged(ShelfStatus?)
            case bookTapped(Book)
        }
        case view(View)
        case path(StackActionOf<BookRoute>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(.filterChanged(filter)):
                state.selectedFilter = filter
                return .none

            case let .view(.bookTapped(book)):
                state.path.append(.bookDetail(BookDetailFeature.State(book: book)))
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
