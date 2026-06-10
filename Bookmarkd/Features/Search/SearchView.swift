//
//  SearchView.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 09/06/26.
//

import SwiftUI
import ComposableArchitecture
import Aesthetics

struct SearchView: View {
    let store: StoreOf<SearchFeature>
    
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        let isDetail = store.selectedBook != nil
        
        NavigationBarView(
            title: isDetail ? (store.selectedBook?.book.title ?? "Details") : "Search",
            titleColor: .highlight,
            scrollOffset: $scrollOffset,
            backAction: isDetail ? { store.send(.detailDismissed) } : nil,
            backgroundColor: .accent
        ) {
            content
        }
        .navigationBarStyle(.search)
        .navigationBarSearch(
            text: Binding(
                get: { store.query },
                set: { store.send(.queryChanged($0)) }
            ),
            prompt: "Search for a book..."
        ) {
            store.send(.searchSubmitted)
        }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            if !store.hasSearched && store.results.isEmpty && !store.isLoading {
                emptyState
            } else if store.isLoading {
                Spacer()
                ProgressView("Searching...")
                    .foregroundStyle(.highlight)
                Spacer()
            } else if store.results.isEmpty && store.hasSearched {
                Spacer()
                Text("No books found")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                resultsList
            }
        }
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
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "book.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color("Highlight").opacity(0.4))
            Text("Search for any book")
                .font(.headline)
                .foregroundStyle(Color("Highlight"))
            Text("Find where to read it, buy it, or get it free")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
    
    private var resultsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(store.results) { book in
                Button {
                    store.send(.bookTapped(book))
                } label: {
                    HStack(spacing: 12) {
                        AsyncImage(url: book.coverURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.highlight.opacity(0.1))
                                .overlay(
                                    Image(systemName: "book.closed.fill")
                                        .foregroundStyle(.highlight.opacity(0.3))
                                )
                        }
                        .frame(width: 50, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.highlight)
                                .lineLimit(2)
                            
                            if !book.authors.isEmpty {
                                Text(book.authorDisplay)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            
                            if let year = book.firstPublishYear {
                                Text(String(year))
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                }
                
                Divider()
                    .padding(.leading, 78)
            }
        }
    }
}

#Preview {
    SearchView(
        store: Store(initialState: SearchFeature.State()) {
            SearchFeature()
        }
    )
}
