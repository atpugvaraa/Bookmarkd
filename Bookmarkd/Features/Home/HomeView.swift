//
//  HomeView.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 10/06/26.
//

import SwiftUI
import Aesthetics
import ComposableArchitecture

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        let isDetail = store.selectedBook != nil
        
        NavigationBarView(
            title: isDetail ? (store.selectedBook?.book.title ?? "Details") : "Bookmarkd",
            titleColor: .highlight,
            scrollOffset: $scrollOffset,
            backAction: isDetail ? { store.send(.detailDismissed) } : nil,
            backgroundColor: .accent
        ) {
            content
        }
        .onAppear { store.send(.onAppear) }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 28) {
            if store.currentlyReading.isEmpty && store.recentlyAdded.isEmpty {
                emptyState
            } else {
                if !store.currentlyReading.isEmpty {
                    section(title: "Currently Reading", entries: store.currentlyReading)
                }
                if !store.recentlyAdded.isEmpty {
                    section(title: "Recently Added", entries: store.recentlyAdded)
                }
            }
        }
        .padding(.vertical)
        .navigationDestination(
            item: Binding(
                get: { store.selectedBook },
                set: { _ in store.send(.detailDismissed) }
            )
        ) { _ in
            if let detailStore = store.scope(
                state: \.selectedBook,
                action: \.bookDetail
            ) {
                BookDetailView(store: detailStore)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private func section(title: String, entries: [ShelfEntry]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.highlight)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 24) {
                    ForEach(entries) { entry in
                        Button {
                            store.send(.bookTapped(entry.book))
                        } label: {
                            BookCard(book: entry.book)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.system(size: 48))
                .foregroundStyle(.highlight.opacity(0.4))
            Text("Welcome to Bookmarkd")
                .font(.headline)
                .foregroundStyle(.highlight)
            Text("Search for books and start building your shelf")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        }
    )
}
