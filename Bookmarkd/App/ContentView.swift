//
//  ContentView.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 10/06/26.
//

import ComposableArchitecture
import SwiftUI

@ViewAction(for: AppFeature.self)
struct ContentView: View {
    @Bindable var store: StoreOf<AppFeature>

    // `BookmarkdFont` is a plain enum read from inside view bodies, so it cannot participate in
    // observation on its own. Observing the choice here and keying each tab on it means picking
    // a face in the font lab redraws every screen immediately. Keyed per tab rather than on the
    // `TabView` so the selected tab survives the change.
    @Shared(.displayFontName) private var displayFontName
    @Shared(.bodyFontName) private var bodyFontName

    private var typeKey: String { "\(displayFontName)|\(bodyFontName)" }

    var body: some View {
        TabView(selection: $store.selectedTab) {
            Tab("Home", systemImage: "house", value: AppFeature.Tab.home) {
                HomeView(store: store.scope(state: \.home, action: \.home))
                    .id(typeKey)
            }

            Tab("Shelf", systemImage: "books.vertical.fill", value: AppFeature.Tab.shelf) {
                ShelfView(store: store.scope(state: \.shelf, action: \.shelf))
                    .id(typeKey)
            }

            Tab("Search", systemImage: "magnifyingglass", value: AppFeature.Tab.search, role: .search) {
                SearchView(store: store.scope(state: \.search, action: \.search))
                    .id(typeKey)
            }
        }
        .onAppear { send(.onAppear) }
        // Development-only chrome for comparing screen designs on device.
        .overlay(alignment: .bottomTrailing) { DesignLabOverlay() }
    }
}
	
#Preview {
    ContentView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
