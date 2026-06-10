//
//  ContentView.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 10/06/26.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    @State private var homeStore = Store(initialState: HomeFeature.State()) { HomeFeature() }
    @State private var shelfStore = Store(initialState: ShelfFeature.State()) { ShelfFeature() }
    @State private var searchStore = Store(initialState: SearchFeature.State()) { SearchFeature() }
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView(store: homeStore)
            }
            
            Tab("Shelf", systemImage: "books.vertical.fill") {
                ShelfView(store: shelfStore)
            }
            
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchView(store: searchStore)
            }
        }
    }
}

#Preview {
    ContentView()
}
