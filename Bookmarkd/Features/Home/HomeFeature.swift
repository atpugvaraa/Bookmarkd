//
//  HomeFeature.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 10/06/26.
//

import ComposableArchitecture

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.shelf) var shelf
        @Shared(.usesSampleLibrary) var usesSampleLibrary
        var path = StackState<BookRoute.State>()

        /// What the screen shows. During design exploration this can be the sample library
        /// instead of the real shelf — reading a different array, never writing to disk, so
        /// a real library is never at risk.
        var entries: [ShelfEntry] {
            usesSampleLibrary ? SampleLibrary.entries : Array(shelf)
        }

        var currentlyReading: [ShelfEntry] {
            entries.filter { $0.status == .reading }
        }

        var recentlyAdded: [ShelfEntry] {
            Array(entries.sorted { $0.dateAdded > $1.dateAdded }.prefix(10))
        }

        /// The book the habit-oriented designs foreground.
        var activeEntry: ShelfEntry? {
            currentlyReading.max { $0.dateUpdated < $1.dateUpdated }
        }

        var isEmpty: Bool {
            currentlyReading.isEmpty && recentlyAdded.isEmpty
        }
    }

    enum Action: ViewAction {
        enum View {
            case bookTapped(Book)
        }
        case view(View)
        case path(StackActionOf<BookRoute>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
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
