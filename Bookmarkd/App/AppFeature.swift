//
//  AppFeature.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 14/06/26.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AppFeature {
    // nonisolated: TabView's selection binding needs a Sendable, non-isolated conformance,
    // and this target defaults to MainActor isolation.
    nonisolated enum Tab: Hashable {
        case home, shelf, search
    }

    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .home
        var home = HomeFeature.State()
        var shelf = ShelfFeature.State()
        var search = SearchFeature.State()

        @Shared(.shelf) var entries
    }

    enum Action: BindableAction, ViewAction {
        enum View {
            case onAppear
        }
        case view(View)
        case binding(BindingAction<State>)
        case home(HomeFeature.Action)
        case shelf(ShelfFeature.Action)
        case search(SearchFeature.Action)
    }

    /// The `UserDefaults` key the shelf used before it moved to file storage.
    private static let legacyShelfKey = "bookmarkd.shelf.entries"

    var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.home, action: \.home) { HomeFeature() }
        Scope(state: \.shelf, action: \.shelf) { ShelfFeature() }
        Scope(state: \.search, action: \.search) { SearchFeature() }

        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                // ponytail: one-shot UserDefaults -> file migration.
                // Delete once it has run on every device that had the old build.
                guard state.entries.isEmpty,
                      let data = UserDefaults.standard.data(forKey: Self.legacyShelfKey),
                      let legacy = try? JSONDecoder().decode([ShelfEntry].self, from: data),
                      !legacy.isEmpty
                else { return .none }
                state.$entries.withLock { $0 = IdentifiedArray(uniqueElements: legacy) }
                return .none

            case .binding, .home, .shelf, .search:
                return .none
            }
        }
    }
}
