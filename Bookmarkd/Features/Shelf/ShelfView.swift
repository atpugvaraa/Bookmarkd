//
//  ShelfView.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 10/06/26.
//

import SwiftUI
import Aesthetics
import ComposableArchitecture

struct ShelfView: View {
    @Bindable var store: StoreOf<ShelfFeature>
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        let isDetail = store.selectedBook != nil
        
        NavigationBarView(
            title: isDetail ? (store.selectedBook?.book.title ?? "Details") : "Your Shelf",
            titleColor: .highlight,
            scrollOffset: $scrollOffset,
            backAction: isDetail ? { store.send(.detailDismissed) } : nil,
            backgroundColor: .accent
        ) {
            filterBar
        } content: {
            content
        }
        .onAppear { store.send(.onAppear) }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            if store.filteredEntries.isEmpty {
                emptyState
            } else {
                shelfGrid
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
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", isSelected: store.selectedFilter == nil) {
                    store.send(.filterChanged(nil))
                }
                ForEach(ShelfStatus.allCases, id: \.self) { status in
                    filterChip(label: status.rawValue, isSelected: store.selectedFilter == status) {
                        store.send(.filterChanged(status))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? .accent : .highlight)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.highlight : Color.highlight.opacity(0.12))
                .clipShape(Capsule())
        }
    }
    
    private var shelfGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 24),
                GridItem(.flexible(), spacing: 24)
            ],
            spacing: 28
        ) {
            ForEach(store.filteredEntries) { entry in
                Button {
                    store.send(.bookTapped(entry.book))
                } label: {
                    BookCard(book: entry.book)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 48))
                .foregroundStyle(.highlight.opacity(0.4))
            Text(store.selectedFilter == nil ? "Your shelf is empty" : "Nothing here yet")
                .font(.headline)
                .foregroundStyle(.highlight)
            Text("Search for books and add them to your shelf")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

#Preview {
    ShelfView(
        store: Store(initialState: ShelfFeature.State()) {
            ShelfFeature()
        }
    )
}
